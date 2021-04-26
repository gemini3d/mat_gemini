cmake_minimum_required(VERSION 3.13...${CMAKE_VERSION})

project(MatGemini LANGUAGES NONE)

enable_testing()

option(oldnew "test multiple version of Matlab" OFF)

set(tmod gemini3d.tests.Test)

find_package(Matlab COMPONENTS MAIN_PROGRAM REQUIRED)

foreach(n ALint AUnit Grid MSIS ZData ZDryrun ZProject)

  add_test(NAME ${n}
  COMMAND ${Matlab_MAIN_PROGRAM} -batch "assertSuccess(runtests('${tmod}${n}'))"
  WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})
  set_tests_properties(${n} PROPERTIES TIMEOUT 900)

endforeach()

if(oldnew)
  include(VersionScan.cmake)

  set(versions 2019b 2021a)
  # oldest supported and newest known Matlab version (should keep working on newer Matlab)

  version_scan(${versions})
endif()
