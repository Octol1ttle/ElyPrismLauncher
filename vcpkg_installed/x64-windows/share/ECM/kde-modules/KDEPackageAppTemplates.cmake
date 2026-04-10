# SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
# SPDX-FileCopyrightText: 2014 Simon Wächter <waechter.simon@gmail.com>
# SPDX-FileCopyrightText: 2013 Nico Kruber <nico.kruber@gmail.com>
# SPDX-FileCopyrightText: 2012 Jeremy Whiting <jpwhiting@kde.org>
#
# SPDX-License-Identifier: BSD-3-Clause

#[=======================================================================[.rst:
KDEPackageAppTemplates
----------------------

Packages KApptemplate/KDevelop compatible application templates

This module provides a functionality to package in a tarball and
install project templates compatible with the format used by
KApptemplate and KDevelop. Useful for providing minimal examples
for the usage of the KDE Frameworks.

This module provides the following function:

::

  kde_package_app_templates(TEMPLATES <template> [<template> [...]]
                            INSTALL_DIR <directory>)

``INSTALL_DIR`` is the directory to install the template package to.
In most cases you will want to use the variable ``KDE_INSTALL_KAPPTEMPLATESDIR``
from :kde-module:`KDEInstallDirs`.

``TEMPLATES`` lists subdirectories containing template files;
each ``<template>`` directory will be packaged into a file named
``<template>.tar.bz2`` and installed to the appropriate location.

The template is a minimal source tree of an application as if it was
an application project by itself, with names (file names or text inside)
the text files replaced by the following placeholders when needed:

``%{PROJECTDIRNAME}``
    name of generated project base folder ex: ``%{APPNAMELC}`` for KAppTemplate
``%{APPNAME}``
    project name as entered by user ex: MyKApp
``%{APPNAMELC}``
    project name in lower case ex: mykapp
``%{APPNAMEUC}``
    project name in upper case ex: MYKAPP

``%{CPP_TEMPLATE}``
    license header for cpp file
``%{H_TEMPLATE}``
    license header for h file

``%{AUTHOR}``
    author name ex: George Ignacious
``%{EMAIL}``
    author email ex: foo@bar.org
``%{VERSION}``
    project version ex: 0.1

Deprecated:

``%{dest}``
   path of generated project base folder, used in .kdevtemplate with the ``ShowFilesAfterGeneration`` entry
   KDevelop >= 5.1.1 supports relative paths with that entry, making this placeholder obsolete

Multiple templates can be passed at once.

This function does nothing when cross-compiling.


Since 5.18
#]=======================================================================]

function(kde_package_app_templates)
    if (CMAKE_CROSSCOMPILING)
        return()
    endif()

    set(_oneValueArgs INSTALL_DIR)
    set(_multiValueArgs TEMPLATES)
    cmake_parse_arguments(ARG "" "${_oneValueArgs}" "${_multiValueArgs}" ${ARGN} )

    if(NOT ARG_TEMPLATES)
        message(FATAL_ERROR "No TEMPLATES argument given to kde_package_app_templates")
    endif()

    if(NOT ARG_INSTALL_DIR)
        message(FATAL_ERROR "No INSTALL_DIR argument given to kde_package_app_templates")
    endif()

    find_program(_tar_executable NAMES gtar tar)
    if(_tar_executable)
        # NOTE: we also pass `--sort=name` here to check if the tar exe supports that
        #       this feature was only added in gnu tar v1.28
        execute_process(
            COMMAND ${_tar_executable} --sort=name --version
            TIMEOUT 3
            RESULT_VARIABLE _tar_exit
            OUTPUT_VARIABLE _tar_version
            ERROR_VARIABLE _tar_stderr
        )
        if("${_tar_exit}" EQUAL 0 AND "${_tar_version}" MATCHES "GNU tar")
            set(GNU_TAR_FOUND ON)
        else()
            set(GNU_TAR_FOUND OFF)
        endif()
    else()
        set(GNU_TAR_FOUND OFF)
    endif()

    foreach(_templateName ${ARG_TEMPLATES})
        get_filename_component(_tmp_file ${_templateName} ABSOLUTE)
        get_filename_component(_baseName ${_tmp_file} NAME_WE)
        set(_template ${CMAKE_CURRENT_BINARY_DIR}/${_baseName}.tar.bz2)

        # also enlist directories as deps to catch file removals
        file(GLOB_RECURSE _subdirs_entries LIST_DIRECTORIES true CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${_templateName}/*")

        add_custom_target(${_baseName}_kapptemplate ALL DEPENDS ${_template})

        if(GNU_TAR_FOUND)
            # Honour SOURCE_DATE_EPOCH if set
            if(DEFINED ENV{SOURCE_DATE_EPOCH})
                set(TIMESTAMP $ENV{SOURCE_DATE_EPOCH})
            else()
                execute_process(
                    COMMAND "date" "+%s"
                    OUTPUT_VARIABLE TIMESTAMP
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
            endif()

            # Make tar archive reproducible, the arguments are only available with GNU tar
            add_custom_command(OUTPUT ${_template}
                COMMAND ${_tar_executable} ARGS
                   --exclude .kdev_ignore --exclude .svn
                   --sort=name
                   --mode=go=rX,u+rw,a-s
                   --numeric-owner --owner=0 --group=0
                   --mtime="@${TIMESTAMP}"
                   --pax-option=exthdr.name=%d/PaxHeaders/%f,delete=atime,delete=ctime
                    -c -j -f ${_template} .
                WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${_templateName}
                DEPENDS ${_subdirs_entries}
            )
        else()
            add_custom_command(OUTPUT ${_template}
                COMMAND ${CMAKE_COMMAND} -E tar "cvfj" ${_template} .
                WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${_templateName}
                DEPENDS ${_subdirs_entries}
            )
        endif()

        install(FILES ${_template} DESTINATION ${ARG_INSTALL_DIR})
        set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "${_template}")

    endforeach()
endfunction()
