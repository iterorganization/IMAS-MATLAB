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
<xsl:include href="put_single.xsl"/>
<xsl:include href="implementations.xsl"/>

<!--================================================-->
<!--         Template for the whole document        -->
<!--================================================-->

<xsl:template match = "/IDSs">
 <xsl:result-document href="src/ids/ids_put.c" standalone="yes" method="text">
/** \addtogroup interface MEX-interface
 *  @{
 */

/**
   \file ids_put.c
   write IDS in MATLAB External Interfaces
   
   This is a MEX file for MATLAB.

   Usage:
   \code{.m}
   ids_put(idx, IDSpath[, occ], ids)
   \endcode

   MATLAB help:
   \include matlab/ids_put.m
 */

/** @}*/

#include "ids_put.h"
#include "imas_mex_utils.h"

/**
   Entry point to C/C++ MEX function built with C Matrix API
 */
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  /* Check for three or four input arguments   */
  if(nrhs != 4 &amp;&amp; nrhs != 3) {
    mexErrMsgIdAndTxt("IMAS:ids_put:nargin",
                      "Three or four inputs required.");
  }

  /* make sure idx is scalar */
  if( !mxIsNumeric(prhs[0]) ||
      !mxIsScalar(prhs[0]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_put:notScalar",
                        "Input idx must be a scalar.");
  }
  /* Get the value of idx */
  int idx = (int) mxGetScalar(prhs[0]);
  if (params.verbosity >= 4)
  mexPrintf("The input idx is:  %d\n", idx);

  /* make sure IDSpath is a string */
  if( !mxIsChar(prhs[1]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_put:notChar",
                        "Input IDSpath must be a string.");
  }
  /* Get the value of IDSpath */
  char *IDSpath = mxArrayToString(prhs[1]);
  if (params.verbosity >= 4)
  mexPrintf("The input IDSpath is:  %s\n", IDSpath);

  if(nrhs == 4) {
  int occ;
  size_t pathlen;
  /* make sure occ is scalar */
  if( !mxIsNumeric(prhs[2]) ||
      !mxIsScalar(prhs[2]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_put:notScalar",
                        "Input occurence must be a scalar.");
  }
  /* Get the value of occ */
  occ = (int) mxGetScalar(prhs[2]);
  if (params.verbosity >= 4)
  mexPrintf("The input occurence is:  %d\n", occ);
  if (occ &gt; 0) {
  pathlen = strlen(IDSpath);
  IDSpath = mxRealloc(IDSpath, (pathlen+5)*sizeof(char));
  snprintf(&amp;IDSpath[pathlen], 5, "/%d", occ);
  }
  }

  /* make sure ids is scalar struct */
  if( !mxIsStruct(prhs[nrhs-1]) ||
      !mxIsScalar(prhs[nrhs-1]) ) {
      mexErrMsgIdAndTxt("IMAS:ids_put:notScalar",
                        "Input ids must be a scalar structure.");
  }
  /* Get the value of ids */
  if (params.verbosity >= 4)
  mexPrintf("The input ids is:  %s\n", "SKIPPED");

  /* Check for no output argument */
  if(nlhs > 0) {
    mexErrMsgIdAndTxt("IMAS:ids_put:nargout",
                      "No output required.");
  }
  
  /* Extract IDS name */
  char* IDSpathcopy = strdup(IDSpath);
  char* name = strtok(IDSpathcopy, "/");

  /* Declare Function Pointer */
  al_status_t(*ids_put)(int, char*, const mxArray*) = NULL;
  /* Assign pointer based on IDS name */
  <xsl:apply-templates select = "IDS" mode="SWITCH">
    <xsl:with-param name="function_name">ids_put</xsl:with-param>
  </xsl:apply-templates>
  /* Error if there was no match */
  mexErrMsgIdAndTxt("IMAS:ids_put:unknown_ids",
           "Unknown IDS name: %s", name);

  /* free now as name uses the same memory */
  free(IDSpathcopy);

  /* Clean-up previous errors */
  resetErrMsgIdAndTxt();
  /* Call function */
  al_status_t err = ids_put(idx, IDSpath, prhs[nrhs-1]);
  if (err.code &lt; 0) 
  my_mexErrMsgIdAndTxt(err, "IMAS:ids_put:");
  return;

}
 </xsl:result-document>
 <xsl:result-document href="src/ids/ids_put.h" standalone="yes" method="text">
  #include "mex.h"
    #include "imas_mex_utils.h"
  <xsl:apply-templates select = "IDS" mode="LIST">
    <xsl:with-param name="prefix" select="'al_status_t ids_put_'"/>
    <xsl:with-param name="suffix" select="'(int expIdx, char* idsFullName, const mxArray* ids);'"/>
  </xsl:apply-templates>
 </xsl:result-document>
  <xsl:result-document href="src/ids/put_ids.c" standalone="yes" method="text">
    #include "imas_mex_utils.h"
    #ifndef _WIN32
    #include "ids_validate.h"
    #endif
    <xsl:for-each select="IDS">
    <xsl:variable name="ids_type" select="@type"/>
    al_status_t ids_delete_<xsl:value-of select="@name"/>(int expIdx, char* idsFullName);
    <xsl:apply-templates select="." mode="METHOD_PUT_H"/>

    al_status_t ids_put_<xsl:value-of select="@name"/>(int expIdx, char* idsFullName, const mxArray* ids)
    {
      <xsl:call-template name="put_implementation"/>
    }

    <xsl:apply-templates select=".//field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_PUT_H"/>

    <xsl:apply-templates select=". | .//field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_PUT">
     <xsl:with-param name="ids_type"><xsl:value-of select="$ids_type"/></xsl:with-param>
    </xsl:apply-templates>
    </xsl:for-each>
  </xsl:result-document>
</xsl:template>

<xsl:template match="IDS | field[@data_type='struct_array' or @data_type='structure']" mode="METHOD_PUT_H">
al_status_t put_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(int ctx, int homogeneousTime, const char* idsFullName);</xsl:template>

<xsl:template match="IDS | field[@data_type='struct_array' or @data_type='structure']" mode="METHOD_PUT">
<xsl:param name="ids_type"/>
al_status_t put_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(int ctx, int homogeneousTime, const char* idsFullName)
    {
    struct imas_mex_actionInfo action;
    struct imas_mex_fieldInfo field;
    const mxArray* data=NULL;
    al_status_t status = {0,""};
    al_status_t status_end;
    int aosArraySize = -1;
    int hliAosArraySize;
    int aosCtx = -1;
    int isEmpty;

    action.context = ctx;
    
    field.fieldPath = malloc(IMAS_PATH_MAX_LENGTH);
    field.timebasePath = malloc(IMAS_PATH_MAX_LENGTH);
        
    <xsl:apply-templates select="field" mode="PUT_SINGLE">
      <xsl:with-param name="dynamic_only" select="'no'"/>
      <xsl:with-param name="ids_type"><xsl:value-of select="$ids_type"/></xsl:with-param>
    </xsl:apply-templates>
    
    free(field.fieldPath);
    free(field.timebasePath);

    return status;
    }
</xsl:template>

</xsl:stylesheet>
