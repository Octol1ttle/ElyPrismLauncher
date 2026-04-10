#----------------------------------------------------------------
# Generated CMake target import file for configuration "Debug".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "LZ4::lz4_shared" for configuration "Debug"
set_property(TARGET LZ4::lz4_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(LZ4::lz4_shared PROPERTIES
  IMPORTED_IMPLIB_DEBUG "${_IMPORT_PREFIX}/debug/lib/lz4d.lib"
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/bin/lz4d.dll"
  )

list(APPEND _cmake_import_check_targets LZ4::lz4_shared )
list(APPEND _cmake_import_check_files_for_LZ4::lz4_shared "${_IMPORT_PREFIX}/debug/lib/lz4d.lib" "${_IMPORT_PREFIX}/debug/bin/lz4d.dll" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
