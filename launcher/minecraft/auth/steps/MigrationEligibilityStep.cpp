#include "MigrationEligibilityStep.h"

#include <QNetworkRequest>

#include "Application.h"
#include "minecraft/auth/Parsers.h"

MigrationEligibilityStep::MigrationEligibilityStep(AccountData* data) : AuthStep(data) {}

MigrationEligibilityStep::~MigrationEligibilityStep() noexcept = default;

QString MigrationEligibilityStep::describe()
{
    return tr("Checking for migration eligibility.");
}

void MigrationEligibilityStep::perform()
{
    m_filesNetJob.reset(new NetJob(tr("Injector URL download"), APPLICATION->network()));

    m_filesNetJob->addNetAction(Net::Download::makeByteArray(QUrl(injector_download_url), m_response));

    connect(m_filesNetJob.get(), &NetJob::succeeded, this, &MigrationEligibilityStep::onUrlRequestDone);
    connect(m_filesNetJob.get(), &NetJob::failed, this, &MigrationEligibilityStep::downloadFailed);

    m_filesNetJob->start();
}

void MigrationEligibilityStep::rehydrate()
{
    // NOOP, for now. We only save bools and there's nothing to check.
}

void MigrationEligibilityStep::onUrlRequestDone() {
    m_filesNetJob.reset(new NetJob(tr("Injector download"), APPLICATION->network()));

    m_filesNetJob->addNetAction(Net::Download::makeFile(QUrl(*m_response), "authlib-injector.jar"));

    connect(m_filesNetJob.get(), &NetJob::succeeded, this, &MigrationEligibilityStep::onDownloadDone);
    connect(m_filesNetJob.get(), &NetJob::failed, this, &MigrationEligibilityStep::downloadFailed);

    m_filesNetJob->start();
}

void MigrationEligibilityStep::onDownloadDone()
{
    emit finished(AccountTaskState::STATE_WORKING, tr("Downloaded injector"));
}

void MigrationEligibilityStep::downloadFailed(QString reason)
{
    emit finished(AccountTaskState::STATE_OFFLINE, tr("Injector download failed"));
}
