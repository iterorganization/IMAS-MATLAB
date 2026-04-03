/** \defgroup utils MEX-utils
 *  Utility functions for IMAS MEX-files.
 *  @{
 */

/**
   \file src/imas_mex_utils.c
   Interaction with AL
 */

/** @}*/

#include "imas_mex_utils.h"

const int EMPTY_INT = -999999999;                   /*!< default value for integer scalars */
const double EMPTY_DOUBLE = -9.0E40;                /*!< default value for double scalars */
const double EMPTY_COMPLEX[2] = {-9.0E40, -9.0E40}; /*!< default value for complex scalars */

const int IDS_TIME_MODE_UNKNOWN = -999999999;       /*!< IDS time mode unset */
const int IDS_TIME_MODE_HETEROGENEOUS = 0;          /*!< IDS in heterogeneous time mode */
const int IDS_TIME_MODE_HOMOGENEOUS = 1;            /*!< IDS in homogeneous time mode  */
const int IDS_TIME_MODE_INDEPENDENT = 2;            /*!< IDS with time independent data only */

const char * mex_errmsgid;                          /*!< MATLAB message identifier for errors */
char mex_errmsgtxt[MAXERRMSGTXTSIZE];               /*!< Error message */
int msglen = 0;                                     /*!< Length of the mex_errmsgtxt string */
int msg_haspathinfo = 0;


#ifdef _WIN32
	#include <process.h>  // For _getpid()

	// Windows implementation of gettimeofday
	int gettimeofday(struct timeval *tv, void *tz) {
		FILETIME ft;
		unsigned __int64 tmpres = 0;
		
		GetSystemTimeAsFileTime(&ft);
		
		tmpres |= ft.dwHighDateTime;
		tmpres <<= 32;
		tmpres |= ft.dwLowDateTime;
		
		// Convert file time to unix epoch
		tmpres /= 10;  // convert to microseconds
		tmpres -= 11644473600000000ULL;  // Windows to UNIX epoch offset
		
		tv->tv_sec = (long)(tmpres / 1000000UL);
		tv->tv_usec = (long)(tmpres % 1000000UL);
		
		return 0;
	}

	// Windows implementation of getpid
	#define getpid _getpid

	// Windows implementation of access
	#define access _access
	#define F_OK 0
#else
	/**
	Convert integer to string
	*/
	char * itoa(int num)
	{
		int i, rem, len = 0, n;
		
		n = num;
		while (n != 0)
		{
			len++;
			n /= 10;
		}
		char * str = (char*)malloc(len);
		for (i = 0; i < len; i++)
		{
			rem = num % 10;
			num = num / 10;
			str[len - (i + 1)] = rem + '0';
		}
		str[len] = '\0';
		return str;
	}

	/**
	Convert integer to string
	*/
	int atoi(const char *s1)
	{
		int sign = 1, number = 0, index = 0;
		if(*s1 == '-'){
			sign = -1;
			index = 1;
		}
		
		while(*s1 != '\0'){
			if(*s1 >= '0' &&  *s1 <= '9'){
				number = number*10 + *s1 - '0';
			} else {
				break;
			}
			*s1++;
		}
	
		number = number * sign;
		return number;
	}
#endif

/**
   Concatenate two strings
 */
char* concat(const char *s1, const char *s2)
{
    char *result = malloc(strlen(s1) + strlen(s2) + 1); 
    strcpy(result, s1);
    strcat(result, s2);
    return result;
}

/**
   Generate temporary file and return its name
 */
char* generate_tmp_file()
{
	char * prefix;
	const char* IMAS_AL_SERIALIZER_TMP_DIR = getenv("IMAS_AL_SERIALIZER_TMP_DIR");
	if(IMAS_AL_SERIALIZER_TMP_DIR != NULL)
	{
		// Check if the path does not end with a '/', if not, add it
		if(IMAS_AL_SERIALIZER_TMP_DIR[strlen(IMAS_AL_SERIALIZER_TMP_DIR)-1] != '/')
		{
			prefix = malloc(strlen(IMAS_AL_SERIALIZER_TMP_DIR) + strlen("/al_serialize_") + 2);
			strcpy(prefix, IMAS_AL_SERIALIZER_TMP_DIR);
			strcat(prefix, "/");
			strcat(prefix, "al_serialize_");
		}
		else
		{
			prefix = malloc(strlen(IMAS_AL_SERIALIZER_TMP_DIR) + strlen("/al_serialize_") + 1);
			strcpy(prefix, IMAS_AL_SERIALIZER_TMP_DIR);
			strcat(prefix, "al_serialize_");
		}
	}
	else
	{
		prefix = SERIALIZE_TEMPORARY_DIRECTORY "al_serialize_";		
	}
    char* fname;
    FILE *fp;

    struct timeval tv;
    gettimeofday(&tv, NULL);
	// seedvalue with seconds, microseconds and process id 
    unsigned long seedvalue= (unsigned long)(tv.tv_sec ^ tv.tv_usec ^ getpid()); 

    srand(seedvalue);   // initialization, should only be called once.
	for( int retry_counter=0; retry_counter<MAX_RETRIES; retry_counter++) {

		unsigned long rnd = rand() ^ getpid();      // XOR random value with process id

		#ifdef _WIN32
			/* Convert random number to string using sprintf instead of itoa */
			char rndstr[32];  /* Enough for unsigned long */
			sprintf(rndstr, "%lu", rnd);
		#else
			char* rndstr = itoa(rnd);
			fname=(char *)malloc( strlen(rndstr) + 1);
		#endif

        fname = concat(prefix, rndstr);

        int file_available_status = access(fname, F_OK); // returns 0 if the file exists and accessible and returns -1 if not exist
        int file_w_status=0;
        if (file_available_status == -1) { // check if file creation is possible
            fp = fopen(fname, "w");
            if(fp==NULL)
            {
				printf("FUNCTION:generate_tmp_file() Could not create temporary file: %s\n", strerror(errno));
                // file cannot be created due to memory issue or any other issue
                file_w_status=1;
            }
            else{
                fclose(fp);// file can be created and no issue with the name
                int ret = remove(fname);// Remove the file
            }
        }
        if(file_available_status == 0 || file_w_status!=0)
        {
            // file is already available or can not be created, regenerating new name
            free(fname);
            fname = NULL;
        }
        else
        {
            break;// filename is available
        }
    } 

    return fname;
}

