# SPDX-FileCopyrightText: 2019, 2021 Friedrich W. H. Kossebau <kossebau@kde.org>
#
# SPDX-License-Identifier: BSD-3-Clause

#[=======================================================================[.rst:
Find7z
------

Try to find 7z.

If the 7z executable is not in your PATH, you can provide
an alternative name or full path location with the ``7z_EXECUTABLE``
variable.

This will define the following variables:

``7z_FOUND``
    TRUE if 7z is available

``7z_EXECUTABLE``
    Path to 7z executable

If ``7z_FOUND`` is TRUE, it will also define the following imported
target:

``7z::7z``
    Path to 7z executable

.. note::
    Only works on Windows.

Deprecated: since 5.113, use  :find-module:`Find7Zip`.

Since 5.85.0.
#]=======================================================================]

find_program(7z_EXECUTABLE NAMES 7z.exe 7za.exe)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(7z
    FOUND_VAR
        7z_FOUND
    REQUIRED_VARS
        7z_EXECUTABLE
)
mark_as_advanced(7z_EXECUTABLE)

if(NOT TARGET 7z::7z AND 7z_FOUND)
    add_executable(7z::7z IMPORTED)
    set_target_properties(7z::7z PROPERTIES
        IMPORTED_LOCATION "${7z_EXECUTABLE}"
    )
endif()

include(FeatureSummary)
set_package_properties(7z PROPERTIES
    URL "https://www.7-zip.org/"
    DESCRIPTION "Data (de)compression program"
)
