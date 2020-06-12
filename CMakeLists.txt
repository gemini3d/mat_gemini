cmake_minimum_required(VERSION 3.13)
project(MSIS LANGUAGES Fortran)

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