/**
   Get filename from path
 */
char * getFilenameFromPath(char *path)
{
    char *s = strrchr(path, '/');
    if (!s)
        return strdup(path);
    else
        return strdup(s + 1);
}

/**
   Reset global variables for error message
 */
void resetErrMsgIdAndTxt(void)
{
	mex_errmsgid = NULL;
	mex_errmsgtxt[0] = '\000';
	msglen = 0;
	msg_haspathinfo = 0;
}

/**
   Assembles text and identifier for an error message then throws it.
   When the global mex_errmsgid variable is not an empty string, this function assembles the error message identifier from the prefix given in input and the content of the mex_errmsgid global variable. The text of the error message is then taken from the mex_errmsgtxt global variable. If mex_errmsgid was an empty string, the identifier and text are the default ones and contain the error code provided by the status parameter.
   @param[in] status error code
   @param[in] prefix string containing the prefix to the MATLAB error message identifier
 */
void my_mexErrMsgIdAndTxt(al_status_t status, const char * prefix)
{
	char msgid[MAXERRMSGIDSIZE];
	char* errtype;

	strncpy(msgid, prefix, strnlen(prefix, MAXERRMSGIDSIZE-1)+1);
	if (mex_errmsgid != NULL && strnlen(mex_errmsgid, MAXERRMSGIDSIZE-1)) {
		strncat(msgid, mex_errmsgid, MAXERRMSGIDSIZE - strnlen(msgid, MAXERRMSGIDSIZE-1));
		mexErrMsgIdAndTxt(msgid,mex_errmsgtxt);
	} else {
		strncat(msgid, "internal_error", MAXERRMSGIDSIZE - strnlen(msgid, MAXERRMSGIDSIZE-1));
		if (status.code == HLI_ERR) errtype = "HLI";
		else if (status.code == LOWLEVEL_ERR) errtype = "LOWLEVEL";
		else if (status.code == BACKEND_ERR) errtype = "BACKEND";
		else if (status.code == CONTEXT_ERR) errtype = "CONTEXT";
		else errtype = "UNKNOWN";
		
		mexErrMsgIdAndTxt(msgid,"internal error of type %s occured with message:\n %s%s", errtype, status.message, mex_errmsgtxt);
	}
}

void my_validation_mexErrMsgIdAndTxt(al_validation_status_t status, const char * prefix)
{
	char msgid[MAXERRMSGIDSIZE];
	char* errtype;

	strncpy(msgid, prefix, strnlen(prefix, MAXERRMSGIDSIZE-1)+1);
	if (mex_errmsgid != NULL && strnlen(mex_errmsgid, MAXERRMSGIDSIZE-1)) {
		strncat(msgid, mex_errmsgid, MAXERRMSGIDSIZE - strnlen(msgid, MAXERRMSGIDSIZE-1));
		mexErrMsgIdAndTxt(msgid,mex_errmsgtxt);
	} else {
		strncat(msgid, "internal_error", MAXERRMSGIDSIZE - strnlen(msgid, MAXERRMSGIDSIZE-1));
		if (status.code == HLI_ERR) errtype = "HLI";
		else if (status.code == LOWLEVEL_ERR) errtype = "LOWLEVEL";
		else if (status.code == BACKEND_ERR) errtype = "BACKEND";
		else if (status.code == CONTEXT_ERR) errtype = "CONTEXT";
		else errtype = "UNKNOWN";
		
		mexErrMsgIdAndTxt(msgid,"internal error of type %s occured with message:\n %s%s", errtype, status.message, mex_errmsgtxt);
	}
}
/**
   Appends MException message to global error message text
   Typically called if an exception occurs during a call to a MATLAB function in a MEX-file, this function will add the message of the corresponding MException object to the mex_errmsgtxt global variable.
   @param[in] exception pointer to an mxArray of class MException
 */
