option(glow "use GLOW model" on)
option(hwm14 "use HWM14 model")
option(msis2 "use MSIS2 model" on)

set_directory_properties(PROPERTIES EP_UPDATE_DISCONNECTED true)

set(CMAKE_TLS_VERIFY true)

# --- auto-ignore build directory
if(NOT EXISTS ${PROJECT_BINARY_DIR}/.gitignore)
  file(WRITE ${PROJECT_BINARY_DIR}/.gitignore "*")
endif()
