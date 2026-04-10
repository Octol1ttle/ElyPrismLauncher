# SPDX-FileCopyrightText: 2020-2023 Alexander Lohnau <alexander.lohnau@gmx.de>
# SPDX-FileCopyrightText: 2022 Ahmad Samir <a.samirh78@gmail.com>
# SPDX-FileCopyrightText: 2023 Johannes Zarl-Zierl <johannes@zarl-zierl.at>
#
# SPDX-License-Identifier: BSD-3-Clause

#[=======================================================================[.rst:
KDEGitCommitHooks
--------------------

This module provides a functionality to enforce formatting
or in the future other QS checks.

This module provides the following function:

::

  kde_configure_git_pre_commit_hook(
     CHECKS <check1> [<check2> [...]
     [CUSTOM_SCRIPTS [<script paths> [<script paths> ...]]] # since 5.109
  )

This function will create a pre-commit hook which contains all the given checks.
In addition to that, you can pass in paths to custom scripts that will be run as the pre-commit hook.
If a custom hooks directory is set via ``core.hooksPath``, a warning is issued.

Checks:

- ``CLANG_FORMAT`` With this check enabled the ``git clang-format`` tool will be used to make sure that
  the changed parts are properly formatted. In case the changes are not properly formatted an error
  message with the command to preview the formatting changes and to format the files in place
  will be displayed. This tool will reuse the exsting ``.clang-format`` file, in case you
  want to use the one provided by ECM you can include ``include(KDEClangFormat)`` which will copy
  the file to the source dir. It is also recommended to reformat the entire project before enforcing
  the formatting using this commit hook.
  - ``JSON_SCHEMA`` Since 5.110, uses the check-jsonschema CLI tool to ensure that all files are valid JSON and
  match the KPluginMetaData spec. This only applied if the JSON file has a "KPlugin" object in its root.
  To ignore invalid files, for example for testing error handling, given files can be exlcuded in the .kde-ci.yml file
  Define Options.json-validate-ignore with an array of the files you want to ignore

Example usage:

.. code-block:: cmake

  include(KDEGitCommitHooks)
  kde_configure_git_pre_commit_hook(CHECKS JSON_SCHEMA CLANG_FORMAT)

Since 5.79
#]=======================================================================]

# try to find clang-format in path
find_program(KDE_CLANG_FORMAT_EXECUTABLE clang-format)
find_program(KDE_CHECK_JSONSCHEMA_EXECUTABLE check-jsonschema)
set(PRE_COMMIT_HOOK_UNIX "${CMAKE_CURRENT_LIST_DIR}/kde-git-commit-hooks/pre-commit.in")
set(CLANG_FORMAT_UNIX "${CMAKE_CURRENT_LIST_DIR}/kde-git-commit-hooks/clang-format.sh")
set(JSON_SCHEMA_SCRIPT "${CMAKE_CURRENT_LIST_DIR}/kde-git-commit-hooks/json-schema.py")
set(JSON_SCHEMA_IN "${CMAKE_CURRENT_LIST_DIR}/kde-git-commit-hooks/combined.schema.json.in")
set(GIT_DIR "${CMAKE_SOURCE_DIR}/.git")
set(GIT_HOOKS_DIR "${GIT_DIR}/hooks")
set(JSON_SCHEMA_OUT "${GIT_HOOKS_DIR}/scripts/combined.schema.json")

function(KDE_CONFIGURE_GIT_PRE_COMMIT_HOOK)
    set(_oneValueArgs "")
    set(_multiValueArgs CHECKS CUSTOM_SCRIPTS)
    cmake_parse_arguments(ARG "" "${_oneValueArgs}" "${_multiValueArgs}" ${ARGN})

    if(NOT CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
        message(STATUS "Project is not top level project - pre-commit hook not installed")
        return()
    endif()

    if(NOT ARG_CHECKS)
        message(FATAL_ERROR "No checks were specified")
    endif()

    find_package(Git QUIET)

    if (NOT IS_DIRECTORY ${GIT_DIR} # In case of tarballs there is no .git directory
        OR NOT (UNIX OR WIN32)
        OR NOT GIT_FOUND
        )
        return()
    endif()

    execute_process(COMMAND "${GIT_EXECUTABLE}" config --get core.hooksPath
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
        RESULT_VARIABLE _gitresult
        OUTPUT_VARIABLE _gitoutput
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE)

    if(_gitresult EQUAL 0 AND NOT ${GIT_HOOKS_DIR} EQUAL "${_gitoutput}")
        message(WARNING "Git is configured to use '${_gitoutput}' for hooks. The generated commit hooks will likely not be executed.")
    endif()

    string(REPLACE ";" "\n" PRE_COMMIT_SCRIPTS "${ARG_CUSTOM_SCRIPTS}")
    set(_write_hook FALSE)
    if(KDE_CLANG_FORMAT_EXECUTABLE)
        list(FIND ARG_CHECKS "CLANG_FORMAT" _index)
        # Used to configure clang-format.sh script
        if (COMMAND KDE_CLANG_FORMAT)
            set(HAS_CLANG_FORMAT_COMMAND_INCLUDED TRUE)
        else()
            set(HAS_CLANG_FORMAT_COMMAND_INCLUDED FALSE)
        endif()
        if (${_index} GREATER -1)
            # get version of clang-format
            execute_process(
                COMMAND "${KDE_CLANG_FORMAT_EXECUTABLE}" --version
                OUTPUT_VARIABLE _clang_format_version_raw
                ERROR_VARIABLE _clang_format_version_raw
            )
            if (_clang_format_version_raw MATCHES "clang-format version ([0-9]+)(\\.[0-9]+)*")
                set(KDE_CLANG_FORMAT_MAJOR_VERSION "${CMAKE_MATCH_1}")
            endif()
            unset(_clang_format_version_raw)
            message(STATUS "Found clang-format version ${KDE_CLANG_FORMAT_MAJOR_VERSION}")

            set(CLANG_FORMAT_SCRIPT "\"$(git rev-parse --git-common-dir)\"/hooks/scripts/clang-format.sh")
            configure_file(${CLANG_FORMAT_UNIX} "${GIT_HOOKS_DIR}/scripts/clang-format.sh" @ONLY)
            set(PRE_COMMIT_SCRIPTS "\"$(git rev-parse --git-common-dir)\"/hooks/scripts/clang-format.sh\n${PRE_COMMIT_SCRIPTS}")
            set(_write_hook TRUE)
        endif()
    endif()

    list(FIND ARG_CHECKS "JSON_SCHEMA" _index)
    if (${_index} GREATER -1)
      set(_write_hook TRUE)
      foreach(path ${CMAKE_PREFIX_PATH};${CMAKE_INCLUDE_PATH})
          file(GLOB files "${path}/${KDE_INSTALL_DATADIR}/kf6/jsonschema/*.json") 
          set(SCHEMA_FILES ${SCHEMA_FILES};${files})
      endforeach()
        foreach (SCHEMA ${SCHEMA_FILES})
            if (SCHEMA_INCLUDES)
                set(SCHEMA_INCLUDES "${SCHEMA_INCLUDES},")
            endif()
            set(SCHEMA_INCLUDES "${SCHEMA_INCLUDES}{\"$ref\": \"${SCHEMA}\"}")
        endforeach()
        configure_file(${JSON_SCHEMA_IN} ${JSON_SCHEMA_OUT} @ONLY)
        if (KDE_CHECK_JSONSCHEMA_EXECUTABLE)
            set(PRE_COMMIT_SCRIPTS "set -e\npython3 ${JSON_SCHEMA_SCRIPT} \"${JSON_SCHEMA_OUT}\"\n${PRE_COMMIT_SCRIPTS}")
        else()
            message(WARNING "check-jsonschema executable not found. Please install it using pip or using your package manager")
        endif()
    endif()


    set(_hook_file "${GIT_HOOKS_DIR}/pre-commit")
    # Appending to the file is quite ugly and causes edge cases. With the CUSTOM_SCRIPTS arg, this should not be needed though
    if (ECM_GLOBAL_FIND_VERSION VERSION_GREATER_EQUAL 5.109.0)
        set(PRE_COMMIT_SCRIPTS "# This file is autogenerated by kde_configure_git_pre_commit_hook, any changes will be lost! \n${PRE_COMMIT_SCRIPTS}")
        configure_file(${PRE_COMMIT_HOOK_UNIX} "${_hook_file}")
    else()
        if(NOT _write_hook)
            message(WARNING "No clang-format executable was found, skipping the formatting pre-commit hook")
            return()
        endif()
        # Doesn't exist? write away
        if(NOT EXISTS ${_hook_file})
            configure_file(${PRE_COMMIT_HOOK_UNIX} "${_hook_file}")
            return()
        endif()

        file(READ ${_hook_file} _contents)

        # For when CLANG_FORMAT_SCRIPT didn't have the 'git rev-parse --git-common-dir' part
        set(_old_cmd "./.git/hooks/scripts/clang-format.sh")
        string(FIND "${_contents}" "${_old_cmd}" _idx)
        if (${_idx} GREATER -1)
            string(REPLACE "${_old_cmd}" "${CLANG_FORMAT_SCRIPT}" _contents "${_contents}")
            file(WRITE ${_hook_file} "${_contents}")
            return()
        endif()

        string(FIND "${_contents}" "${CLANG_FORMAT_SCRIPT}" _idx)
        # File exists and doesn't have the clang-format.sh line, append it
        # so as to not overwrite users' customisations
        if (_idx EQUAL -1)
            file(APPEND ${_hook_file} "${CLANG_FORMAT_SCRIPT}")
        endif()
    endif()
endfunction()