void my_exceptionGetReport(mxArray* exception)
{
	mxArray * report;
	char * reportTxt;

	if (exception == NULL)
		return;

	report = mxGetProperty(exception, (mwIndex) 0, "message");
	reportTxt = mxArrayToString(report);
	msglen = strnlen(reportTxt, MAXERRMSGTXTSIZE-1)+1;
	strncpy(mex_errmsgtxt, reportTxt, msglen);
	mxFree(reportTxt);
	mxDestroyArray(report);

	strncat(mex_errmsgtxt, "\n----------\n", (12 < MAXERRMSGTXTSIZE-1-msglen) ? 12 : MAXERRMSGTXTSIZE-1-msglen);
	msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);

}

/**
   Appends IDS path information to global error message text
   Called after an error status is found when processing a certain field/aos/structure in one of the HLI functions. Because of the nested nature of these functions, one portion of the path could be added multiple times. To avoid this a global variable stores the status of the error message, and the path information is only added if this global status variable is not yet set. The additional argument force allows to disable this check.
   @param[in] pathInfo String containing the path information to be added to the error message
   @param[in] force flag which forces to add the path information if non-zero 
 */
void addIdsPathInfoToErrMsg(const char * pathInfo, int force)
{
	if (force || !msg_haspathinfo) {
		strncat(mex_errmsgtxt, pathInfo, MAXERRMSGTXTSIZE-1-msglen);
		msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
		msg_haspathinfo = 1;
	}
}

/** 
    Gets the default backend ID from environment variable if set. 
    @result backendID
*/
int get_default_backend()
{
  int backendID = MDSPLUS_BACKEND;
  char* backend_value = getenv("IMAS_AL_DEFAULT_BACKEND");
  if (backend_value != NULL)
    backendID = atoi(backend_value);
  return backendID;
}

/** 
    Gets the fallback backend ID from environment variable if set. 
    @result backendID
*/
int get_fallback_backend()
{
  int backendID = NO_BACKEND;
  char* backend_value = getenv("IMAS_AL_FALLBACK_BACKEND");
  if (backend_value != NULL)
    backendID = atoi(backend_value);
  return backendID;
}

/**
   Checks if field has a different value than the default.
   This routine is used for put and put_slice methods before calling al_write_data, if it returns 0 (false) then al_write_data will be skipped.
   @param[in] datatype type of data in the current field.
   @param[in] dim rank of the current field.
   @param[in] data mxArray containing the data.
   @result 1 if field value is not the default, 0 otherwise.

   @note Note that this will be checked again after necessary casts, so integer fields with double values will be declared valid even if their (double) value matches EMPTY_INT.
 */
int is_field_valid(int datatype, int dim, const mxArray * data)
{
	return (data != NULL && !mxIsEmpty(data) &&
			(dim != 0 ||
					(mxIsScalar(data) &&
							(
									(datatype == INTEGER_DATA && (!mxIsInt32(data) || ((int *)    mxGetData(data))[0] != EMPTY_INT)) ||
									(datatype == DOUBLE_DATA  && (mxIsDouble(data) && ((double *) mxGetData(data))[0] != EMPTY_DOUBLE)) ||
									(datatype == COMPLEX_DATA && (mxIsDouble(data) && (((double *) mxGetData(data))[0] != EMPTY_DOUBLE || ((double *) mxGetImagData(data))[0] != EMPTY_DOUBLE)))
							)
					)
			)
	);
}

/**
   Gets data characteristics from datatype and dimension.
   From the input datatype (i.e. INTEGER_DATA, DOUBLE_DATA, CHAR_DATA or COMPLEX_DATA), assigns the basic class for the mxArray objects, the complexity flag (i.e. complex or real), and the size of the basic type. These quantities will be later used when creating mxArray objects.
   @param[in] datatype type of data in the current field.
   @param[in] dim rank of the current field.
   @param[out] classid class to be used in MATLAB for the data.
   @param[out] ComplexFlag complexity flag to be used in MATLAB for the data.
   @param[out] dsize size of an element of the underlying MATLAB type.
   @param[out] pdefault [deprecated].
   @result error status.

   @note Should we use a unique error status?
 */
al_status_t get_data_info(int datatype, int dim, mxClassID * classid, mxComplexity * ComplexFlag, size_t * dsize, void ** pdefault)
{
	al_status_t status = {0,""};

	if (datatype == INTEGER_DATA) {
		*classid = mxINT32_CLASS;
		*ComplexFlag = mxREAL;
		*dsize = sizeof(int);
	} else if (datatype == DOUBLE_DATA) {
		*classid = mxDOUBLE_CLASS;
		*ComplexFlag = mxREAL;
		*dsize = sizeof(double);
	} else if (datatype == CHAR_DATA) {
		*classid = mxCHAR_CLASS;
		*ComplexFlag = mxREAL;
		*dsize = 2*sizeof(char);
	} else if (datatype == COMPLEX_DATA) {
		*classid = mxDOUBLE_CLASS;
		*ComplexFlag = mxCOMPLEX;
		*dsize = sizeof(double);
	} else
		status.code = HLI_ERR;
	return status;
}

