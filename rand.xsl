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

<!--=================================================-->
<!--          Allocate an array of structure         -->
<!--=================================================-->

<xsl:template match="field" mode="RAND">

  <xsl:param name="unique_name"><xsl:if test="@data_type='struct_array'"><xsl:value-of select="concat(@name,'_',generate-id(.))"/></xsl:if></xsl:param>

  <xsl:param name="dynamic"><xsl:choose><xsl:when test="@type='dynamic' and not(ancestor::field[@data_type='struct_array' and @type='dynamic'])">1</xsl:when><xsl:otherwise>0</xsl:otherwise></xsl:choose></xsl:param>


<xsl:call-template name="COMMENT_FIELD"/>
<xsl:choose>
  <!--========== Array of structure ===========-->
    <xsl:when test = "@data_type = 'struct_array'">
      <xsl:choose>
	<xsl:when test="@maxoccur='unbounded' and @type='dynamic'">
	  n<xsl:value-of select="$unique_name"/> = ntime;
	</xsl:when>
	<xsl:when test="@maxoccur='unbounded'">
	  #ifdef _WIN32
	  n<xsl:value-of select="$unique_name"/> = 1+rand()%4;
	  #else
	  n<xsl:value-of select="$unique_name"/> = 1+random()%4;
	  #endif
	</xsl:when>
	<xsl:otherwise>
	  #ifdef _WIN32
	  n<xsl:value-of select="$unique_name"/> = 1+rand()%4;
	  #else
	  n<xsl:value-of select="$unique_name"/> = 1+random()%4;
	  #endif
	  n<xsl:value-of select="$unique_name"/> = n<xsl:value-of select="$unique_name"/> &lt; <xsl:value-of select="@maxoccur"/> ? n<xsl:value-of select="$unique_name"/> : <xsl:value-of select="@maxoccur"/>;
	</xsl:otherwise>
      </xsl:choose>
      if (status.code >= 0) status = begin_dataTree_array_read("<xsl:value-of select="@name"/>", n<xsl:value-of select="$unique_name"/>);
      for (i<xsl:value-of select="$unique_name"/> = 0; i<xsl:value-of select="$unique_name"/> &lt; n<xsl:value-of select="$unique_name"/>; i<xsl:value-of select="$unique_name"/>++) {
      if (status.code >= 0) status = iterate_dataTree_array(i<xsl:value-of select="$unique_name"/>);
      <xsl:apply-templates select = "field" mode = "RAND"/>
      }
      /* Finished processing array of structure <xsl:value-of select="@name"/> */
      if (status.code >= 0) status = end_dataTree_array_action();
      <xsl:if test="@maxoccur='unbounded' and @type='dynamic'">
	if (status.code >= 0 &amp;&amp; slice)
	status = slice_dataTree_array("<xsl:value-of select="@name"/>", slice-1);
      </xsl:if>
      /* Error handling */
      if (status.code &lt; 0) {
      addIdsPathInfoToErrMsg("\n ... in aos <xsl:value-of select="@path"/>",0);
      return status;
      }
    </xsl:when>

  <!--========== Regular structure ===========-->
    <xsl:when test="@data_type='structure'">
      if (status.code >= 0) status = begin_dataTree_read("<xsl:value-of select="@name"/>");
      <xsl:apply-templates select="field" mode="RAND"/>
      /* Finished processing structure <xsl:value-of select="@name"/> */
      if (status.code >= 0) status = end_dataTree_action();
      /* Error handling */
      if (status.code &lt; 0) {
      addIdsPathInfoToErrMsg("\n ... in structure <xsl:value-of select="@path"/>",0);
      return status;
      }
    </xsl:when>

  <!--========== Simple types ===========-->
  

    <xsl:when test="my:get_datatype(@data_type)='CHAR_DATA' or 
		    my:get_datatype(@data_type)='INTEGER_DATA' or 
		    my:get_datatype(@data_type)='DOUBLE_DATA' or 
		    my:get_datatype(@data_type)='COMPLEX_DATA'">
      <xsl:choose>
	<xsl:when test="@path='ids_properties/version_put/data_dictionary'">
	  data = mxCreateString("<xsl:value-of select="$DD_GIT_DESCRIBE"/>");
	</xsl:when>
	
	<xsl:when test="@path='ids_properties/version_put/access_layer'">
	  data = mxCreateString(getALVersion());
	</xsl:when>
	
	<xsl:when test="@path='ids_properties/version_put/access_layer_language'">
	  data = mxCreateString("<xsl:value-of select="concat('matlab (mex) - ', $AL_GIT_DESCRIBE)"/>");
	</xsl:when>

	<xsl:when test = "@name='homogeneous_time' and (@data_type='int_type' or @data_type='INT_0D')">
	  data = mxCreateNumericMatrix(1,1,mxINT32_CLASS,mxREAL);
	  *((int *) mxGetData(data)) = 1;
	</xsl:when>
	
	<xsl:when test = "@name='time' and (@data_type='flt_1d_type' or @data_type='FLT_1D')">
	  data = rand_time(ntime, slice);
	</xsl:when>
	
	<xsl:when test = "@name='time' and (@data_type='flt_type' or @data_type='FLT_0D')">
	  data = rand_time(ntime, 0);
	  *(mxGetPr(data)) = (mxGetPr(data))[i<xsl:value-of select="concat(ancestor::field[@data_type='struct_array' and @maxoccur='unbounded' and @type='dynamic'][1]/@name,'_',generate-id(ancestor::field[@data_type='struct_array' and @maxoccur='unbounded' and @type='dynamic'][1]))"/>];
	  mxSetPr(data,mxRealloc(mxGetPr(data),sizeof(double)));
	  mxSetM(data,1);
	</xsl:when>

	<xsl:otherwise>
	  data = rand_array(<xsl:value-of select="my:get_datatype(@data_type)"/>, <xsl:value-of select="my:get_dim(@data_type)"/>, <xsl:value-of select="$dynamic"/>, ntime, slice);
	  if (data == NULL) status.code = HLI_ERR;
	</xsl:otherwise>
      </xsl:choose>
      if (status.code >= 0) status = put_data_in_dataTree("<xsl:value-of select="@name"/>", data);
      /* Error handling */
      if (status.code &lt; 0) {
      addIdsPathInfoToErrMsg("\n ... in field <xsl:value-of select="@path"/>",0);
      return status;
      }
    </xsl:when>

  <!--========== Unknown type ===========-->
    <xsl:otherwise>
      <xsl:message terminate="yes">ERROR: Unidentified type: <xsl:value-of select="@data_type"/> !</xsl:message>
    </xsl:otherwise>
</xsl:choose>

</xsl:template>

</xsl:stylesheet>
