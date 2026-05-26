/** \addtogroup utils MEX-utils
 *  @{
 */

/**
   \file src/imas_mex_utils.h
   Headers for interaction with AL.
 */

/** @}*/

#ifndef IMAS_MEX_UTILS_H

#define IMAS_MEX_UTILS_H


#include "mex.h"

// DLL export/import macro for Windows
#ifdef _WIN32
  #ifdef AL_MEX_BUILDING_DLL
    #define AL_MEX_EXPORT __declspec(dllexport)
  #else
    #define AL_MEX_EXPORT __declspec(dllimport)
  #endif
  // Undef the deprecation macros to use the actual function names
  // In R2018a+ these are #defined to "IsDeprecated" versions that don't link
  #ifdef mxGetImagData
    #undef mxGetImagData
  #endif
  #ifdef mxSetImagData
    #undef mxSetImagData
  #endif
#else
  // On non-Windows platforms, AL_MEX_EXPORT is empty
  #define AL_MEX_EXPORT
#endif

/** \cond */

AL_MEX_EXPORT extern const int EMPTY_INT;
AL_MEX_EXPORT extern const double EMPTY_DOUBLE;
AL_MEX_EXPORT extern const double EMPTY_COMPLEX[2];

AL_MEX_EXPORT extern const int IDS_TIME_MODE_UNKNOWN;
AL_MEX_EXPORT extern const int IDS_TIME_MODE_HETEROGENEOUS;
AL_MEX_EXPORT extern const int IDS_TIME_MODE_HOMOGENEOUS;
AL_MEX_EXPORT extern const int IDS_TIME_MODE_INDEPENDENT;

/** \endcond */

#include "al_lowlevel.h"
#include "imas_mex_params.h"
#include "imas_mex_casts.h"
#include "imas_mex_structs.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include <time.h>

#ifdef _WIN32
  #include <windows.h>
  #include <io.h>
  // Windows doesn't have sys/time.h or unistd.h
  // gettimeofday() is implemented in imas_mex_utils.c
#else
  #include <sys/time.h>
  #include <unistd.h>
#endif

#include <errno.h>
#ifdef NO_MXISSCALAR
#define mxIsScalar(a) (mxGetNumberOfElements(a)==1)
#endif

#define MAXERRMSGIDSIZE 129
#define MAXERRMSGTXTSIZE 1025

#define HLI_ERR LOWLEVEL_ERR-1

#define ANCESTORS_MAX_COUNT 30
#define NBC_VERSIONS_MAX_COUNT 10
#define ANCESTOR_NAME_MAX_LENGTH 250
#define ANCESTOR_TYPE_MAX_LENGTH 20
#define ANCESTOR_VERSION_MAX_LENGTH 50
#define ANCESTORS_PREVIOUS_NAMES_MAX_LENGTH 250
#define ANCESTORS_VERSIONS_MAX_LENGTH 50
#define IMAS_PATH_MAX_LENGTH 500

#define MAX_RETRIES 100
// On any recent Linux (2.6 or later according to Wikipedia [1]) the /dev/shm folder exists for shared memory.
// Since glibc assumes this to exist anyway [2], we will as well.
// [1] https://en.wikipedia.org/wiki/Shared_memory
// [2] https://www.kernel.org/doc/Documentation/filesystems/tmpfs.txt
// On non-Linux, use the current working directory as temporary directory (since /dev/shm does not exist).
#if defined(__linux__) || defined(__linux) || defined(linux)
#  define SERIALIZE_TEMPORARY_DIRECTORY "/dev/shm/"
#else
#  define SERIALIZE_TEMPORARY_DIRECTORY
#endif


#define RANDOM_NUMBER_LENGTH 9 

/** \endcond */

typedef struct { int code; char message[MAXERRMSGTXTSIZE]; } al_validation_status_t;

/**
   Structure containing information about the current LowLevel context.
 */
struct imas_mex_actionInfo {
  int context; /*!< Index of the Lowlevel context in the global store. */
};

/**
   Structure containing information about the current field.
 */
struct imas_mex_fieldInfo {
  char * fieldPath;    /*!< Path of the field relative to its parent array of structure. */
  char * timebasePath; /*!< Path of the timebase for the current field relative to its parent array of structure. */
  int datatype;        /*!< Type of data in the current field.. */
  int dim;             /*!< Rank of the current field. */
};

#ifdef _WIN32
  /** \cond */
  AL_MEX_EXPORT extern const char * mex_errmsgid;
  AL_MEX_EXPORT extern char mex_errmsgtxt[MAXERRMSGTXTSIZE];
  AL_MEX_EXPORT extern int msglen;
  AL_MEX_EXPORT extern int msg_haspathinfo;
#else
  /** \cond */
  extern const char * mex_errmsgid;
  extern char mex_errmsgtxt[MAXERRMSGTXTSIZE];
  extern int msglen;
  extern int msg_haspathinfo;
#endif

#ifndef _WIN32
  char * itoa(int );

  int atoi(const char *);
#endif

char* concat(const char *, const char *);

char* generate_tmp_file();

char * getFilenameFromPath(char *);

void resetErrMsgIdAndTxt(void);

void my_mexErrMsgIdAndTxt(al_status_t status, const char * prefix);

void my_validation_mexErrMsgIdAndTxt(al_validation_status_t status, const char * prefix);

void my_exceptionGetReport(mxArray* exception);

void addIdsPathInfoToErrMsg(const char * idsPathInfo, int force);

void getFieldRelativePath(char* relativePath, int ancestors_count, char* ancestors_names[], char* ancestors_change_nbc_versions[],
		char* ancestors_change_nbc_previous_names[], char* ancestors_data_types[],  char* dataDictionaryVersion);

void getNodePath(char* path, int ancestors_count, char* ancestors_names[], char* ancestors_change_nbc_versions[],
		char* ancestors_change_nbc_previous_names[], char* dataDictionaryVersion, int k);

int getIndexAfterFirstStructArrayAncestor(char* ancestors_data_types[],  int ancestors_count);

void splitUtil(char* arrayOfCharsPointers[], char* charsToSplit, int charsToSplitLength, int tokenLength, int *tokensCount);

void warningWritingObsolescentNode(const char* idsName, const char* fieldPath, const char* lifeCycleStatus);

int get_default_backend();
int get_fallback_backend();

int is_field_valid(int datatype, int dim, const mxArray * data);

al_status_t mxArray_default_value(int datatype, int dim, mxArray **data);

al_status_t getHomogeneousTimeCtx(int ctx, int *homogeneousTime);

al_status_t getDataDictionaryVersion(int ctx, char** data_dictionary, bool *tagged_version);

al_status_t data_to_mxArray(int datatype, int dim, void *array, int *size, mxArray **data);

al_status_t data_from_mxArray(int datatype, int dim, const mxArray * data, void **array, int *size);

al_status_t my_al_read_data(struct imas_mex_actionInfo * action, struct imas_mex_fieldInfo * field, mxArray ** data);

al_status_t my_al_write_data(struct imas_mex_actionInfo * action, struct imas_mex_fieldInfo * field, const mxArray * data, const char* idsName, const char* lifecycle_status);

/* Check if ids validation should be performed on ids_put*/
bool is_validation_required(void);

/** \endcond */

#endif
