#!/bin/bash
# Bamboo CI script to build and run tests for the Matlab HLI
#
# This script expects to be run from the repository root directory

# Debuggging:
set -e -o pipefail
echo "Loading modules..."

# Set up environment such that module files can be loaded
if test -f /etc/profile.d/modules.sh ;then
. /etc/profile.d/modules.sh
else
. /usr/share/Modules/init/sh
fi
module purge

# Check for TOOLCHAIN
TOOLCHAIN=${TOOLCHAIN:-foss-2023b}
# Load modules that correspond to toolchain
case "$TOOLCHAIN" in
  *-2020b)
echo "... 2020b"
MODULES=(
    CMake/3.24.3-GCCcore-10.2.0
    Boost/1.74.0-GCC-10.2.0  # AL-Core
    Python/3.8.6-GCCcore-10.2.0  # documentation
    libxml2/2.9.10-GCCcore-10.2.0  # AL-Core
    MDSplus/7.131.6-GCCcore-10.2.0  # backend
    MDSplus-Java/7.131.6-GCCcore-10.2.0-Java-11  # backend
    UDA/2.7.5-GCC-10.2.0  # backend
    MATLAB/2020b-GCCcore-10.2.0-Java-11
    MATLAB-Engine/2020b-GCCcore-10.2.0-Java-11
)
  ;;&
  *foss-2020b)
echo "... foss-2020b"
MODULES=(${MODULES[@]}
    HDF5/1.10.7-gompi-2020b  # backend
)
CMAKE_ARGS=(${CMAKE_ARGS[@]}
    -DCMAKE_C_COMPILER=${CC:-gcc}
    -DCMAKE_CXX_COMPILER=${CXX:-g++}
)
  ;;&
  *intel-2020b)
echo "... intel-2020b"
MODULES=(${MODULES[@]}
    HDF5/1.10.7-iimpi-2020b  # backend
)
CMAKE_ARGS=(${CMAKE_ARGS[@]}
    -DCMAKE_C_COMPILER=${CC:-icc}
    -DCMAKE_CXX_COMPILER=${CXX:-icpc}
)
  ;;
  *-2023b)
echo "... 2023b"
module load "${MODULES[@]}"
MODULES=(
    CMake/3.27.6-GCCcore-13.2.0
    Python/3.11.5-GCCcore-13.2.0
    libxml2/2.11.5-GCCcore-13.2.0  # AL-Core
    MDSplus/7.153.3-GCCcore-13.2.0  # backend
    Python/3.11.5-GCCcore-13.2.0  # documentation
    MATLAB/2023b-r5-GCCcore-13.2.0
)
  ;;&
  *foss-2023b)
echo "... foss-2023b"
MODULES=(${MODULES[@]}
    HDF5/1.14.3-gompi-2023b  # backend
    Boost/1.83.0-GCC-13.2.0  # AL-Core
    UDA/2.9.3-GCC-13.2.0  # backend
)
CMAKE_ARGS=(${CMAKE_ARGS[@]}
    -DCMAKE_C_COMPILER=${CC:-gcc}
    -DCMAKE_CXX_COMPILER=${CXX:-g++}
)
  ;;&
  *intel-2023b)
echo "... intel-2023b"
MODULES=(${MODULES[@]}
    HDF5/1.14.3-iimpi-2023b  # backend
    Boost/1.83.0-intel-compilers-2023.2.1 # AL-Core
    UDA/2.9.3-intel-compilers-2023.2.1 # backend
)
CMAKE_ARGS=(${CMAKE_ARGS[@]}
    -DCMAKE_C_COMPILER=${CC:-icx}
    -DCMAKE_CXX_COMPILER=${CXX:-icpx}
)
  ;;
esac
echo "${MODULES[@]}" | tr " " "\n"

module load "${MODULES[@]}"

# Debuggging:
echo "Done loading modules"
set -x

# Ensure the build directory is clean:
rm -rf build

# CMake configuration:
CMAKE_ARGS=(
  -D "CMAKE_INSTALL_PREFIX=$(pwd)/test-install/"
  # Enable all backends
  -D AL_BACKEND_HDF5=${AL_BACKEND_HDF5:-ON}
  -D AL_BACKEND_MDSPLUS=${AL_BACKEND_MDSPLUS:-ON}
  -D AL_BACKEND_UDA=${AL_BACKEND_UDA:-ON}
  # Build MDSplus models
  -D AL_BUILD_MDSPLUS_MODELS=${AL_BUILD_MDSPLUS_MODELS:-ON}
  # Download dependencies from HTTPS (using an access token):
  -D AL_DOWNLOAD_DEPENDENCIES=${AL_DOWNLOAD_DEPENDENCIES:-ON}
  -D AL_CORE_GIT_REPOSITORY=${AL_CORE_GIT_REPOSITORY:-https://github.com/iterorganization/IMAS-Core.git}
  -D AL_PLUGINS_GIT_REPOSITORY=${AL_PLUGINS_GIT_REPOSITORY:-https://github.com/iterorganization/IMAS-Core-Plugins.git}
  -D DD_GIT_REPOSITORY=${DD_GIT_REPOSITORY:-https://github.com/iterorganization/IMAS-Data-Dictionary.git}
  -D AL_PLUGINS_VERSION=${AL_PLUGINS_VERSION:-develop}
  # DD version: can be set with DD_VERSION env variable, otherwise use latest main
  -D DD_VERSION=${DD_VERSION:-main}
  # AL Core version: can be set with AL_CORE_VERSION env variable, otherwise use latest main
  -D AL_CORE_VERSION=${AL_CORE_VERSION:-main}
  # HLI options
  -D AL_EXAMPLES=${AL_EXAMPLES:-ON}
  -D AL_TESTS=${AL_TESTS:-ON}
  -D AL_PLUGINS=${AL_PLUGINS:-ON}
  # Build documentation
  -D AL_HLI_DOCS=${AL_HLI_DOCS:-ON}
  # Work around Boost linker issues on 2020b toolchain
  -D Boost_NO_BOOST_CMAKE=${Boost_NO_BOOST_CMAKE:-ON}
  -D CMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD:-17}
)
# Note: compilers are set as environment variables in the Bamboo config
cmake -B build "${CMAKE_ARGS[@]}"

# Build
make -C build -j8 all

# Create test database, point USER env variable to the test database
rm -rf testdb
export USER="$(pwd)/testdb"
# Test
export ARGS="--output-on-failure --output-junit ctest.xml -V"
make -C build test

# Test install
make -C build install

# List installed files
ls -lR test-install
