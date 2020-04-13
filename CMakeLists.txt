cmake_minimum_required(VERSION 3.13)
project(MSIS LANGUAGES Fortran)


if(NOT gemini_root)
  if(DEFINED ENV{GEMINI_ROOT})
    set(gemini_root $ENV{GEMINI_ROOT})
  elseif(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/../gemini/)
    set(gemini_root ${CMAKE_CURRENT_SOURCE_DIR}/../gemini/)
  else()
    message(FATAL_ERROR "Please define gemini_root path to gemini")
  endif()
endif()

add_subdirectory(${gemini_root}/src/vendor/msis00 ${PROJECT_BINARY_DIR}/msis)
