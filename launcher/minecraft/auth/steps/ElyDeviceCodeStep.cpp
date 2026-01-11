// SPDX-License-Identifier: GPL-3.0-only
/*
 *  ElyPrismLauncher - Minecraft Launcher
 *  Copyright (c) 2025 Octol1ttle <l1ttleofficial@outlook.com>
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

#include "ElyDeviceCodeStep.h"

#include "Application.h"

ElyDeviceCodeStep::ElyDeviceCodeStep(AccountData* data) : MSADeviceCodeStep(data)
{
    m_clientId = APPLICATION->getElyClientID();
    m_scopes = "account_info offline_access minecraft_server_session";
    m_deviceCodeUrl = QUrl("https://account.ely.by/api/oauth2/v1/devicecode");
    m_tokenUrl = QUrl("https://account.ely.by/api/oauth2/v1/token");
}

QString ElyDeviceCodeStep::describe()
{
    return tr("Logging in with Ely.by account(device code).");
}
