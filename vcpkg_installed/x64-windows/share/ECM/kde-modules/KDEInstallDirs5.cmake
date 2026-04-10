# SPDX-FileCopyrightText: 2014-2015 Alex Merry <alex.merry@kde.org>
# SPDX-FileCopyrightText: 2013 Stephen Kelly <steveire@gmail.com>
# SPDX-FileCopyrightText: 2012 David Faure <faure@kde.org>
# SPDX-FileCopyrightText: 2007 Matthias Kretz <kretz@kde.org>
# SPDX-FileCopyrightText: 2006-2007 Laurent Montel <montel@kde.org>
# SPDX-FileCopyrightText: 2006-2013 Alex Neundorf <neundorf@kde.org>
#
# SPDX-License-Identifier: BSD-3-Clause

#[=======================================================================[.rst:
KDEInstallDirs5
---------------

Define KDE standard installation directories for Qt5/KF5 based software.

Note that none of the variables defined by this module provide any
information about the location of already-installed KDE software.

Also sets ``CMAKE_INSTALL_PREFIX`` to the installation prefix of ECM,
unless that variable has been already explicitly set by something else
(since 5.61 and with CMake >= 3.7).

Inclusion of this module defines the following variables:

``KDE_INSTALL_<dir>``
    destination for files of a given type
``KDE_INSTALL_FULL_<dir>``
    corresponding absolute path

where ``<dir>`` is one of (default values in parentheses and alternative,
deprecated variable name in square brackets):

``BUNDLEDIR``
    application bundles (``/Applications/KDE``) [``BUNDLE_INSTALL_DIR``]
``EXECROOTDIR``
    executables and libraries (``<empty>``) [``EXEC_INSTALL_PREFIX``]
``BINDIR``
    user executables (``EXECROOTDIR/bin``) [``BIN_INSTALL_DIR``]
``SBINDIR``
    system admin executables (``EXECROOTDIR/sbin``) [``SBIN_INSTALL_DIR``]
``LIBDIR``
    object code libraries (``EXECROOTDIR/lib``, ``EXECROOTDIR/lib64`` or
    ``EXECROOTDIR/lib/<multiarch-tuple`` on Debian) [``LIB_INSTALL_DIR``]
``LIBEXECDIR``
    executables for internal use by programs and libraries (``BINDIR`` on
    Windows, ``LIBDIR/libexec`` otherwise) [``LIBEXEC_INSTALL_DIR``]
``CMAKEPACKAGEDIR``
    CMake packages, including config files (``LIBDIR/cmake``)
    [``CMAKECONFIG_INSTALL_PREFIX``]
