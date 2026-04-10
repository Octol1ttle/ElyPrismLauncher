cmake_minimum_required (VERSION 3.19 FATAL_ERROR)
find_package(Qt5Core REQUIRED)
find_package(Python3 COMPONENTS Interpreter REQUIRED)

# Taken from https://stackoverflow.com/a/62311397
function(_ecm_get_all_targets var)
    set(targets)
    _ecm_get_all_targets_recursive(targets ${CMAKE_CURRENT_SOURCE_DIR})
    set(${var} ${targets} PARENT_SCOPE)
endfunction()

macro(_ecm_get_all_targets_recursive targets dir)
    get_property(subdirectories DIRECTORY ${dir} PROPERTY SUBDIRECTORIES)
    foreach(subdir ${subdirectories})
        _ecm_get_all_targets_recursive(${targets} ${subdir})
    endforeach()

    get_property(current_targets DIRECTORY ${dir} PROPERTY BUILDSYSTEM_TARGETS)
    list(APPEND ${targets} ${current_targets})
endmacro()

function(_ecm_deferred_androiddeployqt)
    _ecm_get_all_targets(all_targets)
    set(module_targets)
    foreach(tgt ${all_targets})
        get_target_property(tgt_type ${tgt} TYPE)
        if(tgt_type STREQUAL "MODULE_LIBRARY")
            list(APPEND module_targets "$<TARGET_FILE:${tgt}>")
        endif()
    endforeach()
    file(GENERATE OUTPUT "module-plugins" CONTENT "${module_targets}")
endfunction()
cmake_language(DEFER DIRECTORY "${CMAKE_SOURCE_DIR}" CALL _ecm_deferred_androiddeployqt)

