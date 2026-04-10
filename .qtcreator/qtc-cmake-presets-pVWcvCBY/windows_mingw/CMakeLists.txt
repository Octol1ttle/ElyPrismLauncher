
        cmake_minimum_required(VERSION 3.15)

        project(preset-probe)

        set(file_path_value_list QT_HOST_PATH CMAKE_MAKE_PROGRAM)
        if (CMAKE_SYSTEM_NAME STREQUAL "Android")
            # Mapping to compiler prefixes
            set(__ANDROID_i686-linux-android i686-linux-android)
            set(__ANDROID_x86_64-linux-android x86_64-linux-android)
            set(__ANDROID_aarch64-linux-android aarch64-linux-android)
            set(__ANDROID_arm-linux-androideabi armv7a-linux-androideabi)

            # Save the compiler as "aarch64-linux-android30-clang"  instead of just "clang"
            set(CMAKE_C_COMPILER
                "${ANDROID_TOOLCHAIN_ROOT}/bin/${__ANDROID_${CMAKE_C_LIBRARY_ARCHITECTURE}}${ANDROID_PLATFORM_LEVEL}-clang${ANDROID_TOOLCHAIN_SUFFIX}" CACHE FILEPATH "" FORCE)
            set(CMAKE_CXX_COMPILER
                "${ANDROID_TOOLCHAIN_ROOT}/bin/${__ANDROID_${CMAKE_CXX_LIBRARY_ARCHITECTURE}}${ANDROID_PLATFORM_LEVEL}-clang++${ANDROID_TOOLCHAIN_SUFFIX}" CACHE FILEPATH "" FORCE)

            if (DEFINED ENV{ANDROID_HOME})
                set(ANDROID_SDK "$ENV{ANDROID_HOME}")
            endif()
            if (DEFINED ENV{ANDROID_SDK_ROOT})
                set(ANDROID_SDK "$ENV{ANDROID_SDK_ROOT}")
            endif()
            list(APPEND file_path_value_list ANDROID_NDK ANDROID_SDK)
        else()
            list(APPEND file_path_value_list CMAKE_C_COMPILER CMAKE_CXX_COMPILER CMAKE_SYSROOT)
        endif()
        foreach (file_path_value IN LISTS file_path_value_list)
            if (${file_path_value})
                set(${file_path_value} "${${file_path_value}}" CACHE FILEPATH "" FORCE)
            endif()
        endforeach()

        foreach (path_value CMAKE_PREFIX_PATH CMAKE_FIND_ROOT_PATH)
            if (${path_value})
                set(${path_value} "${${path_value}}" CACHE PATH "" FORCE)
            endif()
        endforeach()

        set(string_value_list CMAKE_SYSTEM_NAME CMAKE_C_LIBRARY_ARCHITECTURE CMAKE_CXX_LIBRARY_ARCHITECTURE)
        if (NOT CMAKE_SYSTEM_NAME STREQUAL "Android")
            list(APPEND string_value_list CMAKE_C_COMPILER_TARGET CMAKE_CXX_COMPILER_TARGET)
        endif()
        foreach (string_value IN LISTS string_value_list)
            if (${string_value})
                set(${string_value} "${${string_value}}" CACHE STRING "" FORCE)
            endif()
        endforeach()
    