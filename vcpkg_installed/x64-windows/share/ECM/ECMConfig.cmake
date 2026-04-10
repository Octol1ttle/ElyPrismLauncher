get_filename_component(VCPKG_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_DIR}/../../" ABSOLUTE)

####### Expanded from @PACKAGE_INIT@ by configure_package_config_file() #######
####### Any changes to this file will be overwritten by the next CMake run ####
####### The input file was ECMConfig.cmake.in                            ########

get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../" ABSOLUTE)

macro(set_and_check _var _file)
  set(${_var} "${_file}")
  if(NOT EXISTS "${_file}")
    message(FATAL_ERROR "File or directory ${_file} referenced by variable ${_var} does not exist !")
  endif()
endmacro()

macro(check_required_components _NAME)
  foreach(comp ${${_NAME}_FIND_COMPONENTS})
    if(NOT ${_NAME}_${comp}_FOUND)
      if(${_NAME}_FIND_REQUIRED_${comp})
        set(${_NAME}_FOUND FALSE)
      endif()
    endif()
  endforeach()
endmacro()

####################################################################################

set(ECM_FIND_MODULE_DIR "${PACKAGE_PREFIX_DIR}/share/ECM/find-modules/")

set(ECM_MODULE_DIR "${PACKAGE_PREFIX_DIR}/share/ECM/modules/")

set(ECM_KDE_MODULE_DIR "${PACKAGE_PREFIX_DIR}/share/ECM/kde-modules/")

set(ECM_PREFIX "${VCPKG_IMPORT_PREFIX}")

set(ECM_MODULE_PATH "${ECM_MODULE_DIR}" "${ECM_FIND_MODULE_DIR}" "${ECM_KDE_MODULE_DIR}")

set(ECM_GLOBAL_FIND_VERSION "${ECM_FIND_VERSION}")

include("${ECM_MODULE_DIR}/ECMUseFindModules.cmake")
