
function(list_dependencies target libs)
    execute_process(COMMAND readelf --wide --dynamic ${target} ERROR_VARIABLE readelf_errors OUTPUT_VARIABLE out RESULT_VARIABLE result)

    if (NOT result EQUAL 0)
        message(FATAL_ERROR "readelf failed on ${target} exit(${result}): ${readelf_errors}")
    endif()

    string(REPLACE "\n" ";" lines "${out}")
    set(extralibs ${${libs}})
    foreach(line ${lines})
        string(REGEX MATCH ".*\\(NEEDED\\) +Shared library: +\\[(.+)\\]$" matched ${line})
        set(currentLib ${CMAKE_MATCH_1})

        if(NOT ${currentLib} MATCHES "libQt5.*" AND matched)
            find_file(ourlib-${currentLib} ${currentLib} HINTS ${OUTPUT_DIR} ${EXPORT_DIR} ${ECM_ADDITIONAL_FIND_ROOT_PATH} NO_DEFAULT_PATH PATH_SUFFIXES lib)

            if(ourlib-${currentLib})
                list(APPEND extralibs "${ourlib-${currentLib}}")
            else()
                message(STATUS "could not find ${currentLib} in ${OUTPUT_DIR} ${EXPORT_DIR} ${ECM_ADDITIONAL_FIND_ROOT_PATH}")
            endif()
        endif()
    endforeach()
    set(${libs} ${extralibs} PARENT_SCOPE)
endfunction()

list_dependencies(${TARGET} extralibs)

function(contains_library libpath IS_EQUAL)
    get_filename_component (name ${libpath} NAME)
    unset (IS_EQUAL PARENT_SCOPE)

    foreach (extralib ${extralibs})
        get_filename_component (extralibname ${extralib} NAME)
        if (${extralibname} STREQUAL ${name})
            set (IS_EQUAL TRUE PARENT_SCOPE)
            break()
        endif()
    endforeach()
endfunction()

if (ANDROID_EXTRA_LIBS)
    foreach (extralib ${ANDROID_EXTRA_LIBS})
        contains_library(${extralib} IS_EQUAL)

        if (IS_EQUAL)
            message (STATUS "found duplicate, skipping: " ${extralib})
        else()
            message(STATUS "manually specified extra library: " ${extralib})
            list(APPEND extralibs ${extralib})
        endif()
    endforeach()
endif()

set(extraplugins)
foreach(folder "plugins" "share" "lib/qml") #now we check for folders with extra stuff
    set(plugin "${EXPORT_DIR}/${folder}")
    if(EXISTS "${plugin}")
        list(APPEND extraplugins "${plugin}")
    endif()
endforeach()

if(EXISTS "module-plugins")
    file(READ "module-plugins" moduleplugins)
    foreach(module ${moduleplugins})
        list_dependencies(${module} extralibs)
    endforeach()
    list(REMOVE_DUPLICATES extralibs)
endif()

if(extralibs)
    string(REPLACE ";" "," extralibs "${extralibs}")
    set(extralibs "\"android-extra-libs\": \"${extralibs}\",")
endif()

if(extraplugins)
    string(REPLACE ";" "," extraplugins "${extraplugins}")
    set(extraplugins "\"android-extra-plugins\": \"${extraplugins}\",")
endif()

file(READ "${INPUT_FILE}" CONTENTS)
if(EXISTS "stl") # only provided for legacy pre-Clang toolchains
    file(READ "stl" stl_contents)
endif()

file(READ "ranlib" ranlib_contents)
string(REGEX MATCH ".+/toolchains/llvm/prebuilt/.+/bin/(.+)-ranlib" USE_LLVM ${ranlib_contents})
if (USE_LLVM)
  string(REPLACE "##ANDROID_TOOL_PREFIX##" "llvm" NEWCONTENTS "${CONTENTS}")
  string(REPLACE "##ANDROID_COMPILER_PREFIX##" "${CMAKE_MATCH_1}" NEWCONTENTS "${NEWCONTENTS}")
  string(REPLACE "##USE_LLVM##" true NEWCONTENTS "${NEWCONTENTS}")
else()
  string(REGEX MATCH ".+/toolchains/(.+)-([^\\-]+)/prebuilt/.+/bin/(.+)-ranlib" RANLIB_PATH_MATCH ${ranlib_contents})
  if (NOT RANLIB_PATH_MATCH)
     message(FATAL_ERROR "Couldn't parse the components of the path to ${ranlib_contents}")
  endif()
  string(REPLACE "##ANDROID_TOOL_PREFIX##" "${CMAKE_MATCH_1}" NEWCONTENTS "${CONTENTS}")
  string(REPLACE "##ANDROID_COMPILER_PREFIX##" "${CMAKE_MATCH_3}" NEWCONTENTS "${NEWCONTENTS}")
  string(REPLACE "##USE_LLVM##" false NEWCONTENTS "${NEWCONTENTS}")
endif()

string(REPLACE "##ANDROID_TOOLCHAIN_VERSION##" "${CMAKE_MATCH_2}" NEWCONTENTS "${NEWCONTENTS}") # not used when USE_LLVM is set

string(REPLACE "##EXTRALIBS##" "${extralibs}" NEWCONTENTS "${NEWCONTENTS}")
string(REPLACE "##EXTRAPLUGINS##" "${extraplugins}" NEWCONTENTS "${NEWCONTENTS}")
string(REPLACE "##CMAKE_CXX_STANDARD_LIBRARIES##" "${stl_contents}" NEWCONTENTS "${NEWCONTENTS}")
file(WRITE "${OUTPUT_FILE}" ${NEWCONTENTS})
