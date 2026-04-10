#
# SPDX-FileCopyrightText: 2023 Arjen Hiemstra <ahiemstra@heimr.nl>
#
# SPDX-License-Identifier: BSD-3-Clause

# Qt 6 implementation of ECMQmlModule

set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS ON)
find_package(Qt6 COMPONENTS Core Qml CONFIG)
unset(QT_NO_CREATE_VERSIONLESS_FUNCTIONS)

if (NOT TARGET Qt6::Qml)
    message(WARNING "Target Qt6::Qml was not found. ECMQmlModule requires the QML module when building with Qt 6")
    return()
endif()

# Match KDECMakeSettings' RUNTIME_OUTPUT_DIRECTORY so that we can load plugins from
# the build directory when running tests. But only if we don't yet have an output directory.
if (NOT QT_QML_OUTPUT_DIRECTORY)
    set(QT_QML_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
endif()

# Stop warning about a changed import prefix.
qt6_policy(SET QTP0001 NEW)

function(ecm_add_qml_module ARG_TARGET)
    cmake_parse_arguments(PARSE_ARGV 1 ARG "NO_PLUGIN;QT_NO_PLUGIN;GENERATE_PLUGIN_SOURCE" "URI;VERSION;CLASSNAME;OUTPUT_TARGETS" "")

    if ("${ARG_TARGET}" STREQUAL "")
        message(FATAL_ERROR "ecm_add_qml_module called without a valid target name.")
    endif()

    if ("${ARG_URI}" STREQUAL "")
        message(FATAL_ERROR "ecm_add_qml_module called without a valid module URI.")
    endif()

    string(FIND "${ARG_URI}" " " "_space")
    if (${_space} GREATER_EQUAL 0)
        message(FATAL_ERROR "ecm_add_qml_module called without a valid module URI.")
    endif()

    set(_arguments ${ARG_TARGET} URI ${ARG_URI})

    if (ARG_VERSION)
        list(APPEND _arguments VERSION ${ARG_VERSION})
    endif()

    if (ARG_CLASSNAME)
        message(AUTHOR_WARNING "The CLASSNAME argument to ecm_add_qml_module is deprecated for Qt 6; Use CLASS_NAME instead.")
        list(APPEND _arguments CLASS_NAME ${ARG_CLASSNAME})
    endif()

    if (ARG_NO_PLUGIN)
        message(AUTHOR_WARNING "The NO_PLUGIN argument to ecm_add_qml_module is deprecated for Qt 6; For Qt 6 QML modules always require a plugin library. Use GENERATE_PLUGIN_SOURCE instead. If you wish to use the NO_PLUGIN feature from qt_add_qml_module, use QT_NO_PLUGIN.")
        set(ARG_GENERATE_PLUGIN_SOURCE TRUE)
    endif()

    if (ARG_QT_NO_PLUGIN)
        list(APPEND _arguments NO_PLUGIN)
    endif()

    if (NOT ARG_GENERATE_PLUGIN_SOURCE)
        list(APPEND _arguments NO_GENERATE_PLUGIN_SOURCE)
    endif()

    if (NOT TARGET ${ARG_TARGET})
        list(APPEND _arguments PLUGIN_TARGET ${ARG_TARGET})
        if (BUILD_SHARED_LIBS)
            list(APPEND _arguments SHARED)
        else()
            list(APPEND _arguments STATIC)
        endif()
    endif()

    list(APPEND _arguments ${ARG_UNPARSED_ARGUMENTS})

    qt6_add_qml_module(${_arguments} OUTPUT_TARGETS _out_targets)
    if (ARG_OUTPUT_TARGETS)
        set(${ARG_OUTPUT_TARGETS} ${_out_targets} PARENT_SCOPE)
    endif()

    # KDECMakeSettings sets the prefix of MODULE targets to empty but Qt will
    # not load a QML plugin without prefix. So we need to force it here.
    qt6_query_qml_module(${ARG_TARGET} PLUGIN_TARGET _plugin_target)
    if (NOT WIN32 AND TARGET ${_plugin_target})
        set_target_properties(${_plugin_target} PROPERTIES PREFIX "lib")
    endif()

    option(VERBOSE_QML_COMPILER "Enable verbose output for qmlcachegen" OFF)

    if (VERBOSE_QML_COMPILER)
        set_target_properties(${ARG_TARGET} PROPERTIES
            QT_QMLCACHEGEN_ARGUMENTS "--verbose"
        )
    endif()

endfunction()

function(ecm_add_qml_module_dependencies ARG_TARGET)
    message(AUTHOR_WARNING "ecm_add_qml_module_dependencies is deprecated for Qt 6; use the DEPENDENCIES argument to ecm_add_qml_module() instead.")
endfunction()

function(ecm_target_qml_sources ARG_TARGET)
    cmake_parse_arguments(PARSE_ARGV 1 ARG "PRIVATE" "VERSION;PATH;OUTPUT_TARGETS" "SOURCES")

    if ("${ARG_SOURCES}" STREQUAL "")
        message(FATAL_ERROR "ecm_target_qml_sources called without required argument SOURCES")
    endif()

    if (ARG_VERSION)
        set_source_files_properties(${ARG_SOURCES} PROPERTIES QT_QML_SOURCE_VERSIONS "${ARG_VERSION}")
    endif()

    if (ARG_PRIVATE)
        set_source_files_properties(${ARG_SOURCES} PROPERTIES QT_QML_INTERNAL_TYPE TRUE)
    endif()

    set(_QML_FILES)
    set(_RESOURCES)
    foreach(_path ${ARG_SOURCES})
        get_filename_component(_file "${_path}" NAME)
        get_filename_component(_ext "${_path}" EXT)
        set(_resource_alias "${_file}")
        if (ARG_PATH)
            set(_resource_alias "${ARG_PATH}/${_file}")
        endif()
        set_source_files_properties("${_path}" PROPERTIES QT_RESOURCE_ALIAS "${_resource_alias}")
        if ("${_ext}" MATCHES "(.qml|.js|.mjs)")
            list(APPEND _QML_FILES "${_path}")
        else()
            list(APPEND _RESOURCES "${_path}")
        endif()
    endforeach()

    if(_QML_FILES)
        qt6_target_qml_sources(${ARG_TARGET} QML_FILES ${_QML_FILES} OUTPUT_TARGETS _out_targets_qml ${ARG_UNPARSED_ARGUMENTS})
    endif()
    if(_RESOURCES)
        qt6_target_qml_sources(${ARG_TARGET} RESOURCES ${_RESOURCES} OUTPUT_TARGETS _out_targets_qrc ${ARG_UNPARSED_ARGUMENTS})
    endif()
    list(APPEND _out_targets "${_out_targets_qml}" "${_out_targets_qrc}")
    if (ARG_OUTPUT_TARGETS)
        set(${ARG_OUTPUT_TARGETS} ${_out_targets} PARENT_SCOPE)
    endif()

endfunction()

function(ecm_finalize_qml_module ARG_TARGET)
    cmake_parse_arguments(PARSE_ARGV 1 ARG "" "DESTINATION;VERSION" "")

    if (NOT ARG_DESTINATION)
        set(ARG_DESTINATION "${KDE_INSTALL_QMLDIR}")
    endif()

    if ("${ARG_DESTINATION}" STREQUAL "")
        message(FATAL_ERROR "ecm_finalize_qml_module called without required argument DESTINATION and KDE_INSTALL_QMLDIR is not set")
    endif()

    if (NOT ARG_VERSION)
        set(ARG_VERSION "${PROJECT_VERSION}")
    endif()

    # This is effectively a workaround for missing upstream API, see QTBUG-100102

    qt6_query_qml_module(${ARG_TARGET}
        URI module_uri
        VERSION module_version
        PLUGIN_TARGET module_plugin_target
        TARGET_PATH module_target_path
        QMLDIR module_qmldir
        TYPEINFO module_typeinfo
        QML_FILES module_qml_files
        RESOURCES module_resources
    )

    set(module_dir "${ARG_DESTINATION}/${module_target_path}")

    if (NOT TARGET "${module_plugin_target}")
        return()
    endif()

    install(TARGETS "${module_plugin_target}"
        LIBRARY DESTINATION "${module_dir}"
        RUNTIME DESTINATION "${module_dir}"
    )

    # Install the QML module meta information.
    install(FILES "${module_qmldir}"   DESTINATION "${module_dir}")
    install(FILES "${module_typeinfo}" DESTINATION "${module_dir}")

    # Install QML files, possibly renamed.
    # see Kirigami::StyleSelector::resolveFileX, on Android we never use QML files from disk
    # but rather always the ones from qrc
    if (NOT ANDROID)
        list(LENGTH module_qml_files num_files)
        if (NOT "${module_qml_files}" MATCHES "NOTFOUND" AND ${num_files} GREATER 0)
            qt6_query_qml_module(${ARG_TARGET} QML_FILES_DEPLOY_PATHS qml_files_deploy_paths)

            math(EXPR last_index "${num_files} - 1")
            foreach(i RANGE 0 ${last_index})
                list(GET module_qml_files       ${i} src_file)
                list(GET qml_files_deploy_paths ${i} deploy_path)
                get_filename_component(dst_name "${deploy_path}" NAME)
                get_filename_component(dest_dir "${deploy_path}" DIRECTORY)
                install(FILES "${src_file}" DESTINATION "${module_dir}/${dest_dir}" RENAME "${dst_name}")
            endforeach()
        endif()
    endif()

    # Install resources, possibly renamed.
    list(LENGTH module_resources num_files)
    if (NOT "${module_resources}" MATCHES "NOTFOUND" AND ${num_files} GREATER 0)
        qt6_query_qml_module(${ARG_TARGET} RESOURCES_DEPLOY_PATHS resources_deploy_paths)

        math(EXPR last_index "${num_files} - 1")
        foreach(i RANGE 0 ${last_index})
            list(GET module_resources       ${i} src_file)
            list(GET resources_deploy_paths ${i} deploy_path)
            get_filename_component(dst_name "${deploy_path}" NAME)
            get_filename_component(dest_dir "${deploy_path}" DIRECTORY)
            install(FILES "${src_file}" DESTINATION "${module_dir}/${dest_dir}" RENAME "${dst_name}")
        endforeach()
    endif()

    file(GENERATE OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${ARG_TARGET}-kde-qmlmodule.version" CONTENT "${ARG_VERSION}\n")
    install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${ARG_TARGET}-kde-qmlmodule.version" DESTINATION "${module_dir}" RENAME "kde-qmlmodule.version")
endfunction()
