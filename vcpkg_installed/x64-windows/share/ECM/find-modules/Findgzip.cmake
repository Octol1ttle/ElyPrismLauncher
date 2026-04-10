# SPDX-FileCopyrightText: 2019, 2021 Friedrich W. H. Kossebau <kossebau@kde.org>
#
# SPDX-License-Identifier: BSD-3-Clause

#[=======================================================================[.rst:
Findgzip
--------

Try to find gzip.

If the gzip executable is not in your PATH, you can provide
an alternative name or full path location with the ``gzip_EXECUTABLE``
variable.

This will define the following variables:

``gzip_FOUND``
    TRUE if gzip is available

``gzip_EXECUTABLE``
    Path to gzip executable

If ``gzip_FOUND`` is TRUE, it will also define the following imported
target:

``gzip::gzip``
    Path to gzip executable

Since 5.85.0.
#]=======================================================================]

find_program(gzip_EXECUTABLE NAMES gzip)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(gzip
    FOUND_VAR
        gzip_FOUND
    REQUIRED_VARS
        gzip_EXECUTABLE
)
mark_as_advanced(gzip_EXECUTABLE)

if(NOT TARGET gzip::gzip AND gzip_FOUND)
    add_executable(gzip::gzip IMPORTED)
    set_target_properties(gzip::gzip PROPERTIES
        IMPORTED_LOCATION "${gzip_EXECUTABLE}"
    )
endif()

include(FeatureSummary)
set_package_properties(gzip PROPERTIES
    URL "https://www.gnu.org/software/gzip"
    DESCRIPTION "Data compression program for the gzip format"
)
