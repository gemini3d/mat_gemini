cmake_minimum_required(VERSION 3.14...3.21)

project(MatGemini LANGUAGES NONE)

enable_testing()

option(oldnew "test multiple version of Matlab" OFF)

set(tmod gemini3d.tests.Test)

find_package(Matlab COMPONENTS MAIN_PROGRAM REQUIRED)


add_test(NAME Lint
COMMAND ${Matlab_MAIN_PROGRAM} -batch "assertSuccess(runtests('${tmod}Lint'))"
WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})
set_tests_properties(Lint PROPERTIES
TIMEOUT 120
FIXTURES_SETUP lint_fxt)

foreach(n Unit Grid MSIS)

  add_test(NAME ${n}
  COMMAND ${Matlab_MAIN_PROGRAM} -batch "assertSuccess(runtests('${tmod}${n}'))"
  WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})

  set_tests_properties(${n} PROPERTIES
  TIMEOUT 120
  FIXTURES_REQUIRED lint_fxt
  FIXTURES_SETUP unit_fxt)

endforeach()

add_test(NAME DataIO
COMMAND ${Matlab_MAIN_PROGRAM} -batch "assertSuccess(runtests('${tmod}DataIO'))"
WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})

set_tests_properties(DataIO PROPERTIES
TIMEOUT 120
FIXTURES_REQUIRED unit_fxt
FIXTURES_SETUP io_fxt)


foreach(n Dryrun Project)

  add_test(NAME ${n}
  COMMAND ${Matlab_MAIN_PROGRAM} -batch "assertSuccess(runtests('${tmod}${n}'))"
  WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})

  set_tests_properties(${n} PROPERTIES
  TIMEOUT 240
  FIXTURES_REQUIRED io_fxt)

endforeach()

if(oldnew)
  include(cmake/VersionScan.cmake)

  set(versions 2020b 2021b)
  # oldest supported and newest known Matlab version (should keep working on newer Matlab)

  version_scan(${versions})
endif()
