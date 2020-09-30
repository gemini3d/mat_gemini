cmake_minimum_required(VERSION 3.15)

if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
  message(FATAL_ERROR "use cmake -B build or similar to avoid building in-source, which is messy")
endif()

set(CMAKE_CONFIGURATION_TYPES "Release;RelWithDebInfo;Debug" CACHE STRING "Build type selections" FORCE)
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "default build type")
endif()

project(MSIS LANGUAGES Fortran)

include(CTest)
if(NOT DEFINED ${PROJECT_NAME}_BUILD_TESTING)
  set(${PROJECT_NAME}_BUILD_TESTING ${BUILD_TESTING})
endif()

set(gemini_url "https://github.com/gemini3d/gemini3d.git")
set(gemini_tag "master")

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/git.cmake)

if(NOT gemini_root)
  if(DEFINED ENV{GEMINI_ROOT})
    set(gemini_root $ENV{GEMINI_ROOT})
  else()
    set(gemini_root ${CMAKE_CURRENT_SOURCE_DIR}/../gemini3d/)
  endif()
endif()

set(msis_path ${gemini_root}/src/vendor/msis00)

if(NOT IS_DIRECTORY ${gemini_root})
  # we put inside if() to allow working with existing development code
  git_download(${gemini_root} ${gemini_url} ${gemini_tag})
endif()

# build msis_setup executable
add_subdirectory(${msis_path} ${PROJECT_BINARY_DIR}/msis)

if(${PROJECT_NAME}_BUILD_TESTING)
  # don't run matlab.cmake from Matlab itself or it can infinite loop CMake on MSIS build
  include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/matlab.cmake)
endif()
