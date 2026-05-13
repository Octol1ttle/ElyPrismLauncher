// SPDX-License-Identifier: GPL-3.0-only
/*
 *  PineconeMC - Minecraft Launcher
 *  Copyright (C) 2026 Octol1ttle <l1ttleofficial@outlook.com>
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

#include <QNetworkAccessManager>

class PineconeNetworkCheck : public QObject {
    Q_OBJECT

   public:
    enum class Result : std::uint8_t { UsePrimary, UseNewFallback, UseOldFallback, Offline };
    Q_ENUM(Result)

    explicit PineconeNetworkCheck(QNetworkAccessManager* network);
    ~PineconeNetworkCheck() override = default;

   signals:
    void shouldReloadNews(QString newUrl);

   private:
    void launchRequest(const QUrl& url, Result ifSuccess);

    bool handleUrlOverride(const QString& overrideName, const QMap<Result, QString>& urlMap) const;
    void finished();

   private:
    QNetworkAccessManager* m_network = nullptr;
    Result m_result = Result::Offline;
    int m_pendingRequests = 0;
    bool m_finished = false;
};
