
        set(CMAKE_C_COMPILER "")
        set(CMAKE_CXX_COMPILER "")
        set(VCPKG_TARGET_TRIPLET "x64-windows")
include("C:/Users/Usuario/Desktop/Proyectos/Launcher/vcpkg/scripts/buildsystems/vcpkg.cmake")
        if (VCPKG_TARGET_TRIPLET)
          set(vcpkg_triplet ${VCPKG_TARGET_TRIPLET})
        else()
          if (ANDROID_ABI)
            if (ANDROID_ABI STREQUAL "armeabi-v7a")
              set(vcpkg_triplet arm-neon-android)
            elseif (ANDROID_ABI STREQUAL "arm64-v8a")
              set(vcpkg_triplet arm64-android)
            elseif (ANDROID_ABI STREQUAL "x86")
                set(vcpkg_triplet x86-android)
            elseif (ANDROID_ABI STREQUAL "x86_64")
                set(vcpkg_triplet x64-android)
            else()
                message(FATAL_ERROR "Unsupported Android ABI: ${ANDROID_ABI}")
            endif()
            set(ENV{ANDROID_NDK_HOME} "${ANDROID_NDK}")
          elseif (WIN32)
            if ("$ENV{PROCESSOR_ARCHITECTURE}" STREQUAL "ARM64")
              set(vcpkg_triplet arm64-mingw-static)
            else()
              set(vcpkg_triplet x64-mingw-static)
            endif()
            if (CMAKE_CXX_COMPILER MATCHES ".*/(.*)/cl.exe")
              string(TOLOWER ${CMAKE_MATCH_1} host_arch_lowercase)
              set(vcpkg_triplet ${host_arch_lowercase}-windows)
            endif()
          elseif(APPLE)
            # We're too early to use CMAKE_HOST_SYSTEM_PROCESSOR
            execute_process(
              COMMAND uname -m
              OUTPUT_VARIABLE __apple_host_system_processor
              OUTPUT_STRIP_TRAILING_WHITESPACE)
            if (__apple_host_system_processor MATCHES "arm64")
              set(vcpkg_triplet arm64-osx)
            else()
              set(vcpkg_triplet x64-osx)
            endif()
          else()
            # We're too early to use CMAKE_HOST_SYSTEM_PROCESSOR
            execute_process(
              COMMAND uname -m
              OUTPUT_VARIABLE __linux_host_system_processor
              OUTPUT_STRIP_TRAILING_WHITESPACE)
            if (__linux_host_system_processor MATCHES "aarch64")
              set(vcpkg_triplet arm64-linux)
            else()
              set(vcpkg_triplet x64-linux)
            endif()
          endif()
        endif()

        set(VCPKG_TARGET_TRIPLET ${vcpkg_triplet})
      
        include("C:/Users/Usuario/Desktop/Proyectos/Launcher/vcpkg/scripts/buildsystems/vcpkg.cmake")
      