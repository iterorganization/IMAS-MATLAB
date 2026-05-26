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


<!--================================================-->
<!--         Template for the whole document        -->
<!--================================================-->

<xsl:template name = "get_implementation">
   
    al_status_t status;
    al_status_t status_end;
    int getOpCtx = -1;
    char* dataDictionaryVersion = NULL;
	bool taggedDataDictionaryVersion = false;
    int homogeneousTime = IDS_TIME_MODE_UNKNOWN;
    
    /* Open separate context for reading DD version and homogeneous time (see IMAS-3077) */
    int getCtx = -1;
    status = al_begin_global_action(expIdx, idsFullName, "", READ_OP, &amp;getCtx);
	if (status.code >= 0) status = getDataDictionaryVersion(getCtx, &amp;dataDictionaryVersion, &amp;taggedDataDictionaryVersion);
    if (status.code >= 0) status = getHomogeneousTimeCtx(getCtx, &amp;homogeneousTime);
    if (getCtx > 0) {
    status_end = al_end_action(getCtx);
    if (status.code >= 0) status = status_end; /* Result of al_end_action is only relevant if there was no error before */
    }
    
    if (status.code >= 0) status = init_dataTree_read();
    
    /* Open get context */
    if (status.code >= 0) status = al_begin_global_action(expIdx, idsFullName, "", READ_OP, &amp;getOpCtx);
    if (status.code >= 0) status = al_bind_readback_plugins(getOpCtx); //binding readback plugins just before the get() operation
	if (status.code >= 0) status = get_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(getOpCtx, homogeneousTime, dataDictionaryVersion, taggedDataDictionaryVersion);
    if (getOpCtx > 0) {
    if (status.code >= 0) status = al_unbind_readback_plugins(getOpCtx); //unbinding readback plugins just after the get() operation
    status_end = al_end_action(getOpCtx);
    if (status.code >= 0) status = status_end; /* Result of al_end_action is only relevant if there was no error before */
    }
    
    if (status.code >= 0) status = get_data_from_dataTree(NULL, ids);
    /* Error handling */
    if (status.code &lt; 0) {
    addIdsPathInfoToErrMsg("\n ... in IDS <xsl:value-of select="@name"/>",1);
    }
    if (dataDictionaryVersion != NULL) free(dataDictionaryVersion);

    return status;
    
</xsl:template>


<xsl:template name = "get_sample_implementation">
   
    al_status_t status;
    al_status_t status_end;
    int getOpCtx = -1;
    char* dataDictionaryVersion = NULL;
	  bool taggedDataDictionaryVersion = false;
    int homogeneousTime = IDS_TIME_MODE_UNKNOWN;


    if (tmax &lt; tmin) {
    status.code = -1;
    strcpy(status.message, "GET_SAMPLE: error, tmax should be greater or equals to tmin");
    return status;
  }

  if ((interpmode != 0) &amp;&amp; (csize == 0)) {
    status.code = -1;
    strcpy(status.message, "GET_SAMPLE: error, interpolation mode should be 0 with no resampling (dtime size == 0)");
    return status;
  }

  if ((interpmode == 0) &amp;&amp; (csize &gt;= 1)) {
    status.code = -1;
    strcpy(status.message, "GET_SAMPLE: error, interpolation mode should be specified (non zero) with resampling (dtime size &gt;= 1)");
    return status;
  }
    
    /* Open separate context for reading DD version and homogeneous time (see IMAS-3077) */
    int getCtx = -1;
    status = al_begin_global_action(expIdx, idsFullName, "", READ_OP, &amp;getCtx);
	  if (status.code >= 0) status = getDataDictionaryVersion(getCtx, &amp;dataDictionaryVersion, &amp;taggedDataDictionaryVersion);
    if (status.code >= 0) status = getHomogeneousTimeCtx(getCtx, &amp;homogeneousTime);
    if (getCtx > 0) {
    status_end = al_end_action(getCtx);
    if (status.code >= 0) status = status_end; /* Result of al_end_action is only relevant if there was no error before */
    }

    if(homogeneousTime &lt; 0) {
      strcpy(status.message, "GET_SAMPLE: error reading homogeneous time for <xsl:value-of select="@name"/>");
      status.code = -1;
      return status;
    }

    if (status.code >= 0) status = init_dataTree_read();
    
    /* Open get context */
   if (status.code >= 0) status = al_begin_timerange_action(expIdx, idsFullName, READ_OP, tmin, tmax, dtime, &amp;csize, interpmode, &amp;getOpCtx);

	  if(status.code &lt; 0) {
      strcpy(status.message, "GET_SAMPLE: error calling al_begin_timerange_action for <xsl:value-of select="@name"/> IDS.");
      status.code = -1;
      return status;
    }
    if (status.code >= 0) status = al_bind_readback_plugins(getOpCtx); //binding readback plugins just before the get() operation
	  if (status.code >= 0) status = get_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(getOpCtx, homogeneousTime, dataDictionaryVersion, taggedDataDictionaryVersion);
    if (getOpCtx > 0) {
    if (status.code >= 0) status = al_unbind_readback_plugins(getOpCtx); //unbinding readback plugins just after the get() operation
    status_end = al_end_action(getOpCtx);
    if (status.code >= 0) status = status_end; /* Result of al_end_action is only relevant if there was no error before */
    }
    
    if (status.code >= 0) status = get_data_from_dataTree(NULL, ids);
    /* Error handling */
    if (status.code &lt; 0) {
    addIdsPathInfoToErrMsg("\n ... in IDS <xsl:value-of select="@name"/>",1);
    }
    if (dataDictionaryVersion != NULL) free(dataDictionaryVersion);

    return status;
    
