// SPDX-License-Identifier: GPL-3.0-only
/*
 *  Prism Launcher - Minecraft Launcher
 *  Copyright (c) 2024 Trial97 <alexandru.tripon97@gmail.com>
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

#include "ElyDeviceCodeStep.h"

#include <QUrlQuery>

#include "Application.h"
#include "net/RawHeaderProxy.h"

ElyDeviceCodeStep::ElyDeviceCodeStep(AccountData* data) : MSADeviceCodeStep(data, false)
{
    m_clientId = APPLICATION->getElyClientID();
    connect(&m_expiration_timer, &QTimer::timeout, this, &ElyDeviceCodeStep::abort);
    connect(&m_pool_timer, &QTimer::timeout, this, &ElyDeviceCodeStep::authenticateUser);
}

QString ElyDeviceCodeStep::describe()
{
    return tr("Logging in with Ely.by account(device code).");
}

void ElyDeviceCodeStep::perform()
{
    QUrlQuery data;
    data.addQueryItem("client_id", m_clientId);
    data.addQueryItem("scope", "account_info offline_access minecraft_server_session");
    auto payload = data.query(QUrl::FullyEncoded).toUtf8();
    QUrl url("https://account.ely.by/api/oauth2/v1/devicecode");
    auto headers = QList<Net::HeaderPair>{
        { "Content-Type", "application/x-www-form-urlencoded" },
        { "Accept", "application/json" },
    };
    m_response.reset(new QByteArray());
    m_request = Net::Upload::makeByteArray(url, m_response, payload);
    m_request->addHeaderProxy(new Net::RawHeaderProxy(headers));

    m_task.reset(new NetJob("ElyDeviceCodeStep", APPLICATION->network()));
    m_task->setAskRetry(false);
    m_task->addNetAction(m_request);

    connect(m_task.get(), &Task::finished, this, &ElyDeviceCodeStep::deviceAuthorizationFinished);

    m_task->start();
}

void ElyDeviceCodeStep::authenticateUser()
{
    QUrlQuery data;
    data.addQueryItem("client_id", m_clientId);
    data.addQueryItem("grant_type", "urn:ietf:params:oauth:grant-type:device_code");
    data.addQueryItem("device_code", m_device_code);
    auto payload = data.query(QUrl::FullyEncoded).toUtf8();
    QUrl url("https://account.ely.by/api/oauth2/v1/token");
    auto headers = QList<Net::HeaderPair>{
        { "Content-Type", "application/x-www-form-urlencoded" },
        { "Accept", "application/json" },
    };
    m_response.reset(new QByteArray());
    m_request = Net::Upload::makeByteArray(url, m_response, payload);
    m_request->addHeaderProxy(new Net::RawHeaderProxy(headers));

    connect(m_request.get(), &Task::finished, this, &ElyDeviceCodeStep::authenticationFinished);

    m_request->setNetwork(APPLICATION->network());
    m_request->start();
}