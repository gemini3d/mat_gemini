cmake_minimum_required(VERSION 3.13...${CMAKE_VERSION})

project(MatGemini LANGUAGES NONE)

enable_testing()

option(oldnew "test multiple version of Matlab" OFF)

set(tmod gemini3d.tests.Test)

find_package(Matlab COMPONENTS MAIN_PROGRAM REQUIRED)


add_test(NAME Lint
COMMAND ${Matlab_MAIN_PROGRAM} -batch "assertSuccess(runtests('${tmod}Lint'))"
WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})
set_tests_properties(${n} PROPERTIES
TIMEOUT 90
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


foreach(n DataIO Dryrun Project)

  add_test(NAME ${n}
  COMMAND ${Matlab_MAIN_PROGRAM} -batch "assertSuccess(runtests('${tmod}${n}'))"
  WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})

  set_tests_properties(${n} PROPERTIES
  TIMEOUT 180
  FIXTURES_REQUIRED unit_fxt)

endforeach()

if(oldnew)
  include(VersionScan.cmake)

  set(versions 2019b 2021a)
  # oldest supported and newest known Matlab version (should keep working on newer Matlab)

  version_scan(${versions})
endif()
