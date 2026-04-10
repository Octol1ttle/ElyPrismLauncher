# SPDX-FileCopyrightText: 2021 Alexander Lohnau <alexander.lohnau@gmx.de>
#
# SPDX-License-Identifier: BSD-3-Clause

#[=======================================================================[.rst:
ECMDeprecationSettings
-----------------------

This module provides the ``ecm_set_disabled_deprecation_versions`` function setting the excluding
deprecated API for Qt and KF projects.

This method expects pairs of the identifier and deprecation version.
For the identifier ``QT`` this functions adds the definition ``QT_DISABLE_DEPRECATED_BEFORE`` with the given version in a hexadecimal format.
Otherwise the name for the definition is generated using ``${IDENTIFIER}_DISABLE_DEPRECATED_BEFORE_AND_AT``,
following the naming of the generated code in :module:`ECMGenerateExportHeader`.
The version for the definition can be overwritten, by passing definition name and the deprecation version
as a CMake definition. This allows one to exclude deprecations without having to edit the CMakeLists.txt file.

This module provides the following function:

::

  ecm_set_disabled_deprecation_versions(
      [DISABLE_NEWER_WARNINGS] # since 5.96
      [<identifier> <deprecation_version>]
      [<identifier2> <deprecation_version2>]
  )

``DISABLE_NEWER_WARNINGS`` disables additionally the compiler warnings for API deprecated in newer versions
of the same major version.


Example usage:

.. code-block:: cmake

  set(QT_MIN_VERSION "5.15.2")
  set(KF5_MIN_VERSION "5.90")

  ecm_set_disabled_deprecation_versions(
    QT ${QT_MIN_VERSION}
    KF ${KF5_MIN_VERSION}
    KCOREADDONS 5.89.0 # In case we depend on deprecated KCoreAddons API
  )



Since 5.91
#]=======================================================================]

function (ecm_set_disabled_deprecation_versions)
    cmake_parse_arguments(ARGS "SHOW_DEPRECATIONS;DISABLE_NEWER_WARNINGS" "" "" ${ARGN})

    # support legacy initial flag to opt-in to warnings
    if (ARGS_SHOW_DEPRECATIONS)
        message(DEPRECATION "SHOW_DEPRECATIONS is deprecated, since 5.96 warnings are enabled by default.")
    endif()
    if (ARGS_SHOW_DEPRECATIONS AND ARGS_DISABLE_NEWER_WARNINGS)
        message(FATAL_ERROR "SHOW_DEPRECATIONS && DISABLE_NEWER_WARNINGS cannot be set both.")
    endif()
    set(show_newer_warnings TRUE)
    if (ARGS_DISABLE_NEWER_WARNINGS)
        set(show_newer_warnings FALSE)
    endif()

    list(LENGTH ARGS_UNPARSED_ARGUMENTS PAIR_COUNT)
    math(EXPR is_even_number "${PAIR_COUNT} % 2")
    if (NOT is_even_number EQUAL 0)
        message(FATAL_ERROR "Expected number of arguments is an even number of identifiers and version")
    endif()
    math(EXPR number_pairs "(${PAIR_COUNT} / 2) - 1")
    foreach (it RANGE ${number_pairs})
        # get values
        math(EXPR current_index "${it} * 2")
        list(GET ARGS_UNPARSED_ARGUMENTS ${current_index} DEPRECATION_NAME)
        math(EXPR next_index "(${it} *2) + 1")
        list(GET ARGS_UNPARSED_ARGUMENTS ${next_index} DEPRECATION_VERSION)

        # get the string identifier for the target definition
        string(COMPARE EQUAL ${DEPRECATION_NAME} "QT" IS_QT_DEPRECATION)
        if (IS_QT_DEPRECATION)
            set(DEPRECATION_DEFINITION_NAME QT_DISABLE_DEPRECATED_BEFORE)
        else()
            set(DEPRECATION_DEFINITION_NAME ${DEPRECATION_NAME}_DISABLE_DEPRECATED_BEFORE_AND_AT)
        endif()
        # we want to be able to set this version without being forced to edit the CMakeLists.txt file
        if (${${DEPRECATION_DEFINITION_NAME}})
            set(DEPRECATION_VERSION "${${DEPRECATION_DEFINITION_NAME}}")
        endif()

        # make a sanity check to make sure we do not get malformed versions
        _ecm_version_triple_sanity_check("${DEPRECATION_VERSION}")

        # add the actual compile definition with the given hex value
        _ecm_geh_generate_hex_number_from_version(DEPRECATION_HEX_VERSION ${DEPRECATION_VERSION})
        add_definitions(-D${DEPRECATION_DEFINITION_NAME}=${DEPRECATION_HEX_VERSION})

        # Set the version for the deprecation warnings
        if (show_newer_warnings)
            string(REGEX MATCH "([0-9]+)\\." _ ${DEPRECATION_VERSION})
            if (NOT CMAKE_MATCH_1)
                message(FATAL_ERROR "Failed to get major version from ${DEPRECATION_VERSION}")
            endif()
            # Add 1 to the major version and store it as a hex value
            math(EXPR next_major_version "(${CMAKE_MATCH_1} + 1) * 65536 " OUTPUT_FORMAT HEXADECIMAL)
            add_definitions(-D${DEPRECATION_NAME}_DEPRECATED_WARNINGS_SINCE=${next_major_version})
        endif()

    endforeach()
endfunction()

# helper method
function(_ecm_geh_generate_hex_number_from_version _var_name _version)
    set(_hexnumber 0)

    string(REGEX MATCH "^([0-9]+)\\.([0-9]+)(\\.([0-9]+))?$" _ ${_version})

    # Set the patch version to 0, if none is specified by the regex.
    # This is the case for min. versions that don't specify the patch level, like in the snipped of the method docs.
    if (NOT CMAKE_MATCH_4)
        set(CMAKE_MATCH_4 "0")
    endif()

    math(EXPR _hexnumber "${CMAKE_MATCH_1}*65536 + ${CMAKE_MATCH_2}*256 + ${CMAKE_MATCH_4}" OUTPUT_FORMAT HEXADECIMAL)
    set(${_var_name} ${_hexnumber} PARENT_SCOPE)
endfunction()

function (_ecm_version_triple_sanity_check unchecked_version)
    # helper string
    set(_version_triple_regexp "^([0-9]+)\\.([0-9]+)(\\.([0-9]+))?$")
    # args sanity check
    if (NOT unchecked_version)
        message(FATAL_ERROR "No VERSION passed when calling ecm_set_deprecation_versions().")
    elseif(NOT unchecked_version MATCHES ${_version_triple_regexp})
        message(FATAL_ERROR "VERSION ${unchecked_version} expected to be in x.y.z format when calling ecm_set_deprecation_versions().")
    endif()
endfunction()