/**
   Stores data read by the AL in an mxArray object.
   This function creates an mxArray to store the data read by the AL in a previous call. The array pointer contains the data and the parameters datatype and dim indicate the nature and rank of the data. data_to_mxArray performs a copy of the data. If the AL read action was unsuccessful (read_status was negative) then the default value is assigned to data.
   @param[in] datatype type of data in the current field.
   @param[in] dim rank of the current field.
   @param[in] array pointer to the data returned by the AL read action.
   @param[in] size pointer containing the dimensions of the data as returned by the AL read action.
   @param[out] data mxArray containing the data.
   @result error status.
 */
al_status_t data_to_mxArray(int datatype, int dim, void *array, int *size, mxArray **data)
{
	al_status_t status;
	mxClassID classid;
	mxComplexity ComplexFlag;
	size_t dsize;
	mwSize ndims;
	mwSize dims[MAXDIM];
	mwSize numel = 1;
	mxChar * chararray;
	int i, j;
	double *pr, *pi;

	status = get_data_info(datatype, dim, &classid, &ComplexFlag, &dsize, &array);
	if (status.code < 0)
		return status;
	if (dim == 0 || (size != NULL && size[0] > 0)) {
		if (datatype != CHAR_DATA) {
			/*           **** NUMERIC DATA **** */
			/* Avoid creating empty arrays for scalars */
			ndims = (dim > 0) ? dim : 1;
			dims[0] = 1;
			/* Convert array size and compute total number of elements */
			for (i = 0; i < dim; i++) {
				dims[i] = (mwSize) size[i];
				numel = numel * dims[i];
			}
			if (!numel) ndims=0; /* True empty arrays */
			*data = mxCreateNumericArray(ndims, dims, classid, ComplexFlag);
			if (datatype != COMPLEX_DATA)
				/* integer and double data map directly to MATLAB types */
				memcpy(mxGetData(*data), array, numel * dsize);
			else {
#if MX_HAS_INTERLEAVED_COMPLEX
				memcpy(mxGetData(*data), array, numel * dsize * 2);
#else
				/* MATLAB complex data has two separate pointers for real and imaginary data (separate API) */
				pr = mxGetData(*data);
				pi = mxGetImagData(*data);			
				if (!pr || !pi) {
					mexErrMsgIdAndTxt("imas:mex", "Failed to allocate complex array data (pr=%p, pi=%p)", pr, pi);
					return (al_status_t) {-1, "Failed to allocate complex array data"};
				}				
			    for (i = 0; i < numel; i++) {
					pr[i] = ((double *) array)[2*i];
					pi[i] = ((double *) array)[2*i+1];
				}
#endif
			}
		} else {
			/*           **** CHAR DATA **** */
			if (dim == 1) {
				dims[0] = 1;
				dims[1] = size[0];
			} else {
				/* Size is [nb of strings, string length] (???) */
				dims[0] = (mwSize) size[0];
				dims[1] = (mwSize) size[1];
			}
			*data = mxCreateCharArray(2, dims);
			/* We need to transpose the character array */
			chararray = mxGetData(*data);
			for (i = 0; i < dims[0]; i++)
				for (j = 0; j < dims[1]; j++)
					chararray[j*dims[0]+i] = (mxChar) ((char *) array)[i*dims[1]+j];
		}
	} else {
		if (datatype == CHAR_DATA) {
			/* Create an empty string (0x0 char array) */
			*data = mxCreateCharArray(0, NULL);
		}
		else
			/* Create an empty array of correct class */
			*data = mxCreateNumericArray(0, NULL, classid, ComplexFlag);
	}

	return status;
}

/**
   Extracts data and size information from an mxArray object.
   This function extracts the data pointer and computes the dimensions of the data from an mxArray object based on its type given by datatype and rank given by dim. It performs the reverse operation of data_to_mxArray.
   @param[in] datatype type of data in the current field.
   @param[in] dim rank of the current field.
   @param[in] data mxArray containing the data.
   @param[out] array pointer to the data to be used by the AL write action.
   @param[out] size pointer containing the dimensions of the data.
   @result error status.
 */
