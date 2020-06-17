cmake_minimum_required(VERSION 3.13)
project(MSIS LANGUAGES Fortran)

enable_testing()

set(gemini_url "https://github.com/gemini3d/gemini")


list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules)

if(NOT gemini_root)
 if(DEFINED ENV{GEMINI_ROOT})
   set(gemini_root $ENV{GEMINI_ROOT})
  else()
    set(gemini_root ${CMAKE_CURRENT_SOURCE_DIR}/../gemini/)
  endif()
endif()

set(msis_path ${gemini_root}/src/vendor/msis00)

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/git.cmake)
clone_if_missing(${gemini_root} ${gemini_url} ${msis_path})

add_subdirectory(${msis_path} ${PROJECT_BINARY_DIR}/msis)

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/matlab.cmake)

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/octave.cmake)
