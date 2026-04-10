# SPDX-FileCopyrightText: 2014-2015 Alex Merry <alex.merry@kde.org>
# SPDX-FileCopyrightText: 2013 Stephen Kelly <steveire@gmail.com>
# SPDX-FileCopyrightText: 2012 David Faure <faure@kde.org>
# SPDX-FileCopyrightText: 2007 Matthias Kretz <kretz@kde.org>
# SPDX-FileCopyrightText: 2006-2007 Laurent Montel <montel@kde.org>
# SPDX-FileCopyrightText: 2006-2013 Alex Neundorf <neundorf@kde.org>
# SPDX-FileCopyrightText: 2021 Volker Krause <vkrause@kde.org>
# SPDX-FileCopyrightText: 2021 Ahmad Samir <a.samir78@gmail.com>
#
# SPDX-License-Identifier: BSD-3-Clause

#[=======================================================================[.rst:
KDEInstallDirs6
---------------

Define KDE standard installation directories for Qt6/KF6 based software.

Note that none of the variables defined by this module provide any
information about the location of already-installed KDE software.

Also sets ``CMAKE_INSTALL_PREFIX`` to the installation prefix of ECM,
unless that variable has been already explicitly set by something else.

Inclusion of this module defines the following variables:

``KDE_INSTALL_<dir>``
    destination for files of a given type
``KDE_INSTALL_FULL_<dir>``
    corresponding absolute path

where ``<dir>`` is one of (default values in parentheses):

``BUNDLEDIR``
    application bundles (``/Applications/KDE``)
``EXECROOTDIR``
    executables and libraries (``<empty>``)
``BINDIR``
    user executables (``EXECROOTDIR/bin``)
``SBINDIR``
    system admin executables (``EXECROOTDIR/sbin``)
``LIBDIR``
    object code libraries (``EXECROOTDIR/lib``, ``EXECROOTDIR/lib64`` or
    ``EXECROOTDIR/lib/<multiarch-tuple`` on Debian)
``LIBEXECDIR``
    executables for internal use by programs and libraries (``BINDIR`` on
    Windows, ``LIBDIR/libexec`` otherwise)
``CMAKEPACKAGEDIR``
    CMake packages, including config files (``LIBDIR/cmake``)