al_status_t data_from_mxArray(int datatype, int dim, const mxArray * data, void **array, int *size)
{
	al_status_t status = {0,""};
	mxChar *chararray;
	int ndims;
	const mwSize *dims;
	mwSize numel = 1;
	int i,j;
	double *pr, *pi;

	ndims = mxGetNumberOfDimensions(data);
	dims = mxGetDimensions(data);
	/* Convert array size and compute total number of elements */
	for (i = 0; i < dim; i++) {
		size[i] = ndims > i ? (int) dims[i] : 1;
		numel = numel * size[i];
	}
	/* Allow for 1D row vectors  */
	if (dim == 1 && dims[0] == 1) {
		size[0] = dims[1];
		numel = dims[1];
	}
	/* Get pointer to data */
	if (datatype != CHAR_DATA) {
		/*           **** NUMERIC DATA **** */
		if (datatype != COMPLEX_DATA)
			/* integer and double data map directly to MATLAB types */
			*array = mxGetData(data);
		else {
#if MX_HAS_INTERLEAVED_COMPLEX
			*array = mxGetData(data);
#else
			/* MATLAB complex data has two separate pointers for real and imaginary data (separate API) */
			*array = malloc(numel*2*sizeof(double));
			pr = mxGetData(data);
			pi = mxGetImagData(data);
			if (!pr || !pi) {
				free(*array);
				*array = NULL;
				mexErrMsgIdAndTxt("imas:mex", "Input array is not properly complex (pr=%p, pi=%p)", pr, pi);
				return (al_status_t) {-1, "Input array is not properly complex"};
			}
			for (i = 0; i < numel; i++) {
				((double *) *array)[2*i] = pr[i];
				((double *) *array)[2*i+1] = pi[i];
			}
#endif
		}
	} else {
		/*           **** CHAR DATA **** */
		/* MATLAB uses mxChar (uint16) to represent char arrays */
		if (dim == 1)
			*array = mxArrayToString(data);
		else {
			/* Size is [nb of strings, string length] (???) */
			/* We need to transpose the character array */
			chararray = (mxChar *) mxGetChars(data);
			*array = malloc(numel*sizeof(char));
			for (i = 0; i < size[1]; i++)
				for (j = 0; j < size[0]; j++)
					((char *) *array)[j*size[1]+i] = (char) chararray[i*size[0]+j];
		}
	}
	return status;
}

/**
   Returns an mxArray containing the default value for the specified type and rank.
   @param[in] datatype type of data in the current field.
   @param[in] dim rank of the current field.
   @param[out] data mxArray containing the data.
   @result error status.
 */
al_status_t mxArray_default_value(int datatype, int dim, mxArray **data)
{
	al_status_t status;
	void * array = NULL;
	mxArray * data_old;

	if (dim == 0) {
		if (datatype == INTEGER_DATA)
			array = (int *) &EMPTY_INT;
		else if (datatype == DOUBLE_DATA)
			array = (int *) &EMPTY_DOUBLE;
		else if (datatype == COMPLEX_DATA)
			array = (int *) &EMPTY_COMPLEX[0];
	}

	status = data_to_mxArray(datatype, dim, array, NULL, data);

	if (datatype == CHAR_DATA && dim == 2) {
		/* For STR_1D cast to cell array of strings */
		data_old = *data;
		if (status.code >= 0) status = castCharToCell(data);
		if (status.code >= 0) mxDestroyArray(data_old);
	}

	return status;
}

/**
   Reads the integer field ids_properties/homogeneous_time.
   For a given context (which must correspond to the root of an open IDS object), this function reads the integer field ids_properties/homogeneous_time.
   @param[in] ctx Current operation context.
   @param[out] homogeneousTime Value of ids_properties/homogeneous_time.
   @result error status.
 */
al_status_t getHomogeneousTimeCtx(int ctx, int *homogeneousTime)
{
	al_status_t status;
	char *fieldPath = "ids_properties/homogeneous_time";
	char *timebasePath = "";
	int retSize[MAXDIM];

	status = al_read_data(ctx, fieldPath, timebasePath, (void**)&homogeneousTime,
			INTEGER_DATA, 0, &retSize[0]);

	return status;
}

/**
   Reads the string field ids_properties/version_put/data_dictionary.
   For a given context (which must correspond to the root of an open IDS object), this function reads the string field ids_properties/version_put/data_dictionary.
   @param[in] ctx Current operation context.
   @param[out] data_dictionary Value of ids_properties/version_put/data_dictionary.
   @result error status.
 */
al_status_t getDataDictionaryVersion(int ctx, char** data_dictionary, bool *tagged_version)
{
	*tagged_version = true;
	al_status_t status;
	char *fieldPath = "ids_properties/version_put/data_dictionary";
	char *timebasePath = "";
	int retSize[MAXDIM];
	char* szTemp = NULL;
	status = al_read_data(ctx, fieldPath, timebasePath, (void **)&szTemp,
			CHAR_DATA, 1, &retSize[0]);
	if (status.code==0)
	{
		*data_dictionary = (char *)malloc(retSize[0] + 1);
		memset(*data_dictionary, 0, retSize[0] + 1);
		strncpy(*data_dictionary, szTemp, retSize[0]);
		free(szTemp);
		if (strstr(*data_dictionary, "-") != NULL) {
    		*tagged_version = false;
		}
	}
	return status;
}

/**
   Returns the IMAS path of a node from NBC data provided by the DD. Used for:
   - computing the path of an AOS (e.g k=0, path is computed from the root node)
   - computing the path of a field (if k!=0, path is computed from the first ancestor AOS relative to the field)
   @param[in] ancestors_count, number of ancestors (AOSs, structures) of the node
   @param[in] ancestors_names, ancestors_names[i] gives the name of the ith ancestor of the node (numbering i starts from the root node)
   @param[in] ancestors_change_nbc_versions, ancestors_change_nbc_versions[i] gives a comma separated list of DD versions
              where renaming of the ith ancestor of the node has occurred.
              e.g. ancestors_change_nbc_versions[1] = "3.24.0,3.25.0,3.26.0" refers to 3 versions
              where the 2nd ancestor (starting from the root node) of the node has been renamed
   @param[in] ancestors_change_nbc_previous_names, ancestors_change_nbc_previous_names[i] gives a comma separated list of names
              of the 2nd ancestor of this node in previous versions of the DD given by ancestors_change_nbc_versions[i]
              e.g. ancestors_change_nbc_previous_names[2] = "name_3240,name_3250,name_3260"
   @param[in] dataDictionaryVersion read in 'ids_properties/version_put/data_dictionary'
   @param[out] path, contains the result.
 */
