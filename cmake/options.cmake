option(glow "use GLOW model" on)
option(hwm14 "use HWM14 model")
option(msis2 "use MSIS2 model" on)

set_directory_properties(PROPERTIES EP_UPDATE_DISCONNECTED true)

option(CMAKE_TLS_VERIFY "Verify TLS certificates when downloading dependencies" on)
