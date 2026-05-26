<?xml version="1.0" encoding="UTF-8"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./%24GET%5Bstylesheet%5D" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>
<!-- Generating MEX access layer code from Data Dictionary IDSDef.xml -->
<!-- -->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/02/xpath-functions"
    xmlns:my="dummy"
    version="2.0">

<xsl:output method="text" version="1.0" encoding="UTF-8" indent="no"/>


<!--================================================-->
<!--                 Include section                -->
<!--================================================-->

<xsl:include href="mex_tools.xsl"/>
<xsl:include href="validate_single.xsl"/>

<!--================================================-->
<!--                Debug logs param                -->
<!--================================================-->
<xsl:variable name="enable-logging" select="'no'"/>

<!--================================================-->
<!--         Template for the whole document        -->
<!--================================================-->

<xsl:template match = "/IDSs">
  <xsl:result-document href="src/ids/ids_validate.c" standalone="yes" method="text">
/** \addtogroup interface MEX-interface
 *  @{
 */

/**
   \file ids_validate.c
   read IDS in MATLAB External Interfaces
   
   This is a MEX file for MATLAB.

   Usage:
   \code{.m} 
   ids_validate(IDSname, ids)
   \endcode

   MATLAB help:
   \include matlab/ids_validate.m
 */

/** @}*/

#include "ids_validate.h"
#include "imas_mex_utils.h"

/**
   Entry point to C/C++ MEX function built with C Matrix API
 */
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  /* Check for one input arguments   */
  if(nrhs != 2) {
    mexErrMsgIdAndTxt("IMAS:ids_validate:nargin",
                      "Two inputs required.");
  }

  /* make sure IDSname is a string */
  if( !mxIsChar(prhs[0]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_validate:notChar",
                        "Input IDSname must be a string.");
  }
  /* Get the value of IDSname */
  char *IDSname = mxArrayToString(prhs[0]);
  if (params.verbosity >= 4)
  mexPrintf("The input IDSname is:  %s\n", IDSname);

  /* make sure ids is scalar struct */
  if( !mxIsStruct(prhs[1]) ||
      !mxIsScalar(prhs[1]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_validate:notScalar",
                        "Input ids must be a scalar structure.");
  }
  /* Get the value of ids */
  if (params.verbosity >= 4)
  mexPrintf("The input ids is:  %s\n", "SKIPPED");

  /* Check for no output argument */
  if(nlhs > 0) {
    mexErrMsgIdAndTxt("IMAS:ids_validate:nargout",
                      "No output required.");
  }

  /* Extract IDS name */
  char* name = IDSname;

  /* Declare Function Pointer */
  al_validation_status_t(*ids_validate)(char*,const mxArray*) = NULL;
  /* Assign pointer based on IDS name */
  <xsl:apply-templates select = "IDS" mode="SWITCH">
    <xsl:with-param name="function_name">ids_validate</xsl:with-param>
  </xsl:apply-templates>
  /* Error if there was no match */
  mexErrMsgIdAndTxt("IMAS:ids_validate:unknown_ids",
           "Unknown IDS name: %s", IDSname);
  
  /* Clean-up previous errors */
  resetErrMsgIdAndTxt();
  /* Call function */
  al_validation_status_t err = ids_validate(IDSname, prhs[1]);
  if (err.code &lt; 0 )
  my_validation_mexErrMsgIdAndTxt(err, "IMAS:ids_validate:");
  return;

}
 </xsl:result-document>

  <xsl:result-document href="src/ids/ids_validate.h" standalone="yes" method="text">
    #include "mex.h"
    #include "imas_mex_utils.h"
    <xsl:for-each select="IDS">
    al_validation_status_t ids_validate_<xsl:value-of select="@name"/>(char* idsFullName, const mxArray* ids);
    </xsl:for-each>
 </xsl:result-document>

 <xsl:result-document href="src/ids/validate_ids.c" standalone="yes" method="text">
    #include "imas_mex_utils.h"
    #if (__STDC_VERSION__ >= 199901L)
    #include &lt;stdint.h&gt;
    #endif


    // a hardcoded strok_r. same function but by moving the save pointer
    char *my_strtok_r (char *srcString, char delim, char **save_ptr)
    {
      #ifdef _WIN32
        unsigned int openpar  = 0;
        unsigned int closepar = 0;
      #else
        uint openpar  = 0;
        uint closepar = 0;
      #endif
      if(!srcString)
      {
          srcString = *save_ptr;
      }
      if(!srcString)
      {
          return NULL;
      }
      // handle beginning of the string containing delims
      while(1)
      {
          if(*srcString==delim)
          {
              srcString++;
              continue;
          }
          if(*srcString == '\0')
          {
              // we've reached the end of the string
              return NULL; 
          }
          break;
      }
      char *ret = srcString;
      while(1)
      {
          if(*srcString == '\0')
          {
              /*end of the input string and
              next exec will return NULL*/
              *save_ptr = srcString;
              return ret;
          }
          if(*srcString==delim)
          {
              if (openpar == closepar) {
              *srcString = '\0';
              *save_ptr = srcString + 1;
              return ret;
              }
          }
          if(*srcString=='(')  openpar++;
          if(*srcString==')')  closepar++;
          srcString++;
      }
    }

    // get the pointer of the field name by 'path' from a position field (data) of the tree 
    const mxArray* getFieldFromStruct(char *path, const mxArray * data)
    {
      /* Extracts field from given structure 'data' following '/'-separated path */
    
      int ifield = -1;
      char *token;
      const mxArray* pfield; 
      char *relative_path;
      char *pathcopy = strdup(path);
      #ifdef _WIN32
        mwIndex index = 0;
      #else
        mwIndex index;
      #endif
    
      if (!data) {
        free(pathcopy);
        return NULL;
      }
    
      /* Extract path after last closing bracket */
      token = strtok(pathcopy, ")");
      while (token != NULL) {
        relative_path = token;
        token = strtok(NULL, ")");
      }
    
      pfield = data;
    
      /* Structure unroll */
      token = strtok(relative_path, "/");
      while (token != NULL &amp;&amp; pfield != NULL) {
        if (!mxIsStruct(pfield) || 
      (params.use_cell_array_for_array_of_structures &amp;&amp; !mxIsScalar(pfield))) {
          pfield = NULL;
          break;
        }
        ifield = mxGetFieldNumber(pfield, token);
        if (ifield &lt; 0) {
          pfield = NULL;
          break;
        }
        pfield = (const mxArray *) mxGetFieldByNumber(pfield, index, ifield);
        token = strtok(NULL, "/");
        index = 0; /* Only the first item can be an array */
      }
      free(pathcopy);
      return pfield;
    }

    // Function to replace all the occurrences
