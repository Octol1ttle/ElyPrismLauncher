# SPDX-FileCopyrightText: 2019 Volker Krause <vkrause@kde.org>
#
# SPDX-License-Identifier: BSD-3-Clause

#[=======================================================================[.rst:
FindGradle
----------

Provides the ability to build Android AAR libraries using Gradle.

This relies on the Qt provided Gradle, so a Qt for Android installation
is required.
::

  gradle_add_aar(<target>
                 BUIDLFILE build.gradle
                 NAME <aar-name>)

This builds an Android AAR library using the given ``build.gradle`` file.
::

  gradle_install_aar(<target>
                     DESTINATION <dest>)

Installs a Android AAR library that has been created with ``gradle_add_aar``.

Since 5.76.0.
#]=======================================================================]

include(${CMAKE_CURRENT_LIST_DIR}/../modules/QtVersionOption.cmake)
include(FindPackageHandleStandardArgs)

find_package(Qt${QT_MAJOR_VERSION}Core REQUIRED)

set (Gradle_PRECOMMAND "")
if (NOT WIN32)
    set(Gradle_EXECUTABLE ${CMAKE_BINARY_DIR}/gradle/gradlew)
    # the gradlew script installed by Qt6 is not executable, so running it directly fails
    if (QT_MAJOR_VERSION EQUAL "6")
        set(Gradle_PRECOMMAND "sh")
    endif()
else()
    set(Gradle_EXECUTABLE ${CMAKE_BINARY_DIR}/gradle/gradlew.bat)
endif()

get_target_property(_qt_core_location Qt${QT_MAJOR_VERSION}::Core LOCATION)
get_filename_component(_qt_install_root ${_qt_core_location} DIRECTORY)
get_filename_component(_qt_install_root ${_qt_install_root}/../ ABSOLUTE)

set(_gradle_template_dir ${CMAKE_CURRENT_LIST_DIR})

add_custom_command(OUTPUT ${Gradle_EXECUTABLE}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/gradle
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${_qt_install_root}/src/3rdparty/gradle ${CMAKE_BINARY_DIR}/gradle
)
add_custom_target(gradle DEPENDS ${Gradle_EXECUTABLE})

# Android Gradle plugin version (not the Gradle version!) used by Qt, for use in our own build.gradle files
file(READ ${_qt_install_root}/src/android/templates/build.gradle _build_grade_template)
string(REGEX MATCH "[0-9]+\.[0-9]+\.[0-9]+" Gradle_ANDROID_GRADLE_PLUGIN_VERSION ${_build_grade_template})

find_package_handle_standard_args(Gradle DEFAULT_MSG Gradle_EXECUTABLE)

function(gradle_add_aar target)
    cmake_parse_arguments(ARG "" "BUILDFILE;NAME" "" ${ARGN})

    set(_build_root ${CMAKE_CURRENT_BINARY_DIR}/gradle_build/${ARG_NAME})
    configure_file(${_gradle_template_dir}/local.properties.cmake ${_build_root}/local.properties)
    configure_file(${_gradle_template_dir}/settings.gradle.cmake ${_build_root}/settings.gradle)
    configure_file(${ARG_BUILDFILE} ${_build_root}/build.gradle)

    if (CMAKE_BUILD_TYPE MATCHES "[Dd][Ee][Bb][Uu][Gg]")
        set(_aar_suffix "-debug")
        set(_aar_gradleCmd "assembleDebug")
    else()
        set(_aar_suffix "-release")
        set(_aar_gradleCmd "assembleRelease")
    endif()

    file(GLOB_RECURSE _src_files CONFIGURE_DEPENDS "*")
    add_custom_command(
        OUTPUT ${_build_root}/build/outputs/aar/${ARG_NAME}${_aar_suffix}.aar
        COMMAND ${Gradle_PRECOMMAND} ${Gradle_EXECUTABLE} ${_aar_gradleCmd}
        # this allows make create-apk to work without installations for apps with AAR libs in the same repository
        COMMAND ${CMAKE_COMMAND} -E copy ${_build_root}/build/outputs/aar/${ARG_NAME}${_aar_suffix}.aar ${CMAKE_BINARY_DIR}/jar/${ARG_NAME}.aar
        DEPENDS ${Gradle_EXECUTABLE} ${_src_files}
        DEPENDS gradle
        WORKING_DIRECTORY ${_build_root}
    )
    add_custom_target(${target} ALL DEPENDS ${_build_root}/build/outputs/aar/${ARG_NAME}${_aar_suffix}.aar)
    set_target_properties(${target} PROPERTIES LOCATION ${_build_root}/build/outputs/aar/${ARG_NAME}${_aar_suffix}.aar)
    set_target_properties(${target} PROPERTIES OUTPUT_NAME ${ARG_NAME})
endfunction()

function(gradle_install_aar target)
    cmake_parse_arguments(ARG "" "DESTINATION" "" ${ARGN})
    get_target_property(_loc ${target} LOCATION)
    get_target_property(_name ${target} OUTPUT_NAME)
    install(FILES ${_loc} DESTINATION ${ARG_DESTINATION} RENAME ${_name}.aar)
endfunction()
