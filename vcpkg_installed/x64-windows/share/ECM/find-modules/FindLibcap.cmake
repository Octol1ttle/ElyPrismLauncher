# SPDX-FileCopyrightText: 2014 Hrvoje Senjan <hrvoje.senjan@gmail.com>
#
# SPDX-License-Identifier: BSD-3-Clause

#[=======================================================================[.rst:
FindLibcap
----------
Try to find the setcap binary and cap libraries

This will define:

``Libcap_FOUND``
    system has the cap library and setcap binary
``Libcap_LIBRARIES``
    cap libraries to link against
``SETCAP_EXECUTABLE``
    path of the setcap binary

In addition, the following targets are defined:
  ``Libcap::SetCapabilities``

Since 5.80.0
#]=======================================================================]

find_program(SETCAP_EXECUTABLE NAMES setcap DOC "The setcap executable")

find_library(Libcap_LIBRARIES NAMES cap DOC "The cap (capabilities) library")

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Libcap FOUND_VAR Libcap_FOUND
                                      REQUIRED_VARS SETCAP_EXECUTABLE Libcap_LIBRARIES)

if(Libcap_FOUND AND NOT TARGET Libcap::SetCapabilities)
    add_executable(Libcap::SetCapabilities IMPORTED)
    set_target_properties(Libcap::SetCapabilities PROPERTIES
        IMPORTED_LOCATION "${SETCAP_EXECUTABLE}"
    )
endif()

mark_as_advanced(SETCAP_EXECUTABLE Libcap_LIBRARIES)

include(FeatureSummary)
set_package_properties(Libcap PROPERTIES
    URL https://sites.google.com/site/fullycapable/
    DESCRIPTION "Capabilities are a measure to limit the omnipotence of the superuser.")
