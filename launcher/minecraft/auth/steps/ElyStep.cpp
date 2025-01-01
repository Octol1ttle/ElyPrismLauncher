// SPDX-License-Identifier: GPL-3.0-only
/*
 *  Prism Launcher - Minecraft Launcher
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
 *
 * This file incorporates work covered by the following copyright and
 * permission notice:
 *
 *      Copyright 2013-2021 MultiMC Contributors
 *
 *      Licensed under the Apache License, Version 2.0 (the "License");
 *      you may not use this file except in compliance with the License.
 *      You may obtain a copy of the License at
 *
 *          http://www.apache.org/licenses/LICENSE-2.0
 *
 *      Unless required by applicable law or agreed to in writing, software
 *      distributed under the License is distributed on an "AS IS" BASIS,
 *      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *      See the License for the specific language governing permissions and
 *      limitations under the License.
 */

#include "ElyStep.h"

#include <QAbstractOAuth2>
#include <QOAuthHttpServerReplyHandler>
#include <QOAuthOobReplyHandler>

#include "Application.h"
#include "BuildConfig.h"
#include "FileSystem.h"

#include <QSettings>

ElyStep::ElyStep(AccountData* data, bool silent) : AuthStep(data), m_silent(silent)
{
    m_clientId = APPLICATION->getElyClientID();
    auto replyHandler = new QOAuthHttpServerReplyHandler(this);
    replyHandler->setCallbackText(QString(R"XXX(
    <noscript>
      <meta http-equiv="Refresh" content="0; URL=%1" />
    </noscript>
    Login Successful, redirecting...
    <script>
      window.location.replace("%1");
    </script>
    )XXX")
                                      .arg(BuildConfig.LOGIN_CALLBACK_URL));
    m_oauth2.setReplyHandler(replyHandler);
    m_oauth2.setAuthorizationUrl(QUrl("https://account.ely.by/oauth2/v1"));
    m_oauth2.setAccessTokenUrl(QUrl("https://account.ely.by/api/oauth2/v1/token"));
    m_oauth2.setScope("account_info offline_access minecraft_server_session");
    m_oauth2.setClientIdentifier(m_clientId);
    m_oauth2.setNetworkAccessManager(APPLICATION->network().get());
#if QT_VERSION >= QT_VERSION_CHECK(6, 8, 0)
    m_oauth2.setPkceMethod(QOAuth2AuthorizationCodeFlow::PkceMethod::None);
#endif

    connect(&m_oauth2, &QOAuth2AuthorizationCodeFlow::granted, this, [this] {
        m_data->msaClientID = m_oauth2.clientIdentifier();
        m_data->msaToken.issueInstant = QDateTime::currentDateTimeUtc();
        m_data->msaToken.notAfter = m_oauth2.expirationAt();
        m_data->msaToken.extra = m_oauth2.extraTokens();
        m_data->msaToken.refresh_token = m_oauth2.refreshToken();
        m_data->msaToken.token = m_oauth2.token();
        emit finished(AccountTaskState::STATE_WORKING, tr("Got "));
    });
    connect(&m_oauth2, &QOAuth2AuthorizationCodeFlow::authorizeWithBrowser, this, &ElyStep::authorizeWithBrowser);
    connect(&m_oauth2, &QOAuth2AuthorizationCodeFlow::requestFailed, this, [this, silent](const QAbstractOAuth2::Error err) {
        auto state = AccountTaskState::STATE_FAILED_HARD;
        if (m_oauth2.status() == QAbstractOAuth::Status::Granted || silent) {
            if (err == QAbstractOAuth2::Error::NetworkError) {
                state = AccountTaskState::STATE_OFFLINE;
            } else {
                state = AccountTaskState::STATE_FAILED_SOFT;
            }
        }
        auto message = tr("Ely.by user authentication failed.");
        if (silent) {
            message = tr("Failed to refresh token.");
        }
        qWarning() << message;
        emit finished(state, message);
    });
    connect(&m_oauth2, &QOAuth2AuthorizationCodeFlow::error, this,
            [this](const QString& error, const QString& errorDescription, const QUrl& uri) {
                qWarning() << "Failed to login because" << error << errorDescription;
                emit finished(AccountTaskState::STATE_FAILED_HARD, errorDescription);
            });

    connect(&m_oauth2, &QOAuth2AuthorizationCodeFlow::extraTokensChanged, this,
            [this](const QVariantMap& tokens) { m_data->msaToken.extra = tokens; });

    connect(&m_oauth2, &QOAuth2AuthorizationCodeFlow::clientIdentifierChanged, this,
            [this](const QString& clientIdentifier) { m_data->msaClientID = clientIdentifier; });
}

QString ElyStep::describe()
{
    return tr("Logging in with Ely.by account.");
}

void ElyStep::perform()
{
    if (m_silent) {
        if (m_data->msaClientID != m_clientId) {
            emit finished(AccountTaskState::STATE_DISABLED,
                          tr("Ely.by user authentication failed - client identification has changed."));
            return;
        }
        if (m_data->msaToken.refresh_token.isEmpty()) {
            emit finished(AccountTaskState::STATE_DISABLED, tr("Ely.by user authentication failed - refresh token is empty."));
            return;
        }
        m_oauth2.setRefreshToken(m_data->msaToken.refresh_token);
        m_oauth2.refreshAccessToken();
    } else {
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)  // QMultiMap param changed in 6.0
        m_oauth2.setModifyParametersFunction(
            [](QAbstractOAuth::Stage stage, QMultiMap<QString, QVariant>* map) { map->insert("prompt", "select_account"); });
#else
        m_oauth2.setModifyParametersFunction(
            [](QAbstractOAuth::Stage stage, QMap<QString, QVariant>* map) { map->insert("prompt", "select_account"); });
#endif

        *m_data = AccountData();
        m_data->type = AccountType::Ely;
        m_data->msaClientID = m_clientId;
        m_oauth2.grant();
    }
}