include(ExternalProject)

if(NOT GEMINI_ROOT)
  set(GEMINI_ROOT ${CMAKE_INSTALL_PREFIX})
endif()

set(gemini3d_args
-DBUILD_TESTING:BOOL=off
-Dmpi:BOOL=on
-Dmsis2:BOOL=on
-Dglow:BOOL=on
-Dhdf5:BOOL=on
-Dnetcdf:BOOL=off
--install-prefix=${GEMINI_ROOT}
)

ExternalProject_Add(GEMINI3D_RELEASE
GIT_REPOSITORY ${gemini3d_url}
GIT_TAG ${gemini3d_tag}
CMAKE_ARGS ${gemini3d_args} -DCMAKE_BUILD_TYPE=Release
CMAKE_GENERATOR ${EXTPROJ_GENERATOR}
INACTIVITY_TIMEOUT 15
CONFIGURE_HANDLED_BY_BUILD true
)

set(GEMINI_RUN ${GEMINI_ROOT}/bin/gemini3d.run)

set(GEMINI_BIN ${GEMINI_ROOT}/bin/gemini.bin)

set(GEMINI_COMPARE ${GEMINI_ROOT}/bin/gemini3d.compare)

set(GEMINI_FEATURES "REALBITS:64 MPI GLOW MSIS2 HDF5")
