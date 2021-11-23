# Build Zstandard archive library for .zst files

include(ExternalProject)

if(NOT ZSTD_ROOT)
  set(ZSTD_ROOT ${CMAKE_INSTALL_PREFIX})
endif()

set(zstd_args
-DBUILD_TESTING:BOOL=off
-DCMAKE_BUILD_TYPE=Release
--install-prefix=${ZSTD_ROOT}
)

ExternalProject_Add(ZSTD
GIT_REPOSITORY ${zstd_url}
GIT_TAG ${zstd_tag}
SOURCE_SUBDIR build/cmake
CMAKE_ARGS ${zstd_args}
CMAKE_GENERATOR ${EXTPROJ_GENERATOR}
INACTIVITY_TIMEOUT 15
CONFIGURE_HANDLED_BY_BUILD true
)