function(ecm_androiddeployqt5 QTANDROID_EXPORTED_TARGET ECM_ADDITIONAL_FIND_ROOT_PATH)
    set(EXPORT_DIR "${CMAKE_BINARY_DIR}/${QTANDROID_EXPORTED_TARGET}_build_apk/")
    if (Qt5Core_VERSION VERSION_LESS 5.14.0)
        set(EXECUTABLE_DESTINATION_PATH "${EXPORT_DIR}/libs/${CMAKE_ANDROID_ARCH_ABI}/lib${QTANDROID_EXPORTED_TARGET}.so")
    else()
        set(EXECUTABLE_DESTINATION_PATH "${EXPORT_DIR}/libs/${CMAKE_ANDROID_ARCH_ABI}/lib${QTANDROID_EXPORTED_TARGET}_${CMAKE_ANDROID_ARCH_ABI}.so")
    endif()
    set(QML_IMPORT_PATHS "")
    # add build directory to the search path as well, so this works without installation
    if (EXISTS ${CMAKE_BINARY_DIR}/lib)
        set(QML_IMPORT_PATHS ${CMAKE_BINARY_DIR}/lib)
    endif()
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
    if (QML_IMPORT_PATHS)
        set(DEFINE_QML_IMPORT_PATHS "\"qml-import-paths\": \"${QML_IMPORT_PATHS}\",")
    endif()

    set(EXTRA_PREFIX_DIRS "\"${CMAKE_BINARY_DIR}\"")
    foreach(prefix ${ECM_ADDITIONAL_FIND_ROOT_PATH})
        set(EXTRA_PREFIX_DIRS "${EXTRA_PREFIX_DIRS}, \"${prefix}\"")
    endforeach()

    if (Qt5Core_VERSION VERSION_LESS 5.14.0)
        set(_deployment_file_template "${_CMAKE_ANDROID_DIR}/deployment-file.json.in")
    else()
        set(_deployment_file_template "${_CMAKE_ANDROID_DIR}/deployment-file-qt514.json.in")
    endif()
    string(TOLOWER "${CMAKE_HOST_SYSTEM_NAME}" _LOWER_CMAKE_HOST_SYSTEM_NAME)
    configure_file("${_deployment_file_template}" "${CMAKE_BINARY_DIR}/${QTANDROID_EXPORTED_TARGET}-deployment.json.in1")
    file(GENERATE OUTPUT "${CMAKE_BINARY_DIR}/${QTANDROID_EXPORTED_TARGET}-deployment.json.in2"
                  INPUT  "${CMAKE_BINARY_DIR}/${QTANDROID_EXPORTED_TARGET}-deployment.json.in1")

    if (CMAKE_GENERATOR STREQUAL "Unix Makefiles")
        set(arguments "\\$(ARGS)")
    endif()

    function(havestl var access VALUE)
        if (NOT VALUE STREQUAL "")
            # look for ++ and .so as in libc++.so
            string (REGEX MATCH "\"[^ ]+\\+\\+[^ ]*\.so\"" OUT ${VALUE})
            file(WRITE ${CMAKE_BINARY_DIR}/stl "${OUT}")
        endif()
    endfunction()
    function(haveranlib var access VALUE)
        if (NOT VALUE STREQUAL "")
            file(WRITE ${CMAKE_BINARY_DIR}/ranlib "${VALUE}")
        endif()
    endfunction()
    variable_watch(CMAKE_CXX_STANDARD_LIBRARIES havestl)
    variable_watch(CMAKE_RANLIB haveranlib)

    if (NOT TARGET create-apk)
        add_custom_target(create-apk)
        if (NOT DEFINED ANDROID_FASTLANE_METADATA_OUTPUT_DIR)
            set(ANDROID_FASTLANE_METADATA_OUTPUT_DIR ${CMAKE_BINARY_DIR}/fastlane)
        endif()
        add_custom_target(create-fastlane
            COMMAND Python3::Interpreter ${CMAKE_CURRENT_LIST_DIR}/generate-fastlane-metadata.py --output ${ANDROID_FASTLANE_METADATA_OUTPUT_DIR} --source ${CMAKE_SOURCE_DIR}
        )
    endif()

    if (NOT DEFINED ANDROID_APK_OUTPUT_DIR)
        set(ANDROID_APK_OUTPUT_DIR ${EXPORT_DIR})
    endif()

    set(CREATEAPK_TARGET_NAME "create-apk-${QTANDROID_EXPORTED_TARGET}")
    add_custom_target(${CREATEAPK_TARGET_NAME}
        COMMAND ${CMAKE_COMMAND} -E echo "Generating $<TARGET_NAME:${QTANDROID_EXPORTED_TARGET}> with $<TARGET_FILE_DIR:Qt5::qmake>/androiddeployqt"
        COMMAND ${CMAKE_COMMAND} -E remove_directory "${EXPORT_DIR}"
        COMMAND ${CMAKE_COMMAND} -E copy_directory "$<TARGET_PROPERTY:create-apk-${QTANDROID_EXPORTED_TARGET},ANDROID_APK_DIR>" "${EXPORT_DIR}"
        COMMAND ${CMAKE_COMMAND} -E copy "$<TARGET_FILE:${QTANDROID_EXPORTED_TARGET}>" "${EXECUTABLE_DESTINATION_PATH}"
        COMMAND LANG=C ${CMAKE_COMMAND} "-DTARGET=$<TARGET_FILE:${QTANDROID_EXPORTED_TARGET}>" -P ${_CMAKE_ANDROID_DIR}/hasMainSymbol.cmake
        COMMAND LANG=C ${CMAKE_COMMAND} -DINPUT_FILE="${QTANDROID_EXPORTED_TARGET}-deployment.json.in2" -DOUTPUT_FILE="${QTANDROID_EXPORTED_TARGET}-deployment.json" "-DTARGET=$<TARGET_FILE:${QTANDROID_EXPORTED_TARGET}>" "-DOUTPUT_DIR=$<TARGET_FILE_DIR:${QTANDROID_EXPORTED_TARGET}>" "-DEXPORT_DIR=${CMAKE_INSTALL_PREFIX}" "-DECM_ADDITIONAL_FIND_ROOT_PATH=\"${ECM_ADDITIONAL_FIND_ROOT_PATH}\"" "-DANDROID_EXTRA_LIBS=\"${ANDROID_EXTRA_LIBS}\"" "-DUSE_LLVM=\"${USE_LLVM}\"" -P ${_CMAKE_ANDROID_DIR}/specifydependencies.cmake
        COMMAND $<TARGET_FILE_DIR:Qt5::qmake>/androiddeployqt ${ANDROIDDEPLOYQT_EXTRA_ARGS} --gradle --input "${QTANDROID_EXPORTED_TARGET}-deployment.json" --apk "${ANDROID_APK_OUTPUT_DIR}/${QTANDROID_EXPORTED_TARGET}-${CMAKE_ANDROID_ARCH_ABI}.apk" --output "${EXPORT_DIR}" --android-platform android-${ANDROID_SDK_COMPILE_API} --deployment bundled ${arguments}
    )
    # --android-platform above is only available as a command line option
    # This specifies the actual version of the SDK files to use, and
    # can be different from both the NDK target and the Java API target.

    add_custom_target(install-apk-${QTANDROID_EXPORTED_TARGET}
        COMMAND adb install -r "${ANDROID_APK_OUTPUT_DIR}/${QTANDROID_EXPORTED_TARGET}-${CMAKE_ANDROID_ARCH_ABI}.apk"
    )
    add_dependencies(create-apk ${CREATEAPK_TARGET_NAME})
    add_dependencies(${CREATEAPK_TARGET_NAME} create-fastlane)
endfunction()
