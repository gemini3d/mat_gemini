# Create offline installable archive of this repository
cmake_minimum_required(VERSION 3.17)

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
  set(archive mat_gemini.tar.bz2)
endif()

set(exclude
--exclude-vcs
--exclude=.github/
--exclude=.archive/
--exclude=+test/data/
--exclude=+test/ref_data.json
--exclude=code-coverage/
--exclude=test-results/
--exclude=resources/project/
--exclude=build*/
)


message(STATUS "create archive ${archive}")
execute_process(
COMMAND ${tar} --create --file ${archive} --bzip2 ${exclude} .
WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/..
RESULT_VARIABLE ret
ERROR_VARIABLE err
)
if(NOT ret EQUAL 0)
  message(FATAL_ERROR "Failed to create archive ${archive}:
  ${ret}: ${err}")
endif()
