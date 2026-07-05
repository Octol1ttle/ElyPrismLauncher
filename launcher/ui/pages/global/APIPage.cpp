// SPDX-License-Identifier: GPL-3.0-only
/*
 *  Prism Launcher - Minecraft Launcher
 *  Copyright (C) 2022 Sefa Eyeoglu <contact@scrumplex.net>
 *  Copyright (c) 2022 Jamie Mansfield <jmansfield@cadixdev.org>
 *  Copyright (c) 2022 Lenny McLennington <lenny@sneed.church>
 *  Copyright (C) 2023 TheKodeToad <TheKodeToad@proton.me>
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

#include "APIPage.h"
#include "ui_APIPage.h"

#include <QFileDialog>
#include <QMessageBox>
#include <QRegularExpression>
#include <QStandardPaths>
#include <QTabBar>
#include <QValidator>
#include <QVariant>

#include "Application.h"
#include "BuildConfig.h"
#include "PineconeNetworkCheck.h"
#include "net/PasteUpload.h"
#include "net/flame/FetchFlameAPIKey.h"
#include "settings/SettingsObject.h"
#include "tools/BaseProfiler.h"
#include "ui/dialogs/ProgressDialog.h"

APIPage::APIPage(QWidget* parent) : QWidget(parent), ui(new Ui::APIPage)
{
    // This is here so you can reorder the entries in the combobox without messing stuff up
    int comboBoxEntries[] = { PasteUpload::PasteType::Mclogs, PasteUpload::PasteType::NullPointer, PasteUpload::PasteType::PasteGG,
                              PasteUpload::PasteType::Hastebin };

    static const QRegularExpression s_validUrlRegExp("https?://.+");
    static const QRegularExpression s_validMSAClientID(
        QRegularExpression::anchoredPattern("[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}"));

    ui->setupUi(this);

    for (auto pasteType : comboBoxEntries) {
        ui->pasteTypeComboBox->addItem(PasteUpload::PasteTypes.at(pasteType).name, pasteType);
    }

    void (QComboBox::*currentIndexChangedSignal)(int)(&QComboBox::currentIndexChanged);
    connect(ui->pasteTypeComboBox, currentIndexChangedSignal, this, &APIPage::updateBaseURLPlaceholder);
    // This function needs to be called even when the ComboBox's index is still in its default state.
    updateBaseURLPlaceholder(ui->pasteTypeComboBox->currentIndex());
    // NOTE: this allows http://, but we replace that with https later anyway
    ui->metaURL->setValidator(new QRegularExpressionValidator(s_validUrlRegExp, ui->metaURL));
    ui->resourceURL->setValidator(new QRegularExpressionValidator(s_validUrlRegExp, ui->resourceURL));
    ui->baseURLEntry->setValidator(new QRegularExpressionValidator(s_validUrlRegExp, ui->baseURLEntry));
    ui->legacyFMLLibsURL->setValidator(new QRegularExpressionValidator(s_validUrlRegExp, ui->legacyFMLLibsURL));
    ui->msaClientID->setValidator(new QRegularExpressionValidator(s_validMSAClientID, ui->msaClientID));

    ui->metaURL->setPlaceholderText(BuildConfig.META_URL);
    ui->resourceURL->setPlaceholderText(BuildConfig.DEFAULT_RESOURCE_BASE);
    ui->legacyFMLLibsURL->setPlaceholderText(BuildConfig.LEGACY_FMLLIBS_BASE_URL);
    ui->userAgentLineEdit->setPlaceholderText(BuildConfig.USER_AGENT);

    loadSettings();

    resetBaseURLNote();
    connect(ui->pasteTypeComboBox, currentIndexChangedSignal, this, &APIPage::updateBaseURLNote);
    connect(ui->baseURLEntry, &QLineEdit::textEdited, this, &APIPage::resetBaseURLNote);

    onAutoServersChanged();
    connect(ui->autoServersCheckBox, &QCheckBox::checkStateChanged, this, &APIPage::onAutoServersChanged);
    connect(ui->setHostedServers, &QPushButton::clicked, this, [this] {
        constexpr auto key = PineconeNetworkCheck::Result::UsePrimary;
        ui->metaURL->setText(PineconeNetworkCheck::metaUrls().value(key));
        ui->legacyFMLLibsURL->setText(PineconeNetworkCheck::fmlLibsUrls().value(key));
    });
    connect(ui->setGitHubNew, &QPushButton::clicked, this, [this] {
        constexpr auto key = PineconeNetworkCheck::Result::UseNewFallback;
        ui->metaURL->setText(PineconeNetworkCheck::metaUrls().value(key));
        ui->legacyFMLLibsURL->setText(PineconeNetworkCheck::fmlLibsUrls().value(key));
    });
    connect(ui->setGitHubOld, &QPushButton::clicked, this, [this] {
        constexpr auto key = PineconeNetworkCheck::Result::UseOldFallback;
        ui->metaURL->setText(PineconeNetworkCheck::metaUrls().value(key));
        ui->legacyFMLLibsURL->setText(PineconeNetworkCheck::fmlLibsUrls().value(key));
    });

    connect(ui->fetchFlameKey, &QPushButton::clicked, this, [this] {
        FetchFlameAPIKey task{};
        connect(&task, &Task::succeeded, this, [this, &task] {
            ui->flameKey->setText(task.result());
        });
        connect(&task, &Task::failed, this, [this, &task] {
            QMessageBox::critical(this, tr("Could not fetch API key"),
                tr("Could not fetch CurseForge API key:\n%1").arg(task.failReason()));
        });

        ProgressDialog dialog{this};
        dialog.setSkipButton(true, tr("Abort"));
        dialog.execWithTask(&task);
    });
}

APIPage::~APIPage()
{
    delete ui;
}

void APIPage::resetBaseURLNote()
{
    ui->baseURLNote->hide();
    baseURLPasteType = ui->pasteTypeComboBox->currentIndex();
}

void APIPage::updateBaseURLNote(int index)
{
    if (baseURLPasteType == index) {
        ui->baseURLNote->hide();
    } else if (!ui->baseURLEntry->text().isEmpty()) {
        ui->baseURLNote->show();
    }
}

void APIPage::updateBaseURLPlaceholder(int index)
{
    int pasteType = ui->pasteTypeComboBox->itemData(index).toInt();
    QString pasteDefaultURL = PasteUpload::PasteTypes.at(pasteType).defaultBase;
    ui->baseURLEntry->setPlaceholderText(pasteDefaultURL);
}

void APIPage::onAutoServersChanged() const
{
    const bool autoServers = ui->autoServersCheckBox->isChecked();
    ui->setHostedServers->setEnabled(!autoServers);
    ui->setGitHubNew->setEnabled(!autoServers);
    ui->setGitHubOld->setEnabled(!autoServers);

    ui->metaURL->setEnabled(!autoServers);
    ui->legacyFMLLibsURL->setEnabled(!autoServers);
    if (autoServers) {
        ui->metaURL->clear();
        ui->legacyFMLLibsURL->clear();
    }
}

void APIPage::loadSettings()
{
    auto s = APPLICATION->settings();

    int pasteType = s->get("PastebinType").toInt();
    QString pastebinURL = s->get("PastebinCustomAPIBase").toString();

    ui->baseURLEntry->setText(pastebinURL);
    int pasteTypeIndex = ui->pasteTypeComboBox->findData(pasteType);
    if (pasteTypeIndex == -1) {
        pasteTypeIndex = ui->pasteTypeComboBox->findData(PasteUpload::PasteType::Mclogs);
        ui->baseURLEntry->clear();
    }

    ui->pasteTypeComboBox->setCurrentIndex(pasteTypeIndex);

    if (bool fallbackMRBlockedMods = s->get("FallbackMRBlockedMods").toBool()) {
        ui->FallbackMRBlockedMods->setChecked(fallbackMRBlockedMods);
    }

    QString msaClientID = s->get("MSAClientIDOverride").toString();
    ui->msaClientID->setText(msaClientID);
    QString elyClientID = s->get("ElyClientIDOverride").toString();
    ui->elyClientID->setText(elyClientID);
    QString metaURL = s->get("MetaURLOverride").toString();
    ui->metaURL->setText(metaURL);
    QString resourceURL = s->get("ResourceURLOverride").toString();
    ui->resourceURL->setText(resourceURL);
    QString fmlLibsURL = s->get("LegacyFMLLibsURLOverride").toString();
    ui->legacyFMLLibsURL->setText(fmlLibsURL);
    QString flameKey = s->get("FlameKeyOverride").toString();
    ui->flameKey->setText(flameKey);
    QString modrinthToken = s->get("ModrinthToken").toString();
    ui->modrinthToken->setText(modrinthToken);
    QString customUserAgent = s->get("UserAgentOverride").toString();
    ui->userAgentLineEdit->setText(customUserAgent);
    ui->technicClientID->setText(s->get("TechnicClientID").toString());

    ui->autoServersCheckBox->setChecked(s->get("PineconeAutoServers").toBool());
}

void APIPage::applySettings()
{
    auto s = APPLICATION->settings();

    s->set("PastebinType", ui->pasteTypeComboBox->currentData().toInt());
    s->set("PastebinCustomAPIBase", ui->baseURLEntry->text());

    QString msaClientID = ui->msaClientID->text();
    s->set("MSAClientIDOverride", msaClientID);
    QString elyClientID = ui->elyClientID->text();
    s->set("ElyClientIDOverride", elyClientID);
    QUrl metaURL(ui->metaURL->text());
    QUrl resourceURL(ui->resourceURL->text());
    QUrl fmlLibsURL(ui->legacyFMLLibsURL->text());

    auto addRequiredTrailingSlash = [](QUrl& url) {
        if (!url.isEmpty() && !url.path().endsWith('/')) {
            QString path = url.path();
            path.append('/');
            url.setPath(path);
        }
    };
    addRequiredTrailingSlash(metaURL);
    addRequiredTrailingSlash(resourceURL);
    addRequiredTrailingSlash(fmlLibsURL);

    auto isLocalhost = [](const QUrl& url) { return url.host() == "localhost" || url.host() == "127.0.0.1" || url.host() == "::1"; };
    auto isUnsafe = [isLocalhost](const QUrl& url) { return !url.isEmpty() && url.scheme() == "http" && !isLocalhost(url); };
    auto upgradeToHTTPS = [isUnsafe](QUrl& url) {
        if (isUnsafe(url)) {
            url.setScheme("https");
        }
    };

    upgradeToHTTPS(metaURL);
    upgradeToHTTPS(resourceURL);
    upgradeToHTTPS(fmlLibsURL);

    s->set("FallbackMRBlockedMods", ui->FallbackMRBlockedMods->checkState());
    s->set("MetaURLOverride", metaURL.toString());
    s->set("ResourceURLOverride", resourceURL.toString());
    s->set("LegacyFMLLibsURLOverride", fmlLibsURL.toString());
    QString flameKey = ui->flameKey->text();
    s->set("FlameKeyOverride", flameKey);
    QString modrinthToken = ui->modrinthToken->text();
    s->set("ModrinthToken", modrinthToken);
    s->set("UserAgentOverride", ui->userAgentLineEdit->text());
    s->set("TechnicClientID", ui->technicClientID->text());

    s->set("PineconeAutoServers", ui->autoServersCheckBox->isChecked());
}

bool APIPage::apply()
{
    applySettings();
    return true;
}

void APIPage::retranslate()
{
    ui->retranslateUi(this);
}
