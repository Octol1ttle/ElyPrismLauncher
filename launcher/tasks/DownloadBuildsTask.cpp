#include "DownloadBuildsTask.h"

#include "Application.h"
#include "FileSystem.h"
#include "InstanceList.h"
#include "Json.h"
#include "MMCZip.h"
#include "icons/IconList.h"
#include "icons/IconUtils.h"
#include "minecraft/MinecraftInstance.h"
#include "net/Download.h"

#include <QDebug>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTemporaryDir>
#include <QWidget>

#include "ui/dialogs/CustomMessageBox.h"

DownloadBuildsTask::DownloadBuildsTask(QObject* parent) : Task(parent)
{
    m_tempDir.setPath(FS::PathCombine(APPLICATION->settings()->get("InstanceDir").toString(), "_temp_builds_dl"));
    m_apiResponse = std::make_shared<QByteArray>();
}

bool DownloadBuildsTask::abort()
{
    if (m_apiJob) {
        m_apiJob->abort();
    }
    if (m_dlJob) {
        m_dlJob->abort();
    }
    emitAborted();
    return true;
}

void DownloadBuildsTask::executeTask()
{
    setStatus(tr("Получение списка новейших сборок с GitHub..."));

    m_apiJob.reset(new NetJob("Fetch Builds Release", APPLICATION->network()));

    // We target the "instances" tag release directly
    auto url = QUrl("https://api.github.com/repos/FLEXIY0/BLauncher/releases/tags/instances");

    auto action = Net::Download::makeByteArray(url, m_apiResponse);
    m_apiJob->addNetAction(action);

    connect(m_apiJob.get(), &NetJob::succeeded, this, &DownloadBuildsTask::fetchReleasesFinished);
    connect(m_apiJob.get(), &NetJob::failed, this, &DownloadBuildsTask::fetchReleasesFailed);

    m_apiJob->start();
}

void DownloadBuildsTask::fetchReleasesFinished()
{
    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(*m_apiResponse, &error);

    if (error.error != QJsonParseError::NoError || !doc.isObject()) {
        emitFailed(tr("Не удалось обработать ответ от GitHub API."));
        return;
    }

    QJsonObject root = doc.object();
    QJsonArray assets = root.value("assets").toArray();

    if (assets.isEmpty()) {
        emitFailed(tr("В релизе 'instances' не найдено сборок."));
        return;
    }

    // Prepare temp dir
    if (!m_tempDir.exists()) {
        m_tempDir.mkpath(".");
    }

    m_assetsToDownload.clear();
    m_dlJob.reset(new NetJob("Download Builds", APPLICATION->network()));

    for (const QJsonValue& val : assets) {
        QJsonObject asset = val.toObject();
        QString name = asset.value("name").toString();
        QString dlUrl = asset.value("browser_download_url").toString();

        if (name.endsWith(".zip")) {
            AssetInfo info;
            info.name = name;
            info.url = dlUrl;
            info.targetPath = m_tempDir.absoluteFilePath(name);
            m_assetsToDownload.append(info);

            auto action = Net::Download::makeFile(QUrl(dlUrl), info.targetPath);
            m_dlJob->addNetAction(action);
        }
    }

    if (m_assetsToDownload.isEmpty()) {
        emitFailed(tr("No suitable .zip builds found."));
        return;
    }

    // Check for existing instances
    QString instDir = APPLICATION->settings()->get("InstanceDir").toString();
    QStringList existingInstances;
    for (const auto& asset : m_assetsToDownload) {
        QString instanceId = QFileInfo(asset.name).completeBaseName();
        QString targetDir = FS::PathCombine(instDir, instanceId);
        if (QDir(targetDir).exists()) {
            existingInstances.append(instanceId);
        }
    }

    if (!existingInstances.isEmpty()) {
        auto reply = CustomMessageBox::selectable(qobject_cast<QWidget*>(parent()), tr("Сборки уже существуют"),
                                                  tr("Следующие сборки уже установлены:\n%1\n\nВы хотите переустановить их? Текущие "
                                                     "сохранения и настройки этих сборок будут удалены!")
                                                      .arg(existingInstances.join(", ")),
                                                  QMessageBox::Warning, QMessageBox::Yes | QMessageBox::No, QMessageBox::No)
                         ->exec();

        if (reply != QMessageBox::Yes) {
            // Filter out existing from download list
            QList<AssetInfo> filtered;
            for (const auto& asset : m_assetsToDownload) {
                QString instanceId = QFileInfo(asset.name).completeBaseName();
                if (!existingInstances.contains(instanceId)) {
                    filtered.append(asset);
                }
            }
            m_assetsToDownload = filtered;

            // If user skipped all existing and there's nothing left
            if (m_assetsToDownload.isEmpty()) {
                m_tempDir.removeRecursively();
                emitSucceeded();
                return;
            }

            // Clear and rebuild m_dlJob
            m_dlJob.reset(new NetJob("Download Builds", APPLICATION->network()));
            for (const auto& asset : m_assetsToDownload) {
                auto action = Net::Download::makeFile(QUrl(asset.url), asset.targetPath);
                m_dlJob->addNetAction(action);
            }
        } else {
            m_reinstallExisting = true;
        }
    }

    setStatus(tr("Downloading %1 build(s)...").arg(m_assetsToDownload.size()));

    connect(m_dlJob.get(), &NetJob::succeeded, this, &DownloadBuildsTask::downloadAssetsFinished);
    connect(m_dlJob.get(), &NetJob::failed, this, &DownloadBuildsTask::downloadAssetsFailed);
    connect(m_dlJob.get(), &NetJob::progress, this, [this](qint64 current, qint64 total) { setProgress(current, total); });

    m_dlJob->start();
}

