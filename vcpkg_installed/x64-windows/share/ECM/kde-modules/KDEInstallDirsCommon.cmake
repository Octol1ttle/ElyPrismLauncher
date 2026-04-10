# SPDX-FileCopyrightText: 2014-2015 Alex Merry <alex.merry@kde.org>
# SPDX-FileCopyrightText: 2013 Stephen Kelly <steveire@gmail.com>
# SPDX-FileCopyrightText: 2012 David Faure <faure@kde.org>
# SPDX-FileCopyrightText: 2007 Matthias Kretz <kretz@kde.org>
# SPDX-FileCopyrightText: 2006-2007 Laurent Montel <montel@kde.org>
# SPDX-FileCopyrightText: 2006-2013 Alex Neundorf <neundorf@kde.org>
#
# SPDX-License-Identifier: BSD-3-Clause
#
# Common implementation details of KDEInstallDirsX.cmake, not public API.
#

# Figure out what the default install directory for libraries should be.
# This is based on the logic in GNUInstallDirs, but simplified (the
# GNUInstallDirs code deals with re-configuring, but that is dealt with
# by the _define_* macros in this module).
set(_LIBDIR_DEFAULT "lib")
# Override this default 'lib' with 'lib64' if:
#  - we are on a Linux, kFreeBSD or Hurd system but NOT cross-compiling
#  - we are NOT on debian
#  - we are NOT on flatpak
#  - we are NOT on NixOS
#  - we are on a 64 bits system
# reason is: amd64 ABI: https://gitlab.com/x86-psABIs/x86-64-ABI/-/jobs/artifacts/master/raw/x86-64-ABI/abi.pdf?job=build
# For Debian with multiarch, use 'lib/${CMAKE_LIBRARY_ARCHITECTURE}' if
# CMAKE_LIBRARY_ARCHITECTURE is set (which contains e.g. "i386-linux-gnu"
# See https://wiki.debian.org/Multiarch
if((CMAKE_SYSTEM_NAME MATCHES "Linux|kFreeBSD" OR CMAKE_SYSTEM_NAME STREQUAL "GNU")
   AND NOT CMAKE_CROSSCOMPILING
   AND NOT EXISTS "/etc/arch-release"
   AND NOT DEFINED ENV{FLATPAK_ID}
   AND NOT EXISTS "/etc/NIXOS")
  if (EXISTS "/etc/debian_version") # is this a debian system ?
    if(CMAKE_LIBRARY_ARCHITECTURE)
      set(_LIBDIR_DEFAULT "lib/${CMAKE_LIBRARY_ARCHITECTURE}")
    endif()
  else() # not debian, rely on CMAKE_SIZEOF_VOID_P:
    if(NOT DEFINED CMAKE_SIZEOF_VOID_P)
      message(AUTHOR_WARNING
        "Unable to determine default LIB_INSTALL_LIBDIR directory because no target architecture is known. "
        "Please enable at least one language before including KDEInstallDirs.")
    else()
      if("${CMAKE_SIZEOF_VOID_P}" EQUAL "8")
        set(_LIBDIR_DEFAULT "lib64")
      endif()
    endif()
  endif()
endif()

set(_gnu_install_dirs_vars
    BINDIR
    SBINDIR
    LIBEXECDIR
    SYSCONFDIR
    SHAREDSTATEDIR
    LOCALSTATEDIR
    LIBDIR
    INCLUDEDIR
    OLDINCLUDEDIR
    DATAROOTDIR
    DATADIR
    INFODIR
    LOCALEDIR
    MANDIR
    DOCDIR)