void getNodePath(char* path,
		int ancestors_count,
		char* ancestors_names[],
		char* ancestors_change_nbc_versions[],
		char* ancestors_change_nbc_previous_names[],
		char* dataDictionaryVersion,
		int k) {

#ifdef _WIN32
	/* Allocate pathTokens dynamically - MSVC doesn't support VLAs */
	char** pathTokens = (char**)malloc(ancestors_count * sizeof(char*));
#else
	char* pathTokens[ancestors_count];
#endif
	char* nbc_versions[NBC_VERSIONS_MAX_COUNT];
	char* nbc_previous_names[NBC_VERSIONS_MAX_COUNT];
	char* pathToken =  malloc(ANCESTOR_NAME_MAX_LENGTH);

	int i;

	path = strcpy(path, "");
	pathToken = strcpy(pathToken, "");

	int pathTokensCount = 0;

	for (i = k; i < ancestors_count; i++) {
		pathToken = strcpy(pathToken, ancestors_names[i]);
		int nbc_versions_count = 0;
		splitUtil(nbc_versions, ancestors_change_nbc_versions[i],
				ANCESTORS_VERSIONS_MAX_LENGTH, ANCESTOR_VERSION_MAX_LENGTH, &nbc_versions_count);
		splitUtil(nbc_previous_names, ancestors_change_nbc_previous_names[i],
				ANCESTORS_PREVIOUS_NAMES_MAX_LENGTH, ANCESTOR_NAME_MAX_LENGTH, &nbc_versions_count);

		int j;
		for (j = 0; j < nbc_versions_count; j++) {
			//printf("nbc_version = %s\n", nbc_versions[j]);
			//printf("dataDictionaryVersion = %s\n", dataDictionaryVersion);
			if ((strcmp(nbc_versions[j], "") != 0) && (strcmp(dataDictionaryVersion, nbc_versions[j]) < 0 || strcmp(dataDictionaryVersion, "") == 0)) {
				//printf("aos/structure/field name has been patched to = %s\n", nbc_previous_names[j]);
				pathToken = strcpy(pathToken, nbc_previous_names[j]);
			}
			else {
				//printf("DD version not patched\n");
			}
			free(nbc_versions[j]);
			free(nbc_previous_names[j]);
		}
		if (strcmp(pathToken, "") != 0) {
			pathTokens[pathTokensCount] = malloc(ANCESTOR_NAME_MAX_LENGTH);
			pathTokens[pathTokensCount] = strcpy(pathTokens[pathTokensCount], pathToken);
			pathTokensCount++;
		}
	}

	free(pathToken);

	for (i = 0; i < pathTokensCount; i++) {
		if (i == 0) {
			path = strcpy(path, pathTokens[i]);
		}
		else {
			char* s = malloc(IMAS_PATH_MAX_LENGTH);
			strcpy(s, "/");
			s = strcat(s, pathTokens[i]);
			path = strcat(path, s);
			free(s);
		}
		free(pathTokens[i]);
	}
	// TODO: free pathTokens elements in the loop above to avoid memory leak, but this causes an access violation on Windows, investigate further
#ifdef _WIN32
	free(pathTokens);
#endif
}

/**
   Returns the IMAS path of a field node from NBC data provided by the DD.
   @param[in] ancestors_count, number of ancestors (AOSs, structures) of the node
   @param[in] ancestors_names, ancestors_names[i] gives the name of the ith ancestor of the node (numbering i starts from the root node)
   @param[in] ancestors_data_types, ancestors_data_types[i] gives the name of the type of the ith ancestor of the node
   @param[in] ancestors_change_nbc_versions, ancestors_change_nbc_versions[i] gives a comma separated list of DD versions
              where renaming of the ith ancestor of the node has occurred.
              e.g. ancestors_change_nbc_versions[1] = "3.24.0,3.25.0,3.26.0" refers to 3 versions
              where the 2nd ancestor (starting from the root node) of the node has been renamed
   @param[in] ancestors_change_nbc_previous_names, ancestors_change_nbc_previous_names[i] gives a comma separated list of names
              of the 2nd ancestor of this node in previous versions of the DD given by ancestors_change_nbc_versions[i]
              e.g. ancestors_change_nbc_previous_names[2] = "name_3240,name_3250,name_3260"
   @param[in] dataDictionaryVersion read in 'ids_properties/version_put/data_dictionary'
   @param[out] path, contains the result.
 */
