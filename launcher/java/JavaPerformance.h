// SPDX-License-Identifier: GPL-3.0-only
/*
 *  Prism Launcher - Minecraft Launcher
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

#include <QStringList>

#include "JavaVersion.h"

namespace JavaPerformance {
    enum class GarbageCollectorPreset : std::uint8_t {
        None,
        G1GC,
        Shenandoah,
        ZGC
    };

    inline QString presetToString(const GarbageCollectorPreset preset)
    {
        switch (preset) {
            case GarbageCollectorPreset::None:
                return QStringLiteral("None");
            case GarbageCollectorPreset::G1GC:
                return QStringLiteral("G1GC");
            case GarbageCollectorPreset::Shenandoah:
                return QStringLiteral("Shenandoah");
            case GarbageCollectorPreset::ZGC:
                return QStringLiteral("ZGC");
        }

        Q_ASSERT_X(false, "JavaPerformance::presetToString", "No preset->string mapping found");
        return {};
    }

    inline GarbageCollectorPreset presetFromString(const QString& presetString)
    {
        if (presetString == "G1GC") {
            return GarbageCollectorPreset::G1GC;
        }
        if (presetString == "Shenandoah") {
            return GarbageCollectorPreset::Shenandoah;
        }
        if (presetString == "ZGC") {
            return GarbageCollectorPreset::ZGC;
        }

        if (presetString != "None") {
            qWarning() << "Unknown garbage collection preset:" << presetString;
        }
        return GarbageCollectorPreset::None;
    }

    QStringList getBaseOptimizationArgs(const JavaVersion& version, GarbageCollectorPreset preset);
    QStringList getGarbageCollectorArgs(const JavaVersion& version, GarbageCollectorPreset preset);
    QStringList getCompletePerformanceArgs(const JavaVersion& version, bool useOptimized, GarbageCollectorPreset preset, QString* warning = nullptr);
}
