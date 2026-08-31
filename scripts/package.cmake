# Create offline installable archive of this repository
cmake_minimum_required(VERSION 3.31)

if(NOT DEFINED archive)
  set(archive mat_gemini.zip)
endif()


file(ARCHIVE_CREATE OUTPUT ${archive}
PATHS ./
FORMAT zip
WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/..
VERBOSE
)