void getFieldRelativePath(char* relativePath,
		int ancestors_count,
		char* ancestors_names[],
		char* ancestors_change_nbc_versions[],
		char* ancestors_change_nbc_previous_names[],
		char* ancestors_data_types[],
		char* dataDictionaryVersion) {
	int k= getIndexAfterFirstStructArrayAncestor(ancestors_data_types, ancestors_count);
	getNodePath(relativePath, ancestors_count, ancestors_names, ancestors_change_nbc_versions, ancestors_change_nbc_previous_names,dataDictionaryVersion, k);
}

/**
   Returns the index of the first AOS ancestor of a field node.
   @param[in] ancestors_count, number of ancestors (AOSs, structures) of the node
   @param[in] ancestors_data_types, ancestors_data_types[i] gives the name of the type of the ith ancestor of the node
   @result index (starting from the root node) of the first ancestor + 1.
 */
int getIndexAfterFirstStructArrayAncestor(char* ancestors_data_types[], int ancestors_count) {
	int structarrayAncestorIndex = 0;
	int i;
	char* aos_type = ancestors_data_types[ancestors_count - 1];
	for (i=0; i < ancestors_count; i++) {
		if (strcmp(ancestors_data_types[i], "struct_array") == 0) {
			if ( ! ( (i == ancestors_count - 1) && strcmp(aos_type, "struct_array") == 0 ) ) //excluding the current node itself if it's an AOS
				structarrayAncestorIndex = i + 1;
		}
	}
	return structarrayAncestorIndex;
}

/**
   Extract all tokens from a comma separated strings.
   @param[in] charsToSplit, char* containing comma separated strings
   @param[in] charsToSplitLength, length of charsToSplit
   @param[in] tokenLength, max length of each expected token from charsToSplit
   @param[out] arrayOfCharsPointers, pointers array to char*
   @param[out] tokensCount, number of tokens in charsToSplit
   @result each element of arrayOfCharsPointers[] contains a token of charsToSplit.
 */
void splitUtil(char* arrayOfCharsPointers[], char* charsToSplit,
		int charsToSplitLength, int tokenLength, int *tokensCount) {

	const char s[2] = ",";
	char *token;

	char* toTokenize = malloc(charsToSplitLength);
	strcpy(toTokenize, charsToSplit);

	/* get the first token */
	token = strtok(toTokenize, s);
	if (token == NULL)
	{
		*tokensCount = 0;
		free(toTokenize);
		return;
	}

	/* walk through other tokens */
	int i = 0;
	while( token != NULL ) {
		arrayOfCharsPointers[i] = malloc(tokenLength);
		arrayOfCharsPointers[i] = strcpy(arrayOfCharsPointers[i], token);
		token = strtok(NULL, s);
		i++;
	}

	*tokensCount = i;
	free(toTokenize);
}

/**
   Displays a warning when a DD node has an obsolescent lifecycle_status.
   @param[in] idsName, char*, name of the IDS
   @param[in] fieldPath, char*, path to the node
   @param[out] lifeCycleStatus, char*, data-dictionary lifecycle status
 */
void warningWritingObsolescentNode(const char* idsName, const char* fieldPath, const char* lifeCycleStatus)
{
	char* disable_obsolescent_warning_var = getenv("IMAS_AL_DISABLE_OBSOLESCENT_WARNING");
	int disable_obsolescent_warning = 0;
	if (disable_obsolescent_warning_var != NULL) {
	   disable_obsolescent_warning = atoi(disable_obsolescent_warning_var);
	}
	if (disable_obsolescent_warning == 1)
	   return;
	   
    if (strcmp(lifeCycleStatus, "obsolescent") == 0)
        mexPrintf("Warning : while putting IDS %s, the written IDS has non-empty obsolescent node %s. Please consider updating the code to avoid using obsolescent nodes.\n", idsName, fieldPath);
}

/**
   Reads a field and stores it in an mxArray object.
   Combines the reading of the field data by the AL, its encapsulation in an mxArray and its conversion (if needed).
   @param[in] action Information about the current operation.
   @param[in] field Information about the current field.
   @param[out] data mxArray containing the data.
   @result error status.
 */
al_status_t my_al_read_data(struct imas_mex_actionInfo * action, struct imas_mex_fieldInfo * field, mxArray ** data)
{

	al_status_t status;

	mxArray * data_old;
	void * array = NULL;
	int dims[MAXDIM];

	int i;
	double retTime;

	if (field->dim == 0) {
		if (field->datatype == INTEGER_DATA)
			array = malloc(sizeof(int));
		else if (field->datatype == DOUBLE_DATA)
			array = malloc(sizeof(double));
		else if (field->datatype == COMPLEX_DATA)
#ifdef _WIN32
			/* Complex = real + imaginary parts, MSVC doesn't support _Complex keyword */
			array = malloc(2 * sizeof(double));
#else
			array = malloc(sizeof(double _Complex));
#endif
	}

	status = al_read_data(action->context, field->fieldPath, field->timebasePath, &array, field->datatype, field->dim, &dims[0]);

	if (status.code >= 0) status = data_to_mxArray(field->datatype, field->dim, array, dims, data);

	/* Free arrays  */
	if (array) free(array);

#ifndef NO_LOCAL_CONVERSION
	if (params.get_int_as_double)
		if (field->datatype == INTEGER_DATA) {
			data_old = *data;
			if (status.code >= 0) status = castInt32ToDouble(data);
			if (status.code >= 0) mxDestroyArray(data_old);
		}

	if (params.get_empty_as_nan)
		if (field->datatype == DOUBLE_DATA) {
			data_old = *data;
			if (status.code >= 0) status = castEmptyToNaN(data);
			if (status.code >= 0) mxDestroyArray(data_old);
		}
#endif

	if (field->datatype == CHAR_DATA && field->dim == 2) {
		/* For STR_1D cast to cell array of strings */
		data_old = *data;
		if (status.code >= 0) status = castCharToCell(data);
		if (status.code >= 0) mxDestroyArray(data_old);
	}

	return status;
}

