// SPDX-License-Identifier: GPL-3.0-only
/*
*  Prism Launcher - Minecraft Launcher
*  Copyright (c) 2022-2023 flowln <flowlnlnln@gmail.com>
*  Copyright (C) 2022 Sefa Eyeoglu <contact@scrumplex.net>
*
*  This program is free software: you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation, version 3.
*
*  This program is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

#pragma once

#include "net/NetJob.h"
#include "tasks/SequentialTask.h"

#include "modplatform/ModIndex.h"
#include "minecraft/mod/tasks/LocalModUpdateTask.h"

class ResourceFolderModel;

class ResourceDownloadTask : public SequentialTask {
    Q_OBJECT
public:
    explicit ResourceDownloadTask(ModPlatform::IndexedPack pack, ModPlatform::IndexedVersion version, const std::shared_ptr<ResourceFolderModel> packs, bool is_indexed = true);
    const QString& getFilename() const { return m_pack_version.fileName; }
    const QString& getCustomPath() const { return m_pack_version.custom_target_folder; }
    const QVariant& getVersionID() const { return m_pack_version.fileId; }

private:
    ModPlatform::IndexedPack m_pack;
    ModPlatform::IndexedVersion m_pack_version;
    const std::shared_ptr<ResourceFolderModel> m_pack_model;

    NetJob::Ptr m_filesNetJob;
    LocalModUpdateTask::Ptr m_update_task;

    void downloadProgressChanged(qint64 current, qint64 total);
    void downloadFailed(QString reason);
    void downloadSucceeded();

    std::tuple<QString, QString> to_delete {"", ""};

private slots:
    void hasOldResource(QString name, QString filename);
};



