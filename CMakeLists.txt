# Matlab (and Python) don't have an easy way to specify
# test dependencies between test code files.
# Hence, we use a CMake project to specify depedencies and run tests in parallel.

cmake_minimum_required(VERSION 3.20)

project(MatGemini
LANGUAGES NONE
VERSION 5.5.0
)

enable_testing()

include(cmake/options.cmake)

find_package(Matlab COMPONENTS MAIN_PROGRAM REQUIRED)

# -- setup Gemini3D program
# For repeatability, build MatGemini Gemini3D binaries under mat_gemini/build
if(NOT DEFINED ENV{GEMINI_ROOT})
  include(cmake/gemini3d.cmake)
endif()

# -- MatGemini testing

set(setup_m ${CMAKE_CURRENT_SOURCE_DIR}/setup.m)

add_test(NAME Lint COMMAND ${Matlab_MAIN_PROGRAM} -batch "buildtool check")
set_property(TEST Lint PROPERTY FIXTURES_SETUP lint_fxt)

# --- unit tests

foreach(n IN ITEMS Unit Grid)
  add_test(NAME ${n}
    COMMAND ${Matlab_MAIN_PROGRAM} -batch "buildtool test('Test${n}/*');"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  )
endforeach()

# --- MSIS tests

add_test(NAME MSIS COMMAND ${Matlab_MAIN_PROGRAM} -batch "run('${setup_m}'), buildtool test('TestMSIS/*');")

set_tests_properties(Unit Grid MSIS PROPERTIES
REQUIRED_FILES ${setup_m}
FIXTURES_REQUIRED lint_fxt
FIXTURES_SETUP unit_fxt
)
# --- data download tests

add_test(NAME DataIO
COMMAND ${Matlab_MAIN_PROGRAM} -batch "run('${setup_m}'), buildtool test('TestDataIO/*')"
)

set_tests_properties(DataIO PROPERTIES
FIXTURES_REQUIRED unit_fxt
FIXTURES_SETUP io_fxt
)

# --- integration tests

add_test(NAME Dryrun
COMMAND ${Matlab_MAIN_PROGRAM} -batch "run('${setup_m}'), buildtool test('TestDryrun/*')"
)
set_tests_properties(Dryrun PROPERTIES
FIXTURES_REQUIRED io_fxt
FIXTURES_SETUP dryrun_fxt
)

add_test(NAME Project
COMMAND ${Matlab_MAIN_PROGRAM} -batch "run('${setup_m}'), buildtool test('TestProject/*')"
)
set_property(TEST Project PROPERTY FIXTURES_REQUIRED dryrun_fxt)

set_property(TEST Dryrun MSIS Project PROPERTY ENVIRONMENT "GEMINI_ROOT=${GEMINI_ROOT}")