// of the substring S1 to S2 in string S

char *str_replace(const char *str, const char *from, const char *to) {

	/* Adjust each of the below values to suit your needs. */

	/* Increment positions cache size initially by this number. */
	size_t cache_sz_inc = 16;
	/* Thereafter, each time capacity needs to be increased,
	 * multiply the increment by this factor. */
	const size_t cache_sz_inc_factor = 3;
	/* But never increment capacity by more than this number. */
	const size_t cache_sz_inc_max = 1048576;

	char *pret, *ret = NULL;
	const char *pstr2, *pstr = str;
	size_t i, count = 0;
	#if (__STDC_VERSION__ >= 199901L)
	uintptr_t *pos_cache_tmp, *pos_cache = NULL;
	#else
	ptrdiff_t *pos_cache_tmp, *pos_cache = NULL;
	#endif
	size_t cache_sz = 0;
	size_t cpylen, orglen, retlen, tolen, fromlen = strlen(from);

	/* Find all matches and cache their positions. */
	while ((pstr2 = strstr(pstr, from)) != NULL) {
		count++;

		/* Increase the cache size when necessary. */
		if (cache_sz &lt; count) {
			cache_sz += cache_sz_inc;
			pos_cache_tmp = realloc(pos_cache, sizeof(*pos_cache) * cache_sz);
			if (pos_cache_tmp == NULL) {
				goto end_repl_str;
			} else pos_cache = pos_cache_tmp;
			cache_sz_inc *= cache_sz_inc_factor;
			if (cache_sz_inc > cache_sz_inc_max) {
				cache_sz_inc = cache_sz_inc_max;
			}
		}

		pos_cache[count-1] = pstr2 - str;
		pstr = pstr2 + fromlen;
	}

	orglen = pstr - str + strlen(pstr);

	/* Allocate memory for the post-replacement string. */
	if (count > 0) {
		tolen = strlen(to);
		retlen = orglen + (tolen - fromlen) * count;
	} else	retlen = orglen;
	ret = malloc(retlen + 1);
	if (ret == NULL) {
		goto end_repl_str;
	}

	if (count == 0) {
		/* If no matches, then just duplicate the string. */
		strcpy(ret, str);
	} else {
		/* Otherwise, duplicate the string whilst performing
		 * the replacements using the position cache. */
		pret = ret;
		memcpy(pret, str, pos_cache[0]);
		pret += pos_cache[0];
		for (i = 0; i &lt; count; i++) {
			memcpy(pret, to, tolen);
			pret += tolen;
			pstr = str + pos_cache[i] + fromlen;
			cpylen = (i == count-1 ? orglen : pos_cache[i+1]) - pos_cache[i] - fromlen;
			memcpy(pret, pstr, cpylen);
			pret += cpylen;
		}
		ret[retlen] = '\0';
	}

end_repl_str:
	/* Free the cache and return the post-replacement string,
	 * which will be NULL in the event of an error. */
	free(pos_cache);
	return ret;
}

    // recursive function: get the pointer of the field following his path from a position field (data) of the tree
    const mxArray *getFieldFromPath(const char *path, const mxArray *data, const int *indices_values, const char **indices_names, int nbindices) {

      char *token;
      char *pathcopy = strdup(path);
      char *relative_path;
      char *save_ptr;
      const mxArray *pfield = data;
      token = my_strtok_r(pathcopy, '/', &amp;save_ptr);
      token = my_strtok_r(NULL, '/', &amp;save_ptr);

      
      if (token==NULL) {
        pathcopy = strdup(path);
        token = my_strtok_r(pathcopy, '(', &amp;save_ptr);
        pfield = getFieldFromStruct(token, data);
        if(pfield != NULL) {
          token = my_strtok_r(NULL, ')', &amp;save_ptr);
          if (token != NULL) {
            if (strlen(token)==1) {
              int index = atoi(token);
              pfield = mxGetCell(pfield, index-1);
              return pfield;
            } else {
              // check if is in indices_name array
              for (int i = 0; i &lt; nbindices; i++) {
                if (strcmp(indices_names[i],token)==0) {
                  pfield = mxGetCell(pfield, indices_values[i]);
                  return pfield;
                }
              }
              //
              const mxArray *indexfield = getFieldFromPath(token, data, indices_values, indices_names, nbindices);
              if (indexfield == NULL) {
                return NULL;
              } else {
                if (!mxIsNumeric(indexfield) &amp;&amp; !mxIsScalar(indexfield)) {
                  return NULL;
                } else 
                {
                  int scalar;
                  if (mxIsInt32(data)) {
                    scalar = *(int *) mxGetData(indexfield);
                  } else {
                    scalar = (int) mxGetScalar(indexfield);
                  }
                  pfield = mxGetCell(pfield, scalar-1);
                }
              }
            }
          }
        }
        return pfield;
      } else {
      pathcopy = strdup(path);
      token = my_strtok_r(pathcopy, '/', &amp;save_ptr);    
      pathcopy = strdup(token);
      token = my_strtok_r(pathcopy, '(', &amp;save_ptr);
      pfield = getFieldFromStruct(token, data);
      if(pfield != NULL) {
        token = my_strtok_r(NULL, ')', &amp;save_ptr);
        if (token != NULL) {
          // its a struct_array
         pathcopy = strdup(path);
         token = my_strtok_r(pathcopy, '/', &amp;save_ptr); 
         pfield = getFieldFromPath(token, data, indices_values, indices_names, nbindices);
         if (pfield!=NULL) {
          pfield = getFieldFromPath(save_ptr, pfield, indices_values, indices_names, nbindices);
         }
          
        } else {
          // it's a structure
          pathcopy = strdup(path);
          token = my_strtok_r(pathcopy, '/', &amp;save_ptr);
          pfield = getFieldFromPath(token, data, indices_values, indices_names, nbindices);
          if (pfield!=NULL) {
          pfield = getFieldFromPath(save_ptr, pfield, indices_values, indices_names, nbindices);
          }
        }
      }
    }
      
      free(pathcopy);
      return pfield;
    }

    char* getShapeStr(const mxArray* data, int rank)
     {
      char* result; 
      int ndims;
      const mwSize *dims;
      ndims = mxGetNumberOfDimensions(data);
      dims = mxGetDimensions(data);

      /* Allow for 1D row vectors  */
      if (ndims == 1 &amp;&amp; dims[0] == 1) {
        size_t needed = snprintf(NULL, 0, "%s,%zu,%s","(",dims[1],")");
        char  *result = malloc(needed+1);
        sprintf(result,"%s,%zu,%s","(",dims[1],")");
        return result;
      } else {
        size_t needed = snprintf(NULL, 0, "%s%zu","(",dims[0]);
        for (int i=1;i&lt;rank;i++) needed = needed + snprintf(NULL, 0, ",%zu",dims[i]);
        needed = needed + snprintf(NULL, 0, ")");
        char  *result = malloc(needed+1);
        sprintf(result,"%s%zu","(",dims[0]);
        for (int i=1;i&lt;rank;i++) sprintf(result,"%s,%zu",result,dims[i]);
        sprintf(result,"%s)",result);
        return result;
      }


     }

    mwSize getDimSize(const mxArray * data, int rank, int dim)
      {
        int ndims;
        const mwSize *dims;

        if (data == NULL) return 0;

        if (dim > rank) return 1;
 
        ndims = mxGetNumberOfDimensions(data);
        dims = mxGetDimensions(data);

        if (rank > ndims) return 0;

        /* Allow for 1D row vectors  */
        if (rank == 1 &amp;&amp; dims[0] == 1) {
          return dims[1];
        }

        /* Convert array size and compute total number of elements */
        return ndims > dim-1 ? dims[dim-1] : 1;

       }

    al_validation_status_t validate_coordinate(const mxArray *root, const mxArray *data, int idsTimeMode, bool is_time_coordinate, int timeSize, const char *initialpath, const char *crootpath, const char *path, int rank, const int *indices_values, const char *indices_names[], int nbindices, int cfield_dim,const char *ctargetfield[], int nb_ctargets, int *target_ranks, int ctargetfielddim, int spec_dim) 
    {
      al_status_t alStatus = {0,""};
      al_validation_status_t status = {0,""};
      char *pathcopy = strdup(path);
      const mxArray *pfield;
      char *save_ptr;
      char *token;
      token = my_strtok_r(pathcopy, '/', &amp;save_ptr);
      token = my_strtok_r(NULL, '/', &amp;save_ptr);
      
      if (token==NULL) {
        pathcopy = strdup(path);
        token = my_strtok_r(pathcopy, '(', &amp;save_ptr);
        pfield = getFieldFromStruct(token, data);
        if(pfield != NULL) {
          mwSize aosArraySize = getDimSize(pfield, rank, cfield_dim);
          if (aosArraySize != 0) {
            if(is_time_coordinate &amp;&amp; idsTimeMode == IDS_TIME_MODE_HOMOGENEOUS) {
              if (timeSize != aosArraySize) {
              size_t needed = snprintf(NULL, 0, "Element '%s%s' has incorrect shape %s: its coordinate in dimension %d ('time') has size %d.", crootpath, initialpath, getShapeStr(pfield,rank), cfield_dim, timeSize);
              char  *buffer = malloc(needed+1);
              sprintf(buffer, "Element '%s%s' has incorrect shape %s: its coordinate in dimension %d ('time') has size %d.", crootpath, initialpath, getShapeStr(pfield,rank), cfield_dim, timeSize);
              strncpy(status.message, buffer, needed);
	            status.code = HLI_ERR;
	           free(buffer);
             free(pathcopy);
              return status;
              }
            }
            if((is_time_coordinate == (idsTimeMode == IDS_TIME_MODE_HETEROGENEOUS)) || !is_time_coordinate) {
            bool check = true;
            bool error = true;
            int i = 0;
            mwSize targetFieldSize = 0;
            int targetcpathid = 0;
	          mwSize pfieldSize = 0;
            for (int cpathid = 0; cpathid&lt;nb_ctargets;cpathid++) {
            const mxArray *pfieldtarget = getFieldFromPath(ctargetfield[cpathid], root, indices_values, indices_names, nbindices);
            pfieldSize = getDimSize(pfieldtarget, target_ranks[cpathid], ctargetfielddim);
            if (pfieldSize != 0) {
                targetcpathid = i;
                targetFieldSize = pfieldSize;
                i = i + 1;
              } 
            }
        
            if (i!=1) { 
              check = false;
            }

            if (spec_dim==0 &amp;&amp; i!=1) { 
              size_t neededcoord= snprintf(NULL, 0, "%s%s",crootpath, ctargetfield[0]);
              for (int target=1; target&lt;nb_ctargets;target++) {
                neededcoord+= snprintf(NULL, 0, " OR %s%s",crootpath, ctargetfield[target]);
              }
              if(spec_dim!=0)  neededcoord +=  snprintf(NULL, 0, " OR %d",spec_dim);

              char  *buffercoord = malloc(neededcoord+1);
              sprintf(buffercoord, "%s%s",crootpath, ctargetfield[0]);
              for (int target=1; target&lt;nb_ctargets;target++) {
                sprintf(buffercoord, "%s OR %s%s",buffercoord,crootpath, ctargetfield[target]);
              }
              if(spec_dim!=0) sprintf(buffercoord,"%s OR %d",buffercoord,spec_dim);

              size_t needed = snprintf(NULL, 0, "Element '%s%s' must have its coordinate in dimension %d (any of '%s') filled.", crootpath, initialpath, cfield_dim,buffercoord);
              char  *buffer = malloc(needed+1);
              sprintf(buffer, "Element '%s%s' must have its coordinate in dimension %d (any of '%s') filled.",crootpath, initialpath, cfield_dim, buffercoord);
              strncpy(status.message, buffer, needed);
              for (int k=0;k&lt;nbindices; k++) {
                char *initbuffer = strdup(status.message);
                size_t indexstrneeded = snprintf(NULL,0,"%d",indices_values[k]+1);
                const char* indexstr = indices_names[k];
                char* valuestr = malloc(indexstrneeded+1); 
                sprintf(valuestr,"%d", indices_values[k]+1);
                char* newbuff = str_replace(initbuffer,indexstr,valuestr);
                strncpy(status.message, newbuff, MAXERRMSGTXTSIZE);
                free(valuestr);
                free(newbuff);
                free(initbuffer);
              }
	            status.code = HLI_ERR;
              free(buffer);
              free(buffercoord);
              free(pathcopy);
              return status;
            }
            if (aosArraySize == targetFieldSize) {
              error = false; 
            }

            if (spec_dim!=0 &amp;&amp; error==true) {
              if(aosArraySize==spec_dim) error = false;
            }
              
            if (error &amp;&amp; status.code >= 0) { 
              size_t neededcoord= snprintf(NULL, 0, "%s",ctargetfield[0]);
              for (int target=1; target&lt;nb_ctargets;target++) {
                neededcoord+= snprintf(NULL, 0, " OR %s",ctargetfield[target]);
              }
              if(spec_dim!=0) neededcoord+=snprintf(NULL, 0, "1...1");
              size_t neededindices =0;
              for (int index=0; index&lt;nbindices; index++) {
                  neededindices+=snprintf(NULL, 0, "\r\nFor %s = %d",indices_names[index], indices_values[index]+1);
              }

              char  *buffercoord = malloc(neededcoord+1);
              sprintf(buffercoord, "%s",ctargetfield[0]);
              for (int target=1; target&lt;nb_ctargets;target++) {
                sprintf(buffercoord, "%s OR %s",buffercoord,ctargetfield[target]);
              }
              if(spec_dim!=0) sprintf(buffercoord,"%s OR %d",buffercoord,spec_dim);
              size_t needed = snprintf(NULL, 0, "Element '%s%s' has incorrect shape %s: its coordinate in dimension %d ('%s%s') has size %zu.", crootpath, initialpath, getShapeStr(pfield,rank), cfield_dim,crootpath,ctargetfield[targetcpathid], targetFieldSize);
              char  *buffer = malloc(needed+1);
              sprintf(buffer, "Element '%s%s' has incorrect shape %s: its coordinate in dimension %d ('%s%s') has size %zu.", crootpath, initialpath,getShapeStr(pfield,rank), cfield_dim,crootpath,ctargetfield[targetcpathid], targetFieldSize);
              strncpy(status.message, buffer, needed);
              /// --- replacement of each index by its value
              for (int k=0;k&lt;nbindices; k++) {
                char *initbuffer = strdup(status.message);
                size_t indexstrneeded = snprintf(NULL,0,"%d",indices_values[k]+1);
                const char* indexstr = indices_names[k];
                char* valuestr = malloc(indexstrneeded+1); 
                sprintf(valuestr,"%d", indices_values[k]+1);
                char* newbuff = str_replace(initbuffer,indexstr,valuestr);
                strncpy(status.message, newbuff, MAXERRMSGTXTSIZE );
                free(valuestr);
                free(newbuff);
                free(initbuffer);
              }
              ///
              status.code = HLI_ERR;
              free(buffer);
              free(buffercoord);
              free(pathcopy);
              return status;
            }
              free(pathcopy);
              return status;
          }
          if (is_time_coordinate == (idsTimeMode == IDS_TIME_MODE_INDEPENDENT)) {
            if(aosArraySize != 0) {
              size_t needed = snprintf(NULL, 0, "Element '%s%s' has incorrect shape %s: dimension %d must have size 0.", crootpath, initialpath, getShapeStr(pfield,rank), cfield_dim);
              char  *buffer = malloc(needed+1);
              sprintf(buffer,  "Element '%s%s' has incorrect shape %s: dimension %d must have size 0.", crootpath, initialpath, getShapeStr(pfield,rank), cfield_dim);
              strncpy(status.message, buffer, needed);
              status.code = HLI_ERR;
              free(pathcopy);
              return status;
            }
          }
          }
        }
      } else {
      pathcopy = strdup(path);
      token = my_strtok_r(pathcopy, '/', &amp;save_ptr);    
      pathcopy = strdup(token);
      token = my_strtok_r(pathcopy, '(', &amp;save_ptr);
      pfield = getFieldFromStruct(token, data);
      if(pfield != NULL) {
        token = my_strtok_r(NULL, ')', &amp;save_ptr);
        if (token != NULL) {
          // its a struct_array
          int field_size = mxGetNumberOfElements(pfield);
          if (field_size==0) {
            return status;
            free(pathcopy);
          }
          int *new_indices_values = malloc((nbindices+1)*sizeof(int));
          char **new_indices_names = malloc((nbindices+1)*sizeof(char *));
          for (int index=0;index&lt;nbindices;index++) {
            new_indices_values[index] = indices_values[index];
            new_indices_names[index] = strdup(indices_names[index]);
          }
          new_indices_names[nbindices] = strdup(token);
          for (int index=0;index&lt;field_size;index++) {
            new_indices_values[nbindices] = index;
            const mxArray *pfield_elem = mxGetCell(pfield, index);
            if (pfield_elem) {
              pathcopy = strdup(path);
              char * newtoken = my_strtok_r(pathcopy, '/', &amp;save_ptr);
              status = validate_coordinate(root, pfield_elem, idsTimeMode, is_time_coordinate, timeSize, initialpath, crootpath, save_ptr, rank, new_indices_values, (const char **) new_indices_names, nbindices + 1, cfield_dim, ctargetfield, nb_ctargets, target_ranks, ctargetfielddim, spec_dim);
            }
          }
         free(new_indices_values);
         for (int index=0;index&lt;nbindices+1;index++) free(new_indices_names[index]);
         free(new_indices_names);
        } else {
          // it's a structure
          pathcopy = strdup(path);
          token = my_strtok_r(pathcopy, '/', &amp;save_ptr);
          status = validate_coordinate(root, pfield, idsTimeMode, is_time_coordinate, timeSize, initialpath, crootpath, save_ptr, rank, indices_values, (const char **) indices_names, nbindices, cfield_dim, ctargetfield, nb_ctargets, target_ranks, ctargetfielddim, spec_dim);
        }
      }
      
      free(pathcopy);
      return status;

    }
      // Default return if no other path was taken
      free(pathcopy);
      return status;
    }

    al_validation_status_t validateCoordinateFromPath(const mxArray *data, int idsTimeMode, int timeSize, bool is_time_coordinate, const char *crootpath, const char *path, int rank, int cfield_dim,const char *ctargetfield[], int nb_ctargets, int *target_ranks, int ctargetfielddim, int spec_dim) {
      const mxArray *root = data;
      #ifdef _WIN32
        int *indices_values = NULL;
      #else
        int *indices_values;
      #endif
      char *indices_names[] = {};
      const char *initialpath = path;

      return validate_coordinate(root, data, idsTimeMode, is_time_coordinate, timeSize, initialpath, crootpath, path, rank, indices_values, (const char **) indices_names, 0, cfield_dim, ctargetfield, nb_ctargets, target_ranks, ctargetfielddim, spec_dim);

    }

    <xsl:for-each select="IDS">
    <xsl:apply-templates select="field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_VALIDATE_H"/>
    
    al_validation_status_t ids_validate_<xsl:value-of select="@name"/>(char* idsFullName, const mxArray* ids)
    {
    al_validation_status_t status = {0,""};
    al_status_t alStatus = {0,""};
    int ifield;
    const mxArray* data=NULL; 
    const mxArray* pfield=NULL;
    int idsTimeMode = IDS_TIME_MODE_UNKNOWN;
    int timeSize = 0;
    int isEmpty;
    int i1max, i2max, i3max, i4max, itimemax;
    int aosArraySize;
    int coordSize;

    alStatus = init_dataTree_write((mxArray *) ids);
    status.code = alStatus.code; strncpy(status.message, alStatus.message, MAX_ERR_MSG_LEN);
    if (status.code >= 0) {
      alStatus = getHomogeneousTime(&amp;idsTimeMode);
      status.code = alStatus.code; strncpy(status.message, alStatus.message, MAX_ERR_MSG_LEN);
    }
    if (status.code &lt; 0) mexErrMsgIdAndTxt("IMAS:ids_validate:invalid_homogeneous_time",
    "Unable to retrieve ids%%ids_properties%%homogeneous_time"); 
    
    <xsl:if test="not(@type='constant')">
    if( idsTimeMode == IDS_TIME_MODE_UNKNOWN )
    {
    mexErrMsgIdAndTxt("IMAS:ids_validate:empty_ids", "ids%%ids_properties%%homogeneous_time is not defined.");
    return status;
    }
    else if ( idsTimeMode == IDS_TIME_MODE_HOMOGENEOUS ) {
      ifield = mxGetFieldNumber(ids, "time");
      data = mxGetFieldByNumber(ids, (mwIndex) 0, ifield);
      if (data == NULL) {
        mexErrMsgIdAndTxt("IMAS:ids_validate:invalid_time",
	"Unable to retrieve ids%%time");
	status.code = HLI_ERR;
      }
      timeSize = mxGetNumberOfElements(data);
      if (timeSize &lt; 1)
      mexErrMsgIdAndTxt("IMAS:ids_validate:empty_time",
      "If time is homogeneous, ids%%time must have at least one element");
    }
    </xsl:if>
    
    if (status.code &gt;= 0) {
      alStatus = get_data_from_dataTree(NULL, (mxArray **) &amp;data);
      status.code = alStatus.code; strncpy(status.message, alStatus.message, MAX_ERR_MSG_LEN);
    }

    if (status.code &gt;= 0) {
    <xsl:apply-templates select="field" mode="VALIDATE_CHILD_CALL"/>
    <xsl:apply-templates select="field[@data_type='struct_array']" mode="VALIDATE_CHILD_1D"/>
    <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_1D"/>
    <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_2D"/>
    <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_3D"/>
    <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_4D"/>
    <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_5D"/>
    <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_6D"/>
    <xsl:apply-templates select="field" mode="VALIDATE_CHILD_FIXED_SIZE"/>
    }

    return status;
    }

    <!-- <xsl:apply-templates select="field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_VALIDATE_H"/> -->

    <xsl:apply-templates select="field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_VALIDATE"/>
    </xsl:for-each>
  </xsl:result-document>
