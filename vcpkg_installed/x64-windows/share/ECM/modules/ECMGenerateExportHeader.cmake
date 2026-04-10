# SPDX-FileCopyrightText: 2019 Friedrich W. H. Kossebau <kossebau@kde.org>
#
# SPDX-License-Identifier: BSD-3-Clause

#[=======================================================================[.rst:
ECMGenerateExportHeader
-----------------------

This module provides the ``ecm_generate_export_header`` function for
generating export macros for libraries with version-based control over
visibility of and compiler warnings for deprecated API for the library user,
as well as over excluding deprecated API and their implementation when
building the library itself.

For preparing some values useful in the context it also provides a function
``ecm_export_header_format_version``.

::

  ecm_generate_export_header(<library_target_name>
      VERSION <version>
      [BASE_NAME <base_name>]
      [GROUP_BASE_NAME <group_base_name>]
      [EXPORT_MACRO_NAME <export_macro_name>]
      [EXPORT_FILE_NAME <export_file_name>]
      [DEPRECATED_MACRO_NAME <deprecated_macro_name>]
      [NO_EXPORT_MACRO_NAME <no_export_macro_name>]
      [INCLUDE_GUARD_NAME <include_guard_name>]
      [STATIC_DEFINE <static_define>]
      [PREFIX_NAME <prefix_name>]
      [DEPRECATED_BASE_VERSION <deprecated_base_version>]
      [DEPRECATION_VERSIONS <deprecation_version> [<deprecation_version2> [...]]]
      [EXCLUDE_DEPRECATED_BEFORE_AND_AT <exclude_deprecated_before_and_at_version>]
      [NO_BUILD_SET_DEPRECATED_WARNINGS_SINCE]
      [NO_DEFINITION_EXPORT_TO_BUILD_INTERFACE]
      [USE_VERSION_HEADER [<version_file_name>]] #  Since 5.106
      [VERSION_BASE_NAME <version_base_name>] #  Since 5.106
      [VERSION_MACRO_NAME <version_macro_name>] #  Since 5.106
      [CUSTOM_CONTENT_FROM_VARIABLE <variable>]
  )

``VERSION`` specifies the version of the library, given in the format
"<major>.<minor>.<patchlevel>".

``GROUP_BASE_NAME`` specifies the name to use for the macros defining
library group default values. If set, this will generate code supporting
``<group_base_name>_NO_DEPRECATED_WARNINGS``,
``<group_base_name>_DISABLE_DEPRECATED_BEFORE_AND_AT``,
``<group_base_name>_DEPRECATED_WARNINGS_SINCE``  and
``<group_base_name>_NO_DEPRECATED`` (see below).
If not set, the generated code will ignore any such macros.

``DEPRECATED_BASE_VERSION`` specifies the default version before and at which
deprecated API is disabled. Possible values are "0", "CURRENT" (which
resolves to <version>) and a version string in the format
"<major>.<minor>.<patchlevel>". The default is the value of
"<exclude_deprecated_before_and_at_version>" if set, or "<major>.0.0", with
<major> taken from <version>.

``DEPRECATION_VERSIONS`` specifies versions in "<major>.<minor>" format in
which API was declared deprecated. Any version used with the generated
macro ``<prefix_name><base_name>_DEPRECATED_VERSION(major, minor, text)``
or ``<prefix_name><base_name>_DEPRECATED_VERSION_BELATED(major, minor, textmajor, textminor, text)``
needs to be listed here, otherwise the macro will fail to work.

``EXCLUDE_DEPRECATED_BEFORE_AND_AT`` specifies the version for which all API
deprecated before and at should be excluded from the build completely.
Possible values are "0" (default), "CURRENT" (which resolves to <version>)
and a version string in the format "<major>.<minor>.<patchlevel>".

``NO_BUILD_SET_DEPRECATED_WARNINGS_SINCE`` specifies that the definition
``<prefix_name><uppercase_base_name>_DEPRECATED_WARNINGS_SINCE`` will
not be set for the library inside its own build, and thus will be defined
by either explicit definition in the build system configuration or by the
default value mechanism (see below).
The default is that it is set for the build, to the version specified by
``EXCLUDE_DEPRECATED_BEFORE_AND_AT``, so no deprecation warnings are
done for any own deprecated API used in the library implementation itself.

``NO_DEFINITION_EXPORT_TO_BUILD_INTERFACE`` specifies that the definition
``<prefix_name><uppercase_base_name>_DISABLE_DEPRECATED_BEFORE_AND_AT`` will
not be set in the public interface of the library inside its own build, and
the same for the definition
``<prefix_name><uppercase_base_name>_DEPRECATED_WARNINGS_SINCE`` (if not
disabled by ``NO_BUILD_SET_DEPRECATED_WARNINGS_SINCE`` already).
The default is that they are set, to the version specified by
``EXCLUDE_DEPRECATED_BEFORE_AND_AT``, so e.g. test and examples part of the
project automatically build against the full API included in the build and
without any deprecation warnings for it.

``USE_VERSION_HEADER`` defines whether a given header file
``<version_file_name>`` providing macros specifying the library version should
be included in the generated header file. By default angle-brackets are used
for the include statement. To generate includes with double quotes, add
double quotes to the argument string (needs escaping), e.g. ``\"version.h\"``.
The macro from the included version header holding the library version is
given as ``<version_macro_name>`` by the argument ``VERSION_MACRO_NAME`` and
used in the generated code for calculating defaults. If not specified, the
defaults for the version file name and the version macro are derived from
``<version_base_name>`` as passed with ``VERSION_BASE_NAME``, which again
defaults to ``<base_name>`` or otherwise ``<library_target_name>``.
The macro name defaults to ``<uppercase_version_base_name>_VERSION``,
the version file name to ``<lowercase_version_base_name>_version.h``.
Since 5.106.

