# SPDX-FileCopyrightText: 2014 Alex Merry <alex.merry@kde.org>
# SPDX-FileCopyrightText: 2013 Stephen Kelly <steveire@gmail.com>
#
# SPDX-License-Identifier: BSD-3-Clause

#[=======================================================================[.rst:
FindKF6
-------

Find KDE Frameworks 6 with a single find_package() call.

This will use the package config files provided by the individual frameworks.
For example, if you wish to find KArchive, which presents itself to CMake as
KF6Archive (ie: you would do ``find_package(KF6Archive)`` to find it
directly), you can do

.. code-block:: cmake

  find_package(KF6 COMPONENTS Archive)

If all the required components (those given in the COMPONENTS argument, but
not those given in the OPTIONAL_COMPONENTS argument) are found, ``KF6_FOUND``
will be set to true. Otherwise, it will be set to false.

Since 6.0.0.
#]=======================================================================]

include(${CMAKE_CURRENT_LIST_DIR}/ECMFindModuleHelpersStub.cmake)

ecm_find_package_version_check(KF6)

if (NOT KF6_FIND_COMPONENTS)
    set(KF6_NOT_FOUND_MESSAGE "The KF6 package requires at least one component")
    set(KF6_FOUND False)
    return()
endif()

set(_quiet_arg)
if (KF6_FIND_QUIETLY)
    set(_quiet_arg QUIET)
endif()
set(_exact_arg)
if (KF6_FIND_EXACT)
    set(_exact_arg EXACT)
endif()

include(FindPackageHandleStandardArgs)
include(FeatureSummary)

set(KF6_VERSION)
foreach(_module ${KF6_FIND_COMPONENTS})
    find_package(KF6${_module} ${KF6_FIND_VERSION}
        ${_exact_arg} ${_quiet_arg}
        CONFIG
    )
    # CMake >= 3.17 wants to be explicitly told we are fine with name mismatch here
    set(_name_mismatched_arg)
    if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.17)
       set(_name_mismatched_arg NAME_MISMATCHED)
    endif()
    find_package_handle_standard_args(KF6${_module} CONFIG_MODE ${_name_mismatched_arg})
    if (KF6_FIND_REQUIRED AND KF6_FIND_REQUIRED_${_module})
        # If the component was required, we tell FeatureSummary so that it
        # will be displayed in the correct list. We do not use the REQUIRED
        # argument of find_package() to allow all the missing frameworks
        # to be listed at once (fphsa will error out at the end of this file
        # anyway).
        set_package_properties(KF6${_module} PROPERTIES TYPE REQUIRED)
    endif()

    # Component-based find modules are expected to set
    # <module>_<component>_FOUND and <module>_<component>_VERSION variables,
    # but the find_package calls above will have set KF6<component>_*
    # variables.
    set(KF6_${_module}_FOUND ${KF6${_module}_FOUND})
    if(KF6${_module}_FOUND)
        set(KF6_${_module}_VERSION ${KF6${_module}_VERSION})

        # make KF6_VERSION the minimum found version
        if(NOT KF6_VERSION OR KF6_VERSION VERSION_GREATER KF6${_module}_VERSION)
            set(KF6_VERSION ${KF6${_module}_VERSION})
        endif()
    endif()
endforeach()

# Annoyingly, find_package_handle_standard_args requires you to provide
# REQUIRED_VARS even when using HANDLE_COMPONENTS, but all we actually
# care about is whether the required components were found. So we provide
# a dummy variable that is just set to something that will be printed
# on success.
set(_dummy_req_var "success")

find_package_handle_standard_args(KF6
    FOUND_VAR
        KF6_FOUND
    REQUIRED_VARS
        _dummy_req_var
    VERSION_VAR
        KF6_VERSION
    HANDLE_COMPONENTS
)

