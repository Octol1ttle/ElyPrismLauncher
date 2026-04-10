# SPDX-FileCopyrightText: 2020 Andreas Cord-Landwehr <cordlandwehr@kde.org>
#
# SPDX-License-Identifier: BSD-3-Clause

#[=======================================================================[.rst:
WARNING: FOR ECM-INTERNAL USE ONLY, DO NOT USE IN OWN PROJECTS
THIS FILE MIGHT DISAPPEAR IN FUTURE VERSIONS OF ECM.

Finds the REUSE Tool by FSFE: https://github.com/fsfe/reuse-tool

 REUSETOOL_FOUND      - True if REUSE tool is found.
 REUSETOOL_EXECUTABLE - Path to executable
#]=======================================================================]

find_program(REUSETOOL_EXECUTABLE NAMES reuse)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ReuseTool
    FOUND_VAR
        REUSETOOL_FOUND
    REQUIRED_VARS
        REUSETOOL_EXECUTABLE
)
