# CMake build configuration for the Access Layer C++ HLI
cmake_minimum_required( VERSION 3.16 )
if(POLICY CMP0144)
  cmake_policy(SET CMP0144 NEW)
endif()
if(WIN32)
 if(DEFINED CMAKE_TOOLCHAIN_FILE AND
     CMAKE_TOOLCHAIN_FILE MATCHES "vcpkg.cmake")
    message(STATUS "vcpkg in use")
    set(CMAKE_FIND_PACKAGE_PREFER_CONFIG ON)
    set(CMAKE_FIND_PACKAGE_PREFER_CMAKE_PATH ON)

    if(DEFINED VCPKG_INSTALLED_DIR AND DEFINED VCPKG_TARGET_TRIPLET)
      list(APPEND CMAKE_PREFIX_PATH
        "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}")
    endif()

  else()
    message(STATUS "vcpkg not in use")
  endif()
endif()

# Local paths for IMAS-MATLAB
################################################################################
# Include local paths to eliminate AL_COMMON_PATH dependency
# Use full path since CMAKE_MODULE_PATH hasn't been configured yet
include(${CMAKE_CURRENT_SOURCE_DIR}/common/cmake/ALLocalPaths.cmake)
option( AL_DOWNLOAD_DEPENDENCIES "Automatically download assets from the AL git repository" ON )
set( AL_CORE_GIT_REPOSITORY "https://github.com/iterorganization/IMAS-Core.git" CACHE STRING "Git repository of AL-core" )
set( AL_CORE_VERSION "main" CACHE STRING "Git commit/tag/branch of AL-core" )