``QTPLUGINDIR``
    Qt plugins (``LIBDIR/plugins`` or qtpaths's ``QT_INSTALL_PLUGINS``)
``PLUGINDIR``
    Plugins (``QTPLUGINDIR``) [``PLUGIN_INSTALL_DIR``]
``QMLDIR``
    QtQuick2 imports (``LIBDIR/qml`` or qtpaths's ``QT_INSTALL_QML``)
``INCLUDEDIR``
    C and C++ header files (``include``)
``LOCALSTATEDIR``
    modifiable single-machine data (``var``)
``SHAREDSTATEDIR``
    modifiable architecture-independent data (``com``)
``DATAROOTDIR``
    read-only architecture-independent data root (``BINDIR/data`` on
    Windows, ``share`` otherwise)
``DATADIR``
    read-only architecture-independent data (``DATAROOTDIR``)
``DOCBUNDLEDIR``
    documentation bundles generated using kdoctools
    (``DATAROOTDIR/doc/HTML``)
``KCFGDIR``
    kconfig description files (``DATAROOTDIR/config.kcfg``)
``KCONFUPDATEDIR``
    kconf_update scripts (``DATAROOTDIR/kconf_update``)
``KXMLGUIDIR``
    kxmlgui .rc files (``DATAROOTDIR/kxmlgui5``)
``KAPPTEMPLATESDIR``
    KAppTemplate and KDevelop templates (``DATAROOTDIR/kdevappwizard/templates``)
``KFILETEMPLATESDIR``
    KDevelop file templates (``DATAROOTDIR/kdevfiletemplates/templates``)
``KNOTIFYRCDIR``
    knotify description files (``DATAROOTDIR/knotifications6``)
``ICONDIR``
    icons (``DATAROOTDIR/icons``)
``LOCALEDIR``
    locale-dependent data (``DATAROOTDIR/locale``)
``SOUNDDIR``
    sound files (``DATAROOTDIR/sounds``)
``TEMPLATEDIR``
    templates (``DATAROOTDIR/templates``)
``WALLPAPERDIR``
    desktop wallpaper images (``DATAROOTDIR/wallpapers``)
``APPDIR``
    application desktop files (``DATAROOTDIR/applications``)
``DESKTOPDIR``
    desktop directories (``DATAROOTDIR/desktop-directories``)
``MIMEDIR``
    mime description files (``DATAROOTDIR/mime/packages``)
``METAINFODIR``
    AppStream component metadata files (``DATAROOTDIR/metainfo``)
``QTQCHDIR``
    documentation bundles in QCH format for Qt-extending libraries (``DATAROOTDIR/doc/qch`` or qtpaths's ``QT_INSTALL_DOCS``)
``QCHDIR``
    documentation bundles in QCH format (``DATAROOTDIR/doc/qch``)
``MANDIR``
    man documentation (``DATAROOTDIR/man``)
``INFODIR``
    info documentation (``DATAROOTDIR/info``)
``DBUSDIR``
    D-Bus (``DATAROOTDIR/dbus-1``)
``DBUSINTERFACEDIR``
    D-Bus interfaces (``DBUSDIR/interfaces``)
``DBUSSERVICEDIR``
    D-Bus session services (``DBUSDIR/services``)
``DBUSSYSTEMSERVICEDIR``
    D-Bus system services (``DBUSDIR/system-services``)
``SYSCONFDIR``
    read-only single-machine data
    (``etc``, or ``/etc`` if ``CMAKE_INSTALL_PREFIX`` is ``/usr``)
``CONFDIR``
    application configuration files (``SYSCONFDIR/xdg``)
``AUTOSTARTDIR``
    autostart files (``CONFDIR/autostart``)
``LOGGINGCATEGORIESDIR``
    Qt logging categories files directory (``DATAROOTDIR/qlogging-categories6``)
``JARDIR``
    Java AAR/JAR files for Android.
``SYSTEMDUNITDIR``
    Systemd Units (``lib/systemd``)
``SYSTEMDUSERUNITDIR``
    Systemd User Units (``lib/systemd/user``)

If ``KDE_INSTALL_USE_QT_SYS_PATHS`` is set to ``TRUE`` before including this
module, the default values for some variables are instead queried from
Qt6's qmake (where mentioned in the parentheses above).
If not set, it will default to ``TRUE`` if Qt6's qmake is found and
it's ``QT_INSTALL_PREFIX`` is the same as ``CMAKE_INSTALL_PREFIX``,
otherwise default to ``FALSE``.
This variable should NOT be set from within CMakeLists.txt files, instead
is intended to be set manually when configuring a project which uses
KDEInstallDirs (e.g. by packagers).

In addition, for each ``KDE_INSTALL_*`` variable, an equivalent
``CMAKE_INSTALL_*`` variable is defined, if such a variable is also
defined by the ``GNUInstallDirs`` module (shipped with CMake).
If ``KDE_INSTALL_DIRS_NO_CMAKE_VARIABLES`` is set to ``TRUE``, no variables with
a ``CMAKE_`` prefix will be defined by this module (other than
``CMAKE_INSTALL_DEFAULT_COMPONENT_NAME`` - see below).

The ``KDE_INSTALL_<dir>`` variables may be passed to the ``DESTINATION`` options of
``install()`` commands for the corresponding file type.  They are set in the
CMake cache, and so the defaults above can be overridden by users.

Note that the ``KDE_INSTALL_<dir>`` or ``CMAKE_INSTALL_<dir>`` variables
can be changed using CMake command line variable definitions; in either case,
both forms of the variable will be affected. The effect of passing multiple
forms of the same variable on the command line
(such as ``KDE_INSTALL_BINDIR`` and ``CMAKE_INSTALL_BINDIR`` is undefined.

The variable ``KDE_INSTALL_TARGETS_DEFAULT_ARGS`` is also defined.
This should be used when libraries or user-executable applications are installed,
in the following manner:

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

The ``KDE_INSTALL_PREFIX_SCRIPT`` option will install a ${CMAKE_INSTALL_PREFIX}/prefix.sh
file that allows to easily incorporate the necessary environment variables
for the prefix into a process.
#]=======================================================================]

set(KDE_INSTALL_DIRS_NO_DEPRECATED TRUE)

include(${CMAKE_CURRENT_LIST_DIR}/KDEInstallDirsCommon.cmake)

if(WIN32)
    _define_non_cache(LIBEXECDIR_KF "${CMAKE_INSTALL_LIBEXECDIR}")
else()
    _define_non_cache(LIBEXECDIR_KF "${CMAKE_INSTALL_LIBEXECDIR}/kf6")
endif()

include(${ECM_MODULE_DIR}/ECMQueryQt.cmake)
ecm_query_qt(qt_install_prefix_dir QT_INSTALL_PREFIX)

set(_qt_prefix_is_cmake_install_prefix FALSE)
if(qt_install_prefix_dir STREQUAL "${CMAKE_INSTALL_PREFIX}")
    set(_qt_prefix_is_cmake_install_prefix TRUE)
endif()

set(_default_KDE_INSTALL_USE_QT_SYS_PATHS OFF)
if(NOT DEFINED KDE_INSTALL_USE_QT_SYS_PATHS)
    if(_qt_prefix_is_cmake_install_prefix)
       message(STATUS "Installing in the same prefix as Qt, adopting their path scheme.")
       set(_default_KDE_INSTALL_USE_QT_SYS_PATHS ON)
    endif()
endif()

option (KDE_INSTALL_USE_QT_SYS_PATHS
        "Install mkspecs files, QCH files for Qt-based libs, Plugins and Imports to the Qt 6 install dir"
        "${_default_KDE_INSTALL_USE_QT_SYS_PATHS}"
)

if(KDE_INSTALL_USE_QT_SYS_PATHS)
   # Qt-specific vars
    ecm_query_qt(qt_plugins_dir QT_INSTALL_PLUGINS)
    if(_qt_prefix_is_cmake_install_prefix)
        file(RELATIVE_PATH qt_plugins_dir ${qt_install_prefix_dir} ${qt_plugins_dir})
    endif()
    _define_absolute(QTPLUGINDIR ${qt_plugins_dir} "Qt plugins")

    ecm_query_qt(qt_qml_dir QT_INSTALL_QML)
    if(_qt_prefix_is_cmake_install_prefix)
        file(RELATIVE_PATH qt_qml_dir ${qt_install_prefix_dir} ${qt_qml_dir})
    endif()
   _define_absolute(QMLDIR ${qt_qml_dir} "QtQuick2 imports")
else()
    set(_pluginsDirParent LIBDIR)
    if (ANDROID)
        set(_pluginsDirParent)
        #androiddeployqt wants plugins right in the prefix
    endif()
    _define_relative(QTPLUGINDIR "${_pluginsDirParent}" "plugins"
        "Qt plugins")

    _define_relative(QMLDIR LIBDIR "qml"
        "QtQuick2 imports")
endif()

_define_relative(PLUGINDIR QTPLUGINDIR ""
    "Plugins")

_define_non_cache(INCLUDEDIR_KF "${CMAKE_INSTALL_INCLUDEDIR}/KF6")

_define_non_cache(DATADIR_KF "${CMAKE_INSTALL_DATADIR}/kf6")

# Qt-specific data vars
if(KDE_INSTALL_USE_QT_SYS_PATHS)
    ecm_query_qt(qt_docs_dir QT_INSTALL_DOCS)

   _define_absolute(QTQCHDIR ${qt_docs_dir} "documentation bundles in QCH format for Qt-extending libraries")
else()
    _define_relative(QTQCHDIR DATAROOTDIR "doc/qch"
        "documentation bundles in QCH format for Qt-extending libraries")
endif()


# KDE Framework-specific things
_define_relative(KNOTIFYRCDIR DATAROOTDIR "knotifications6"
    "knotify description files")
# TODO MOVE TO KXMLGUI
_define_relative(KXMLGUIDIR DATAROOTDIR "kxmlgui5"
    "kxmlgui .rc files")
_define_relative(LOGGINGCATEGORIESDIR DATAROOTDIR "qlogging-categories6"
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
                                      ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
                                      OBJECTS DESTINATION "${CMAKE_INSTALL_LIBDIR}"
                                      COMPONENT Devel
)
if(APPLE)
    set(KDE_INSTALL_TARGETS_DEFAULT_ARGS  ${KDE_INSTALL_TARGETS_DEFAULT_ARGS}
                                          BUNDLE DESTINATION "${KDE_INSTALL_BUNDLEDIR}" )
endif()

set(KF_INSTALL_TARGETS_DEFAULT_ARGS RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
                                    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
                                    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
                                    OBJECTS DESTINATION "${CMAKE_INSTALL_LIBDIR}"
                                    COMPONENT Devel
)

# on macOS support an extra install directory for application bundles
if(APPLE)
    set(KF_INSTALL_TARGETS_DEFAULT_ARGS  ${KF_INSTALL_TARGETS_DEFAULT_ARGS}
                                          BUNDLE DESTINATION "${KDE_INSTALL_BUNDLEDIR}" )
endif()

include(${CMAKE_CURRENT_LIST_DIR}/KDESetupPrefixScript.cmake)