# Macro for variables that are relative to another variable. We store an empty
# value in the cache (for documentation/GUI cache editor purposes), and store
# the default value in a local variable. If the cache variable is ever set to
# something non-empty, the local variable will no longer be set. However, if
# the cache variable remains (or is set to be) empty, the value will be
# relative to that of the parent variable.
#
# varname:   the variable name suffix (eg: BINDIR for KDE_INSTALL_BINDIR)
# parent:    the variable suffix of the variable this is relative to
#            (eg: DATAROOTDIR for KDE_INSTALL_DATAROOTDIR)
# subdir:    the path of the default value of KDE_INSTALL_${varname}
#            relative to KDE_INSTALL_${parent}: no leading /
# docstring: documentation about the variable (not including the default value)
# oldstylename (optional): the old-style name of the variable
# alias (optional): alias for the variable (e.g. without '5' in the name)
macro(_define_relative varname parent subdir docstring)
    set(_oldstylename)
    if(NOT KDE_INSTALL_DIRS_NO_DEPRECATED AND ${ARGC} GREATER 4)
        set(_oldstylename "${ARGV4}")
    endif()
    set(_aliasname)
    if(${ARGC} GREATER 5)
        set(_aliasname "${ARGV5}")
    endif()
    set(_cmakename)
    if(NOT KDE_INSTALL_DIRS_NO_CMAKE_VARIABLES)
        list(FIND _gnu_install_dirs_vars "${varname}" _list_offset)
        set(_cmakename_is_deprecated FALSE)
        if(NOT KDE_INSTALL_DIRS_NO_DEPRECATED OR NOT _list_offset EQUAL -1)
            set(_cmakename CMAKE_INSTALL_${varname})
            if(_list_offset EQUAL -1)
                set(_cmakename_is_deprecated TRUE)
            endif()
        endif()
    endif()

    # Surprisingly complex logic to deal with joining paths.
    # Note that we cannot use arg vars directly in if() because macro args are
    # not proper variables.
    set(_parent "${parent}")
    set(_subdir "${subdir}")
    if(_parent AND _subdir)
        set(_docpath "${_parent}/${_subdir}")
        if(KDE_INSTALL_${_parent})
            set(_realpath "${KDE_INSTALL_${_parent}}/${_subdir}")
        else()
            set(_realpath "${_subdir}")
        endif()
    elseif(_parent)
        set(_docpath "${_parent}")
        set(_realpath "${KDE_INSTALL_${_parent}}")
    else()
        set(_docpath "${_subdir}")
        set(_realpath "${_subdir}")
    endif()

    if(KDE_INSTALL_${varname})
        # make sure the cache documentation is set correctly
        get_property(_iscached CACHE KDE_INSTALL_${varname} PROPERTY VALUE SET)
        if (_iscached)
            # make sure the docs are still set if it was passed on the command line
            set_property(CACHE KDE_INSTALL_${varname}
                PROPERTY HELPSTRING "${docstring} (${_docpath})")
            # make sure the type is correct if it was passed on the command line
            set_property(CACHE KDE_INSTALL_${varname}
                PROPERTY TYPE PATH)
        endif()
    elseif(${_oldstylename})
       message(DEPRECATION "${_oldstylename} is deprecated, use KDE_INSTALL_${varname} instead.")
        # The old name was given (probably on the command line): move
        # it to the new name
        set(KDE_INSTALL_${varname} "${${_oldstylename}}"
            CACHE PATH
                  "${docstring} (${_docpath})"
                  FORCE)
    elseif(${_aliasname})
        # The alias variable was given (probably on the command line): move
        # it to the new name
        set(KDE_INSTALL_${varname} "${${_aliasname}}"
            CACHE PATH
                  "${docstring} (${_docpath})"
                  FORCE)
    elseif(${_cmakename})
        if(_cmakename_is_deprecated)
            message(DEPRECATION "${_cmakename} is deprecated, use KDE_INSTALL_${varname} instead.")
        endif()
        # The CMAKE_ name was given (probably on the command line): move
        # it to the new name
        set(KDE_INSTALL_${varname} "${${_cmakename}}"
            CACHE PATH
                  "${docstring} (${_docpath})"
                  FORCE)
    else()
        # insert an empty value into the cache, indicating the default
        # should be used (including compatibility vars above)
        set(KDE_INSTALL_${varname} ""
            CACHE PATH "${docstring} (${_docpath})")
        set(KDE_INSTALL_${varname} "${_realpath}")
    endif()

    mark_as_advanced(KDE_INSTALL_${varname})

    if(NOT IS_ABSOLUTE ${KDE_INSTALL_${varname}})
        set(KDE_INSTALL_FULL_${varname}
            "${CMAKE_INSTALL_PREFIX}/${KDE_INSTALL_${varname}}")
    else()
        set(KDE_INSTALL_FULL_${varname} "${KDE_INSTALL_${varname}}")
    endif()

    # Override compatibility vars at runtime, even though we don't touch
    # them in the cache; this way, we keep the variables in sync where
    # KDEInstallDirs is included, but don't interfere with, say,
    # GNUInstallDirs in a parallel part of the CMake tree.
    if(_cmakename)
        set(${_cmakename} "${KDE_INSTALL_${varname}}")
        set(CMAKE_INSTALL_FULL_${varname} "${KDE_INSTALL_FULL_${varname}}")
    endif()

    if(_oldstylename)
        set(${_oldstylename} "${KDE_INSTALL_${varname}}")
    endif()
    if (_aliasname)
        set(KDE_INSTALL_${_aliasname} "${KDE_INSTALL_${varname}}")
        set(KDE_INSTALL_FULL_${_aliasname} "${KDE_INSTALL_FULL_${varname}}")
    endif()
