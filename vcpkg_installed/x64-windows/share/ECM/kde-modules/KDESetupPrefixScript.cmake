# SPDX-FileCopyrightText: 2014-2015 Alex Merry <alex.merry@kde.org>
# SPDX-FileCopyrightText: 2013 Stephen Kelly <steveire@gmail.com>
# SPDX-FileCopyrightText: 2012 David Faure <faure@kde.org>
# SPDX-FileCopyrightText: 2007 Matthias Kretz <kretz@kde.org>
# SPDX-FileCopyrightText: 2006-2007 Laurent Montel <montel@kde.org>
# SPDX-FileCopyrightText: 2006-2013 Alex Neundorf <neundorf@kde.org>
#
# SPDX-License-Identifier: BSD-3-Clause
#
# Prefix script setup code shared between KDEInstallDirsX.cmake, not public API.
#

if (CMAKE_CROSSCOMPILING)
    # we can't run anything when cross-compiling, so no need to even bother with a prefix script in this case
    return()
endif()

configure_file(${CMAKE_CURRENT_LIST_DIR}/prefix.sh.cmake ${CMAKE_CURRENT_BINARY_DIR}/prefix.sh @ONLY)

find_program(FISH_EXECUTABLE fish)
if(FISH_EXECUTABLE)
    configure_file(${CMAKE_CURRENT_LIST_DIR}/prefix.sh.fish.cmake ${CMAKE_CURRENT_BINARY_DIR}/prefix.sh.fish @ONLY)
endif()

option(KDE_INSTALL_PREFIX_SCRIPT "Installs ${CMAKE_INSTALL_PREFIX}/prefix.sh that sets up the necessary environment variables" OFF)
if(KDE_INSTALL_PREFIX_SCRIPT)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/prefix.sh DESTINATION ${CMAKE_INSTALL_PREFIX} PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ)
endif()

if(NOT KDE_INSTALL_USE_QT_SYS_PATHS)
    message("Installing in ${CMAKE_INSTALL_PREFIX}. Run ${CMAKE_CURRENT_BINARY_DIR}/prefix.sh to set the environment for ${CMAKE_PROJECT_NAME}.")
endif()
