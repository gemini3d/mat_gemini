cmake_minimum_required(VERSION 3.13)
project(MSIS LANGUAGES Fortran)

enable_testing()
set(CTEST_TEST_TIMEOUT 300)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules)

if(NOT gemini_root)
 if(DEFINED ENV{GEMINI_ROOT})
   set(gemini_root $ENV{GEMINI_ROOT})
  else()
    set(gemini_root ${CMAKE_CURRENT_SOURCE_DIR}/../gemini/)
  endif()
endif()

if(IS_DIRECTORY ${gemini_root})
  message(STATUS "using ${gemini_root}")
else()
  find_package(Git REQUIRED)
  execute_process(COMMAND "${GIT_EXECUTABLE}" "clone" "https://github.com/gemini3d/gemini" "${gemini_root}"
    RESULT_VARIABLE _git_ok
    TIMEOUT 60)
endif()

add_subdirectory(${gemini_root}/src/vendor/msis00 ${PROJECT_BINARY_DIR}/msis)

# ----
# unfortunately, GNU Octave 5.2.0 with Octave-NetCDF still has bugs serious enough to prevent use
# We look forward to reenabling Octave with Gemini.

find_package(Matlab COMPONENTS MAIN_PROGRAM)
if(NOT Matlab_FOUND)
  message(STATUS "Matlab tests not available from CMake.")
  return()
endif()

# other sources of info that aren't as easy to use
# * appdata\version.xml
# * appdata\prodcontents.json
# I have observed over the years that this directory name is universally used.
string(REGEX MATCH "R([0-9][0-9][0-9][0-9][a-z])" Matlab_RELEASE ${Matlab_ROOT_DIR})
matlab_get_version_from_release_name(${Matlab_RELEASE} Matlab_VERSION)

if(Matlab_VERSION AND Matlab_VERSION VERSION_LESS 9.6)
  message(STATUS "Matlab >= R2019a required for -batch mode")
  return()
endif()

add_test(NAME Lint COMMAND ${Matlab_MAIN_PROGRAM} -batch "setup; r=runtests('test_lint'); assert(~any(cell2mat({r.Failed})), 'fail')"
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

add_test(NAME Unit COMMAND ${Matlab_MAIN_PROGRAM} -batch "setup; r=runtests('test_unit'); assert(~any(cell2mat({r.Failed})), 'fail')"
WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

add_test(NAME Project COMMAND ${Matlab_MAIN_PROGRAM} -batch "setup; r=runtests('test_project'); assert(~any(cell2mat({r.Failed})), 'fail')"
WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
