# SPDX-FileCopyrightText: 2020 David Edmundson <davidedmundson@kde.org>
#
# SPDX-License-Identifier: BSD-3-Clause

#[=======================================================================[.rst:
ECMConfiguredInstall
--------------------

Takes a list of files, runs ``configure_file`` on each and installs the resultant configured files in the given location.

Any suffix of ".in" in the passed file names will be stripped from the file name at the installed location.

::

  ecm_install_configured_files(
      INPUT <file> [<file2> [...]]
      DESTINATION <INSTALL_DIRECTORY>
      [COPYONLY]
      [ESCAPE_QUOTES]
      [@ONLY]
      [COMPONENT <component>])

Example usage:

.. code-block:: cmake

  ecm_install_configured_files(INPUT foo.txt.in DESTINATION ${KDE_INSTALL_DATADIR} @ONLY)

This will install the file as foo.txt with any cmake variable replacements made into the data directory.

Since 5.73.0.
#]=======================================================================]

function(ecm_install_configured_files)
    set(options COPYONLY ESCAPE_QUOTES @ONLY)
    set(oneValueArgs DESTINATION COMPONENT)
    set(multiValueArgs INPUT)

    cmake_parse_arguments(ARGS "${options}" "${oneValueArgs}"
                          "${multiValueArgs}" ${ARGN})


    if(ARGS_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unknown arguments given to ecm_install_configured_file(): \"${ARGS_UNPARSED_ARGUMENTS}\"")
    endif()

    if (NOT ARGS_DESTINATION)
        message(FATAL_ERROR "missing DESTINATION argument to ECMConfiguredInstall")
    endif()

    foreach(_input ${ARGS_INPUT})
        # convert absolute paths
        get_filename_component(_name ${_input} NAME)

        string(REGEX REPLACE "\\.in$"  "" _name ${_name})

        set(_out_file ${CMAKE_CURRENT_BINARY_DIR}/${_name})

        set(_configure_args)
        if (ARGS_COPY_ONLY)
                list(APPEND _configure_args COPY_ONLY)
        endif()
        if (ARGS_ESCAPE_QUOTES)
                list(APPEND _configure_args  ESCAPE_QUOTES)
        endif()
        if (ARGS_@ONLY)
                list(APPEND _configure_args @ONLY)
        endif()

        configure_file(${_input} ${_out_file} ${_configure_args})

        if (DEFINED ARGS_COMPONENT)
            set(_component COMPONENT ${ARGS_COMPONENT})
        else()
            set(_component)
        endif()

        install(FILES ${_out_file} DESTINATION ${ARGS_DESTINATION} ${_component})
    endforeach()
endfunction()
