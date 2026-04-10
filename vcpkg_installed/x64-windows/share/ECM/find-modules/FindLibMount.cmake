# SPDX-FileCopyrightText: 2021 Ahmad Samir <a.samirh78@gmail.com>
#
# SPDX-License-Identifier: BSD-3-Clause

#[=======================================================================[.rst:

FindLibMount
------------

Try to find the libmount library (part of util-linux), once done this will define:

``LibMount_FOUND``
    LibMount was found on the system.

``LibMount_INCLUDE_DIRS``
    The libmount include directory.

``LibMount_LIBRARIES``
    The libmount libraries.

``LibMount_VERSION``
    The libmount version.

If ``LibMount_FOUND`` is TRUE, it will also define the following imported target:

``LibMount::LibMount``
    The libmount library

Since 5.83.0
#]=======================================================================]

find_package(PkgConfig QUIET)
pkg_check_modules(PC_LIBMOUNT QUIET IMPORTED_TARGET mount)

find_path(LibMount_INCLUDE_DIRS NAMES libmount/libmount.h HINTS ${PC_LIBMOUNT_INCLUDE_DIRS})
find_library(LibMount_LIBRARIES NAMES mount HINTS ${PC_LIBMOUNT_LIBRARY_DIRS})

set(LibMount_VERSION ${PC_LIBMOUNT_VERSION})

if(LibMount_INCLUDE_DIRS AND NOT LibMount_VERSION)
    file(READ "${LibMount_INCLUDE_DIRS}/libmount/libmount.h" _LibMount_header_contents)
    string(REGEX MATCHALL "#define[ \t]+LIBMOUNT_VERSION[ \t]+\"*[0-9.]+" _LibMount_version_line "${_LibMount_header_contents}")
    unset(_LibMount_header_contents)
    string(REGEX REPLACE ".*LIBMOUNT_VERSION[ \t]+\"*([0-9.]+)\"*" "\\1" _version "${_LibMount_version_line}")
    set(LibMount_VERSION "${_version}")
    unset(_LibMount_version_line)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LibMount
    FOUND_VAR LibMount_FOUND
    REQUIRED_VARS LibMount_INCLUDE_DIRS LibMount_LIBRARIES
    VERSION_VAR LibMount_VERSION
)

mark_as_advanced(LibMount_INCLUDE_DIRS LibMount_LIBRARIES)

if(LibMount_FOUND AND NOT TARGET LibMount::LibMount)
    add_library(LibMount::LibMount UNKNOWN IMPORTED)
    set_target_properties(LibMount::LibMount PROPERTIES
        IMPORTED_LOCATION "${LibMount_LIBRARIES}"
        INTERFACE_INCLUDE_DIRECTORIES "${LibMount_INCLUDE_DIRS}"
        INTERFACE_COMPILE_DEFINITIONS "${PC_LIBMOUNT_CFLAGS_OTHER}"
    )
    if (TARGET PkgConfig::PC_LIBMOUNT)
        target_link_libraries(LibMount::LibMount INTERFACE PkgConfig::PC_LIBMOUNT)
    endif()
endif()

include(FeatureSummary)
set_package_properties(LibMount PROPERTIES
    DESCRIPTION "API for getting info about mounted filesystems (part of util-linux)"
    URL "https://www.kernel.org/pub/linux/utils/util-linux/"
)
