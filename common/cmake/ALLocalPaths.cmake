# Local paths for IMAS-MATLAB
# This file defines local paths to eliminate AL_COMMON_PATH dependency

# Directory containing CMake modules
set(AL_LOCAL_CMAKE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/common/cmake)

# Directory containing documentation common files
set(AL_LOCAL_DOC_COMMON_DIR ${CMAKE_CURRENT_SOURCE_DIR}/doc/doc_common)

# XSLT processor script
set(AL_LOCAL_XSLTPROC_SCRIPT ${CMAKE_CURRENT_SOURCE_DIR}/common/xsltproc.py)

# Add cmake modules to CMake module path
list(APPEND CMAKE_MODULE_PATH ${AL_LOCAL_CMAKE_DIR})