endmacro()

# varname:   the variable name suffix (eg: BINDIR for KDE_INSTALL_BINDIR)
# dir:       the relative path of the default value of KDE_INSTALL_${varname}
#            relative to CMAKE_INSTALL_PREFIX: no leading /
# docstring: documentation about the variable (not including the default value)
# oldstylename (optional): the old-style name of the variable
macro(_define_absolute varname dir docstring)
    _define_relative("${varname}" "" "${dir}" "${docstring}" ${ARGN})
endmacro()

macro(_define_non_cache varname value)
    set(KDE_INSTALL_${varname} "${value}")
    if(NOT IS_ABSOLUTE ${KDE_INSTALL_${varname}})
        set(KDE_INSTALL_FULL_${varname}
            "${CMAKE_INSTALL_PREFIX}/${KDE_INSTALL_${varname}}")
    else()
        set(KDE_INSTALL_FULL_${varname} "${KDE_INSTALL_${varname}}")
    endif()

    if(NOT KDE_INSTALL_DIRS_NO_CMAKE_VARIABLES)
        list(FIND _gnu_install_dirs_vars "${varname}" _list_offset)
        if(NOT KDE_INSTALL_DIRS_NO_DEPRECATED OR NOT _list_offset EQUAL -1)
            set(CMAKE_INSTALL_${varname} "${KDE_INSTALL_${varname}}")
            set(CMAKE_INSTALL_FULL_${varname} "${KDE_INSTALL_FULL_${varname}}")
        endif()
    endif()
endmacro()

if(APPLE)
    _define_absolute(BUNDLEDIR "/Applications/KDE"
        "application bundles"
        BUNDLE_INSTALL_DIR)
endif()

# Only supported since cmake 3.7
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX "${ECM_PREFIX}" CACHE PATH "Install path prefix" FORCE)
endif()

_define_absolute(EXECROOTDIR ""
    "executables and libraries"
    EXEC_INSTALL_PREFIX)

_define_relative(BINDIR EXECROOTDIR "bin"
    "user executables"
    BIN_INSTALL_DIR)
_define_relative(SBINDIR EXECROOTDIR "sbin"
    "system admin executables"
    SBIN_INSTALL_DIR)
_define_relative(LIBDIR EXECROOTDIR "${_LIBDIR_DEFAULT}"
    "object code libraries"
    LIB_INSTALL_DIR)

if(WIN32)
    _define_relative(LIBEXECDIR BINDIR ""
        "executables for internal use by programs and libraries"
        LIBEXEC_INSTALL_DIR)
else()
    _define_relative(LIBEXECDIR LIBDIR "libexec"
        "executables for internal use by programs and libraries"
        LIBEXEC_INSTALL_DIR)
endif()

_define_relative(CMAKEPACKAGEDIR LIBDIR "cmake"
    "CMake packages, including config files"
    CMAKECONFIG_INSTALL_PREFIX)

_define_absolute(INCLUDEDIR "include"
    "C and C++ header files"
    INCLUDE_INSTALL_DIR)

_define_absolute(LOCALSTATEDIR "var"
    "modifiable single-machine data")

_define_absolute(SHAREDSTATEDIR "com"
    "modifiable architecture-independent data")

if (WIN32)
    _define_relative(DATAROOTDIR BINDIR "data"
        "read-only architecture-independent data root"
        SHARE_INSTALL_PREFIX)
else()
    _define_absolute(DATAROOTDIR "share"
        "read-only architecture-independent data root"
        SHARE_INSTALL_PREFIX)
endif()

_define_relative(DATADIR DATAROOTDIR ""
    "read-only architecture-independent data"
    DATA_INSTALL_DIR)

# KDE Framework-specific things
_define_relative(DOCBUNDLEDIR DATAROOTDIR "doc/HTML"
    "documentation bundles generated using kdoctools"
    HTML_INSTALL_DIR)
_define_relative(KCFGDIR DATAROOTDIR "config.kcfg"
    "kconfig description files"
    KCFG_INSTALL_DIR)
_define_relative(KCONFUPDATEDIR DATAROOTDIR "kconf_update"
    "kconf_update scripts"
    KCONF_UPDATE_INSTALL_DIR)
_define_relative(KAPPTEMPLATESDIR DATAROOTDIR "kdevappwizard/templates"
    "KAppTemplate and KDevelop templates"
    KDE_INSTALL_KTEMPLATESDIR
    )
_define_relative(KFILETEMPLATESDIR DATAROOTDIR "kdevfiletemplates/templates"
    "KDevelop file templates")
_define_relative(JARDIR "" "jar"
    "Java AAR/JAR files for Android")


