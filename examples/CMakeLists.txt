project( mexinterface-ex )

find_package( Matlab COMPONENTS MAIN_PROGRAM )
include( ALExampleUtilities )

get_target_property( LIB_FOLDER al-mex BINARY_DIR )
get_target_property( M_FOLDER al-mex SOURCE_DIR )
set( M_FOLDER ${M_FOLDER}/matlab )

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

# Examples that use MDSplus backend
set( M_FILES_MDSPLUS
    test_amns_data_validate
    test_distributions_validate
    test_get
    test_isdefined
    test_put
    test_serialize
    test_waves_validate
)

# Examples that use HDF5 backend
set( M_FILES_HDF5
    test_get_sample_magnetics
)

# Add tests for MDSplus examples
foreach( M_FILE ${M_FILES_MDSPLUS} )
  add_test( NAME example-mex-${M_FILE}
    COMMAND ${Matlab_MAIN_PROGRAM}
      -nodisplay
      -batch "addpath ${LIB_FOLDER} ${M_FOLDER}; ${M_FILE}; exit()"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  )

  set( DISABLED OFF )
  if( NOT AL_BACKEND_MDSPLUS )
    set( DISABLED ON )
    message(STATUS "Disabling example ${M_FILE}: requires MDSplus backend")
  endif()
  # Note: added ids_path for backward compatibility with IMAS-Core<5.6
  set_al_example_properties( example-mex-${M_FILE} ${DISABLED} OFF "MDSPLUS_MODELS_PATH=${MDSPLUS_MODEL_DIR};ids_path=${MDSPLUS_MODEL_DIR}" )

  if( AL_PLUGINS )
    add_test( NAME example-mex-${M_FILE}-with-plugins
      COMMAND ${Matlab_MAIN_PROGRAM}
        -nodisplay
        -batch "addpath ${LIB_FOLDER} ${M_FOLDER}; ${M_FILE}; exit()"
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
    # Note: added ids_path for backward compatibility with IMAS-Core<5.6
    set_al_example_properties( example-mex-${M_FILE}-with-plugins ${DISABLED} ON "MDSPLUS_MODELS_PATH=${MDSPLUS_MODEL_DIR};ids_path=${MDSPLUS_MODEL_DIR}" )
  endif()
endforeach()

# Add tests for HDF5 examples
foreach( M_FILE ${M_FILES_HDF5} )
  add_test( NAME example-mex-${M_FILE}
    COMMAND ${Matlab_MAIN_PROGRAM}
      -nodisplay
      -batch "addpath ${LIB_FOLDER} ${M_FOLDER}; ${M_FILE}; exit()"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  )

  set( DISABLED OFF )
  if( NOT AL_BACKEND_HDF5 )
    set( DISABLED ON )
    message(STATUS "Disabling example ${M_FILE}: requires HDF5 backend")
  endif()
  # Note: added ids_path for backward compatibility with IMAS-Core<5.6
  set_al_example_properties( example-mex-${M_FILE} ${DISABLED} OFF "MDSPLUS_MODELS_PATH=${MDSPLUS_MODEL_DIR};ids_path=${MDSPLUS_MODEL_DIR}" )

  if( AL_PLUGINS )
    add_test( NAME example-mex-${M_FILE}-with-plugins
      COMMAND ${Matlab_MAIN_PROGRAM}
        -nodisplay
        -batch "addpath ${LIB_FOLDER} ${M_FOLDER}; ${M_FILE}; exit()"
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
    # Note: added ids_path for backward compatibility with IMAS-Core<5.6
    set_al_example_properties( example-mex-${M_FILE}-with-plugins ${DISABLED} ON "MDSPLUS_MODELS_PATH=${MDSPLUS_MODEL_DIR};ids_path=${MDSPLUS_MODEL_DIR}" )
  endif()
endforeach()
