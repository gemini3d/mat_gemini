# Create offline installable archive of this repository
cmake_minimum_required(VERSION 3.31)

find_package(Git REQUIRED)

# ensure this project has the Git submodules updated
execute_process(COMMAND ${GIT_EXECUTABLE} submodule update --init
WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/..
RESULT_VARIABLE ret
)
if(NOT ret EQUAL 0)
  message(FATAL_ERROR "could not get matlab-stdlib Git submodule")
endif()

find_program(tar NAMES tar)
if(NOT tar)
  message(FATAL_ERROR "Could not find tar program")
endif()

if(NOT DEFINED archive)
  set(archive mat_gemini.zip)
endif()


file(ARCHIVE_CREATE OUTPUT ${archive}
PATHS ./
FORMAT zip
WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/..
VERBOSE
)