include(FetchContent)
# Load AL-core library (used for the shared library)
################################################################################
if(WIN32)
  if( ${AL_DOWNLOAD_DEPENDENCIES} )
    # FetchContent_Declare causing reursive call wrapped by vcpkg to _find_package
    # So manually clone al-core here. Need fix in later release
    set( al-core_SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/_deps/al-core-src" )
    if( NOT EXISTS "${al-core_SOURCE_DIR}/.git" )
      message( STATUS "Cloning al-core from ${AL_CORE_GIT_REPOSITORY}" )
      execute_process(
        COMMAND git clone "${AL_CORE_GIT_REPOSITORY}" "${al-core_SOURCE_DIR}"
        RESULT_VARIABLE _GIT_CLONE_RESULT
        ERROR_VARIABLE _GIT_CLONE_ERROR
      )
      if( _GIT_CLONE_RESULT )
        message( FATAL_ERROR "Failed to clone al-core: ${_GIT_CLONE_ERROR}" )
      endif()
    endif()
    # Checkout the specified version
    execute_process(
      COMMAND git fetch origin
      WORKING_DIRECTORY "${al-core_SOURCE_DIR}"
      RESULT_VARIABLE _GIT_FETCH_RESULT
    )
    execute_process(
      COMMAND git checkout "${AL_CORE_VERSION}"
      WORKING_DIRECTORY "${al-core_SOURCE_DIR}"
      RESULT_VARIABLE _GIT_CHECKOUT_RESULT
      ERROR_VARIABLE _GIT_CHECKOUT_ERROR
    )
    if( _GIT_CHECKOUT_RESULT )
      message( FATAL_ERROR "Failed to checkout ${AL_CORE_VERSION}: ${_GIT_CHECKOUT_ERROR}" )
    endif()
  elseif ( ${AL_DEVELOPMENT_LAYOUT} )
    set( al-core_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../al-core" )
  endif()
else()
  if( ${AL_DOWNLOAD_DEPENDENCIES} )
    # Download common assets from the ITER git:
    FetchContent_Declare(
      al-core
      GIT_REPOSITORY "${AL_CORE_GIT_REPOSITORY}"
      GIT_TAG "${AL_CORE_VERSION}"
    )
    FetchContent_MakeAvailable( al-core )
  elseif ( ${AL_DEVELOPMENT_LAYOUT} )
    FetchContent_Declare(
      al-core
      SOURCE_DIR      "${CMAKE_CURRENT_SOURCE_DIR}/../al-core"
    )
    FetchContent_MakeAvailable( al-core )
  endif()
  
endif()

# Define project
################################################################################

# Set VERSION and FULL_VERSION from `git describe`:
set( GIT_ARCHIVE_DESCRIBE [[$Format:%(describe)$]] )
include( ALDetermineVersion )
project( al-matlab
  VERSION ${VERSION}
  DESCRIPTION "MATLAB High Level Interface of the IMAS Access Layer"
  HOMEPAGE_URL "https://imas.iter.org/"
  LANGUAGES C CXX
)
if( NOT PROJECT_VERSION_TWEAK EQUAL 0 )
  message( "Building a development version of the Access Layer Matlab HLI" )
endif()

# Compiler settings
include( ALSetCompilerFlags )
# Common HLI options
include( ALCommonConfig )
# Data dictionary
include( ALBuildDataDictionary )
# AL core, plugins and documentation
include( ALCore )

# Stop processing when only building documentation
if( AL_DOCS_ONLY )
  return()
endif()
# Dependencies
################################################################################
find_package( Python3 REQUIRED COMPONENTS Interpreter )
if(WIN32)
 find_package(Matlab REQUIRED MODULE)
else()
 find_package( Matlab REQUIRED )
endif()
# Utility sources and target
################################################################################

set( MEX_UTIL_SOURCES
  src/imas_mex_casts.c
  src/imas_mex_params.c
  src/imas_mex_rand.c
  src/imas_mex_structs.c
  src/imas_mex_utils.c
)
if(WIN32)
  # This should be built as a shared library (not a MEX file) with name libal-mex.so/.dll
  # It's a utility library that MEX files link to, so use add_library instead of matlab_add_mex
  add_library( al-mex SHARED ${MEX_UTIL_SOURCES} )
  target_link_libraries( al-mex PUBLIC al Matlab::mex Matlab::mx )
  target_include_directories( al-mex PRIVATE src )
  target_include_directories( al-mex PUBLIC ${Matlab_INCLUDE_DIRS} )

  # Use separate (non-interleaved) complex API for compatibility
  target_compile_definitions( al-mex PUBLIC)

  # Define AL_MEX_BUILDING_DLL when building the al-mex library
  target_compile_definitions( al-mex PRIVATE AL_MEX_BUILDING_DLL )

  # Compile as C (al-core exports C symbols via extern "C")
  set_source_files_properties(${MEX_UTIL_SOURCES} PROPERTIES LANGUAGE C)
  # Force C compilation on Windows
  target_compile_options(al-mex PRIVATE /TC)
  # Link as C library (al exports C symbols)
  set_target_properties(al-mex PROPERTIES LINKER_LANGUAGE C)
else()
  # This should be built as a shared library with name libal-mex.so
  matlab_add_mex( NAME al-mex SRC ${MEX_UTIL_SOURCES} SHARED LINK_TO al )
  target_include_directories( al-mex PRIVATE src )
endif()

set_target_properties( al-mex PROPERTIES
  PREFIX "lib"
)
if(WIN32)
  # On Windows, it's a regular DLL, not a MEX file
  set_target_properties( al-mex PROPERTIES 
    SUFFIX ".dll"
    WINDOWS_EXPORT_ALL_SYMBOLS ON
  )
else()
  set_target_properties( al-mex PROPERTIES
    SUFFIX ".so"
    LINK_FLAGS " -Wl,--as-needed"
  )
endif()
set( MEX_TARGETS )

# Generate sources and define targets
################################################################################

add_custom_target( al-mex-sources ALL )


# Macro for source generation with saxonche (Python)
macro( GENERATE GENERATOR IS_C_GENERATOR OUTPUT_FILES )
  if( ${IS_C_GENERATOR} )
    set( WORK_DIR "${CMAKE_CURRENT_BINARY_DIR}" )
  else()
    set( WORK_DIR "${CMAKE_CURRENT_SOURCE_DIR}" )
  endif()
  set( GENERATED_FILENAMES ${OUTPUT_FILES} )
  list( TRANSFORM GENERATED_FILENAMES PREPEND "${WORK_DIR}/" )

  add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${GENERATOR}_dummy.txt
    COMMAND
      ${_VENV_PYTHON} "${AL_LOCAL_XSLTPROC_SCRIPT}"
        -xsl ${CMAKE_CURRENT_SOURCE_DIR}/${GENERATOR}.xsl
        -s ${IDSDEF}
        -o ${CMAKE_CURRENT_BINARY_DIR}/${GENERATOR}_output.xml
        DD_GIT_DESCRIBE=${DD_VERSION}
        AL_GIT_DESCRIBE=${FULL_VERSION}
    COMMAND ${CMAKE_COMMAND} -E touch ${CMAKE_CURRENT_BINARY_DIR}/${GENERATOR}_dummy.txt
    DEPENDS ${IDSDEF} ${GENERATOR}.xsl
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  )
  add_custom_target( al-mex-source-${GENERATOR}
    COMMAND ${CMAKE_COMMAND} -E echo ""
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${GENERATOR}_dummy.txt
    BYPRODUCTS ${GENERATED_FILENAMES}
  )
  
  # For non-C generators (e.g., matlab/IDS_list.m), copy generated files from build to source dir
  if( NOT ${IS_C_GENERATOR} )
    foreach( OUTPUT_FILE ${OUTPUT_FILES} )
      add_custom_command(
        TARGET al-mex-source-${GENERATOR} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
          ${CMAKE_CURRENT_BINARY_DIR}/${OUTPUT_FILE}
          ${CMAKE_CURRENT_SOURCE_DIR}/${OUTPUT_FILE}
      )
    endforeach()
  endif()
  
  add_dependencies( al-mex-sources al-mex-source-${GENERATOR} )
endmacro()

# Macro to generate source name triplets for an ids_<method>
macro( FILES_FROM_METHOD_NAME FILES METHOD_NAME )
  set( ${FILES} "src/ids/ids_${METHOD_NAME}.c;src/ids/ids_${METHOD_NAME}.;src/ids/${METHOD_NAME}_ids.c" )
endmacro()

# Macro to add a mex target
if(WIN32)
  macro( ADD_IMAS_MEX NAME SOURCES )
    # Let matlab_add_mex handle the suffix automatically
    # Or explicitly set .mexw64 if needed:
    matlab_add_mex( NAME "mex-${NAME}" SRC ${SOURCES} LINK_TO al al-mex OUTPUT_NAME "${NAME}" )
    if(MATLAB_VERSION VERSION_GREATER_EQUAL "9.4")  # R2018a+
      set_target_properties("mex-${NAME}" PROPERTIES SUFFIX ".mexw64")
    endif()
    target_include_directories( "mex-${NAME}" PRIVATE src )
    # Use separate (non-interleaved) complex API for compatibility
    target_compile_definitions( "mex-${NAME}" PUBLIC)
    # Add /bigobj flag for large generated code files
    target_compile_options( "mex-${NAME}" PRIVATE /bigobj )
    # Ensure all source-generation targets finish before this MEX target compiles.
    # Without this, parallel builds (cmake --build -j N) can race: the MEX target
    # tries to compile BYPRODUCT files before al-mex-source-* has generated them.
    add_dependencies( "mex-${NAME}" al-mex-sources )
    list( APPEND MEX_TARGETS "mex-${NAME}" )
  endmacro()
else()
  # Macro to add a mex target
  macro( ADD_IMAS_MEX NAME SOURCES )
    matlab_add_mex( NAME "mex-${NAME}" SRC ${SOURCES} LINK_TO al al-mex OUTPUT_NAME "${NAME}" )
    target_include_directories( "mex-${NAME}" PRIVATE src )
    # Ensure all source-generation targets finish before this MEX target compiles.
    # Without this, parallel builds (cmake --build -j N) can race: the MEX target
    # tries to compile BYPRODUCT files before al-mex-source-* has generated them.
    add_dependencies( "mex-${NAME}" al-mex-sources )
    list( APPEND MEX_TARGETS "mex-${NAME}" )
  endmacro()
endif()
# These XSLs generate files in triplets, which are then compiled into one mex target
foreach( METHOD_NAME allocate delete gen get get_sample get_slice init put put_slice rand validate )
  FILES_FROM_METHOD_NAME( OUTPUT_FILES ${METHOD_NAME} )
  GENERATE( "ids_${METHOD_NAME}" 1 "${OUTPUT_FILES}" )
  ADD_IMAS_MEX( "ids_${METHOD_NAME}" "${OUTPUT_FILES}" )
endforeach()

# 'put' and 'put_slice' in addition need these sources:
target_sources( "mex-ids_put" PRIVATE
  src/ids/delete_ids.c
  src/ids/validate_ids.c
)
target_sources( "mex-ids_put_slice" PRIVATE
  src/ids/put_ids.c
  src/ids/delete_ids.c
  src/ids/validate_ids.c
)

# The ids_converter.xsl generates many targets:
set( IDS_CONVERTER_SOURCES )
foreach( CONVERTER_METHOD
  int_to_double
  double_to_int
  empty_to_nan
  nan_to_empty
  cell_to_struct
  struct_to_cell
)
  FILES_FROM_METHOD_NAME( OUTPUT_FILES ${CONVERTER_METHOD} )
  list( APPEND IDS_CONVERTER_SOURCES ${OUTPUT_FILES} )
  ADD_IMAS_MEX( "ids_${CONVERTER_METHOD}" "${OUTPUT_FILES}" )
endforeach()
GENERATE( ids_converter 1 "${IDS_CONVERTER_SOURCES}" )

# imas_versions only generates a single file and target
GENERATE( imas_versions 1 "src/imas_versions.c")
ADD_IMAS_MEX( "imas_versions" "src/imas_versions.c" )

# Only generate, no mex target
GENERATE( IDS_list 0 "matlab/IDS_list.m")

# Targets for other sources
################################################################################

set( TARGETS
  ids_isdefined
  imas_al_bind_plugin
  imas_al_register_plugin
  imas_al_setvalue_parameter_plugin
  imas_al_unbind_plugin
  imas_al_unregister_plugin
  imas_close
  imas_create_env
  imas_create_env_backend
  imas_deserialize
  imas_get_backendID
  imas_get_mex_params
  imas_open
  imas_open_env
  imas_open_env_backend
  imas_serialize
  imas_set_mex_params
  imas_build_uri_from_legacy_parameters
  imas_list_all_occurrences
  imas_partial_get
)
foreach( TARGET ${TARGETS} )
  ADD_IMAS_MEX( ${TARGET} "src/${TARGET}.c" )
endforeach()

add_custom_target( al-matlab )
add_dependencies( al-matlab al-mex-sources al-mex ${MEX_TARGETS} )

# Install
################################################################################

# Install libal-mex to lib folder
if(WIN32)
  install( TARGETS al-mex DESTINATION bin RUNTIME DESTINATION bin LIBRARY DESTINATION lib )
else()
  install( TARGETS al-mex DESTINATION lib )
endif()
# Install compiled libraries to the mex folder
install( TARGETS ${MEX_TARGETS} DESTINATION mex )
# Install static and generated '.m' files to the mex folder
install( DIRECTORY matlab/ DESTINATION mex )

# Create MATLAB toolbox folder structure with all necessary files
if(WIN32)
  # Install al-mex DLL to toolbox folder
  install( TARGETS al-mex DESTINATION toolbox RUNTIME DESTINATION toolbox )
else()
  # Install al-mex shared library to toolbox folder
  install( TARGETS al-mex DESTINATION toolbox )
endif()
# Install MEX files to toolbox folder
install( TARGETS ${MEX_TARGETS} DESTINATION toolbox )
# Install M-files to toolbox folder
install( DIRECTORY matlab/ DESTINATION toolbox 
  FILES_MATCHING PATTERN "*.m" )

# Install AL shared library to toolbox folder (if not an alias)
# The al library comes from al-core and may already be installed
# Copy runtime dependencies to toolbox during install
if(WIN32)
  # On Windows, install runtime DLLs that MEX files depend on
  install(CODE "
    file(GLOB AL_RUNTIME_LIBS 
      \"\${CMAKE_INSTALL_PREFIX}/bin/*.dll\"
    )
    foreach(lib IN LISTS AL_RUNTIME_LIBS)
      file(COPY \"\${lib}\" DESTINATION \"\${CMAKE_INSTALL_PREFIX}/toolbox\")
    endforeach()
    message(STATUS \"Copied runtime libraries to toolbox folder\")
  ")
else()
  # On Linux, install shared libraries that MEX files depend on
  install(CODE "
    file(GLOB AL_RUNTIME_LIBS 
      \"\${CMAKE_INSTALL_PREFIX}/lib/*.so*\"
    )
    foreach(lib IN LISTS AL_RUNTIME_LIBS)
      file(COPY \"\${lib}\" DESTINATION \"\${CMAKE_INSTALL_PREFIX}/toolbox\")
    endforeach()
    message(STATUS \"Copied runtime libraries to toolbox folder\")
  ")
endif()

# Copy toolbox packaging script
install( FILES ${CMAKE_CURRENT_SOURCE_DIR}/create_matlab_toolbox.m
  DESTINATION . )

# Option to create MATLAB toolbox package during installation
option(AL_CREATE_TOOLBOX "Automatically create MATLAB toolbox package during installation" OFF)

# Get MATLAB executable path
if(DEFINED Matlab_MAIN_PROGRAM)
  set(MATLAB_EXECUTABLE "${Matlab_MAIN_PROGRAM}")
elseif(DEFINED Matlab_ROOT_DIR)
  if(WIN32)
    set(MATLAB_EXECUTABLE "${Matlab_ROOT_DIR}/bin/matlab.exe")
  else()
    set(MATLAB_EXECUTABLE "${Matlab_ROOT_DIR}/bin/matlab")
  endif()
else()
  # Try to find matlab in PATH
  find_program(MATLAB_EXECUTABLE matlab)
endif()

if(MATLAB_EXECUTABLE)
  message(STATUS "MATLAB executable: ${MATLAB_EXECUTABLE}")
  
  # Add custom target to create MATLAB toolbox package
  # NOTE: This target requires that 'cmake --install' has been run first to create the toolbox folder
  add_custom_target( matlab-toolbox
    COMMAND ${CMAKE_COMMAND} -E echo "NOTE: Ensure 'cmake --install' has been run before creating the toolbox package"
    COMMAND ${CMAKE_COMMAND} -E echo "Looking for toolbox in: ${CMAKE_INSTALL_PREFIX}/toolbox"
    COMMAND "${MATLAB_EXECUTABLE}" 
      -batch "create_matlab_toolbox('${CMAKE_INSTALL_PREFIX}', '${CMAKE_BINARY_DIR}', '${PROJECT_VERSION}', '${DD_VERSION}')"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Creating MATLAB toolbox package: IMAS-MATLAB/${PROJECT_VERSION}-DD-${DD_VERSION}"
    VERBATIM
  )

  # Optionally run toolbox packaging as part of installation
  if(AL_CREATE_TOOLBOX)
    install(CODE "
      message(STATUS \"Creating MATLAB toolbox package: IMAS-MATLAB/${PROJECT_VERSION}-DD-${DD_VERSION}\")
      execute_process(
        COMMAND \"${MATLAB_EXECUTABLE}\"
          -batch \"create_matlab_toolbox('\${CMAKE_INSTALL_PREFIX}', '${CMAKE_BINARY_DIR}', '${PROJECT_VERSION}', '${DD_VERSION}')\"
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        RESULT_VARIABLE _TOOLBOX_RESULT
        OUTPUT_VARIABLE _TOOLBOX_OUTPUT
        ERROR_VARIABLE _TOOLBOX_ERROR
      )
      if(_TOOLBOX_RESULT)
        message(WARNING \"Failed to create MATLAB toolbox package: \${_TOOLBOX_ERROR}\")
        message(WARNING \"You can create it manually by running: cmake --build . --target matlab-toolbox\")
      else()
        message(STATUS \"MATLAB toolbox package created successfully\")
        message(STATUS \"\${_TOOLBOX_OUTPUT}\")
      endif()
    ")
  endif()
else()
  message(WARNING "MATLAB executable not found. Toolbox packaging target will not be available.")
  message(WARNING "You can manually package the toolbox by running create_matlab_toolbox.m from MATLAB.")
endif()

# Tests
################################################################################

if( AL_TESTS )
  add_subdirectory( tests )
endif()

if( AL_EXAMPLES )
  add_subdirectory( examples )
endif()
