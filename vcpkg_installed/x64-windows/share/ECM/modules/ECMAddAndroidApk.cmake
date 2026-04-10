# SPDX-FileCopyrightText: 2018-2023 Aleix Pol <aleixpol@kde.org>
# SPDX-FileCopyrightText: 2023 Volker Krause <vkrause@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

#[=======================================================================[.rst:
ECMAddAndroidApk
----------------

Functions for creating Android APK packages using Qt6's ``androiddeployqt`` tool
as well as the associated Fastlane metadata.

::

  ecm_add_android_apk(<target>
      [ANDROID_DIR <dir>]
      # TODO extra args?
  )

Creates an Android APK for the given target.

If ``ANDROID_DIR`` is given, the Android manifest file as well as any potential
Gradle build system files or Java/Kotlin source files are taken from that directory.
If not set, the standard template shipped with Qt6 is used, which in usually not
what you want for production applications.

The use of this function creates a build target called ``create-apk-<target>``
which will run ``androiddeployqt`` to produce an (unsigned) APK, as well
as convert Appstream application metadata (if present) into the Fastlane format used
by F-Droid and Play store automation.

There's also a ``create-apk`` convenience target being created that
will build all APKs defined in a project.

When building for another platform than Android, this function does nothing.

The following variables impact the behavior:
``ECM_ADDITIONAL_FIND_ROOT_PATH``
    See documentation in the Android toolchain file.

``ECM_APK_STAGING_ROOT_PATH``
    For use with Craft's image directory. If set this is used as the source
    for all content of the APK rather than the search paths used for building.
    This allows to separate e.g. development files from what ends up in the APK.

Since 6.0.0
#]=======================================================================]

# make ExecuteCoreModules test pass on Qt5
include(${CMAKE_CURRENT_LIST_DIR}/../modules/QtVersionOption.cmake)
if (QT_MAJOR_VERSION EQUAL 5)
    message(WARNING "ECMAddAndroidApk is not compatible with Qt5 - skipping.")
    return()
endif()

find_package(Qt6Core REQUIRED) # required for the following to work stand-alone
find_package(Qt6CoreTools REQUIRED)
find_package(Python3 COMPONENTS Interpreter REQUIRED)

set(_ECM_TOOLCHAIN_DIR "${CMAKE_CURRENT_LIST_DIR}/../toolchain")

