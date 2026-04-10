# SPDX-FileCopyrightText: 2021 Alexander Lohnau <alexander.lohnau@gmx.de>
# SPDX-License-Identifier: BSD-3-Clause

set PATH "@KDE_INSTALL_FULL_BINDIR@:$PATH"

# LD_LIBRARY_PATH only needed if you are building without rpath
# set -x LD_LIBRARY_PATH "@KDE_INSTALL_FULL_LIBDIR@:$LD_LIBRARY_PATH"

if test -z "$XDG_DATA_DIRS"
    set -x --path XDG_DATA_DIRS /usr/local/share/ /usr/share/
end
set -x --path XDG_DATA_DIRS "@KDE_INSTALL_FULL_DATADIR@" $XDG_DATA_DIRS

if test -z "$XDG_CONFIG_DIRS"
    set -x --path XDG_CONFIG_DIRS /etc/xdg
end
set -x --path XDG_CONFIG_DIRS "@KDE_INSTALL_FULL_CONFDIR@" $XDG_CONFIG_DIRS

set -x --path QT_PLUGIN_PATH "@KDE_INSTALL_FULL_QTPLUGINDIR@" $QT_PLUGIN_PATH
set -x --path QML2_IMPORT_PATH "@KDE_INSTALL_FULL_QMLDIR@" $QML2_IMPORT_PATH

set -x --path QT_QUICK_CONTROLS_STYLE_PATH "@KDE_INSTALL_FULL_QMLDIR@/QtQuick/Controls.2/" $QT_QUICK_CONTROLS_STYLE_PATH
