/** \addtogroup utils MEX-utils
 *  @{
 */

/**
   \file src/imas_mex_params.h
   Headers for session-wide parameters for IMAS MEX-files.
 */

/** @}*/

#ifndef IMAS_MEX_PARAMS_H

#define IMAS_MEX_PARAMS_H

/**
   Structure for the IMAS MEX-files parameters.
 */
struct imas_mex_params {
  int get_int_as_double;                      /*!< In get methods, convert integer fields to double (default: 0). */
  int put_int_from_double;                    /*!< In put methods, allows to provide double values for integer fields (default: 1). */
  int get_empty_as_nan;                       /*!< In get methods, for fields of type float replace EMPTY_DOUBLE values by NaNs (default: 0). */
  int put_empty_from_nan;                     /*!< In put methods, for fields of type float replace NaNs by EMPTY_DOUBLE (default: 0). */
  int use_cell_array_for_array_of_structures; /*!< If enabled arrays of structures will be represented using cell arrays of structes (default), otherwise using structure arrays (default: 1). */
  int convert_whole_ids;                      /*!< OBSOLETE. Present behavior corresponds to the old default value (0) where fields were converted just before/after AL write/read methods. Will be removed in a future release. */
  int error_on_missing_field;                 /*!< If enabled put methods will trigger an error if any field is missing from the input IDS (default: 1). */
  int verbosity;                              /*!< Controls the verbosity level of the interface, higher means more verbose. Minimum value is 0, maximum value is 4 (default: 0). */
};

#ifdef _WIN32
  /** \cond */
  AL_MEX_EXPORT extern struct imas_mex_params params;
#else
  extern struct imas_mex_params params;
#endif
int setDefaultParams(void);
/** \endcond */
#endif
