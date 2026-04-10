# SPDX-FileCopyrightText: 2022 Albert Astals Cid <aacid@kde.org>
#
# SPDX-License-Identifier: BSD-3-Clause

#[=======================================================================[.rst:
KDEMetaInfoPlatformCheck
------------------------

By including this module there will be an automatic check between the supported
platforms listed in the metainfo.yaml file and the current platform
that is the target of the build

If the current platform that is the target of the build is not supported
a CMake ``FATAL_ERROR`` will be issued

The check can be ignored by setting ``KF_IGNORE_PLATFORM_CHECK`` to ``ON``.

Since 5.93
#]=======================================================================]

option(KF_IGNORE_PLATFORM_CHECK "Ignore the supported platform check against metainfo.yaml" OFF)
if ("$ENV{KF_IGNORE_PLATFORM_CHECK}" STREQUAL "ON")
    message(WARNING "KF_IGNORE_PLATFORM_CHECK set to ON from the environment")
    set(KF_IGNORE_PLATFORM_CHECK ON)
endif()

if (NOT "${KF_IGNORE_PLATFORM_CHECK}")
    file(STRINGS metainfo.yaml MetaInfoContents)
    set(_MetainfoParserInPlatforms false)
    set(_MetainfoFoundSupportedPlatform false)
    set(_MetainfoSupportedPlatforms "")
    foreach(MetaInfoString IN LISTS MetaInfoContents)
        if ("${MetaInfoString}" STREQUAL "platforms:")
            set(_MetainfoParserInPlatforms true)
        elseif(_MetainfoParserInPlatforms AND "${MetaInfoString}" MATCHES ".*name:[ \t\r\n]*(.*)")
            list(APPEND _MetainfoSupportedPlatforms ${CMAKE_MATCH_1})
            if (${CMAKE_MATCH_1} STREQUAL "Linux")
                if (CMAKE_SYSTEM_NAME MATCHES "Linux")
                    set(_MetainfoFoundSupportedPlatform true)
                endif()
            elseif (${CMAKE_MATCH_1} STREQUAL "FreeBSD")
                if (CMAKE_SYSTEM_NAME MATCHES "FreeBSD")
                    set(_MetainfoFoundSupportedPlatform true)
                endif()
            elseif (${CMAKE_MATCH_1} STREQUAL "OpenBSD")
                if (CMAKE_SYSTEM_NAME MATCHES "OpenBSD")
                    set(_MetainfoFoundSupportedPlatform true)
                endif()
            elseif (${CMAKE_MATCH_1} STREQUAL "Windows")
                if (WIN32)
                    set(_MetainfoFoundSupportedPlatform true)
                endif()
            elseif (${CMAKE_MATCH_1} STREQUAL "macOS")
                if (CMAKE_SYSTEM_NAME MATCHES "Darwin")
                    set(_MetainfoFoundSupportedPlatform true)
                endif()
            elseif (${CMAKE_MATCH_1} STREQUAL "Android")
                if (ANDROID)
                    set(_MetainfoFoundSupportedPlatform true)
                endif()
            elseif (${CMAKE_MATCH_1} STREQUAL "iOS")
                if (IOS)
                    set(_MetainfoFoundSupportedPlatform true)
                endif()
            elseif (${CMAKE_MATCH_1} STREQUAL "All")
                set(_MetainfoFoundSupportedPlatform true)
            else()
                list(POP_BACK _MetainfoSupportedPlatforms)
                message(WARNING "Found platform not recognized by the metainfo platform parser: ${CMAKE_MATCH_1}")
            endif()
        elseif("${MetaInfoString}" MATCHES "^[A-Za-z0-9_]+:")
            set(_MetainfoParserInPlatforms false)
        endif()
    endforeach()

    if (NOT _MetainfoFoundSupportedPlatform)
        message(FATAL_ERROR "Your current platform '${CMAKE_SYSTEM_NAME}' is not supported. The list of supported platorms is '${_MetainfoSupportedPlatforms}'.If you think this is a mistake or you are working on enabling the platform please build with the KF_IGNORE_PLATFORM_CHECK variable set to true")
    endif()
endif()