</xsl:template>
<xsl:template match = "field[@data_type='structure' or @data_type='struct_array']" mode="VALIDATE_CHILD_CALL">
  <xsl:choose>
  <xsl:when test="@data_type='structure'"> 
    if (status.code &gt;= 0) pfield = getFieldFromStruct("<xsl:value-of select="@name"/>", data);
    if (pfield != NULL &amp;&amp; status.code &gt;= 0) {
      if (status.code &gt;= 0) {
      alStatus = begin_dataTree_write("<xsl:value-of select="@name"/>", &amp;isEmpty);
      status.code = alStatus.code; strncpy(status.message, alStatus.message, MAX_ERR_MSG_LEN);
      }
    if (!isEmpty &amp;&amp; status.code &gt;= 0) status = validate_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(idsTimeMode, timeSize);
    if (status.code &gt;= 0) end_dataTree_action();
    }
  </xsl:when>
  <xsl:when test="@data_type='struct_array'">
    if (status.code &gt;= 0) pfield = getFieldFromStruct("<xsl:value-of select="@name"/>", data);
    if (pfield != NULL &amp;&amp; status.code &gt;= 0) {
      <xsl:if test="$enable-logging = 'yes'">
        printf("Size of struct_array: %d elements.\n\r",(pfield == NULL) ? 0 : mxGetNumberOfElements(pfield));
      </xsl:if>
    if (status.code &gt;= 0) {
      alStatus = begin_dataTree_array_write("<xsl:value-of select="@name"/>", &amp;aosArraySize);
      status.code = alStatus.code; strncpy(status.message, alStatus.message, MAX_ERR_MSG_LEN);
    }
    if (status.code &gt;= 0) {
      <xsl:if test="$enable-logging = 'yes'">
        printf("Loop for <xsl:value-of select="@name"/> over %d elements.\n\r",aosArraySize);
      </xsl:if>
      for (int i=0; i&lt;aosArraySize; i++) {
      const mxArray* elem = mxGetCell(pfield, i);
      if (elem != NULL) {
        if (status.code &gt;= 0 &amp;&amp; (mxIsStruct(elem))) {
          if (status.code &gt;= 0) {
            alStatus = iterate_dataTree_array(i);
            status.code = alStatus.code; strncpy(status.message, alStatus.message, MAX_ERR_MSG_LEN);
          }
          if (status.code &gt;= 0) status = validate_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(idsTimeMode, timeSize);
          if (status.code &lt; 0) {
              char *buffer = strdup(status.message);
              size_t needed_nb_char = snprintf(NULL, 0, "%s", buffer);
              size_t needed = snprintf(NULL,0,"%d",i+1);
              char* indexstr = "<xsl:value-of select="substring-before(substring-after(@path_doc,concat(@name,'(')),')')"/>";
              char* valuestr = malloc(needed+1); 
              sprintf(valuestr,"%d", i+1);
              needed_nb_char += needed-snprintf(NULL,0,"%s",indexstr);;
              char* newbuff = str_replace(buffer,indexstr,valuestr);
              needed = snprintf(NULL, 0, "%s", newbuff);
              strncpy(status.message, newbuff, needed_nb_char);
              free(valuestr);
              free(newbuff);
              free(buffer);
          }
        }
        }
      }
    }
    if (status.code &gt;= 0) {
      alStatus = end_dataTree_array_action();
      status.code = alStatus.code; strncpy(status.message, alStatus.message, MAX_ERR_MSG_LEN);
    }
    }
  </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="field[@data_type='struct_array' or @data_type='structure']" mode="METHOD_VALIDATE_H">
