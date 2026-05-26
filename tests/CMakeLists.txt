find_package( Matlab COMPONENTS MAIN_PROGRAM )

set( LIB_FOLDER ${CMAKE_CURRENT_BINARY_DIR}/../ )
set( M_FOLDER ${CMAKE_CURRENT_SOURCE_DIR}/../matlab )

if( AL_BACKEND_MDSPLUS )
  if( TARGET al-mdsplus-model )
    get_target_property( MDSPLUS_MODEL_DIR al-mdsplus-model BINARY_DIR )
  else()
    if( DEFINED ENV{MDSPLUS_MODELS_PATH} )
      set( MDSPLUS_MODEL_DIR "$ENV{MDSPLUS_MODELS_PATH}" )
    else()
      set( MDSPLUS_MODEL_DIR "$ENV{ids_path}" )
    endif()
  endif()
endif()

add_test( NAME al-mex-test 
  COMMAND
    ${Matlab_MAIN_PROGRAM}
      -nodisplay
      -batch "addpath ${LIB_FOLDER} ${M_FOLDER}; res = runtests('imas_unit_tests');exit(~all([res.Passed]))"
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
# Note: added ids_path for backward compatibility with IMAS-Core<5.6
set( MATLAB_ENV "IMAS_AL_DISABLE_VALIDATE=1;IMAS_AL_DISABLE_OBSOLESCENT_WARNING=1;ids_path=${MDSPLUS_MODEL_DIR};MDSPLUS_MODELS_PATH=${MDSPLUS_MODEL_DIR}" )
if( AL_BACKEND_HDF5 )
  # The HDF5 library built-in with matlab may conflict with the one that the AL
  # was built against. Preload the AL-linked library:
  find_package( HDF5 COMPONENTS C HL REQUIRED )
  # LD_PRELOAD expects a space-separated list:
  string( REPLACE ";" " " PRELOAD_LIBS "${HDF5_HL_LIBRARIES}" )
  list( APPEND MATLAB_ENV "LD_PRELOAD=${PRELOAD_LIBS}" )
endif()

set_tests_properties( al-mex-test PROPERTIES
  TIMEOUT 3600
  ENVIRONMENT "${MATLAB_ENV}"
)

if( AL_PLUGINS )
  if( TARGET al-plugins )
    add_test( NAME al-partial-get-test 
      COMMAND
        ${Matlab_MAIN_PROGRAM}
          -nodisplay
          -batch "addpath ${LIB_FOLDER} ${M_FOLDER}; res = runtests('imas_partial_get_tests');exit(~all([res.Passed]))"
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
    get_target_property( PLUGIN_DIR al-plugins BINARY_DIR )
    set( ENVIRONMENT_WITH_PLUGINS 
      ${MATLAB_ENV}
      "IMAS_AL_ENABLE_PLUGINS=TRUE"
      "IMAS_AL_PLUGINS=${PLUGIN_DIR}"
    )

    set_tests_properties( al-partial-get-test PROPERTIES
      TIMEOUT 3600
      ENVIRONMENT "${ENVIRONMENT_WITH_PLUGINS}"
    )
  endif()
endif()

# Tests require at least one backend (HDF5 or MDSPLUS)
if( NOT AL_BACKEND_MDSPLUS AND NOT AL_BACKEND_HDF5 )
  message(STATUS "Disabling tests: No backend available (requires HDF5 or MDSplus)")
  set_tests_properties( al-mex-test PROPERTIES DISABLED ON )
  if( AL_PLUGINS )
    set_tests_properties( al-partial-get-test PROPERTIES DISABLED ON )
  endif()
else()
  if( AL_BACKEND_HDF5 AND NOT AL_BACKEND_MDSPLUS )
    message(STATUS "Tests will run with HDF5 backend only")
  elseif( AL_BACKEND_MDSPLUS AND NOT AL_BACKEND_HDF5 )
    message(STATUS "Tests will run with MDSplus backend only")
  else()
    message(STATUS "Tests will run with both HDF5 and MDSplus backends")
  endif()
endif()

