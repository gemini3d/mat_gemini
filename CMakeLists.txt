#  cmake --workflow default

cmake_minimum_required(VERSION 3.25)

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

# --- MSIS tests

add_test(NAME MSIS COMMAND ${Matlab_MAIN_PROGRAM} -batch "buildtool test:msis")

# --- Unit tests

add_test(NAME Unit
COMMAND ${Matlab_MAIN_PROGRAM} -batch "buildtool test:unit"
)

# --- integration tests

add_test(NAME Project
COMMAND ${Matlab_MAIN_PROGRAM} -batch "buildtool test:gemini"
)

set_property(TEST Unit MSIS Project PROPERTY ENVIRONMENT "GEMINI_ROOT=${GEMINI_ROOT}")
