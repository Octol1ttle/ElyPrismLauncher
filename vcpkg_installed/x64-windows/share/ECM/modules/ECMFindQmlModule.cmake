# SPDX-FileCopyrightText: 2015 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
# SPDX-FileCopyrightText: 2023 Alexander Lohnau <alexander.lohnau@gmx.de>
#
# SPDX-License-Identifier: BSD-3-Clause

#[=======================================================================[.rst:
ECMFindQmlModule
----------------

Find QML import modules through a ``find_qmlmodule()`` call.
It looks for the qmldir and uses the qmlplugindump if needed application to find the plugins and sets them up as
runtime dependencies.
This is useful so that when we configure a project we are notified when some
QML imports are not present in the system.

::

  ecm_find_qmlmodule(<module_name>
    <version> # Optional for Qt6 builds
    [REQUIRED] # Since 6.0
  )

Usage example:

.. code-block:: cmake

  ecm_find_qmlmodule(org.kde.kirigami 2.1)
  ecm_find_qmlmodule(org.kde.kirigami 2.1 REQUIRED) # CMake will fail if the required version is not found
  ecm_find_qmlmodule(org.kde.kirigami) # Find it without a given version
  ecm_find_qmlmodule(org.kde.kirigami REQUIRED) # CMake will fail if it is not found

Since 5.38.0.
#]=======================================================================]

set(MODULES_DIR ${CMAKE_CURRENT_LIST_DIR})

function(ecm_find_qmlmodule MODULE_NAME)
    if (QT_MAJOR_VERSION STREQUAL 6)
      cmake_parse_arguments(ARG REQUIRED "" "" ${ARGN})
        if (ARG_UNPARSED_ARGUMENTS)
          list(GET ARG_UNPARSED_ARGUMENTS 0 VERSION) # If we have any unparsed args, that should be the version
        endif()
        set(ARGN "") # The find_package call below should not recieve arguments in KF6
    else()
        list(GET ARGN 0 VERSION)
        list(REMOVE_AT ARGN 0)
    endif()

    set(GENMODULE "${MODULE_NAME}-QMLModule")
    configure_file("${MODULES_DIR}/ECMFindQmlModule.cmake.in" "Find${GENMODULE}.cmake" @ONLY)
    set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_BINARY_DIR}" ${CMAKE_MODULE_PATH})
    find_package(${GENMODULE} ${ARGN})

    if(COMMAND set_package_properties)
      if (ARG_REQUIRED)
        set(TYPE_STRING TYPE REQUIRED)
      else()
        set(TYPE_STRING TYPE RUNTIME)
      endif()
        set_package_properties(${GENMODULE} PROPERTIES
            DESCRIPTION "QML module '${MODULE_NAME}' is a runtime dependency."
            ${TYPE_STRING})
    endif()
endfunction()