``CUSTOM_CONTENT_FROM_VARIABLE`` specifies the name of a variable whose
content will be appended at the end of the generated file, before any
final inclusion guard closing. Note that before 5.98 this was broken and
would only append the string passed as argument value.

The function ``ecm_generate_export_header`` defines C++ preprocessor macros
in the generated export header, some for use in the sources of the library
the header is generated for, other for use by projects linking agsinst the
library.

The macros for use in the library C++ sources are these, next to those also
defined by `GenerateExportHeader
<https://cmake.org/cmake/help/latest/module/GenerateExportHeader.html>`_:

``<prefix_name><uppercase_base_name>_DEPRECATED_VERSION(major, minor, text)``
  to use to conditionally set a
  ``<prefix_name><uppercase_base_name>_DEPRECATED`` macro for a class, struct
  or function (other elements to be supported in future versions), depending
  on the visibility macro flags set (see below)

``<prefix_name><uppercase_base_name>_DEPRECATED_VERSION_BELATED(major, minor, textmajor, textminor, text)``
  to use to conditionally set a
  ``<prefix_name><uppercase_base_name>_DEPRECATED`` macro for a class, struct
  or function (other elements to be supported in future versions), depending
  on the visibility macro flags set (see below), with ``major`` & ``minor``
  applied for the logic and ``textmajor`` & ``textminor`` for the warnings message.
  Useful for retroactive tagging of API for the compiler without injecting the
  API into the compiler warning conditions of already released versions.
  Since 5.71.

``<prefix_name><uppercase_base_name>_ENUMERATOR_DEPRECATED_VERSION(major, minor, text)``
  to use to conditionally set a
  ``<prefix_name><uppercase_base_name>_DEPRECATED`` macro for an enumerator, depending
  on the warnings macro flags set (see below). In builds using C++14 standard or earlier,
  where enumerator attributes are not yet supported, the macro will always yield an empty string.
  With MSVC it is also always an empty string for now.
  Since 5.82.

``<prefix_name><uppercase_base_name>_ENUMERATOR_DEPRECATED_VERSION_BELATED(major, minor, textmajor, textminor, text)``
  to use to conditionally set a
  ``<prefix_name><uppercase_base_name>_DEPRECATED`` macro for an enumerator, depending
  on the warnings macro flags set (see below), with ``major`` & ``minor``
  applied for the logic and ``textmajor`` & ``textminor`` for the warnings message.
  In builds using C++14 standard or earlier, where enumerator attributes are not yet supported,
  the macro will always yield an empty string.
  Useful for retroactive tagging of API for the compiler without injecting the
  API into the compiler warning conditions of already released versions.
  With MSVC it is also always an empty string for now.
  Since 5.82.

``<prefix_name><uppercase_base_name>_ENABLE_DEPRECATED_SINCE(major, minor)``
  evaluates to ``TRUE`` or ``FALSE`` depending on the visibility macro flags
  set (see below). To be used mainly with ``#if``/``#endif`` to mark sections
  of code which should be included depending on the visibility requested.

``<prefix_name><uppercase_base_name>_BUILD_DEPRECATED_SINCE(major, minor)``
  evaluates to ``TRUE`` or ``FALSE`` depending on the value of
  ``EXCLUDE_DEPRECATED_BEFORE_AND_AT``. To be used mainly with
  ``#if``/``#endif`` to mark sections of two types of code: implementation
  code for deprecated API and declaration code of deprecated API which only
  may be disabled at build time of the library for BC reasons (e.g. virtual
  methods, see notes below).

``<prefix_name><uppercase_base_name>_EXCLUDE_DEPRECATED_BEFORE_AND_AT``
  holds the version used to exclude deprecated API at build time of the
  library.

The macros used to control visibility when building against the library are:

``<prefix_name><uppercase_base_name>_DISABLE_DEPRECATED_BEFORE_AND_AT``
  definition to set to a value in single hex number version notation
  (``0x<major><minor><patchlevel>``).

``<prefix_name><uppercase_base_name>_NO_DEPRECATED``
  flag to define to disable all deprecated API, being a shortcut for
  settings ``<prefix_name><uppercase_base_name>_DISABLE_DEPRECATED_BEFORE_AND_AT``
  to the current version. If both are set, this flag overrules.

``<prefix_name><uppercase_base_name>_DEPRECATED_WARNINGS_SINCE``
  definition to set to a value in single hex number version notation
  (``0x<major><minor><patchlevel>``). Warnings will be only activated for
  API deprecated up to and including the version. If
  ``<prefix_name><uppercase_base_name>_DISABLE_DEPRECATED_BEFORE_AND_AT``
  is set (directly or via the group default), it will default to that
  version, resulting in no warnings. Otherwise the default is the current
  version, resulting in warnings for all deprecated API.

``<prefix_name><uppercase_base_name>_NO_DEPRECATED_WARNINGS``
  flag to define to disable all deprecation warnings, being a shortcut for
  setting ``<prefix_name><uppercase_base_name>_DEPRECATED_WARNINGS_SINCE``
  to "0". If both are set, this flag overrules.

When the ``GROUP_BASE_NAME`` has been used, the same macros but with the
given ``<group_base_name>`` prefix are available to define the defaults of
these macros, if not explicitly set.