</xsl:template>

<xsl:template name = "get_slice_implementation">
    al_status_t status;
      al_status_t status_end;
      int getSliceOpCtx = -1;
      char* dataDictionaryVersion = NULL;
    bool taggedDataDictionaryVersion = false;
      int homogeneousTime = IDS_TIME_MODE_UNKNOWN;

      /* Open separate context for reading DD version and homogeneous time (see IMAS-3077) */
      int getCtx = -1;
    status = al_begin_global_action(expIdx, idsFullName, "", READ_OP, &amp;getCtx);
    if (status.code >= 0) status = getDataDictionaryVersion(getCtx, &amp;dataDictionaryVersion, &amp;taggedDataDictionaryVersion);
      if (status.code >= 0) status = getHomogeneousTimeCtx(getCtx, &amp;homogeneousTime);
      if (getCtx > 0) {
      status_end = al_end_action(getCtx);
      if (status.code >= 0) status = status_end; /* Result of al_end_action is only relevant if there was no error before */
      }
      
      if (status.code >= 0) status = init_dataTree_read();
      
      /* Open getSlice context */
      if (status.code >= 0) status = al_begin_slice_action(expIdx, idsFullName, READ_OP, inTime, interpolMode, &amp;getSliceOpCtx);
      if (status.code >= 0) status = al_bind_readback_plugins(getSliceOpCtx); //binding readback plugins just before calling the get_slice() operation
    if (status.code >= 0) status = get_slice_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(getSliceOpCtx, homogeneousTime, dataDictionaryVersion, taggedDataDictionaryVersion);
      if (getSliceOpCtx > 0) {
      if (status.code >= 0) status = al_unbind_readback_plugins(getSliceOpCtx); //unbinding readback plugins just after callig the get_slice() operation
      status_end = al_end_action(getSliceOpCtx);
      if (status.code >= 0) status = status_end; /* Result of al_end_action is only relevant if there was no error before */
      }

      if (status.code >= 0) status = get_data_from_dataTree(NULL, ids);
      /* Error handling */
      if (status.code &lt; 0) {
      addIdsPathInfoToErrMsg("\n ... in IDS <xsl:value-of select="@name"/>",1);
      }
      if (dataDictionaryVersion != NULL) free(dataDictionaryVersion);

      return status;
</xsl:template>

