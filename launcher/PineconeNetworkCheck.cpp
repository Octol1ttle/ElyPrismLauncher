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

#include "PineconeNetworkCheck.h"

#include "Application.h"
#include "net/HttpMetaCache.h"
#include "settings/SettingsObject.h"

PineconeNetworkCheck::PineconeNetworkCheck(QNetworkAccessManager* network)
{
    m_network = network;

    static auto s_urlToResult = std::array{
        std::pair{ QUrl("https://pineconemc.ru"), Result::UsePrimary },
        std::pair{ QUrl("https://pineconemc.github.io"), Result::UseNewFallback },
        std::pair{ QUrl("https://elyprismlauncher.github.io"), Result::UseOldFallback },
    };
    for (auto& [url, result] : s_urlToResult) {
        launchRequest(url, result);
    }
}

QMap<PineconeNetworkCheck::Result, QString> PineconeNetworkCheck::metaUrls()
{
    return {
        { Result::UsePrimary, "" },
        { Result::UseNewFallback, "https://pineconemc.github.io/meta/v1/" },
        { Result::UseOldFallback, "https://elyprismlauncher.github.io/meta/v1/" },
    };
}

QMap<PineconeNetworkCheck::Result, QString> PineconeNetworkCheck::fmlLibsUrls()
{
    return {
        { Result::UsePrimary, "" },
        { Result::UseNewFallback, "https://pineconemc.github.io/files/fmllibs/" },
        { Result::UseOldFallback, "https://elyprismlauncher.github.io/files/fmllibs/" },
    };
}

QMap<PineconeNetworkCheck::Result, QString> PineconeNetworkCheck::newsUrls()
{
    return {
        { Result::UsePrimary, "" },
        { Result::UseNewFallback, "https://pineconemc.github.io/feed/feed.xml" },
        { Result::UseOldFallback, "https://elyprismlauncher.github.io/feed/feed.xml" },
    };
}

QMap<PineconeNetworkCheck::Result, QString> PineconeNetworkCheck::translationsUrls()
{
    return {
        { Result::UsePrimary, "" },
        { Result::UseNewFallback, "https://pineconemc.github.io/i18n" },
        { Result::UseOldFallback, "https://elyprismlauncher.github.io/i18n" },
    };
}

void PineconeNetworkCheck::launchRequest(const QUrl& url, Result ifSuccess)
{
    QNetworkRequest request(url);
    request.setTransferTimeout(std::chrono::seconds(3));
    request.setAttribute(QNetworkRequest::Http2AllowedAttribute, false);
    auto* reply = m_network->head(request);
    m_pendingRequests++;

    qInfo() << "[PineconeNetworkCheck] Checking" << url;
    connect(reply, &QNetworkReply::finished, this, [this, reply, ifSuccess] {
        m_pendingRequests--;

        const int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        qInfo() << "[PineconeNetworkCheck]" << reply->url() << "result:" << reply->error() << status;
        if (reply->error() == QNetworkReply::NoError && status < 400 && ifSuccess < m_result) {
            m_result = ifSuccess;
        }
        reply->deleteLater();

        if (!m_finished && (m_pendingRequests == 0 || m_result == Result::UsePrimary)) {
            qInfo() << "[PineconeNetworkCheck] Final result:" << m_result;
            finished();
            m_finished = true;
        }
    });
}

bool PineconeNetworkCheck::handleUrlOverride(const QString& overrideName, const QMap<Result, QString>& urlMap) const
{
    if (!urlMap.contains(m_result)) {
        return false;
    }
    const QString newOverride = urlMap.value(m_result);

    auto* settings = APPLICATION->settings();
    const auto currentOverride = settings->get(overrideName).toString();
    if (currentOverride == newOverride) {
        return false;
    }
    if (!currentOverride.isEmpty() && !urlMap.values().contains(currentOverride)) {
        return false;
    }

    settings->set(overrideName, newOverride);
    qInfo() << "[PineconeNetworkCheck] Updated setting" << overrideName << "to" << newOverride;
    return true;
}

void PineconeNetworkCheck::finished()
{
    if (APPLICATION->settings()->get("PineconeAutoServers").toBool()) {
        qInfo() << "[PineconeNetworkCheck] Automatic server switching is disabled";
        return;
    }

    if (handleUrlOverride("MetaURLOverride", metaUrls())) {
        if (!APPLICATION->metacache()->softEvict()) {
            qWarning() << "[PineconeNetworkCheck] Could not evict metacache during automatic meta switch";
        }
        APPLICATION->metacache()->SaveNow();
    }

    std::ignore = handleUrlOverride("LegacyFMLLibsURLOverride", fmlLibsUrls());

    if (const auto newsUrls = this->newsUrls(); newsUrls.contains(m_result)) {
        emit shouldReloadNews(newsUrls.value(m_result));
    }
}
