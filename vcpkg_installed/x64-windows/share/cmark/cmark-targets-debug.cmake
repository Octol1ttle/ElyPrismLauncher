#----------------------------------------------------------------
# Generated CMake target import file for configuration "Debug".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "cmark::cmark" for configuration "Debug"
set_property(TARGET cmark::cmark APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(cmark::cmark PROPERTIES
  IMPORTED_IMPLIB_DEBUG "${_IMPORT_PREFIX}/debug/lib/cmark.lib"
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/bin/cmark.dll"
  )

list(APPEND _cmake_import_check_targets cmark::cmark )
list(APPEND _cmake_import_check_files_for_cmark::cmark "${_IMPORT_PREFIX}/debug/lib/cmark.lib" "${_IMPORT_PREFIX}/debug/bin/cmark.dll" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