.. warning::
  The tricks applied here for hiding deprecated API to the compiler
  when building against a library do not work for all deprecated API:

  * virtual methods need to stay visible to the compiler to build proper
    virtual method tables for subclasses
  * enumerators from enums cannot be simply removed, as this changes
    auto values of following enumerators, also can poke holes in enumerator
    series used as index into tables

  In such cases the API can be only "hidden" at build time of the library,
  itself, by generated hard coded macro settings, using
  ``<prefix_name><uppercase_base_name>_BUILD_DEPRECATED_SINCE(major, minor)``.

Examples:

Preparing a library "Foo" created by target "foo", which is part of a group
of libraries "Bar", where some API of "Foo" got deprecated at versions
5.0 & 5.12:

.. code-block:: cmake

  ecm_generate_export_header(foo
      GROUP_BASE_NAME BAR
      VERSION ${FOO_VERSION}
      DEPRECATION_VERSIONS 5.0 5.12
  )

In the library "Foo" sources in the headers the API would be prepared like
this, using the generated macros ``FOO_ENABLE_DEPRECATED_SINCE`` and
``FOO_DEPRECATED_VERSION``:

.. code-block:: cpp

  #include <foo_export.h>

  #if FOO_ENABLE_DEPRECATED_SINCE(5, 0)
  /**
    * @deprecated Since 5.0
    */
  FOO_EXPORT
  FOO_DEPRECATED_VERSION(5, 0, "Use doFoo2()")
  void doFoo();
  #endif

  #if FOO_ENABLE_DEPRECATED_SINCE(5, 12)
  /**
    * @deprecated Since 5.12
    */
  FOO_EXPORT
  FOO_DEPRECATED_VERSION(5, 12, "Use doBar2()")
  void doBar();
  #endif

Projects linking against the "Foo" library can control which part of its
deprecated API should be hidden to the compiler by adding a definition
using the ``FOO_DISABLE_DEPRECATED_BEFORE_AND_AT`` macro variable set to the
desired value (in version hex number notation):

.. code-block:: cmake

  add_definitions(-DFOO_DISABLE_DEPRECATED_BEFORE_AND_AT=0x050000)

Or using the macro variable of the group:

.. code-block:: cmake

  add_definitions(-DBAR_DISABLE_DEPRECATED_BEFORE_AND_AT=0x050000)

If both are specified, ``FOO_DISABLE_DEPRECATED_BEFORE_AND_AT`` will take
precedence.

To build a variant of a library with some deprecated API completely left
out from the build, not only optionally invisible to consumers, one uses the
``EXCLUDE_DEPRECATED_BEFORE_AND_AT`` parameter. This is best combined with a
cached CMake variable.

.. code-block:: cmake

  set(EXCLUDE_DEPRECATED_BEFORE_AND_AT 0 CACHE STRING "Control the range of deprecated API excluded from the build [default=0].")

  ecm_generate_export_header(foo
      VERSION ${FOO_VERSION}
      EXCLUDE_DEPRECATED_BEFORE_AND_AT ${EXCLUDE_DEPRECATED_BEFORE_AND_AT}
      DEPRECATION_VERSIONS 5.0 5.12
  )

The macros used in the headers for library consumers are reused for
disabling the API excluded in the build of the library. For disabling the
implementation of that API as well as for disabling deprecated API which
only can be disabled at build time of the library for BC reasons, one
uses the generated macro ``FOO_BUILD_DEPRECATED_SINCE``, like this:

.. code-block:: cpp

  #include <foo_export.h>

  enum Bars {
      One,
  #if FOO_BUILD_DEPRECATED_SINCE(5, 0)
      Two FOO_ENUMERATOR_DEPRECATED_VERSION(5, 0, "Use Three"), // macro available since 5.82
  #endif
      Three,
  };

  #if FOO_ENABLE_DEPRECATED_SINCE(5, 0)
  /**
    * @deprecated Since 5.0
    */
  FOO_EXPORT
  FOO_DEPRECATED_VERSION(5, 0, "Use doFoo2()")
  void doFoo();
  #endif

  #if FOO_ENABLE_DEPRECATED_SINCE(5, 12)
  /**
    * @deprecated Since 5.12
    */
  FOO_EXPORT
  FOO_DEPRECATED_VERSION(5, 12, "Use doBar2()")
  void doBar();
  #endif

  class FOO_EXPORT Foo {
  public:
  #if FOO_BUILD_DEPRECATED_SINCE(5, 0)
      /**
        * @deprecated Since 5.0
        */
      FOO_DEPRECATED_VERSION(5, 0, "Feature removed")
      virtual void doWhat();
  #endif
  };

.. code-block:: cpp

  #if FOO_BUILD_DEPRECATED_SINCE(5, 0)
  void doFoo()
  {
      // [...]
  }
  #endif

  #if FOO_BUILD_DEPRECATED_SINCE(5, 12)
  void doBar()
  {
      // [...]
  }
  #endif

  #if FOO_BUILD_DEPRECATED_SINCE(5, 0)
  void Foo::doWhat()
  {
      // [...]
  }
  #endif

So e.g. if ``EXCLUDE_DEPRECATED_BEFORE_AND_AT`` is set to "5.0.0", the
enumerator ``Two`` as well as the methods ``::doFoo()`` and ``Foo::doWhat()``
will be not available to library consumers. The methods will not have been
compiled into the library binary, and the declarations will be hidden to the
compiler, ``FOO_DISABLE_DEPRECATED_BEFORE_AND_AT`` also cannot be used to
reactivate them.