<xsl:template name = "put_implementation">
    int ifield;
    const mxArray* ptime=NULL;
    al_status_t status = {0,""};
    al_status_t status_end = {0,""};
    int putOpCtx = -1;
    int homogeneousTime = IDS_TIME_MODE_UNKNOWN;
    /* Validation check for input schema (not supported on Windows) */
#ifndef _WIN32
    al_validation_status_t status_val = {0,""};
    bool flag = is_validation_required();
    if(flag) {
	status_val = ids_validate_<xsl:value-of select="@name"/>(idsFullName,(mxArray *) ids);
    }
    status.code = status_val.code;
    strncpy(status.message, status_val.message, MAX_ERR_MSG_LEN-1);
    status.message[MAX_ERR_MSG_LEN-1]= '\0';
    if( status.code &lt; 0 ) {
	mexWarnMsgIdAndTxt("IMAS:ids_validate:invalid_ids", "IDS <xsl:value-of select="@name"/> is found to be invalid . PUT quits with no action.");
	return status;
    }
#endif
    status = init_dataTree_write((mxArray *) ids);
    /* TODO: move these checks to external function? */
    if (status.code >= 0) status = getHomogeneousTime(&amp;homogeneousTime);
    if (status.code &lt; 0) mexErrMsgIdAndTxt("IMAS:ids_put:invalid_homogeneous_time",
    "Unable to retrieve ids%%ids_properties%%homogeneous_time");
    if( homogeneousTime == IDS_TIME_MODE_UNKNOWN )
    {
    mexWarnMsgIdAndTxt("IMAS:ids_put:empty_ids", "IDS <xsl:value-of select="@name"/> is found to be EMPTY (homogeneous_time undefined). PUT quits with no action.");
    return status;
    }
    <xsl:choose>
      <xsl:when test="@type='dynamic' or not(@type)">
        /* Delete existing IDS if any */
        if (status.code >= 0) status = ids_delete_<xsl:value-of select="@name"/>(expIdx, idsFullName);
      </xsl:when>
       <xsl:when test="@type='constant'">
        else if ( homogeneousTime != IDS_TIME_MODE_INDEPENDENT ) {
           if (status.code >= 0) status = setHomogeneousTime(IDS_TIME_MODE_INDEPENDENT);
           mexPrintf("AL warning:ids_properties/homogeneous_time has been set to %d for the constant IDS %s, please check the program which has filled this IDS since this is the mandatory value for a constant IDS", IDS_TIME_MODE_INDEPENDENT, idsFullName);
        }
        int getCtx = -1;
        if (status.code >= 0) status = al_begin_global_action(expIdx, idsFullName, "", READ_OP, &amp;getCtx);
        if (status.code >= 0) status = getHomogeneousTimeCtx(getCtx, &amp;homogeneousTime);
        if (getCtx > 0) {
           status_end = al_end_action(getCtx);
           if (status.code >= 0) status = status_end; /* Result of al_end_action is only relevant if there was no error before */
        }
        if (status.code >= 0) {
          if (homogeneousTime != IDS_TIME_MODE_UNKNOWN)
             return status;
        }

       </xsl:when> 
    </xsl:choose>

    
    /* Open put context */
    if (status.code >= 0) status = al_begin_global_action(expIdx, idsFullName, "", WRITE_OP, &amp;putOpCtx);

    if (status.code >= 0) status = put_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(putOpCtx, homogeneousTime, idsFullName);
    if (putOpCtx > 0) {
    if (status.code >= 0)  status = al_write_plugins_metadata(putOpCtx); //writing plugins metadata just after calling the put() operation
    status_end = al_end_action(putOpCtx);
    if (status.code >= 0) status = status_end; /* Result of al_end_action is only relevant if there was no error before */
    }
    /* Error handling */
    if (status.code &lt; 0) {
    addIdsPathInfoToErrMsg("\n ... in IDS <xsl:value-of select="@name"/>",1);
    }

    return status;
</xsl:template>

