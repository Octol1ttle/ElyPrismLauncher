#pragma once

#include "net/NetJob.h"
#include "tasks/Task.h"

#include <QDir>
#include <QStringList>

class DownloadBuildsTask : public Task {
    Q_OBJECT
   public:
    explicit DownloadBuildsTask(QObject* parent = nullptr);
    virtual ~DownloadBuildsTask() = default;

    bool canAbort() const override { return true; }

   public slots:
    bool abort() override;

   protected:
    void executeTask() override;

   private slots:
    void fetchReleasesFinished();
    void fetchReleasesFailed(QString reason);

    void downloadAssetsFinished();
    void downloadAssetsFailed(QString reason);

   private:
    void extractAndInstallBuilds();

   private:
    NetJob::Ptr m_apiJob;
    NetJob::Ptr m_dlJob;

    std::shared_ptr<QByteArray> m_apiResponse;

    struct AssetInfo {
        QString name;
        QString url;
        QString targetPath;
    };
    QList<AssetInfo> m_assetsToDownload;

    bool m_reinstallExisting = false;

    QDir m_tempDir;
};
