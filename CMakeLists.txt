# Matlab (and Python) don't have an easy way to specify
# test dependencies between test code files.
# Hence, we use a CMake project to specify depedencies and run tests in parallel.

cmake_minimum_required(VERSION 3.20)

file(READ ${CMAKE_CURRENT_LIST_DIR}/codemeta.json _libj)
string(JSON PROJECT_VERSION GET ${_libj} version)

project(MatGemini
LANGUAGES NONE
VERSION ${PROJECT_VERSION}
)

enable_testing()

include(cmake/options.cmake)

set(tmod gemini3d.test.Test)

find_package(Matlab COMPONENTS MAIN_PROGRAM REQUIRED)
if(Matlab_VERSION_STRING AND Matlab_VERSION_STRING VERSION_LESS 9.9)
  message(STATUS "Matlab >= 9.9 required, found ${Matlab_VERSION_STRING}")
endif()

# -- setup Gemini3D program
# For repeatability, build MatGemini Gemini3D binaries under mat_gemini/build

include(cmake/gemini3d.cmake)

# -- MatGemini testing

cmake_path(SET setup_m ${CMAKE_CURRENT_SOURCE_DIR}/setup.m)

add_test(NAME Lint
COMMAND ${Matlab_MAIN_PROGRAM} -batch "r=runtests('${tmod}Lint'); assert(~isempty(r)), assertSuccess(r)"
WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})
set_tests_properties(Lint PROPERTIES
TIMEOUT 120
FIXTURES_SETUP lint_fxt
)

# --- unit tests

set(unit_tests Unit Grid)

foreach(n ${unit_tests})

  add_test(NAME ${n}
  COMMAND ${Matlab_MAIN_PROGRAM} -batch "r=runtests('${tmod}${n}'); assert(~isempty(r)), assertSuccess(r)"
  WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
  )

endforeach()

# --- MSIS tests

add_test(NAME MSIS
COMMAND ${Matlab_MAIN_PROGRAM} -batch "run('${setup_m}'), r=runtests('${tmod}MSIS'); assert(~isempty(r)), assertSuccess(r)"
)

set_tests_properties(${unit_tests} MSIS PROPERTIES
TIMEOUT 120
REQUIRED_FILES ${setup_m}
FIXTURES_REQUIRED lint_fxt
FIXTURES_SETUP unit_fxt
)
set_tests_properties(MSIS PROPERTIES
ENVIRONMENT "GEMINI_ROOT=${GEMINI_ROOT}"
)

# --- data download tests

add_test(NAME DataIO
COMMAND ${Matlab_MAIN_PROGRAM} -batch "run('${setup_m}'), r=runtests('${tmod}DataIO'); assert(~isempty(r)), assertSuccess(r)"
)

set_tests_properties(DataIO PROPERTIES
TIMEOUT 120
REQUIRED_FILES ${setup_m}
FIXTURES_REQUIRED unit_fxt
FIXTURES_SETUP io_fxt
)

# --- integration tests

add_test(NAME Dryrun
COMMAND ${Matlab_MAIN_PROGRAM} -batch "run('${setup_m}'), r=runtests('${tmod}Dryrun'); assert(~isempty(r)), assertSuccess(r)"
)
set_tests_properties(Dryrun PROPERTIES
TIMEOUT 240
REQUIRED_FILES ${setup_m}
FIXTURES_REQUIRED io_fxt
FIXTURES_SETUP dryrun_fxt
ENVIRONMENT "GEMINI_ROOT=${GEMINI_ROOT}"
)

add_test(NAME Project
COMMAND ${Matlab_MAIN_PROGRAM} -batch "run('${setup_m}'), r=runtests('${tmod}Project'); assert(~isempty(r)), assertSuccess(r)"
)
set_tests_properties(Project PROPERTIES
TIMEOUT 240
REQUIRED_FILES ${setup_m}
FIXTURES_REQUIRED dryrun_fxt
ENVIRONMENT "GEMINI_ROOT=${GEMINI_ROOT}"
)
