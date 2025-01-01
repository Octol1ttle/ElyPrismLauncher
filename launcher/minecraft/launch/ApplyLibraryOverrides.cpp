#include "ApplyLibraryOverrides.h"
#include <launch/LaunchTask.h>
#include "minecraft/PackProfile.h"
#include "net/Download.h"
#include "net/NetJob.h"

#include "Application.h"

ApplyLibraryOverrides::ApplyLibraryOverrides(LaunchTask* parent, AuthSessionPtr session) : LaunchStep(parent), m_session(session), m_instance(m_parent->instance())
{}

void ApplyLibraryOverrides::executeTask()
{
    downloadLibraryOverrideList();
}

void ApplyLibraryOverrides::downloadLibraryOverrideList()
{
    const auto libraryOverrideListUrl = QUrl("https://raw.githubusercontent.com/ElyPrismLauncher/ElyPrismLauncher/refs/heads/develop/epl_metadata.json");
    m_request = Net::Download::makeByteArray(libraryOverrideListUrl, m_response);

    m_task.reset(new NetJob("Fetch EPL metadata", APPLICATION->network()));
    m_task->addNetAction(m_request);

    connect(m_task.get(), &NetJob::finished, this, &ApplyLibraryOverrides::onLibraryOverrideDownloadFinished);
    connect(m_task.get(), &NetJob::aborted, this, [this] { emitFailed(tr("Aborted")); });

    m_task->start();
}

void ApplyLibraryOverrides::onLibraryOverrideDownloadFinished()
{
    if (m_request->error() != QNetworkReply::NoError) {
        emitFailed("Failed to download EPL metadata.");
        return;
    }

    QJsonParseError jsonError;
    const QJsonDocument doc = QJsonDocument::fromJson(*m_response, &jsonError);
    if (jsonError.error) {
        emitFailed("Failed to parse EPL metadata.");
        return;
    }

    bool replacedAuthlib = false;
    auto root = doc.object();
    auto overrides = root["overrides"].toObject();

    for (const auto &library : m_instance->getPackProfile()->getProfile()->getLibraries()) {
        const QString& artifact = library->artifactPrefix();
        const bool isAuthlib = artifact == "com.mojang:authlib";

        auto artifactRef = overrides[artifact];
        if (!artifactRef.isObject()) {
            continue;
        }

        auto versionRef = artifactRef.toObject()[library->version()];
        if (!versionRef.isObject()) {
            continue;
        }

        library->setHint("always-stale");
        if (isAuthlib && !m_session->wants_ely_patch) {
            continue;
        }

        auto override = versionRef.toObject();
        auto newDownloadInfo = std::make_shared<MojangDownloadInfo>();
        newDownloadInfo->url = override["url"].toString();
        newDownloadInfo->sha1 = override["sha1"].toString();
        newDownloadInfo->size = override["size"].toInt();

        const auto newLibraryInfo = std::make_shared<MojangLibraryDownloadInfo>(newDownloadInfo);

        library->setMojangDownloadInfo(newLibraryInfo);

        replacedAuthlib = replacedAuthlib || isAuthlib;
    }

    m_session->ely_authlib_replaced = replacedAuthlib;

    if (replacedAuthlib) {
        emitSucceeded();
        return;
    }

    downloadAuthlibInjector(root["extras"].toObject()["authlib-injector"].toString());
}

void ApplyLibraryOverrides::downloadAuthlibInjector(const QUrl &downloadUrl) {
    m_request = Net::Download::makeFile(downloadUrl, "authlib-injector.jar");

    m_task.reset(new NetJob("Download authlib-injector", APPLICATION->network()));
    m_task->addNetAction(m_request);

    connect(m_task.get(), &NetJob::succeeded, this, &ApplyLibraryOverrides::emitSucceeded);
    connect(m_task.get(), &NetJob::failed, this, &ApplyLibraryOverrides::emitFailed);
    connect(m_task.get(), &NetJob::aborted, this, [this] { emitFailed(tr("Aborted")); });

    m_task->start();
}