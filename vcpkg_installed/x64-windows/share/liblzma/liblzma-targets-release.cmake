#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "liblzma::liblzma" for configuration "Release"
set_property(TARGET liblzma::liblzma APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(liblzma::liblzma PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/lzma.lib"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/liblzma.dll"
  )

list(APPEND _cmake_import_check_targets liblzma::liblzma )
list(APPEND _cmake_import_check_files_for_liblzma::liblzma "${_IMPORT_PREFIX}/lib/lzma.lib" "${_IMPORT_PREFIX}/bin/liblzma.dll" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
