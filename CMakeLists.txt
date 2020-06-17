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

if(IS_DIRECTORY ${gemini_root}/src/vendor/msis00)
  message(STATUS "Gemini3D at: ${gemini_root}")
else()
  find_package(Git REQUIRED)
  execute_process(COMMAND ${GIT_EXECUTABLE} clone --depth 1 ${gemini_git} ${gemini_root}
    RESULT_VARIABLE _gitok
    TIMEOUT 60)
  if(NOT _gitok STREQUAL 0)
    message(FATAL_ERROR "could not get Gemini via Git, return code ${_gitok}")
  endif()
endif()

add_subdirectory(${gemini_root}/src/vendor/msis00 ${PROJECT_BINARY_DIR}/msis)

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/matlab.cmake)

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/octave.cmake)
