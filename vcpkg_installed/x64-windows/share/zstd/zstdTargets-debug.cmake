#----------------------------------------------------------------
# Generated CMake target import file for configuration "Debug".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "zstd::libzstd_shared" for configuration "Debug"
set_property(TARGET zstd::libzstd_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(zstd::libzstd_shared PROPERTIES
  IMPORTED_IMPLIB_DEBUG "${_IMPORT_PREFIX}/debug/lib/zstd.lib"
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/bin/zstd.dll"
  )

list(APPEND _cmake_import_check_targets zstd::libzstd_shared )
list(APPEND _cmake_import_check_files_for_zstd::libzstd_shared "${_IMPORT_PREFIX}/debug/lib/zstd.lib" "${_IMPORT_PREFIX}/debug/bin/zstd.dll" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