void DownloadBuildsTask::fetchReleasesFailed(QString reason)
{
    emitFailed(tr("Failed to fetch builds list: %1").arg(reason));
}

void DownloadBuildsTask::downloadAssetsFinished()
{
    setStatus(tr("Extracting and installing builds..."));
    setProgress(0, 100);
    extractAndInstallBuilds();
}

void DownloadBuildsTask::downloadAssetsFailed(QString reason)
{
    // Cleanup Temp
    m_tempDir.removeRecursively();
    emitFailed(tr("Failed to download builds: %1").arg(reason));
}

void DownloadBuildsTask::extractAndInstallBuilds()
{
    QString instDir = APPLICATION->settings()->get("InstanceDir").toString();
    QStringList extractedIds;

    int current = 0;
    int total = m_assetsToDownload.size();

    for (const auto& asset : m_assetsToDownload) {
        QString instanceId = QFileInfo(asset.name).completeBaseName();
        QString targetDir = FS::PathCombine(instDir, instanceId);

        if (QDir(targetDir).exists()) {
            if (m_reinstallExisting) {
                qInfo() << "Removing existing build for reinstall:" << instanceId;
                FS::deletePath(targetDir);
            } else {
                qInfo() << "Build" << instanceId << "already exists, skipping.";
                current++;
                setProgress(current, total);
                continue;
            }
        }

        if (!QDir(targetDir).exists()) {
            QDir::current().mkpath(targetDir);
            auto result = MMCZip::extractDir(asset.targetPath, targetDir);
            if (result.has_value()) {
                qInfo() << "Extracted downloaded build:" << instanceId;
                extractedIds.append(instanceId);

                // Install icon if present
                QString instIconKey = instanceId;
                auto importIconPath = IconUtils::findBestIconIn(targetDir, "icon.png");
                if (importIconPath.isNull() || !QFile::exists(importIconPath))
                    importIconPath = IconUtils::findBestIconIn(FS::PathCombine(targetDir, "overrides"), "icon.png");

                if (!importIconPath.isNull() && QFile::exists(importIconPath)) {
                    auto iconList = APPLICATION->icons();
                    if (iconList->iconFileExists(instIconKey)) {
                        iconList->deleteIcon(instIconKey);
                    }
                    iconList->installIcon(importIconPath, instIconKey + "." + QFileInfo(importIconPath).suffix());
                }
            } else {
                qWarning() << "Failed to extract downloaded build:" << instanceId;
            }
        }

        current++;
        setProgress(current, total);
    }

    // Cleanup Temp
    m_tempDir.removeRecursively();

    if (!extractedIds.isEmpty()) {
        // Reload to pick up newly extracted instances
        auto m_instances = APPLICATION->instances();
        m_instances->loadList();

        for (const auto& id : extractedIds) {
            auto inst = m_instances->getInstanceById(id);
            if (inst) {
                m_instances->setInstanceGroup(id, "[BTTR] Community");

                // If we also installed an icon specifically for this instance ID, assign it
                if (APPLICATION->icons()->iconFileExists(id)) {
                    inst->setIconKey(id);
                }
            }
        }
        emitSucceeded();
    } else {
        emitFailed(tr("Все сборки уже установлены, либо произошла ошибка распаковки."));
    }
}