<xsl:template name = "put_slice_implementation">
    int ifield;
      const mxArray* ptime=NULL;
      al_status_t status;
      al_status_t status_end;
      int putSliceOpCtx = -1;
      int homogeneousTime = IDS_TIME_MODE_UNKNOWN;
      int getOpCtx = -1;
      int homogeneousTimeStored = IDS_TIME_MODE_UNKNOWN;
      int sliceOp = 1;

      status = init_dataTree_write((mxArray *) ids);
      /* TODO: move these checks to external function? */
      if (status.code >= 0) status = getHomogeneousTime(&amp;homogeneousTime);
      if (status.code &lt; 0) mexErrMsgIdAndTxt("IMAS:ids_put:invalid_homogeneous_time",
      "Unable to retrieve ids%%ids_properties%%homogeneous_time");
      if( homogeneousTime == IDS_TIME_MODE_UNKNOWN )
      {
      mexWarnMsgIdAndTxt("IMAS:ids_put_slice:empty_ids", "IDS <xsl:value-of select="@name"/> is found to be EMPTY (homogeneous_time undefined). PUT_SLICE quits with no action.");
      return status;
      }
      else if( homogeneousTime == IDS_TIME_MODE_INDEPENDENT )
      {
      mexWarnMsgIdAndTxt("IMAS:ids_put_slice:empty_ids", "homogeneous_time=2 makes an IDS <xsl:value-of select="@name"/> with static/constant data only. No static data stored with put_slice operation.");
      return status;
      }
      /* Check stored homogeneousTime mode */
      /* Open read context */
      if (status.code >= 0) status = al_begin_global_action(expIdx, idsFullName, "", READ_OP, &amp;getOpCtx);
      if (status.code >= 0) status = getHomogeneousTimeCtx(getOpCtx, &amp;homogeneousTimeStored);
      if (status.code >= 0) {
        /* If no IDS previously stored */
        if (homogeneousTimeStored == IDS_TIME_MODE_UNKNOWN) {
          sliceOp = 0;
        }
        /* Otherwise check that the stored and new value match */
        else if (homogeneousTimeStored != homogeneousTime) { 
          snprintf(mex_errmsgtxt, MAXERRMSGTXTSIZE, "homogeneous_time mode from input IDS <xsl:value-of select="@name"/> (%d) differs from value already stored in database (%d)",homogeneousTime, homogeneousTimeStored);
          msglen = strnlen(mex_errmsgtxt, MAXERRMSGTXTSIZE-1);
          status.code = -5;
        }
      }
      if (getOpCtx > 0) {
        status_end = al_end_action(getOpCtx);
        if (status.code >= 0) status.code = status_end.code; /* Result of al_end_action is only relevant if there was no error before */
      }
      
      if (sliceOp) {
        /* Open putSlice context */
        if (status.code >= 0) status = al_begin_slice_action(expIdx, idsFullName, WRITE_OP, UNDEFINED_TIME, UNDEFINED_INTERP, &amp;putSliceOpCtx);
        
        if (status.code >= 0) status = put_slice_<xsl:value-of select="concat(@name,'_',generate-id(.))"/>(putSliceOpCtx, homogeneousTime, idsFullName);
        if (putSliceOpCtx > 0) {
          if (status.code >= 0)  status = al_write_plugins_metadata(putSliceOpCtx); //writing plugins metadata just after calling the put_slice() operation
          status_end = al_end_action(putSliceOpCtx);
          if (status.code >= 0) status = status_end; /* Result of al_end_action is only relevant if there was no error before */
        }
      } else {
        /* Call put method */
        if (status.code >= 0) {
          status = ids_put_<xsl:value-of select="@name"/>(expIdx, idsFullName, ids);
          /* Error handling
              Ensures the error is shown as originating in ids_put
                and avoids displaying twice the ids name */
          if (status.code &lt; 0) my_mexErrMsgIdAndTxt(status, "IMAS:ids_put:");
          return status;
        }
      }
      /* Error handling */
      if (status.code &lt; 0) {
      addIdsPathInfoToErrMsg("\n ... in IDS <xsl:value-of select="@name"/>",1);
      }

      return status;
</xsl:template>



</xsl:stylesheet>
