
####### Expanded from @PACKAGE_INIT@ by configure_package_config_file() #######
####### Any changes to this file will be overwritten by the next CMake run ####
####### The input file was tomlplusplusConfig.cmake.meson.in ########

get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../" ABSOLUTE)

macro(set_and_check _var _file)
  set(${_var} "${_file}")
  if(NOT EXISTS "${_file}")
    message(FATAL_ERROR "File or directory ${_file} referenced by variable ${_var} does not exist !")
  endif()
endmacro()
####################################################################################


# If tomlplusplus::tomlplusplus target is not defined it will be included
if(NOT TARGET tomlplusplus::tomlplusplus)

  if (1)
    set(imported_type UNKNOWN)
  else()
    set(imported_type INTERFACE)
  endif()

  # Import tomlplusplus interface library
  add_library(tomlplusplus::tomlplusplus ${imported_type} IMPORTED)
  set_target_properties(tomlplusplus::tomlplusplus PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${PACKAGE_PREFIX_DIR}/include")

  # Require C++17
  target_compile_features(tomlplusplus::tomlplusplus INTERFACE cxx_std_17)

  # Set the path to the installed library so that users can link to it
  if (1)
    set_target_properties(tomlplusplus::tomlplusplus PROPERTIES
       IMPORTED_CONFIGURATIONS "DEBUG;RELEASE"
          IMPORTED_LOCATION_DEBUG "${PACKAGE_PREFIX_DIR}/debug/lib/tomlplusplus.lib"
          IMPORTED_LOCATION_RELEASE "${PACKAGE_PREFIX_DIR}/lib/tomlplusplus.lib"
    )
    # compile_options not quoted on purpose
    target_compile_options(tomlplusplus::tomlplusplus INTERFACE -DTOML_HEADER_ONLY=0 -DTOML_SHARED_LIB=1)
  endif()

endif()
