# Matlab (and Python) don't have an easy way to specify
# test dependencies between test code files.
# Hence, we use a CMake project to specify depedencies and run tests in parallel.

cmake_minimum_required(VERSION 3.20...3.22)

file(READ ${CMAKE_CURRENT_LIST_DIR}/codemeta.json _libj)
string(JSON PROJECT_VERSION GET ${_libj} version)

project(MatGemini
LANGUAGES NONE
VERSION ${PROJECT_VERSION}
)

enable_testing()
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

set(CMAKE_TLS_VERIFY true)

include(cmake/options.cmake)

set(tmod gemini3d.tests.Test)

find_package(Matlab COMPONENTS MAIN_PROGRAM REQUIRED)

if(NOT Matlab_OK)
  execute_process(COMMAND ${Matlab_MAIN_PROGRAM} -nojvm -batch "assert(~verLessThan('matlab', '9.9'))"
  RESULT_VARIABLE ret
  TIMEOUT 60
  )
  if(NOT ret EQUAL 0)
    message(FATAL_ERROR "Matlab version is too old. Please upgrade Matlab >= R2020b")
  endif()
  set(Matlab_OK true CACHE BOOL "Matlab is OK")
endif()

# -- setup Gemini3D program
# For repeatability, build MatGemini Gemini3D binaries under mat_gemini/build

include(cmake/build_gemini3d.cmake)

# -- MatGemini testing

add_test(NAME Lint
COMMAND ${Matlab_MAIN_PROGRAM} -batch "assertSuccess(runtests('${tmod}Lint'))"
WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})
set_tests_properties(Lint PROPERTIES
TIMEOUT 120
FIXTURES_SETUP lint_fxt
)

foreach(n Unit Grid MSIS)

add_test(NAME ${n}
COMMAND ${Matlab_MAIN_PROGRAM} -batch "assertSuccess(runtests('${tmod}${n}'))"
WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
)

set_tests_properties(${n} PROPERTIES
TIMEOUT 120
FIXTURES_REQUIRED lint_fxt
FIXTURES_SETUP unit_fxt
)

endforeach()

add_test(NAME DataIO
COMMAND ${Matlab_MAIN_PROGRAM} -batch "assertSuccess(runtests('${tmod}DataIO'))"
WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
)

set_tests_properties(DataIO PROPERTIES
TIMEOUT 120
FIXTURES_REQUIRED unit_fxt
FIXTURES_SETUP io_fxt
)

foreach(n Dryrun Project)

add_test(NAME ${n}
COMMAND ${Matlab_MAIN_PROGRAM} -batch "assertSuccess(runtests('${tmod}${n}'))"
WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
)

set_tests_properties(${n} PROPERTIES
TIMEOUT 240
FIXTURES_REQUIRED io_fxt
)

endforeach()

set_tests_properties(MSIS Dryrun Project PROPERTIES
ENVIRONMENT "GEMINI_ROOT=${GEMINI_ROOT}"
)