al_validation_status_t validate_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(int idsTimeMode, int timeSize);
</xsl:template>

<xsl:template match="field[@data_type='struct_array' or @data_type='structure']" mode="METHOD_VALIDATE">
<xsl:apply-templates select="field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_VALIDATE_H"/>
    al_validation_status_t validate_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(int idsTimeMode, int timeSize)
    {
    const mxArray* data=NULL;
    const mxArray* pfield=NULL;
    al_validation_status_t status = {0,""};
    al_status_t alStatus = {0,""};
    int isEmpty;
    int aosArraySize;
    int ifield;
    int ndims;
    int i1max, i2max, i3max, i4max, itimemax;
	  const mwSize *dims;

    if (status.code &gt;= 0) {
      alStatus = get_data_from_dataTree(NULL, (mxArray **) &amp;data);
      status.code = alStatus.code; strncpy(status.message, alStatus.message, MAX_ERR_MSG_LEN);
    }

    if (data != NULL &amp;&amp; !mxIsEmpty(data)) {

    <xsl:if test="$enable-logging = 'yes'">
      printf("In validate_<xsl:value-of select="@path"/>\n\r");
    </xsl:if>

    <xsl:apply-templates select="field" mode="VALIDATE_CHILD_CALL"/>

    <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_1D"/>
    <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_2D"/>
    <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_3D"/>
    <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_4D"/>
    <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_5D"/>
    <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_6D"/>
    <xsl:apply-templates select="field" mode="VALIDATE_CHILD_FIXED_SIZE"/>
    }

    <xsl:if test="$enable-logging = 'yes'">
      printf("end validate_<xsl:value-of select="@path"/> with statuscode: %d\n\r",status.code);
    </xsl:if>

    return status;
    }
    <xsl:apply-templates select="field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_VALIDATE"/>
</xsl:template>


</xsl:stylesheet>
