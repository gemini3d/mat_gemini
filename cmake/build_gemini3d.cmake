include(ExternalProject)

if(NOT GEMINI_ROOT)
  set(GEMINI_ROOT ${CMAKE_INSTALL_PREFIX})
endif()

set(gemini_args
-DBUILD_TESTING:BOOL=off
-Dmpi:BOOL=on
-Dmsis2:BOOL=on
-Dglow:BOOL=on
-Dhdf5:BOOL=on
-Dnetcdf:BOOL=off
--install-prefix=${GEMINI_ROOT}
)

file(READ ${PROJECT_SOURCE_DIR}/libraries.json _libj)
string(JSON gemini_url GET ${_libj} gemini3d url)
string(JSON gemini_tag GET ${_libj} gemini3d tag)

ExternalProject_Add(GEMINI3D_RELEASE
GIT_REPOSITORY ${gemini_url}
GIT_TAG ${gemini_tag}
CMAKE_ARGS ${gemini_args} -DCMAKE_BUILD_TYPE=Release
CMAKE_GENERATOR ${EXTPROJ_GENERATOR}
INACTIVITY_TIMEOUT 15
CONFIGURE_HANDLED_BY_BUILD true
)

set(GEMINI_RUN ${GEMINI_ROOT}/bin/gemini3d.run)

set(GEMINI_BIN ${GEMINI_ROOT}/bin/gemini.bin)

set(GEMINI_COMPARE ${GEMINI_ROOT}/bin/gemini3d.compare)

set(GEMINI_FEATURES "REALBITS:64 MPI GLOW MSIS2 HDF5")
