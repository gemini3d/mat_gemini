set(CMAKE_EXPORT_COMPILE_COMMANDS on)

if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
  message(FATAL_ERROR "use cmake -B build or similar to avoid building in-source, which is messy")
endif()

if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.20)
  # ninja path resolution
  cmake_policy(SET CMP0116 NEW)
  # explicit source file extensions
  cmake_policy(SET CMP0115 NEW)
endif()
