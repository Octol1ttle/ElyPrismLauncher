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
    if (m_request->error() != QNetworkReply::NoError || !m_response) {
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
    const auto root = doc.object();
    const QJsonObject overrides = root.value("overrides").toObject();

    for (const auto &library : m_instance->getPackProfile()->getProfile()->getLibraries()) {
        const QString& libraryArtifact = library->artifactPrefix();
        const bool isAuthlib = libraryArtifact == "com.mojang:authlib";

        const QJsonValue artifact = overrides.value(libraryArtifact);
        if (!artifact.isObject()) {
            continue;
        }

        const QJsonValue version = artifact.toObject().value(library->version());
        if (!version.isObject()) {
            continue;
        }

        library->setHint("always-stale");
        if (isAuthlib && !m_session->wants_ely_patch) {
            continue;
        }

        const QJsonObject override = version.toObject();
        const auto newDownloadInfo = std::make_shared<MojangDownloadInfo>();
        newDownloadInfo->url = override.value("url").toString();
        newDownloadInfo->sha1 = override.value("sha1").toString();
        newDownloadInfo->size = override.value("size").toInt();

        const auto newLibraryInfo = std::make_shared<MojangLibraryDownloadInfo>(newDownloadInfo);
        library->setMojangDownloadInfo(newLibraryInfo);

        replacedAuthlib = replacedAuthlib || isAuthlib;
    }

    m_session->ely_authlib_replaced = replacedAuthlib;

    if (replacedAuthlib) {
        emitSucceeded();
        return;
    }

    downloadAuthlibInjector(root.value("extras").toObject().value("authlib-injector").toString());
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