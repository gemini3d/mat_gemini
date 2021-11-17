include(ExternalProject)

set(gemini_args
-DBUILD_TESTING:BOOL=off
--install-prefix=${PROJECT_BINARY_DIR}
-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
)

file(READ ${PROJECT_SOURCE_DIR}/libraries.json _libj)
string(JSON gemini_url GET ${_libj} gemini3d url)
string(JSON gemini_tag GET ${_libj} gemini3d tag)

ExternalProject_Add(GEMINI3D
GIT_REPOSITORY ${gemini_url}
GIT_TAG ${gemini_tag}
CMAKE_ARGS ${gemini_args}
INACTIVITY_TIMEOUT 15
CONFIGURE_HANDLED_BY_BUILD true
)

ExternalProject_Get_property(GEMINI3D SOURCE_DIR)
cmake_path(NORMAL_PATH SOURCE_DIR OUTPUT_VARIABLE GEMINI_ROOT)