When using the ``NO_DEFINITION_EXPORT_TO_BUILD_INTERFACE`` and the project
for the "Foo" library includes also tests and examples linking against the
library and using deprecated API (like tests covering it), one better
explicitly sets ``FOO_DISABLE_DEPRECATED_BEFORE_AND_AT`` for those targets
to the version before and at which all deprecated API has been excluded from
the build.
Even more when building against other libraries from the same group "Bar" and
disabling some deprecated API of those libraries using the group macro
``BAR_DISABLE_DEPRECATED_BEFORE_AND_AT``, which also works as default for
``FOO_DISABLE_DEPRECATED_BEFORE_AND_AT``.

To get the hex number style value the helper macro
``ecm_export_header_format_version()`` will be used:

.. code-block:: cmake

  set(EXCLUDE_DEPRECATED_BEFORE_AND_AT 0 CACHE STRING "Control what part of deprecated API is excluded from build [default=0].")

  ecm_generate_export_header(foo
      VERSION ${FOO_VERSION}
      GROUP_BASE_NAME BAR
      EXCLUDE_DEPRECATED_BEFORE_AND_AT ${EXCLUDE_DEPRECATED_BEFORE_AND_AT}
      NO_DEFINITION_EXPORT_TO_BUILD_INTERFACE
      DEPRECATION_VERSIONS 5.0 5.12
  )

  ecm_export_header_format_version(${EXCLUDE_DEPRECATED_BEFORE_AND_AT}
      CURRENT_VERSION ${FOO_VERSION}
      HEXNUMBER_VAR foo_no_deprecated_before_and_at
  )

  # disable all deprecated API up to 5.9.0 from all other libs of group "BAR" that we use ourselves
  add_definitions(-DBAR_DISABLE_DEPRECATED_BEFORE_AND_AT=0x050900)

  add_executable(app app.cpp)
  target_link_libraries(app foo)
  target_compile_definitions(app
       PRIVATE "FOO_DISABLE_DEPRECATED_BEFORE_AND_AT=${foo_no_deprecated_before_and_at}")

Since 5.64.0.
#]=======================================================================]

include(GenerateExportHeader)

cmake_policy(PUSH)
cmake_policy(SET CMP0057 NEW) # if IN_LIST

# helper method
function(_ecm_geh_generate_hex_number _var_name _version)
    set(_hexnumber 0)

    set(version_regex "^([0-9]+)\\.([0-9]+)\\.([0-9]+)$")
    string(REGEX REPLACE ${version_regex} "\\1" _version_major "${_version}")
    string(REGEX REPLACE ${version_regex} "\\2" _version_minor "${_version}")
    string(REGEX REPLACE ${version_regex} "\\3" _version_patch "${_version}")
    set(_outputformat)
    set(_outputformat OUTPUT_FORMAT HEXADECIMAL)
    math(EXPR _hexnumber "${_version_major}*65536 + ${_version_minor}*256 + ${_version_patch}" ${_outputformat})
    set(${_var_name} ${_hexnumber} PARENT_SCOPE)
endfunction()