/**
   Writes a field from an mxArray object.
   Combines the conversion of the data stored in the MATLAB array (if needed), its conversion into a basic type and the writing action by the AL.
   @param[in] action Information about the current operation.
   @param[in] field Information about the current field.
   @param[in] data mxArray containing the data.
   @result error status.
 */
al_status_t my_al_write_data(struct imas_mex_actionInfo * action, struct imas_mex_fieldInfo * field, const mxArray * data, const char* idsName, const char* lifecycle_status)
{

	al_status_t status = {0,""};
	al_status_t cast_status = {HLI_ERR,""}; /* Necessary flag in case a cast was made and clean-up is required */

	const mxArray * ptime;
	void * array = NULL;
	int dims[MAXDIM];

	int i;
	bool IMAS_AL_ENABLE_PLUGINS = false;
	char* flag = getenv("IMAS_AL_ENABLE_PLUGINS");
	if (flag != NULL && strcmp(flag, "TRUE") == 0)
		IMAS_AL_ENABLE_PLUGINS = true;

#ifndef NO_LOCAL_CONVERSION
	if (params.put_int_from_double)
		if (field->datatype == INTEGER_DATA) {
			if (mxIsNumeric(data) && mxIsDouble(data)) {
				if (status.code >= 0) status = cast_status = castDoubleToInt32((mxArray **) &data);
				/* Check again field validity */
				if (status.code >= 0) {
					bool isFieldValid = is_field_valid(field->datatype, field->dim, data);
					if (!isFieldValid && !IMAS_AL_ENABLE_PLUGINS)
					   return (al_status_t) {0,""};
					else if (!isFieldValid && IMAS_AL_ENABLE_PLUGINS) {
					   status = al_write_data(action->context, field->fieldPath, field->timebasePath, NULL, field->datatype, field->dim, NULL);
					   return status;	
					}
				}
				
			}
		}

	if (params.put_empty_from_nan)
		if (field->datatype == DOUBLE_DATA) {
			if (mxIsNumeric(data) && mxIsDouble(data)) {
				if (status.code >= 0) status = cast_status = castNaNToEmpty((mxArray **) &data);
				/* Check again field validity */
				if (status.code >= 0) {
					bool isFieldValid = is_field_valid(field->datatype, field->dim, data);
					if (!isFieldValid && !IMAS_AL_ENABLE_PLUGINS)
						return (al_status_t) {0,""};
					else if (!isFieldValid && IMAS_AL_ENABLE_PLUGINS) {
				    	status = al_write_data(action->context, field->fieldPath, field->timebasePath, NULL, field->datatype, field->dim, NULL);
				    	return status;
					}
				}
			}
		}
#endif

	if (field->datatype == CHAR_DATA && field->dim == 2) {
		if (mxIsCell(data)) {
			if (status.code >= 0) status = cast_status = castCellToChar((mxArray **) &data);
			if (data == NULL) return (al_status_t) {0,""};
		}
	}

	if (status.code >= 0) status = data_from_mxArray(field->datatype, field->dim, data, &array, dims);

    if (status.code >= 0) {
      if (is_field_valid(field->datatype, field->dim, data))
         warningWritingObsolescentNode(idsName, field->fieldPath, lifecycle_status);
		 if (status.code >= 0) status = al_write_data(action->context, field->fieldPath, field->timebasePath, array, field->datatype, field->dim, &dims[0]);
    }
    else {
		if (IMAS_AL_ENABLE_PLUGINS)
		   if (status.code >= 0) status = al_write_data(action->context, field->fieldPath, field->timebasePath, array, field->datatype, field->dim, &dims[0]);
	}
	
	/* Clean up memory allocated by data_from_mxArray */
	if (field->datatype == CHAR_DATA) {
		if (array != NULL)
			(field->dim == 1) ? mxFree(array) : free(array);
	} else if (field->datatype == COMPLEX_DATA) {
		if (array != NULL)
			free(array);
	}

	/* Clean up data created by cast operation */
	if (cast_status.code == 0)
		mxDestroyArray((mxArray *) data);

	return status;
}

/**
   Returns boolean value to enable or disable ids validation on ids_put
   @result true or false.
 */
bool is_validation_required() {
    const char* disable_validation = getenv("IMAS_AL_DISABLE_VALIDATE");
    return !(disable_validation && (*disable_validation == '1'));
}
