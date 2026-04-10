# SPDX-FileCopyrightText: 2020 Kai Uwe Broulik <kde@broulik.de>
# SPDX-FileCopyrightText: 2020 Henri Chain <henri.chain@enioka.com>
#
# SPDX-License-Identifier: BSD-3-Clause

#[=======================================================================[.rst:
ECMGenerateDBusServiceFile
---------------------------

This module provides the ``ecm_generate_dbus_service_file`` function for
generating and installing a D-Bus service file.

::

  ecm_generate_dbus_service_file(
      NAME <service name>
      EXECUTABLE <executable>
      [SYSTEMD_SERVICE <systemd service>]
      DESTINATION <install_path>
      [RENAME <dbus service filename>] # Since 5.75
  )

A D-Bus service file ``<service name>.service`` will be generated and installed
in the relevant D-Bus config location. This filename can be customized with RENAME.

``<executable>`` must be an absolute path to the installed service executable. When using it with
:kde-module:`KDEInstallDirs` it needs to be the ``_FULL_`` variant of the path variable.

.. note::
  On Windows, the macro will only use the file name part of ``<executable>`` since D-Bus
  service executables are to be installed in the same directory as the D-Bus daemon.

Optionally, a ``<systemd service>`` can be specified to launch the corresponding
systemd service instead of the ``<executable>`` if the D-Bus daemon is started by systemd.

Example usage:

.. code-block:: cmake

  ecm_generate_dbus_service_file(
      NAME org.kde.kded5
      EXECUTABLE ${KDE_INSTALL_FULL_BINDIR}/kded5
      DESTINATION ${KDE_INSTALL_DBUSSERVICEDIR}
  )

.. code-block:: cmake

  ecm_generate_dbus_service_file(
      NAME org.kde.kded5
      EXECUTABLE ${KDE_INSTALL_FULL_BINDIR}/kded5
      SYSTEMD_SERVICE plasma-kded.service
      DESTINATION ${KDE_INSTALL_DBUSSERVICEDIR}
      RENAME org.kde.daemon.service
  )

Since 5.73.0.
#]=======================================================================]

function(ecm_generate_dbus_service_file)
    set(options)
    set(oneValueArgs EXECUTABLE NAME SYSTEMD_SERVICE DESTINATION RENAME)
    set(multiValueArgs)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(ARG_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unexpected arguments to ecm_generate_dbus_service_file: ${ARG_UNPARSED_ARGUMENTS}")
    endif()
    if(NOT ARG_NAME)
        message(FATAL_ERROR "Missing NAME argument for ecm_generate_dbus_service_file")
    endif()
    if(NOT ARG_EXECUTABLE)
        message(FATAL_ERROR "Missing EXECUTABLE argument for ecm_generate_dbus_service_file")
    endif()
    if(NOT ARG_DESTINATION)
        message(FATAL_ERROR "Missing DESTINATION argument for ecm_generate_dbus_service_file")
    endif()

    if(WIN32)
        get_filename_component(_exec "${ARG_EXECUTABLE}" NAME)
    else()
        if (NOT IS_ABSOLUTE ${ARG_EXECUTABLE})
            message(FATAL_ERROR "EXECUTABLE must be an absolute path in ecm_generate_dbus_service_file")
        else()
            set(_exec ${ARG_EXECUTABLE})
        endif()
    endif()

    set(_service_file ${CMAKE_CURRENT_BINARY_DIR}/${ARG_NAME}.service)

    file(WRITE ${_service_file}
    "[D-BUS Service]
Name=${ARG_NAME}
Exec=${_exec}
")

    if (ARG_SYSTEMD_SERVICE)
        file(APPEND ${_service_file} "SystemdService=${ARG_SYSTEMD_SERVICE}\n")
    endif()

    if (ARG_RENAME)
        install(FILES ${_service_file} DESTINATION ${ARG_DESTINATION} RENAME ${ARG_RENAME})
    else()
        install(FILES ${_service_file} DESTINATION ${ARG_DESTINATION})
    endif()
endfunction()