``QTPLUGINDIR``
    Qt plugins (``LIBDIR/plugins`` or qmake-qt5's ``QT_INSTALL_PLUGINS``) [``QT_PLUGIN_INSTALL_DIR``]
``PLUGINDIR``
    Plugins (``QTPLUGINDIR``) [``PLUGIN_INSTALL_DIR``]
``QTQUICKIMPORTSDIR``
    QtQuick1 imports (``QTPLUGINDIR/imports`` or qmake-qt5's ``QT_INSTALL_IMPORTS``) [``IMPORTS_INSTALL_DIR``]
``QMLDIR``
    QtQuick2 imports (``LIBDIR/qml`` or qmake-qt5's ``QT_INSTALL_QML``) [``QML_INSTALL_DIR``]
``INCLUDEDIR``
    C and C++ header files (``include``) [``INCLUDE_INSTALL_DIR``]
``LOCALSTATEDIR``
    modifiable single-machine data (``var``)
``SHAREDSTATEDIR``
    modifiable architecture-independent data (``com``)
``DATAROOTDIR``
    read-only architecture-independent data root (``BINDIR/data`` on
    Windows, ``share`` otherwise)
    [``SHARE_INSTALL_PREFIX``]
``DATADIR``
    read-only architecture-independent data (``DATAROOTDIR``)
    [``DATA_INSTALL_DIR``]
``DOCBUNDLEDIR``
    documentation bundles generated using kdoctools
    (``DATAROOTDIR/doc/HTML``) [``HTML_INSTALL_DIR``]
``KCFGDIR``
    kconfig description files (``DATAROOTDIR/config.kcfg``)
    [``KCFG_INSTALL_DIR``]
``KCONFUPDATEDIR``
    kconf_update scripts (``DATAROOTDIR/kconf_update``)
    [``KCONF_UPDATE_INSTALL_DIR``]
``KSERVICES5DIR`` or (since 5.89) ``KSERVICESDIR``
    services for KDE Frameworks 5 (``DATAROOTDIR/kservices5``)
    [``SERVICES_INSTALL_DIR``]
``KSERVICETYPES5DIR`` or (since 5.89) ``KSERVICETYPESDIR``
    service types for KDE Frameworks 5 (``DATAROOTDIR/kservicetypes5``)
    [``SERVICETYPES_INSTALL_DIR``]
``KXMLGUI5DIR`` or (since 5.89) ``KXMLGUIDIR``
    kxmlgui .rc files (``DATAROOTDIR/kxmlgui5``)
    [``KXMLGUI_INSTALL_DIR``]
``KAPPTEMPLATESDIR``
    KAppTemplate and KDevelop templates (``DATAROOTDIR/kdevappwizard/templates``)
    [``KDE_INSTALL_KTEMPLATESDIR``] Since 5.77.
``KFILETEMPLATESDIR``
    KDevelop file templates (``DATAROOTDIR/kdevfiletemplates/templates``) Since 5.77.
``KNOTIFY5RCDIR`` or (since 5.89) ``KNOTIFYRCDIR``
    knotify description files (``DATAROOTDIR/knotifications5``)
    [``KNOTIFYRC_INSTALL_DIR``]
``ICONDIR``
    icons (``DATAROOTDIR/icons``) [``ICON_INSTALL_DIR``]
``LOCALEDIR``
    locale-dependent data (``DATAROOTDIR/locale``)
    [``LOCALE_INSTALL_DIR``]
``SOUNDDIR``
    sound files (``DATAROOTDIR/sounds``) [``SOUND_INSTALL_DIR``]
``TEMPLATEDIR``
    templates (``DATAROOTDIR/templates``) [``TEMPLATES_INSTALL_DIR``]
``WALLPAPERDIR``
    desktop wallpaper images (``DATAROOTDIR/wallpapers``)
    [``WALLPAPER_INSTALL_DIR``]
``APPDIR``
    application desktop files (``DATAROOTDIR/applications``) Since 1.1.0.
    [``XDG_APPS_INSTALL_DIR``]
``DESKTOPDIR``
    desktop directories (``DATAROOTDIR/desktop-directories``)
    [``XDG_DIRECTORY_INSTALL_DIR``]
``MIMEDIR``
    mime description files (``DATAROOTDIR/mime/packages``)
    [``XDG_MIME_INSTALL_DIR``]
``METAINFODIR``
    AppStream component metadata files (``DATAROOTDIR/metainfo``)
``QTQCHDIR``
    documentation bundles in QCH format for Qt-extending libraries (``DATAROOTDIR/doc/qch`` or qmake-qt5's ``QT_INSTALL_DOCS``) Since 5.36.0.
``QCHDIR``
    documentation bundles in QCH format (``DATAROOTDIR/doc/qch``) Since 5.36.0.
``MANDIR``
    man documentation (``DATAROOTDIR/man``) [``MAN_INSTALL_DIR``]
``INFODIR``
    info documentation (``DATAROOTDIR/info``)
``DBUSDIR``
    D-Bus (``DATAROOTDIR/dbus-1``)
``DBUSINTERFACEDIR``
    D-Bus interfaces (``DBUSDIR/interfaces``)
    [``DBUS_INTERFACES_INSTALL_DIR``]
``DBUSSERVICEDIR``
    D-Bus session services (``DBUSDIR/services``)
    [``DBUS_SERVICES_INSTALL_DIR``]
``DBUSSYSTEMSERVICEDIR``
    D-Bus system services (``DBUSDIR/system-services``)
    [``DBUS_SYSTEM_SERVICES_INSTALL_DIR``]
``SYSCONFDIR``
    read-only single-machine data
    (``etc``, or ``/etc`` if ``CMAKE_INSTALL_PREFIX`` is ``/usr``)
    [``SYSCONF_INSTALL_DIR``]
``CONFDIR``
    application configuration files (``SYSCONFDIR/xdg``)
    [``CONFIG_INSTALL_DIR``]
``AUTOSTARTDIR``
    autostart files (``CONFDIR/autostart``) [``AUTOSTART_INSTALL_DIR``]
``LOGGINGCATEGORIESDIR``
    Qt logging categories files directory (``DATAROOTDIR/qlogging-categories5``) Since 5.59.0
``JARDIR``
    Java AAR/JAR files for Android. Since 5.62.0
``SYSTEMDUNITDIR``
    Systemd Units (``lib/systemd``)
    [``SYSTEMD_UNIT_INSTALL_DIR``]. Since 5.65
``SYSTEMDUSERUNITDIR``
    Systemd User Units (``lib/systemd/user``)
    [``SYSTEMD_USER_UNIT_INSTALL_DIR``]. Since 5.65
``ZSHAUTOCOMPLETEDIR``
    Zsh functions and autocompletion definitions (``zsh/site-functions``)
    Since 5.101

If ``KDE_INSTALL_USE_QT_SYS_PATHS`` is set to ``TRUE`` before including this
module, the default values for some variables are instead queried from
Qt5's qmake (where mentioned in the parentheses above).
If not set, it will default to ``TRUE`` if Qt5's qmake is found and
it's ``QT_INSTALL_PREFIX`` is the same as ``CMAKE_INSTALL_PREFIX``,
otherwise default to ``FALSE``.
This variable should NOT be set from within CMakeLists.txt files, instead
is intended to be set manually when configuring a project which uses
KDEInstallDirs (e.g. by packagers).

If ``KDE_INSTALL_DIRS_NO_DEPRECATED`` is set to ``TRUE`` before including this
module, the deprecated variables (listed in the square brackets above) are
not defined.

In addition, for each ``KDE_INSTALL_*`` variable, an equivalent
``CMAKE_INSTALL_*`` variable is defined. If
``KDE_INSTALL_DIRS_NO_DEPRECATED`` is set to ``TRUE``, only those variables
defined by the ``GNUInstallDirs`` module (shipped with CMake) are defined.
If ``KDE_INSTALL_DIRS_NO_CMAKE_VARIABLES`` is set to ``TRUE``, no variables with
a ``CMAKE_`` prefix will be defined by this module (other than
``CMAKE_INSTALL_DEFAULT_COMPONENT_NAME`` - see below).

The ``KDE_INSTALL_<dir>`` variables (or their ``CMAKE_INSTALL_<dir>`` or
deprecated counterparts) may be passed to the ``DESTINATION`` options of
``install()`` commands for the corresponding file type.  They are set in the
CMake cache, and so the defaults above can be overridden by users.

Note that the ``KDE_INSTALL_<dir>``, ``CMAKE_INSTALL_<dir>`` or deprecated
form of the variable can be changed using CMake command line variable
definitions; in either case, all forms of the variable will be affected. The
effect of passing multiple forms of the same variable on the command line
(such as ``KDE_INSTALL_BINDIR`` and ``CMAKE_INSTALL_BINDIR`` is undefined.

The variable ``KDE_INSTALL_TARGETS_DEFAULT_ARGS`` is also defined (along with
the deprecated form ``INSTALL_TARGETS_DEFAULT_ARGS``).  This should be used
when libraries or user-executable applications are installed, in the
following manner:

.. code-block:: cmake

  install(TARGETS mylib myapp ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

It MUST NOT be used for installing plugins, system admin executables or
executables only intended for use internally by other code.  Those should use
``KDE_INSTALL_PLUGINDIR``, ``KDE_INSTALL_SBINDIR`` or
``KDE_INSTALL_LIBEXECDIR`` respectively.

Additionally, ``CMAKE_INSTALL_DEFAULT_COMPONENT_NAME`` will be set to
``${PROJECT_NAME}`` to provide a sensible default for this CMake option.

Note that mixing absolute and relative paths, particularly for ``BINDIR``,
``LIBDIR`` and ``INCLUDEDIR``, can cause issues with exported targets. Given
that the default values for these are relative paths, relative paths should
be used on the command line when possible (eg: use
``-DKDE_INSTALL_LIBDIR=lib64`` instead of
``-DKDE_INSTALL_LIBDIR=/usr/lib/lib64`` to override the library directory).

Since 5.82.0, prior to that available as :kde-module:`KDEInstallDirs`.

NB: The variables starting ``KDE_INSTALL_`` are available since 1.6.0,
unless otherwise noted with the variable.

The ``KDE_INSTALL_PREFIX_SCRIPT`` option will install a ${CMAKE_INSTALL_PREFIX}/prefix.sh
file that allows to easily incorporate the necessary environment variables
for the prefix into a process.

#]=======================================================================]

include(${CMAKE_CURRENT_LIST_DIR}/KDEInstallDirsCommon.cmake)

if(WIN32)
    _define_non_cache(LIBEXECDIR_KF5 "${CMAKE_INSTALL_LIBEXECDIR}")
else()
    _define_non_cache(LIBEXECDIR_KF5 "${CMAKE_INSTALL_LIBEXECDIR}/kf5")
endif()
if(NOT KDE_INSTALL_DIRS_NO_DEPRECATED)
    set(KF5_LIBEXEC_INSTALL_DIR "${CMAKE_INSTALL_LIBEXECDIR_KF5}")
endif()

include("${ECM_MODULE_DIR}/ECMQueryQt.cmake")

set(_default_KDE_INSTALL_USE_QT_SYS_PATHS OFF)
if(NOT DEFINED KDE_INSTALL_USE_QT_SYS_PATHS)
    ecm_query_qt(qt_install_prefix_dir QT_INSTALL_PREFIX TRY)
    if(qt_install_prefix_dir STREQUAL "${CMAKE_INSTALL_PREFIX}")
        message(STATUS "Installing in the same prefix as Qt, adopting their path scheme.")
        set(_default_KDE_INSTALL_USE_QT_SYS_PATHS ON)
    endif()
endif()

option (KDE_INSTALL_USE_QT_SYS_PATHS "Install mkspecs files, QCH files for Qt-based libs, Plugins and Imports to the Qt 5 install dir" "${_default_KDE_INSTALL_USE_QT_SYS_PATHS}")
if(KDE_INSTALL_USE_QT_SYS_PATHS)
    # Qt-specific vars
    ecm_query_qt(qt_install_prefix_dir QT_INSTALL_PREFIX TRY)
    ecm_query_qt(qt_plugins_dir QT_INSTALL_PLUGINS)

    if(qt_install_prefix_dir STREQUAL "${CMAKE_INSTALL_PREFIX}")
        file(RELATIVE_PATH qt_plugins_dir ${qt_install_prefix_dir} ${qt_plugins_dir})
    endif()
    _define_absolute(QTPLUGINDIR ${qt_plugins_dir}
        "Qt plugins"
         QT_PLUGIN_INSTALL_DIR)

    ecm_query_qt(qt_imports_dir QT_INSTALL_IMPORTS)

    if(qt_install_prefix_dir STREQUAL "${CMAKE_INSTALL_PREFIX}")
        file(RELATIVE_PATH qt_imports_dir ${qt_install_prefix_dir} ${qt_imports_dir})
    endif()
    _define_absolute(QTQUICKIMPORTSDIR ${qt_imports_dir}
        "QtQuick1 imports"
        IMPORTS_INSTALL_DIR)

    ecm_query_qt(qt_qml_dir QT_INSTALL_QML)

    if(qt_install_prefix_dir STREQUAL "${CMAKE_INSTALL_PREFIX}")
        file(RELATIVE_PATH qt_qml_dir ${qt_install_prefix_dir} ${qt_qml_dir})
    endif()
    _define_absolute(QMLDIR ${qt_qml_dir}
        "QtQuick2 imports"
        QML_INSTALL_DIR)
else()
    set(_pluginsDirParent LIBDIR)
    if (ANDROID)
        set(_pluginsDirParent)
        #androiddeployqt wants plugins right in the prefix
    endif()
    _define_relative(QTPLUGINDIR "${_pluginsDirParent}" "plugins"
        "Qt plugins"
        QT_PLUGIN_INSTALL_DIR)

    _define_relative(QTQUICKIMPORTSDIR QTPLUGINDIR "imports"
        "QtQuick1 imports"
        IMPORTS_INSTALL_DIR)

    _define_relative(QMLDIR LIBDIR "qml"
        "QtQuick2 imports"
        QML_INSTALL_DIR)
endif()

_define_relative(PLUGINDIR QTPLUGINDIR ""
    "Plugins"
    PLUGIN_INSTALL_DIR)

_define_non_cache(INCLUDEDIR_KF5 "${CMAKE_INSTALL_INCLUDEDIR}/KF5")
if(NOT KDE_INSTALL_DIRS_NO_DEPRECATED)
    set(KF5_INCLUDE_INSTALL_DIR "${CMAKE_INSTALL_INCLUDEDIR_KF5}")
endif()


_define_non_cache(DATADIR_KF5 "${CMAKE_INSTALL_DATADIR}/kf5")
if(NOT KDE_INSTALL_DIRS_NO_DEPRECATED)
    set(KF5_DATA_INSTALL_DIR "${CMAKE_INSTALL_DATADIR_KF5}")
endif()

# Qt-specific data vars
if(KDE_INSTALL_USE_QT_SYS_PATHS)
    ecm_query_qt(qt_docs_dir QT_INSTALL_DOCS)

    _define_absolute(QTQCHDIR ${qt_docs_dir}
        "documentation bundles in QCH format for Qt-extending libraries")
else()
    _define_relative(QTQCHDIR DATAROOTDIR "doc/qch"
        "documentation bundles in QCH format for Qt-extending libraries")
endif()


# KDE Framework-specific things
_define_relative(KSERVICES5DIR DATAROOTDIR "kservices5"
    "services for KDE Frameworks 5"
    SERVICES_INSTALL_DIR KSERVICESDIR)
_define_relative(KSERVICETYPES5DIR DATAROOTDIR "kservicetypes5"
    "service types for KDE Frameworks 5"
    SERVICETYPES_INSTALL_DIR KSERVICETYPESDIR)
_define_relative(KNOTIFY5RCDIR DATAROOTDIR "knotifications5"
    "knotify description files"
    KNOTIFYRC_INSTALL_DIR KNOTIFYRCDIR)
_define_relative(KXMLGUI5DIR DATAROOTDIR "kxmlgui5"
    "kxmlgui .rc files"
    KXMLGUI_INSTALL_DIR KXMLGUIDIR)
_define_relative(LOGGINGCATEGORIESDIR DATAROOTDIR "qlogging-categories5"
    "Qt Logging categories files")


# For more documentation see above.
# Later on it will be possible to extend this for installing OSX frameworks
# The COMPONENT Devel argument has the effect that static libraries belong to the
# "Devel" install component. If we use this also for all install() commands
# for header files, it will be possible to install
#   -everything: make install OR cmake -P cmake_install.cmake
#   -only the development files: cmake -DCOMPONENT=Devel -P cmake_install.cmake
#   -everything except the development files: cmake -DCOMPONENT=Unspecified -P cmake_install.cmake
# This can then also be used for packaging with cpack.
set(KDE_INSTALL_TARGETS_DEFAULT_ARGS  RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
                                      LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
                                      ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}" COMPONENT Devel
                                      INCLUDES DESTINATION "${KDE_INSTALL_INCLUDEDIR}"
)
if(APPLE)
    set(KDE_INSTALL_TARGETS_DEFAULT_ARGS  ${KDE_INSTALL_TARGETS_DEFAULT_ARGS}
                                          BUNDLE DESTINATION "${BUNDLE_INSTALL_DIR}" )
endif()

set(KF5_INSTALL_TARGETS_DEFAULT_ARGS  RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
                                      LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
                                      ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}" COMPONENT Devel
                                      INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR_KF5}"
)

# on macOS support an extra install directory for application bundles
if(APPLE)
    set(KF5_INSTALL_TARGETS_DEFAULT_ARGS  ${KF5_INSTALL_TARGETS_DEFAULT_ARGS}
                                          BUNDLE DESTINATION "${BUNDLE_INSTALL_DIR}" )
endif()

if(NOT KDE_INSTALL_DIRS_NO_DEPRECATED)
    set(INSTALL_TARGETS_DEFAULT_ARGS ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
endif()

# version-less forward compatibility variants, see also KDEInstallDirs6.cmake
set(KF_INSTALL_TARGETS_DEFAULT_ARGS ${KF5_INSTALL_TARGETS_DEFAULT_ARGS})
_define_non_cache(INCLUDEDIR_KF "${KDE_INSTALL_INCLUDEDIR_KF5}")
_define_non_cache(DATADIR_KF "${KDE_INSTALL_DATADIR_KF5}")
_define_non_cache(LIBEXECDIR_KF "${KDE_INSTALL_LIBEXECDIR_KF5}")

include(${CMAKE_CURRENT_LIST_DIR}/KDESetupPrefixScript.cmake)