function (ecm_add_android_apk TARGET)
    cmake_parse_arguments(ARGS "" "ANDROID_DIR" "" ${ARGN})
    if (NOT ANDROID)
        return()
    endif()

    set(APK_OUTPUT_DIR "${CMAKE_BINARY_DIR}/${TARGET}_build_apk/")
    set(APK_EXECUTABLE_PATH "${APK_OUTPUT_DIR}/libs/${CMAKE_ANDROID_ARCH_ABI}/lib${TARGET}_${CMAKE_ANDROID_ARCH_ABI}.so")

    set(QML_IMPORT_PATHS "")
    # add build directory to the search path as well, so this works without installation
    if (EXISTS ${CMAKE_BINARY_DIR}/lib)
        set(QML_IMPORT_PATHS ${CMAKE_BINARY_DIR}/lib)
    endif()
    if (ECM_APK_STAGING_ROOT_PATH)
        set(QML_IMPORT_PATHS "${ECM_APK_STAGING_ROOT_PATH}/lib/qml")
        set(ANDROID_QT6_INSTALL_PREFIX ${ECM_APK_STAGING_ROOT_PATH})
    else()
        foreach(prefix ${ECM_ADDITIONAL_FIND_ROOT_PATH})
            # qmlimportscanner chokes on symlinks, so we need to resolve those first
            get_filename_component(qml_path "${prefix}/lib/qml" REALPATH)
            if(EXISTS ${qml_path})
                if (QML_IMPORT_PATHS)
                    set(QML_IMPORT_PATHS "${QML_IMPORT_PATHS},${qml_path}")
                else()
                    set(QML_IMPORT_PATHS "${qml_path}")
                endif()
            endif()
        endforeach()
        set(ANDROID_QT6_INSTALL_PREFIX ${QT6_INSTALL_PREFIX})
    endif()
    if (QML_IMPORT_PATHS)
        set(DEFINE_QML_IMPORT_PATHS "\"qml-import-paths\": \"${QML_IMPORT_PATHS}\",")
    endif()

    set(EXTRA_PREFIX_DIRS "\"${CMAKE_BINARY_DIR}\"")
    set(EXTRA_LIB_DIRS "\"${CMAKE_BINARY_DIR}/lib\"")
    if (ECM_APK_STAGING_ROOT_PATH)
        set(EXTRA_PREFIX_DIRS "${EXTRA_PREFIX_DIRS}, \"${ECM_APK_STAGING_ROOT_PATH}\"")
        set(EXTRA_LIB_DIRS "${EXTRA_LIB_DIRS}, \"${ECM_APK_STAGING_ROOT_PATH}/lib\"")
    else()
        foreach(prefix ${ECM_ADDITIONAL_FIND_ROOT_PATH})
            set(EXTRA_PREFIX_DIRS "${EXTRA_PREFIX_DIRS}, \"${prefix}\"")
            set(EXTRA_LIB_DIRS "${EXTRA_LIB_DIRS}, \"${prefix}/lib\"")
        endforeach()
    endif()

    if (ARGS_ANDROID_DIR AND EXISTS ${ARGS_ANDROID_DIR}/AndroidManifest.xml)
        set(ANDROID_APK_DIR ${ARGS_ANDROID_DIR})
    else()
        message("Using default Qt APK template - this is often not intentional!")
        get_filename_component(_qtCore_install_prefix "${Qt6Core_DIR}/../../../" ABSOLUTE)
        set(ANDROID_APK_DIR "${_qtCore_install_prefix}/src/android/templates/")
    endif()

    get_target_property(QT6_RCC_BINARY Qt6::rcc LOCATION)
    string(TOLOWER "${CMAKE_HOST_SYSTEM_NAME}" _LOWER_CMAKE_HOST_SYSTEM_NAME)
    configure_file("${_ECM_TOOLCHAIN_DIR}/deployment-file-qt6.json.in" "${CMAKE_BINARY_DIR}/${TARGET}-deployment.json.in")

    if (NOT TARGET create-apk)
        add_custom_target(create-apk)
        if (NOT DEFINED ANDROID_FASTLANE_METADATA_OUTPUT_DIR)
            set(ANDROID_FASTLANE_METADATA_OUTPUT_DIR ${CMAKE_BINARY_DIR}/fastlane)
        endif()
        add_custom_target(create-fastlane
            COMMAND Python3::Interpreter ${_ECM_TOOLCHAIN_DIR}/generate-fastlane-metadata.py --output ${ANDROID_FASTLANE_METADATA_OUTPUT_DIR} --source ${CMAKE_SOURCE_DIR}
        )
    endif()

    if (NOT DEFINED ANDROID_APK_OUTPUT_DIR)
        set(ANDROID_APK_OUTPUT_DIR ${APK_OUTPUT_DIR})
    endif()

    if (CMAKE_GENERATOR STREQUAL "Unix Makefiles")
        set(arguments "\\$(ARGS)")
    endif()

    if (NOT ECM_APK_STAGING_ROOT_PATH)
        set(ECM_APK_STAGING_ROOT_PATH "${CMAKE_INSTALL_PREFIX}")
    endif()

    file(WRITE ${CMAKE_BINARY_DIR}/ranlib "${CMAKE_RANLIB}")
    set(CREATEAPK_TARGET_NAME "create-apk-${TARGET}")
    add_custom_target(${CREATEAPK_TARGET_NAME}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMAND ${CMAKE_COMMAND} -E echo "Generating $<TARGET_NAME:${TARGET}> with $<TARGET_FILE:Qt6::androiddeployqt>"
        COMMAND ${CMAKE_COMMAND} -E remove_directory "${APK_OUTPUT_DIR}"
        COMMAND ${CMAKE_COMMAND} -E copy "$<TARGET_FILE:${TARGET}>" "${APK_EXECUTABLE_PATH}"
        COMMAND LANG=C ${CMAKE_COMMAND} "-DTARGET=$<TARGET_FILE:${TARGET}>" -P ${_ECM_TOOLCHAIN_DIR}/hasMainSymbol.cmake
        COMMAND LANG=C ${CMAKE_COMMAND}
            -DINPUT_FILE="${CMAKE_BINARY_DIR}/${TARGET}-deployment.json.in"
            -DOUTPUT_FILE="${CMAKE_BINARY_DIR}/${TARGET}-deployment.json"
            "-DTARGET=$<TARGET_FILE:${TARGET}>"
            "-DOUTPUT_DIR=$<TARGET_FILE_DIR:${TARGET}>"
            "-DEXPORT_DIR=${ECM_APK_STAGING_ROOT_PATH}"
            "-DECM_ADDITIONAL_FIND_ROOT_PATH=\"${ECM_ADDITIONAL_FIND_ROOT_PATH}\""
            -P ${_ECM_TOOLCHAIN_DIR}/specifydependencies.cmake
        COMMAND Qt6::androiddeployqt
            ${ANDROIDDEPLOYQT_EXTRA_ARGS}
            --gradle
            --input "${CMAKE_BINARY_DIR}/${TARGET}-deployment.json"
            --apk "${ANDROID_APK_OUTPUT_DIR}/${TARGET}-${CMAKE_ANDROID_ARCH_ABI}.apk"
            --output "${APK_OUTPUT_DIR}"
            --android-platform android-${ANDROID_SDK_COMPILE_API}
            --deployment bundled
            --qml-importscanner-binary $<TARGET_FILE:Qt6::qmlimportscanner>
            ${arguments}
    )

    add_dependencies(create-apk ${CREATEAPK_TARGET_NAME})
    add_dependencies(${CREATEAPK_TARGET_NAME} create-fastlane)
endfunction()
