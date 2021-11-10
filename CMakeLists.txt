# Matlab (and Python) don't have an easy way to specify test dependencies between files.
# Hence, we use a CMake project to specify depedencies and run tests in parallel.

cmake_minimum_required(VERSION 3.20...3.22)

file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json _libj)
string(JSON PROJECT_VERSION GET ${_libj} mat_gemini version)

project(MatGemini
LANGUAGES NONE
VERSION ${PROJECT_VERSION}
)

enable_testing()

set(CMAKE_TLS_VERIFY true)
set(tmod gemini3d.tests.Test)

find_package(Matlab COMPONENTS MAIN_PROGRAM REQUIRED)

if(NOT Matlab_OK)
  execute_process(COMMAND ${Matlab_MAIN_PROGRAM} -batch "assert(~verLessThan('matlab', '9.9'))"
  RESULT_VARIABLE ret
  TIMEOUT 60
  )
  if(NOT ret EQUAL 0)
    message(FATAL_ERROR "Matlab version is too old. Please upgrade to at least R2020b")
  endif()
  set(Matlab_OK true CACHE BOOL "Matlab is OK")
endif()

# -- setup Gemini3D program
include(ExternalProject)

if(NOT GEMINI_ROOT)
  set(GEMINI_ROOT $ENV{GEMINI_ROOT})
endif()

set(gemini_args
-DBUILD_TESTING:BOOL=off
--install-prefix=${PROJECT_BINARY_DIR}
)

if(CMAKE_BUILD_TYPE)
  list(APPEND cmake_args -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE})
endif()

if(GEMINI_ROOT)
  ExternalProject_Add(GEMINI3D
  SOURCE_DIR ${GEMINI_ROOT}
  CMAKE_ARGS ${gemini_args}
  INACTIVITY_TIMEOUT 15
  CONFIGURE_HANDLED_BY_BUILD true
  )
else()
  string(JSON gemini_url GET ${_libj} gemini3d url)
  string(JSON gemini_tag GET ${_libj} gemini3d tag)

  ExternalProject_Add(GEMINI3D
  GIT_REPOSITORY ${gemini_url}
  GIT_TAG ${gemini_tag}
  CMAKE_ARGS ${gemini_args}
  INACTIVITY_TIMEOUT 15
  CONFIGURE_HANDLED_BY_BUILD true
  )
endif()

ExternalProject_Get_property(GEMINI3D SOURCE_DIR)
cmake_path(NORMAL_PATH SOURCE_DIR OUTPUT_VARIABLE GEMINI_ROOT)
message(STATUS "Gemini3D source: ${GEMINI_ROOT}")

# -- testing

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
