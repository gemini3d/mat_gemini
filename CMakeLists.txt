# Matlab (and Python) don't have an easy way to specify
# test dependencies between test code files.
# Hence, we use a CMake project to specify depedencies and run tests in parallel.

cmake_minimum_required(VERSION 3.20)

if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
  message(FATAL_ERROR "Please use out-of-source builds
  cmake -Bbuild")
endif()

project(MatGemini
LANGUAGES NONE
VERSION 5.5.0
)

enable_testing()

file(GENERATE OUTPUT .gitignore CONTENT "*")

include(cmake/options.cmake)

find_package(Matlab COMPONENTS MAIN_PROGRAM REQUIRED)

# -- setup Gemini3D program
# For repeatability, build MatGemini Gemini3D binaries under mat_gemini/build
if(NOT DEFINED ENV{GEMINI_ROOT})
  include(cmake/gemini3d.cmake)
endif()

# -- MatGemini testing

add_test(NAME Lint COMMAND ${Matlab_MAIN_PROGRAM} -batch "buildtool check")

# --- unit tests

foreach(n IN ITEMS Unit Grid)
  add_test(NAME ${n}
    COMMAND ${Matlab_MAIN_PROGRAM} -batch "buildtool test('Test${n}/*');"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  )
endforeach()

# --- MSIS tests

add_test(NAME MSIS COMMAND ${Matlab_MAIN_PROGRAM} -batch "buildtool test('TestMSIS/*');")

# --- data download tests

add_test(NAME DataIO
COMMAND ${Matlab_MAIN_PROGRAM} -batch "buildtool test('TestDataIO/*')"
)

# --- integration tests

add_test(NAME Dryrun
COMMAND ${Matlab_MAIN_PROGRAM} -batch "buildtool test('TestDryrun/*')"
)
set_property(TEST Dryrun PROPERTY FIXTURES_SETUP dryrun_fxt)
set_property(TEST Dryrun DataIO PROPERTY RUN_SERIAL true)

add_test(NAME Project
COMMAND ${Matlab_MAIN_PROGRAM} -batch "buildtool test('TestProject/*')"
)
set_property(TEST Project PROPERTY FIXTURES_REQUIRED dryrun_fxt)

set_property(TEST Dryrun MSIS Project PROPERTY ENVIRONMENT "GEMINI_ROOT=${GEMINI_ROOT}")
