cmake_minimum_required(VERSION 3.19)

include(cmake/policy.cmake)
include(cmake/compiler_find.cmake)
find_c_fortran()

project(MSIS LANGUAGES Fortran)

include(CTest)
if(NOT DEFINED ${PROJECT_NAME}_BUILD_TESTING)
  set(${PROJECT_NAME}_BUILD_TESTING ${BUILD_TESTING})
endif()

option(msis20 "build MSIS 2.0" true)

include(cmake/git.cmake)
include(cmake/libraries.cmake)

if(NOT DEFINED gemini_root)
  if(DEFINED ENV{GEMINI_ROOT})
    set(gemini_root $ENV{GEMINI_ROOT})
  else()
    set(gemini_root ${CMAKE_CURRENT_SOURCE_DIR}/../gemini3d/)
  endif()
endif()

set(msis_path ${gemini_root}/src/vendor/msis00)

if(NOT IS_DIRECTORY ${msis_path})
  # we put inside if() to allow working with existing development code
  git_download(${gemini_root} ${gemini3d_url} ${gemini3d_tag})
endif()

# build msis_setup executable
add_subdirectory(${msis_path} ${PROJECT_BINARY_DIR}/msis)

if(${PROJECT_NAME}_BUILD_TESTING)
  # don't run matlab.cmake from Matlab itself or it can infinite loop CMake on MSIS build
  include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/matlab.cmake)
endif()
