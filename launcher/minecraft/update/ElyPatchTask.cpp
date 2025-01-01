#include "ElyPatchTask.h"

#include <Application.h>
#include <meta/Index.h>
#include <minecraft/MinecraftInstance.h>
#include <minecraft/PackProfile.h>
#include <net/NetJob.h>

ElyPatchTask::ElyPatchTask(MinecraftInstance *inst, RuntimeContext &context, Net::Mode mode) : m_inst(inst), m_runtimeContext(context), m_netMode(mode)
{
}

void ElyPatchTask::executeTask()
{
    setStatus(tr("Preparing Ely.by patch..."));

    QString authlibVersion;
    const auto& libraries = m_inst->getPackProfile()->getProfile()->getLibraries();
    for (const auto& library : libraries) {
        if (const QString& artifact = library->artifactPrefix(); artifact == "com.mojang:authlib") {
            authlibVersion = library->version();
            break;
        }
    }

    if (!authlibVersion.isEmpty()) {
        resolveAuthlib(authlibVersion);
    } else {
        resolveAuthlibInjector();
    }
}

bool ElyPatchTask::canAbort() const
{
    return true;
}

bool ElyPatchTask::abort()
{
    return m_currentTask->abort();
}

void ElyPatchTask::resolveAuthlib(QString version)
{
    setDetails("Resolving Ely.by Authlib");

    const auto metaVersionList = APPLICATION->metadataIndex()->get("by.ely.authlib");
    auto metaVersion = metaVersionList->getVersion(version);

    if (!metaVersion->isLoaded()) {
        m_currentTask = APPLICATION->metadataIndex()->loadVersion("by.ely.authlib", version, m_netMode);
        connect(m_currentTask.get(), &Task::succeeded, this, [this, metaVersion] {
            applyAuthlib(metaVersion);
        });
        connect(m_currentTask.get(), &Task::failed, this, [this](QString reason) {
            qWarning() << "Resolving Ely.by Authlib failed:" << reason;
            resolveAuthlibInjector();
        });
        connect(m_currentTask.get(), &Task::progress, this, &ElyPatchTask::setProgress);
        connect(m_currentTask.get(), &Task::stepProgress, this, &ElyPatchTask::propagateStepProgress);
        m_currentTask->start();
        return;
    }

    applyAuthlib(metaVersion);
}

void ElyPatchTask::resolveAuthlibInjector()
{
    setDetails(tr("Resolving authlib-injector"));

    const auto metaVersionList = APPLICATION->metadataIndex()->get("moe.yushi.authlibinjector");
    if (metaVersionList->status() == Meta::BaseEntity::LoadStatus::NotLoaded) {
        m_currentTask = metaVersionList->loadTask(m_netMode);
        connect(m_currentTask.get(), &Task::succeeded, this, [this] {
            resolveAuthlibInjector();
        });
        connect(m_currentTask.get(), &Task::failed, this, &ElyPatchTask::emitFailed);
        connect(m_currentTask.get(), &Task::progress, this, &ElyPatchTask::setProgress);
        connect(m_currentTask.get(), &Task::stepProgress, this, &ElyPatchTask::propagateStepProgress);
        m_currentTask->start();
        return;
    }

    Meta::Version::Ptr recommendedVersion = nullptr;
    for (int i = 0; i < metaVersionList->count(); ++i) {
        const auto version = metaVersionList->concreteAt(i);
        if (version->isRecommended()) {
            recommendedVersion = version;
            break;
        }
    }
    if (!recommendedVersion) {
        emitFailed(tr("Couldn't get recommended authlib-injector version"));
        return;
    }

    if (!recommendedVersion->isLoaded()) {
        m_currentTask = APPLICATION->metadataIndex()->loadVersion("moe.yushi.authlibinjector", recommendedVersion->version(), m_netMode);
        connect(m_currentTask.get(), &Task::succeeded, this, [this, recommendedVersion] {
            applyMetaVersion(recommendedVersion);
        });
        connect(m_currentTask.get(), &Task::failed, this, &ElyPatchTask::emitFailed);
        connect(m_currentTask.get(), &Task::progress, this, &ElyPatchTask::setProgress);
        connect(m_currentTask.get(), &Task::stepProgress, this, &ElyPatchTask::propagateStepProgress);
        m_currentTask->start();
        return;
    }

    applyMetaVersion(recommendedVersion);
}

void ElyPatchTask::applyMetaVersion(Meta::Version::Ptr metaVersion)
{
    metaVersion->data()->applyTo(m_inst->getPackProfile()->getProfile().get(), m_runtimeContext);
    emitSucceeded();
}

void ElyPatchTask::applyAuthlib(Meta::Version::Ptr metaVersion)
{
    auto& libraries = m_inst->getPackProfile()->getProfile()->getLibrariesMut();
    for (int i = libraries.size() - 1; i >= 0; --i) {
        if (const auto library = libraries.at(i); library->artifactPrefix() == "com.mojang:authlib") {
            libraries.removeAt(i);
        }
    }

    applyMetaVersion(metaVersion);
}
