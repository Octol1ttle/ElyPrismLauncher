# SPDX-FileCopyrightText: 2019, 2021, 2023 Friedrich W. H. Kossebau <kossebau@kde.org>
#
# SPDX-License-Identifier: BSD-3-Clause

#[=======================================================================[.rst:
Find7Zip
--------

Try to find 7-Zip.

If the 7-Zip executable is not in your PATH, you can provide
an alternative name or full path location with the ``7Zip_EXECUTABLE``
variable.

This will define the following variables:

``7Zip_FOUND``
    TRUE if 7-Zip is available

``7Zip_EXECUTABLE``
    Path to 7-Zip executable

If ``7Zip_FOUND`` is TRUE, it will also define the following imported
target:

``7Zip::7Zip``
    Path to 7-Zip executable

.. note::
    It will see to only find the original 7-Zip, not one of the  p7zip forks.

Since 5.113.0.
#]=======================================================================]

if(WIN32)
    find_program(7Zip_EXECUTABLE NAMES 7z 7za)
else()
    # Some p7zip used to be a fork for Linux of older 7-Zip,
    # just supporting the 7z format, and occupied the 7z binary name.
    # When 7-Zip got its official Linux support, it chose 7zz to not conflict,
    # given it also has another set of arguments.
    # Later p7zip was forked once more into some p7zip-zstd, using a newer copy of 7-Zip,
    # supporting more than 7z format, therefore also many of the arguments known from 7-Zip.
    # Being a different project though and now a real fork due to 7-Zip supporting Linux,
    # we try to only find the original here, so consumers can rely on the original 7-Zip documentation.
    find_program(7Zip_EXECUTABLE NAMES 7zz)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(7Zip
    FOUND_VAR
        7Zip_FOUND
    REQUIRED_VARS
        7Zip_EXECUTABLE
)
mark_as_advanced(7Zip_EXECUTABLE)

if(NOT TARGET 7Zip::7Zip AND 7Zip_FOUND)
    add_executable(7Zip::7Zip IMPORTED)
    set_target_properties(7Zip::7Zip PROPERTIES
        IMPORTED_LOCATION "${7Zip_EXECUTABLE}"
    )
endif()

include(FeatureSummary)
set_package_properties(7Zip PROPERTIES
    URL "https://www.7-zip.org/"
    DESCRIPTION "Data (de)compression program"
)
