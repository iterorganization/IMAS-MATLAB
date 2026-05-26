#!/bin/bash
#SBATCH --job-name=IMAS-Matlab-build
#SBATCH --partition=rigel
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G
#SBATCH --time=01:00:00
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err

module purge
module load CMake/3.27.6-GCCcore-13.2.0 \
            Python/3.11.5-GCCcore-13.2.0 \
            libxml2/2.11.5-GCCcore-13.2.0 \
            MDSplus/7.153.3-GCCcore-13.2.0 \
            MATLAB/2023b-r5-GCCcore-13.2.0 \
            HDF5/1.14.3-gompi-2023b \
            Boost/1.83.0-GCC-13.2.0 \
            UDA/2.9.3-GCC-13.2.0 \
            SciPy-bundle/2023.11-gfbf-2023b \
            Ninja/1.11.1-GCCcore-13.2.0 \
            Blitz++/1.0.2-GCCcore-13.2.0 \
            scikit-build-core/0.9.3-GCCcore-13.2.0 \
            Cython/3.0.10-GCCcore-13.2.0 \
            cython-cmake/0.2.0-GCCcore-13.2.0 \
            setuptools-scm/8.1.0-GCCcore-13.2.0 \
            typing-extensions/4.10.0-GCCcore-13.2.0


# Clean previous build
rm -rf build test-install

# CMake configure
cmake -B build \
    -DCMAKE_INSTALL_PREFIX="$(pwd)/test-install/" \
    -DAL_BACKEND_HDF5=ON \
    -DAL_BACKEND_MDSPLUS=ON \
    -DAL_BACKEND_UDA=ON \
    -DAL_BUILD_MDSPLUS_MODELS=ON \
    -DAL_PYTHON_BINDINGS=no-build-isolation \
    -DAL_DOWNLOAD_DEPENDENCIES=ON \
    -DDD_GIT_REPOSITORY=https://github.com/iterorganization/IMAS-Data-Dictionary.git \
    -DDD_VERSION=4.1.1 \
    -DBoost_NO_BOOST_CMAKE=ON \
    -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_C_COMPILER=gcc \
    -DCMAKE_CXX_COMPILER=g++ \
    -DAL_TESTS=OFF \
    -DAL_EXAMPLES=OFF \
    -DAL_PLUGINS=OFF

# Build and install (use all allocated CPUs)
cmake --build build --target install --parallel "${SLURM_CPUS_PER_TASK:-16}"

echo "Build and install completed successfully."