# Cross-desktop or other system things
_define_relative(ICONDIR DATAROOTDIR "icons"
    "icons"
    ICON_INSTALL_DIR)
_define_relative(LOCALEDIR DATAROOTDIR "locale"
    "locale-dependent data"
    LOCALE_INSTALL_DIR)
_define_relative(SOUNDDIR DATAROOTDIR "sounds"
    "sound files"
    SOUND_INSTALL_DIR)
_define_relative(TEMPLATEDIR DATAROOTDIR "templates"
    "templates"
    TEMPLATES_INSTALL_DIR)
_define_relative(WALLPAPERDIR DATAROOTDIR "wallpapers"
    "desktop wallpaper images"
    WALLPAPER_INSTALL_DIR)
_define_relative(APPDIR DATAROOTDIR "applications"
    "application desktop files"
    XDG_APPS_INSTALL_DIR)
_define_relative(DESKTOPDIR DATAROOTDIR "desktop-directories"
    "desktop directories"
    XDG_DIRECTORY_INSTALL_DIR)
_define_relative(MIMEDIR DATAROOTDIR "mime/packages"
    "mime description files"
    XDG_MIME_INSTALL_DIR)
_define_relative(METAINFODIR DATAROOTDIR "metainfo"
    "AppStream component metadata")
_define_relative(QCHDIR DATAROOTDIR "doc/qch"
    "documentation bundles in QCH format")
_define_relative(MANDIR DATAROOTDIR "man"
    "man documentation"
    MAN_INSTALL_DIR)
_define_relative(INFODIR DATAROOTDIR "info"
    "info documentation")
_define_relative(DBUSDIR DATAROOTDIR "dbus-1"
    "D-Bus")
_define_relative(DBUSINTERFACEDIR DBUSDIR "interfaces"
    "D-Bus interfaces"
    DBUS_INTERFACES_INSTALL_DIR)
_define_relative(DBUSSERVICEDIR DBUSDIR "services"
    "D-Bus session services"
    DBUS_SERVICES_INSTALL_DIR)
_define_relative(DBUSSYSTEMSERVICEDIR DBUSDIR "system-services"
    "D-Bus system services"
    DBUS_SYSTEM_SERVICES_INSTALL_DIR)
_define_relative(SYSTEMDUNITDIR CMAKE_INSTALL_PREFIX "lib/systemd"
    "Systemd units"
    SYSTEMD_UNIT_INSTALL_DIR)
_define_relative(SYSTEMDUSERUNITDIR SYSTEMDUNITDIR "user"
    "Systemd user units"
    SYSTEMD_USER_UNIT_INSTALL_DIR)
_define_relative(ZSHAUTOCOMPLETEDIR DATAROOTDIR "zsh/site-functions"
    "Zsh functions and autocompletion definitions")

set(_default_sysconf_dir "etc")
if (CMAKE_INSTALL_PREFIX STREQUAL "/usr")
    set(_default_sysconf_dir "/etc")
endif()

_define_absolute(SYSCONFDIR "${_default_sysconf_dir}"
    "read-only single-machine data"
    SYSCONF_INSTALL_DIR)
_define_relative(CONFDIR SYSCONFDIR "xdg"
    "application configuration files"
    CONFIG_INSTALL_DIR)
_define_relative(AUTOSTARTDIR CONFDIR "autostart"
    "autostart files"
    AUTOSTART_INSTALL_DIR)


set(_mixed_core_path_styles FALSE)
if (IS_ABSOLUTE "${KDE_INSTALL_BINDIR}")
    if (NOT IS_ABSOLUTE "${KDE_INSTALL_LIBDIR}" OR NOT IS_ABSOLUTE "${KDE_INSTALL_INCLUDEDIR}")
        set(_mixed_core_path_styles )
    endif()
else()
    if (IS_ABSOLUTE "${KDE_INSTALL_LIBDIR}" OR IS_ABSOLUTE "${KDE_INSTALL_INCLUDEDIR}")
        set(_mixed_core_path_styles TRUE)
    endif()
endif()
if (_mixed_core_path_styles)
    message(WARNING "KDE_INSTALL_BINDIR, KDE_INSTALL_LIBDIR and KDE_INSTALL_INCLUDEDIR should either all be absolute paths or all be relative paths.")
endif()


# new in cmake 2.8.9: this is used for all installed files which do not have a component set
# so set the default component name to the name of the project, if a project name has been set:
if(NOT "${PROJECT_NAME}" STREQUAL "Project")
    set(CMAKE_INSTALL_DEFAULT_COMPONENT_NAME "${PROJECT_NAME}")
endif()
