# SPDX-FileCopyrightText: 2013 Albert Astals Cid <aacid@kde.org>
# SPDX-FileCopyrightText: 2007 Matthias Kretz <kretz@kde.org>
# SPDX-FileCopyrightText: 2006-2007 Laurent Montel <montel@kde.org>
# SPDX-FileCopyrightText: 2006-2013 Alex Neundorf <neundorf@kde.org>
#
# SPDX-License-Identifier: BSD-3-Clause

#[=======================================================================[
Backward-compatibility support
------------------------------

For all the non-KF projects which reused the KDEFrameworkCompilerSettings
module to get more strict settings.

Kept as is, to be removed on next backward-compatibility-breakage occasion.
#]=======================================================================]

if (NOT CMAKE_CXX_STANDARD)
    if (ECM_GLOBAL_FIND_VERSION VERSION_GREATER_EQUAL 5.84.0)
        set(CMAKE_CXX_STANDARD 17)
        set(CMAKE_CXX_STANDARD_REQUIRED ON)
        set(CMAKE_CXX_EXTENSIONS OFF)
    endif()
endif()

include(KDECompilerSettings NO_POLICY_SCOPE)

add_definitions(-DQT_NO_CAST_TO_ASCII
                -DQT_NO_CAST_FROM_ASCII
                -DQT_NO_URL_CAST_FROM_STRING
                -DQT_NO_CAST_FROM_BYTEARRAY
                -DQT_USE_QSTRINGBUILDER
                -DQT_NO_NARROWING_CONVERSIONS_IN_CONNECT
               )

if (NOT WIN32)
    # Strict iterators can't be used on Windows, they lead to a link error
    # when application code iterates over a QVector<QPoint> for instance, unless
    # Qt itself was also built with strict iterators.
    # See example at https://bugreports.qt.io/browse/AUTOSUITE-946
    add_definitions(-DQT_STRICT_ITERATORS)
endif()

# Some non-KF projects make (ab)use of KDEFrameworkCompilerSettings currently,
# let them only hit this as well when bumping their min. ECM requirement to a newer version.
if (ECM_GLOBAL_FIND_VERSION VERSION_GREATER_EQUAL 5.79.0)
    add_definitions(
        -DQT_NO_KEYWORDS
        -DQT_NO_FOREACH
    )
else()
    add_definitions(-DQT_NO_SIGNALS_SLOTS_KEYWORDS)
endif()

add_definitions(
    -DQT_DEPRECATED_WARNINGS_SINCE=0x060000
    -DKF_DEPRECATED_WARNINGS_SINCE=0x060000
)

if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pedantic")
endif()

if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
   if (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 5.0.0)
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wzero-as-null-pointer-constant" )
   endif()
endif()

if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
   if (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 5.0.0)
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wzero-as-null-pointer-constant" )
   endif()
endif()

if (ECM_GLOBAL_FIND_VERSION VERSION_GREATER_EQUAL 5.80.0)
    include(KDEClangFormat)
    # add clang-format target
    file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES *.cpp *.h *.hpp *.c)
    kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})
endif ()
