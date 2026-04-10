# SPDX-FileCopyrightText: 2021 Volker Krause <vkrause@kde.org>
#
# SPDX-License-Identifier: BSD-3-Clause

#[=======================================================================[.rst:
KDEInstallDirs
--------------

Compatibility wrapper around :kde-module:`KDEInstallDirs5`.

Since 5.82.0, prior to that equivalent to :kde-module:`KDEInstallDirs5`.
#]=======================================================================]

include(${CMAKE_CURRENT_LIST_DIR}/../modules/QtVersionOption.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/KDEInstallDirs${QT_MAJOR_VERSION}.cmake)
