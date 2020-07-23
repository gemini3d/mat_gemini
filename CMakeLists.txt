cmake_minimum_required(VERSION 3.15)
project(MSIS LANGUAGES Fortran)
enable_testing()

set(gemini_url "https://github.com/gemini3d/gemini3d.git")
set(gemini_tag "v0.6.1")

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

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/matlab.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/octave.cmake)
