include(ExternalProject)


cmake_path(SET GEMINI_ROOT ${PROJECT_BINARY_DIR})

set(gemini_args
-DCMAKE_BUILD_TYPE=Release
-DBUILD_TESTING:BOOL=off
-Dmpi:BOOL=on
-Dmsis2:BOOL=${msis2}
-Dglow:BOOL=${glow}
-Dhdf5:BOOL=on
-Dhwm14:BOOL=${hwm14}
-Dnetcdf:BOOL=off
-Dcpp:BOOL=on
-DCMAKE_INSTALL_PREFIX:PATH=${PROJECT_BINARY_DIR}
)
if(CMAKE_PREFIX_PATH)
  list(APPEND gemini_args -DCMAKE_PREFIX_PATH:PATH=${CMAKE_PREFIX_PATH})
endif()
if(MPI_ROOT)
  list(APPEND gemini_args -DMPI_ROOT:PATH=${MPI_ROOT})
endif()

file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json lib_json)
string(JSON gemini3d_url GET ${lib_json} gemini3d url)
if(gemini3d_tag)
  message(STATUS "overriding Gemini3D Git tag with ${gemini3d_tag}")
else()
  string(JSON gemini3d_tag GET ${lib_json} gemini3d tag)
endif()

ExternalProject_Add(GEMINI3D
GIT_REPOSITORY ${gemini3d_url}
GIT_TAG ${gemini3d_tag}
CMAKE_ARGS ${gemini_args}
CMAKE_GENERATOR ${EXTPROJ_GENERATOR}
INACTIVITY_TIMEOUT 15
CONFIGURE_HANDLED_BY_BUILD true
)
