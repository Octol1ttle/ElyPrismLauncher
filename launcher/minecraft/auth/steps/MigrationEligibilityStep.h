#pragma once
#include <QObject>

#include "QObjectPtr.h"
#include "minecraft/auth/AuthStep.h"
#include "net/NetJob.h"
static const char* const injector_download_url =
    "https://raw.githubusercontent.com/Octol1ttle/PrismLauncher-elyby/develop/injector-download.url";

class MigrationEligibilityStep : public AuthStep {
    Q_OBJECT

   public:
    explicit MigrationEligibilityStep(AccountData* data);
    virtual ~MigrationEligibilityStep() noexcept;

    void perform() override;
    void rehydrate() override;

    QString describe() override;

   private:
    NetJob::Ptr m_filesNetJob;
    std::shared_ptr<QByteArray> m_response = std::make_shared<QByteArray>();

   private slots:
    void onUrlRequestDone();
    void onDownloadDone();
    void downloadFailed(QString reason);
};