function(ecm_export_header_format_version _version)
    set(options
    )
    set(oneValueArgs
        CURRENT_VERSION
        STRING_VAR
        HEXNUMBER_VAR
    )
    set(multiValueArgs
    )
    cmake_parse_arguments(ARGS "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if (NOT ARGS_STRING_VAR AND NOT ARGS_HEXNUMBER_VAR)
        message(FATAL_ERROR "No STRING_VAR or HEXNUMBER_VAR passed when calling ecm_export_header_format_version().")
    endif()

    if(_version STREQUAL "CURRENT")
        if (NOT ARGS_CURRENT_VERSION )
            message(FATAL_ERROR "\"CURRENT\" as version value not supported when CURRENT_VERSION not passed on calling ecm_export_header_format_version().")
        endif()
        set(_version ${ARGS_CURRENT_VERSION})
    endif()

    if (ARGS_STRING_VAR)
        set(${ARGS_STRING_VAR} ${_version} PARENT_SCOPE)
    endif()

    if (ARGS_HEXNUMBER_VAR)
        set(_hexnumber 0) # by default build all deprecated API
        if(_version)
            _ecm_geh_generate_hex_number(_hexnumber ${_version})
        endif()
        set(${ARGS_HEXNUMBER_VAR} ${_hexnumber} PARENT_SCOPE)
    endif()
endfunction()


function(ecm_generate_export_header target)
    set(options
        NO_DEFINITION_EXPORT_TO_BUILD_INTERFACE
        NO_BUILD_SET_DEPRECATED_WARNINGS_SINCE
    )
    set(oneValueArgs
        BASE_NAME
        GROUP_BASE_NAME
        EXPORT_FILE_NAME
        DEPRECATED_BASE_VERSION
        VERSION
        VERSION_BASE_NAME
        VERSION_MACRO_NAME
        EXCLUDE_DEPRECATED_BEFORE_AND_AT
        EXPORT_MACRO_NAME
        DEPRECATED_MACRO_NAME
        NO_EXPORT_MACRO_NAME
        INCLUDE_GUARD_NAME
        STATIC_DEFINE
        PREFIX_NAME
        CUSTOM_CONTENT_FROM_VARIABLE
    )
    set(multiValueArgs
        DEPRECATION_VERSIONS
        USE_VERSION_HEADER
    )
    cmake_parse_arguments(ARGS "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # helper string
    set(_version_triple_regexp "^([0-9]+)\\.([0-9]+)\\.([0-9]+)$")
    # args sanity check
    if (NOT ARGS_VERSION)
        message(FATAL_ERROR "No VERSION passed when calling ecm_generate_export_header().")
    elseif(NOT ARGS_VERSION MATCHES ${_version_triple_regexp})
        message(FATAL_ERROR "VERSION expected to be in x.y.z format when calling ecm_generate_export_header().")
    endif()
    if (NOT ARGS_EXCLUDE_DEPRECATED_BEFORE_AND_AT)
        set(ARGS_EXCLUDE_DEPRECATED_BEFORE_AND_AT 0)
    elseif(ARGS_EXCLUDE_DEPRECATED_BEFORE_AND_AT STREQUAL "CURRENT")
        set(ARGS_EXCLUDE_DEPRECATED_BEFORE_AND_AT ${ARGS_VERSION})
    elseif(NOT ARGS_EXCLUDE_DEPRECATED_BEFORE_AND_AT MATCHES ${_version_triple_regexp} AND
           NOT ARGS_EXCLUDE_DEPRECATED_BEFORE_AND_AT STREQUAL "0")
        message(FATAL_ERROR "EXCLUDE_DEPRECATED_BEFORE_AND_AT expected to be in \"x.y.z\" format, \"0\" or \"CURRENT\" when calling ecm_generate_export_header().")
    endif()
    if (NOT DEFINED ARGS_DEPRECATED_BASE_VERSION)
        if (ARGS_EXCLUDE_DEPRECATED_BEFORE_AND_AT)
            set(ARGS_DEPRECATED_BASE_VERSION "${ARGS_EXCLUDE_DEPRECATED_BEFORE_AND_AT}")
        else()
            string(REGEX REPLACE ${_version_triple_regexp} "\\1" _version_major "${ARGS_VERSION}")
            set(ARGS_DEPRECATED_BASE_VERSION "${_version_major}.0.0")
        endif()
    else()
        if(ARGS_DEPRECATED_BASE_VERSION STREQUAL "CURRENT")
            set(ARGS_DEPRECATED_BASE_VERSION ${ARGS_VERSION})
        elseif(NOT ARGS_DEPRECATED_BASE_VERSION MATCHES ${_version_triple_regexp} AND
               NOT ARGS_DEPRECATED_BASE_VERSION STREQUAL "0")
            message(FATAL_ERROR "DEPRECATED_BASE_VERSION expected to be in \"x.y.z\" format, \"0\" or \"CURRENT\" when calling ecm_generate_export_header().")
        endif()
        if (ARGS_DEPRECATED_BASE_VERSION VERSION_LESS ARGS_EXCLUDE_DEPRECATED_BEFORE_AND_AT)
            message(STATUS "DEPRECATED_BASE_VERSION (${ARGS_DEPRECATED_BASE_VERSION}) was lower than EXCLUDE_DEPRECATED_BEFORE_AND_AT (${ARGS_EXCLUDE_DEPRECATED_BEFORE_AND_AT}) when calling ecm_generate_export_header(), raising to that.")
            set(ARGS_DEPRECATED_BASE_VERSION "${ARGS_EXCLUDE_DEPRECATED_BEFORE_AND_AT}")
        endif()
    endif()
    if(NOT ARGS_BASE_NAME)
        set(ARGS_BASE_NAME "${target}")
    endif()
    if(NOT ARGS_VERSION_BASE_NAME)
        set(ARGS_VERSION_BASE_NAME "${ARGS_BASE_NAME}")
    endif()
    string(TOUPPER "${ARGS_BASE_NAME}" _upper_base_name)
    string(TOLOWER "${ARGS_BASE_NAME}" _lower_base_name)
    set(_version_header)
    if (USE_VERSION_HEADER IN_LIST ARGS_KEYWORDS_MISSING_VALUES)
        string(TOLOWER "${ARGS_VERSION_BASE_NAME}" _lower_version_base_name)
        set(_version_header "${_lower_version_base_name}_version.h")
    elseif (DEFINED ARGS_USE_VERSION_HEADER)
        list(LENGTH ARGS_USE_VERSION_HEADER _arg_count)
        if (_arg_count GREATER 1)
            message(FATAL_ERROR "USE_VERSION_HEADER only takes 1 or no arg when calling ecm_generate_export_header().")
        endif()
        set(_version_header ${ARGS_USE_VERSION_HEADER})
    endif()
    if(_version_header)
        if(ARGS_VERSION_MACRO_NAME)
            set(_version_hexnumber "${ARGS_VERSION_MACRO_NAME}")
        else()
            string(TOUPPER "${ARGS_VERSION_BASE_NAME}" _upper_version_base_name)
            set(_version_hexnumber "${_upper_version_base_name}_VERSION")
        endif()
    else()
        _ecm_geh_generate_hex_number(_version_hexnumber "${ARGS_VERSION}")
    endif()

    if(NOT ARGS_EXPORT_FILE_NAME)
        set(ARGS_EXPORT_FILE_NAME "${_lower_base_name}_export.h")
    endif()
    if (ARGS_DEPRECATED_BASE_VERSION STREQUAL "0")
        set(_default_disabled_deprecated_version_hexnumber "0")
    else()
        _ecm_geh_generate_hex_number(_default_disabled_deprecated_version_hexnumber "${ARGS_DEPRECATED_BASE_VERSION}")
    endif()

    set(_macro_base_name "${ARGS_PREFIX_NAME}${_upper_base_name}")
    if (ARGS_EXPORT_MACRO_NAME)
        set(_export_macro_name "${ARGS_EXPORT_MACRO_NAME}")
    else()
        set(_export_macro_name "${_macro_base_name}_EXPORT")
    endif()
    if (ARGS_NO_EXPORT_MACRO_NAME)
        set(_no_export_macro_name "${ARGS_NO_EXPORT_MACRO_NAME}")
    else()
        set(_no_export_macro_name "${_macro_base_name}_NO_EXPORT")
    endif()
    if (ARGS_DEPRECATED_MACRO_NAME)
        set(_deprecated_macro_name "${ARGS_DEPRECATED_MACRO_NAME}")
    else()
        set(_deprecated_macro_name "${_macro_base_name}_DEPRECATED")
    endif()

    if(NOT IS_ABSOLUTE ${ARGS_EXPORT_FILE_NAME})
        set(ARGS_EXPORT_FILE_NAME "${CMAKE_CURRENT_BINARY_DIR}/${ARGS_EXPORT_FILE_NAME}")
    endif()

    set_property(TARGET ${target} APPEND PROPERTY AUTOGEN_TARGET_DEPENDS "${ARGS_EXPORT_FILE_NAME}")
    # build with all the API not excluded, ensure all deprecated API is visible in the build itself
    _ecm_geh_generate_hex_number(_hexnumber ${ARGS_EXCLUDE_DEPRECATED_BEFORE_AND_AT})
    set(_disabling_visibility_definition "${_macro_base_name}_DISABLE_DEPRECATED_BEFORE_AND_AT=${_hexnumber}")
    target_compile_definitions(${target} PRIVATE "${_disabling_visibility_definition}")
    if (NOT ARGS_NO_DEFINITION_EXPORT_TO_BUILD_INTERFACE)
        target_compile_definitions(${target} INTERFACE "$<BUILD_INTERFACE:${_disabling_visibility_definition}>")
    endif()
    if(NOT ARGS_NO_BUILD_SET_DEPRECATED_WARNINGS_SINCE)
        set(_enabling_warnings_definition "${_macro_base_name}_DEPRECATED_WARNINGS_SINCE=${_hexnumber}")
        target_compile_definitions(${target} PRIVATE "${_enabling_warnings_definition}")
        if (NOT ARGS_NO_DEFINITION_EXPORT_TO_BUILD_INTERFACE)
            target_compile_definitions(${target} INTERFACE "$<BUILD_INTERFACE:${_enabling_warnings_definition}>")
        endif()
    endif()

    # for the set of compiler versions supported by ECM/KF we can assume those attributes supported
    # KF6: with C++17 as minimum standard planned, switch to always use [[deprecated(text)]]
    if (CMAKE_C_COMPILER_ID STREQUAL "GNU" OR CMAKE_C_COMPILER_ID MATCHES "Clang")
        set(_decl_deprecated_text_definition "__attribute__ ((__deprecated__(text)))")
    elseif(MSVC)
        set(_decl_deprecated_text_definition "__declspec(deprecated(text))")
    else()
        set(_decl_deprecated_text_definition "${_macro_base_name}_DECL_DEPRECATED")
    endif()
    # generate header file
    set(_output)
    if(_version_header)
        if (_version_header MATCHES "^\".+\"$")
            string(APPEND _output "#include ${_version_header}\n")
        else()
            string(APPEND _output "#include <${_version_header}>\n")
        endif()
    endif()
    string(APPEND _output "
#define ${_macro_base_name}_DECL_DEPRECATED_TEXT(text) ${_decl_deprecated_text_definition}
"
    )
    if (ARGS_GROUP_BASE_NAME)
        string(TOUPPER "${ARGS_GROUP_BASE_NAME}" _upper_group_name)
        string(APPEND _output "
/* Take any defaults from group settings */
#if !defined(${_macro_base_name}_NO_DEPRECATED) && !defined(${_macro_base_name}_DISABLE_DEPRECATED_BEFORE_AND_AT)
#  ifdef ${_upper_group_name}_NO_DEPRECATED
#    define ${_macro_base_name}_NO_DEPRECATED
#  elif defined(${_upper_group_name}_DISABLE_DEPRECATED_BEFORE_AND_AT)
#    define ${_macro_base_name}_DISABLE_DEPRECATED_BEFORE_AND_AT ${_upper_group_name}_DISABLE_DEPRECATED_BEFORE_AND_AT
#  endif
#endif
#if !defined(${_macro_base_name}_DISABLE_DEPRECATED_BEFORE_AND_AT) && defined(${_upper_group_name}_DISABLE_DEPRECATED_BEFORE_AND_AT)
#  define ${_macro_base_name}_DISABLE_DEPRECATED_BEFORE_AND_AT ${_upper_group_name}_DISABLE_DEPRECATED_BEFORE_AND_AT
#endif

#if !defined(${_macro_base_name}_NO_DEPRECATED_WARNINGS) && !defined(${_macro_base_name}_DEPRECATED_WARNINGS_SINCE)
#  ifdef ${_upper_group_name}_NO_DEPRECATED_WARNINGS
#    define ${_macro_base_name}_NO_DEPRECATED_WARNINGS
#  elif defined(${_upper_group_name}_DEPRECATED_WARNINGS_SINCE)
#    define ${_macro_base_name}_DEPRECATED_WARNINGS_SINCE ${_upper_group_name}_DEPRECATED_WARNINGS_SINCE
#  endif
#endif
#if !defined(${_macro_base_name}_DEPRECATED_WARNINGS_SINCE) && defined(${_upper_group_name}_DEPRECATED_WARNINGS_SINCE)
#  define ${_macro_base_name}_DEPRECATED_WARNINGS_SINCE ${_upper_group_name}_DEPRECATED_WARNINGS_SINCE
#endif
"
        )
    endif()
    string(APPEND _output "
#if defined(${_macro_base_name}_NO_DEPRECATED)
#  undef ${_deprecated_macro_name}
#  define ${_deprecated_macro_name}_EXPORT ${_export_macro_name}
#  define ${_deprecated_macro_name}_NO_EXPORT ${_no_export_macro_name}
#elif defined(${_macro_base_name}_NO_DEPRECATED_WARNINGS)
#  define ${_deprecated_macro_name}
#  define ${_deprecated_macro_name}_EXPORT ${_export_macro_name}
#  define ${_deprecated_macro_name}_NO_EXPORT ${_no_export_macro_name}
#else
#  define ${_deprecated_macro_name} ${_macro_base_name}_DECL_DEPRECATED
#  define ${_deprecated_macro_name}_EXPORT ${_macro_base_name}_DECL_DEPRECATED_EXPORT
#  define ${_deprecated_macro_name}_NO_EXPORT ${_macro_base_name}_DECL_DEPRECATED_NO_EXPORT
#endif
"
    )
    if (ARGS_EXCLUDE_DEPRECATED_BEFORE_AND_AT)
        message(STATUS "Excluding from build all API deprecated before and at: ${ARGS_EXCLUDE_DEPRECATED_BEFORE_AND_AT}")
        # TODO: the generated code ideally would emit a warning if some consumer used a value
        # smaller then what the the build was done with
        _ecm_geh_generate_hex_number(_excluded_before_and_at_version_hexnumber "${ARGS_EXCLUDE_DEPRECATED_BEFORE_AND_AT}")
        string(APPEND _output "
/* Build was done with the API removed deprecated before: ${ARGS_EXCLUDE_DEPRECATED_BEFORE_AND_AT} */
#define ${_macro_base_name}_EXCLUDE_DEPRECATED_BEFORE_AND_AT ${_excluded_before_and_at_version_hexnumber}

#ifdef ${_macro_base_name}_DISABLE_DEPRECATED_BEFORE_AND_AT
#  if ${_macro_base_name}_DISABLE_DEPRECATED_BEFORE_AND_AT < ${_macro_base_name}_EXCLUDE_DEPRECATED_BEFORE_AND_AT
#    undef ${_macro_base_name}_DISABLE_DEPRECATED_BEFORE_AND_AT
#    define ${_macro_base_name}_DISABLE_DEPRECATED_BEFORE_AND_AT ${_macro_base_name}_EXCLUDE_DEPRECATED_BEFORE_AND_AT
#  endif
#endif

#define ${_macro_base_name}_BUILD_DEPRECATED_SINCE(major, minor) (((major<<16)|(minor<<8)) > ${_macro_base_name}_EXCLUDE_DEPRECATED_BEFORE_AND_AT)
"
        )
    else()
        string(APPEND _output "
/* No deprecated API had been removed from build */
#define ${_macro_base_name}_EXCLUDE_DEPRECATED_BEFORE_AND_AT 0

#define ${_macro_base_name}_BUILD_DEPRECATED_SINCE(major, minor) 1
"
        )
    endif()
    string(APPEND _output "
#ifdef ${_macro_base_name}_NO_DEPRECATED
#  define ${_macro_base_name}_DISABLE_DEPRECATED_BEFORE_AND_AT ${_version_hexnumber}
#endif
#ifdef ${_macro_base_name}_NO_DEPRECATED_WARNINGS
#  define ${_macro_base_name}_DEPRECATED_WARNINGS_SINCE 0
#endif

#ifndef ${_macro_base_name}_DEPRECATED_WARNINGS_SINCE
#  ifdef ${_macro_base_name}_DISABLE_DEPRECATED_BEFORE_AND_AT
#    define ${_macro_base_name}_DEPRECATED_WARNINGS_SINCE ${_macro_base_name}_DISABLE_DEPRECATED_BEFORE_AND_AT
#  else
#    define ${_macro_base_name}_DEPRECATED_WARNINGS_SINCE ${_version_hexnumber}
#  endif
#endif

#ifndef ${_macro_base_name}_DISABLE_DEPRECATED_BEFORE_AND_AT
#  define ${_macro_base_name}_DISABLE_DEPRECATED_BEFORE_AND_AT ${_default_disabled_deprecated_version_hexnumber}
#endif

#ifdef ${_deprecated_macro_name}
#  define ${_macro_base_name}_ENABLE_DEPRECATED_SINCE(major, minor) (((major<<16)|(minor<<8)) > ${_macro_base_name}_DISABLE_DEPRECATED_BEFORE_AND_AT)
#else
#  define ${_macro_base_name}_ENABLE_DEPRECATED_SINCE(major, minor) 0
#endif
"
    )
    if (DEFINED ARGS_DEPRECATION_VERSIONS)
        set(_major_versions)
        foreach(_version ${ARGS_DEPRECATION_VERSIONS})
            _ecm_geh_generate_hex_number(_version_hexnumber "${_version}.0")
            string(REPLACE "." "_" _underscored_version "${_version}")
            string(REGEX REPLACE "^([0-9]+)\\.([0-9]+)$" "\\1"
 _version_major "${_version}")
            # IN_LIST only since cmake 3.3
            set(_in_list FALSE)
            foreach(_v ${_major_versions})
                if (_v STREQUAL _version_major)
                    set(_in_list TRUE)
                    break()
                endif()
            endforeach()
            if(NOT _in_list)
                list(APPEND _major_versions ${_version_major})
            endif()

            string(APPEND _output "
#if ${_macro_base_name}_DEPRECATED_WARNINGS_SINCE >= ${_version_hexnumber}
#  define ${_macro_base_name}_DEPRECATED_VERSION_${_underscored_version}(text) ${_macro_base_name}_DECL_DEPRECATED_TEXT(text)
#else
#  define ${_macro_base_name}_DEPRECATED_VERSION_${_underscored_version}(text)
#endif
"
            )
        endforeach()
        foreach(_major_version ${_major_versions})
            string(APPEND _output
"#define ${_macro_base_name}_DEPRECATED_VERSION_${_major_version}(minor, text)      ${_macro_base_name}_DEPRECATED_VERSION_${_major_version}_##minor(text)
"
            )
        endforeach()

        string(APPEND _output
"#define ${_macro_base_name}_DEPRECATED_VERSION(major, minor, text) ${_macro_base_name}_DEPRECATED_VERSION_##major(minor, \"Since \"#major\".\"#minor\". \" text)
"
        )
        string(APPEND _output
"#define ${_macro_base_name}_DEPRECATED_VERSION_BELATED(major, minor, textmajor, textminor, text) ${_macro_base_name}_DEPRECATED_VERSION_##major(minor, \"Since \"#textmajor\".\"#textminor\". \" text)
"
        )
        # reusing the existing version-controlled deprecation macros for enumerator deprecation macros
        # to avoid having to repeat all the explicit version variants
        # TODO: MSVC seems to have issues with __declspec(deprecated) being used as enumerator attribute
        # and deals only with standard [[deprecated(text)]].
        # But for now we have to keep the deprecation macros using the compiler-specific attributes,
        # because CMake's GenerateExportHeader uses the latter for the export macros and
        # at least GCC does not support both being used mixed e.g. on the same class or method.
        # Possibly needs to be solved by forking GenerateExportHeader to get complete control.
        if(NOT MSVC)
            string(APPEND _output
"#if defined(__cpp_enumerator_attributes) && __cpp_enumerator_attributes >= 201411
#  define ${_macro_base_name}_ENUMERATOR_DEPRECATED_VERSION(major, minor, text) ${_macro_base_name}_DEPRECATED_VERSION(major, minor, text)
#  define ${_macro_base_name}_ENUMERATOR_DEPRECATED_VERSION_BELATED(major, minor, textmajor, textminor, text) ${_macro_base_name}_DEPRECATED_VERSION_BELATED(major, minor, textmajor, textminor, text)
#else
#  define ${_macro_base_name}_ENUMERATOR_DEPRECATED_VERSION(major, minor, text)
#  define ${_macro_base_name}_ENUMERATOR_DEPRECATED_VERSION_BELATED(major, minor, textmajor, textminor, text)
#endif
"
            )
        else()
            string(APPEND _output
"// Not yet implemented for MSVC
#define ${_macro_base_name}_ENUMERATOR_DEPRECATED_VERSION(major, minor, text)
#define ${_macro_base_name}_ENUMERATOR_DEPRECATED_VERSION_BELATED(major, minor, textmajor, textminor, text)
"
            )
        endif()
    endif()
    if (ARGS_CUSTOM_CONTENT_FROM_VARIABLE)
        if(DEFINED "${ARGS_CUSTOM_CONTENT_FROM_VARIABLE}")
            string(APPEND _output "${${ARGS_CUSTOM_CONTENT_FROM_VARIABLE}}\n")
        else()
            message(DEPRECATION "Passing a value instead of a variable name with CUSTOM_CONTENT_FROM_VARIABLE. Since 5.98, use the name of a variable.")
            string(APPEND _output "${ARGS_CUSTOM_CONTENT_FROM_VARIABLE}\n")
        endif()
    endif()

    # prepare optional arguments to pass through to generate_export_header
    set(_include_guard_name_args)
    if (ARGS_INCLUDE_GUARD_NAME)
        set(_include_guard_name_args INCLUDE_GUARD_NAME "${ARGS_INCLUDE_GUARD_NAME}")
    endif()
    set(_export_macro_name_args)
    if (ARGS_EXPORT_MACRO_NAME)
        set(_export_macro_name_args EXPORT_MACRO_NAME "${ARGS_EXPORT_MACRO_NAME}")
    endif()
    set(_no_export_macro_name_args)
    if (ARGS_NO_EXPORT_MACRO_NAME)
        set(_no_export_macro_name_args ARGS_NO_EXPORT_MACRO_NAME "${ARGS_NO_EXPORT_MACRO_NAME}")
    endif()
    set(_prefix_name_args)
    if (ARGS_PREFIX_NAME)
        set(_prefix_name_args PREFIX_NAME "${ARGS_PREFIX_NAME}")
    endif()
    set(_static_define_args)
    if (ARGS_STATIC_DEFINE)
        set(_static_define_args STATIC_DEFINE "${ARGS_STATIC_DEFINE}")
    endif()
    generate_export_header(${target}
        BASE_NAME ${ARGS_BASE_NAME}
        DEPRECATED_MACRO_NAME "${_macro_base_name}_DECL_DEPRECATED"
        ${_prefix_name_args}
        ${_export_macro_name_args}
        ${_no_export_macro_name_args}
        ${_static_define_args}
        EXPORT_FILE_NAME "${ARGS_EXPORT_FILE_NAME}"
        ${_include_guard_name_args}
        CUSTOM_CONTENT_FROM_VARIABLE _output
    )
endfunction()

cmake_policy(POP)
