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

<xsl:template match="field[@data_type='struct_array']" mode="VALIDATE_CHILD_1D">
    <xsl:choose>
  <xsl:when test="not(contains(@coordinate1,' OR ')) and not(contains(@coordinate1, '1...'))">
   <xsl:if test="contains(@coordinate1,'/time')">
  // validation of <xsl:value-of select="@path"/>
  if (status.code &gt;= 0) {
        pfield = getFieldFromStruct("<xsl:value-of select="@name"/>", data);
    if (pfield != NULL &amp;&amp; !mxIsEmpty(pfield)) {
      if (status.code &gt;= 0) {
      alStatus = begin_dataTree_array_write("<xsl:value-of select="@name"/>", &amp;aosArraySize);
      status.code = alStatus.code; strncpy(status.message, alStatus.message, MAX_ERR_MSG_LEN);
     }
  if (aosArraySize != 0) {
  if (idsTimeMode == IDS_TIME_MODE_HOMOGENEOUS ) {
  if(aosArraySize != timeSize) {
        size_t needed = snprintf(NULL, 0,  "Element '<xsl:value-of select="@path"/>' has incorrect shape %s: its coordinate in dimension %d ('time') has size %d.", getShapeStr(pfield,<xsl:apply-templates select='.' mode="get-rank"/>), 1, timeSize);
        char  *buffer = malloc(needed+1);
        sprintf(buffer, "Element '<xsl:value-of select="@path"/>' has incorrect shape %s: its coordinate in dimension %d ('time') has size %d.", getShapeStr(pfield,<xsl:apply-templates select='.' mode="get-rank"/>), 1, timeSize);
        strncpy(status.message, buffer, needed);
        status.code = HLI_ERR;
        free(buffer);
      }
  }
  <xsl:variable name="coord" select="@coordinate1"/>
    <xsl:if test=".//field[@path_doc=$coord and (@data_type='flt_type' or @data_type='FLT_0D')]">
  if (idsTimeMode == IDS_TIME_MODE_HETEROGENEOUS ) {
      for (int itime = 0; itime&lt;aosArraySize;itime++) {
        const mxArray *elem = mxGetCell(pfield, itime); //get the cell of index (itime) 
        double scalar_time = EMPTY_DOUBLE;
        if (elem != NULL) {
        ifield = mxGetFieldNumber(elem, "time");
        const mxArray *pfieldelem = mxGetFieldByNumber(elem, (mwIndex) 0, ifield);
        if (pfieldelem != NULL &amp;&amp; status.code &gt;= 0) {
          if (mxIsNumeric(pfieldelem) || mxIsScalar(pfieldelem)) {
            if (mxIsDouble(pfieldelem)) {
              scalar_time = *(double *) mxGetData(pfieldelem);
            }
          }
        }
      }
      if (scalar_time == EMPTY_DOUBLE) { 
        size_t needed = snprintf(NULL, 0, "Time coordinate of '<xsl:value-of select="@name"/>' ('<xsl:value-of select="@name"/>(%d)/time') has empty values.", itime+1);
        char *buffer = malloc(needed + 1);
        sprintf(buffer, "Time coordinate of '<xsl:value-of select="@name"/>' ('<xsl:value-of select="@name"/>(%d)/time') has empty values.", itime+1);
        strncpy(status.message, buffer, needed);
        status.code = HLI_ERR;
        free(buffer);
      }
      }
    }
  </xsl:if>
  if (status.code &gt;= 0) {
      alStatus = end_dataTree_array_action();
      status.code = alStatus.code; strncpy(status.message, alStatus.message, MAX_ERR_MSG_LEN);
     }
  }
  }
  }
  </xsl:if>
  <xsl:if test="not(contains(@coordinate1,'/time'))">
  if (status.code &gt;= 0) {
        pfield = getFieldFromStruct("<xsl:value-of select="@name"/>", data);
    if (pfield != NULL &amp;&amp; !mxIsEmpty(pfield)) {
  if (status.code &gt;= 0) {
      alStatus = begin_dataTree_array_write("<xsl:value-of select="@name"/>", &amp;aosArraySize);
      status.code = alStatus.code; strncpy(status.message, alStatus.message, MAX_ERR_MSG_LEN);
     }
  const mxArray *pfieldcoord = getFieldFromStruct("<xsl:value-of select="@coordinate1"/>", data);
  mwSize coordSize = getDimSize(pfieldcoord, 1, 1);
  if (status.code &gt;= 0 &amp;&amp; !(coordSize &gt; 0)) {
    coordSize = 0;
    }
  if (aosArraySize != coordSize) {
    size_t needed = snprintf(NULL, 0,  "Element '<xsl:value-of select="@path"/>' has incorrect shape %s: its coordinate in dimension %d ('<xsl:value-of select="@coordinate1"/>') has size %d.", getShapeStr(pfield,<xsl:apply-templates select='.' mode="get-rank"/>), 1, coordSize);
    char  *buffer = malloc(needed+1);
    sprintf(buffer, "Element '<xsl:value-of select="@path"/>' has incorrect shape %s: its coordinate in dimension %d ('<xsl:value-of select="@coordinate1"/>') has size %d.", getShapeStr(pfield,<xsl:apply-templates select='.' mode="get-rank"/>), 1, coordSize);
    strncpy(status.message, buffer, needed);
    status.code = HLI_ERR;
    free(buffer);
  }
  if (status.code &gt;= 0) {
      alStatus = end_dataTree_array_action();
      status.code = alStatus.code; strncpy(status.message, alStatus.message, MAX_ERR_MSG_LEN);
     }
  }
  }
  </xsl:if>
  </xsl:when>
  <xsl:otherwise>
    // warning <xsl:value-of select="@path_doc"/> coordinates consistency not verified (<xsl:value-of select="@coordinate1"/>)
  </xsl:otherwise>
    </xsl:choose>
    </xsl:template>

    <xsl:template match="field" mode="VALIDATE_CHILD_FIXED_SIZE">
        <xsl:choose>
          <xsl:when test="@data_type='struct_array' or @data_type='flt_1d_type' or @data_type='FLT_1D'
              or @data_type='int_1d_type' or @data_type='INT_1D'
              or @data_type='cpx_1d_type' or @data_type='CPX_1D'">

              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate1"/>
                <xsl:with-param name="dimension" select="'0'"/>
              </xsl:apply-templates>
          </xsl:when>
          <xsl:when test="@data_type='FLT_2D' or @data_type='INT_2D' or @data_type='CPX_2D'">

              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate1"/>
                <xsl:with-param name="dimension" select="'0'"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate2"/>
                <xsl:with-param name="dimension" select="'1'"/>
              </xsl:apply-templates>
          </xsl:when>
          <xsl:when test="@data_type='FLT_3D' or @data_type='INT_3D' or @data_type='CPX_3D'">

              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate1"/>
                <xsl:with-param name="dimension" select="'0'"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate2"/>
                <xsl:with-param name="dimension" select="'1'"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate3"/>
                <xsl:with-param name="dimension" select="'2'"/>
              </xsl:apply-templates>
          </xsl:when>
          <xsl:when test="@data_type='FLT_4D' or @data_type='INT_4D' or @data_type='CPX_4D'">

              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate1"/>
                <xsl:with-param name="dimension" select="'0'"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate2"/>
                <xsl:with-param name="dimension" select="'1'"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate3"/>
                <xsl:with-param name="dimension" select="'2'"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate4"/>
                <xsl:with-param name="dimension" select="'3'"/>
              </xsl:apply-templates>
          </xsl:when>
          <xsl:when test="@data_type='FLT_5D' or @data_type='INT_5D' or @data_type='CPX_5D'">

              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate1"/>
                <xsl:with-param name="dimension" select="'0'"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate2"/>
                <xsl:with-param name="dimension" select="'1'"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate3"/>
                <xsl:with-param name="dimension" select="'2'"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate4"/>
                <xsl:with-param name="dimension" select="'3'"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate5"/>
                <xsl:with-param name="dimension" select="'4'"/>
              </xsl:apply-templates>
          </xsl:when>
          <xsl:when test="@data_type='FLT_6D' or @data_type='INT_6D' or @data_type='CPX_6D'">

              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate1"/>
                <xsl:with-param name="dimension" select="'0'"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate2"/>
                <xsl:with-param name="dimension" select="'1'"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate3"/>
                <xsl:with-param name="dimension" select="'2'"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate4"/>
                <xsl:with-param name="dimension" select="'3'"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate5"/>
                <xsl:with-param name="dimension" select="'4'"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="." mode="VALIDATE_FIXED_SIZE_COORDINATES">
                <xsl:with-param name="coord" select="@coordinate6"/>
                <xsl:with-param name="dimension" select="'5'"/>
              </xsl:apply-templates>
          </xsl:when>
        </xsl:choose>
        </xsl:template>

      <xsl:template match="field" mode="VALIDATE_FIXED_SIZE_COORDINATES">
      <xsl:param name="coord"/>
      <xsl:param name="dimension"/>
        <xsl:if test="not(contains($coord,' OR ')) and contains($coord, '1...') and not(contains($coord, '1...N')) and not(string(number(substring-after($coord,'1...')))='NaN')">
        // validation of <xsl:value-of select="@path"/> dimension <xsl:value-of select="number($dimension)"/>
        ifield = mxGetFieldNumber(data, "<xsl:value-of select="@name"/>");
        pfield = mxGetFieldByNumber(data, (mwIndex) 0, ifield);
        aosArraySize = getDimSize(pfield,<xsl:apply-templates select='.' mode="get-rank"/>,<xsl:value-of select="number($dimension)+1"/>);
        if (pfield != NULL) {
          if (aosArraySize != 0) {
            if (aosArraySize != <xsl:value-of select = "substring-after($coord,'1...')"/>) {
	            size_t needed = snprintf(NULL, 0, "Element '<xsl:value-of select="@path"/>' has incorrect shape %s: dimension <xsl:value-of select="number($dimension)+1"/> must have size <xsl:value-of select = "substring-after($coord,'1...')"/>.",getShapeStr(pfield,<xsl:apply-templates select='.' mode="get-rank"/>));
              char  *buffer = malloc(needed+1);
              sprintf(buffer, "Element '<xsl:value-of select="@path"/>' has incorrect shape %s: dimension <xsl:value-of select="number($dimension)+1"/> must have size <xsl:value-of select = "substring-after($coord,'1...')"/>.",getShapeStr(pfield,<xsl:apply-templates select='.' mode="get-rank"/>));
              strncpy(status.message, buffer, needed);
              status.code = HLI_ERR;
              free(buffer);
            }
          }
        }
        </xsl:if>
      </xsl:template>

    <xsl:template match="IDS" mode="VALIDATE_DESCENDANT_1D">
    <xsl:apply-templates select=".//field[@data_type='struct_array' or  @data_type='flt_1d_type' or @data_type='FLT_1D'
    or @data_type='int_1d_type' or @data_type='INT_1D'
    or @data_type='cpx_1d_type' or @data_type='CPX_1D']" mode="VALIDATE_DESCENDANT_SINGLE">
    <xsl:with-param name="currpath" select="''"/>
    <xsl:with-param name="dimension" select="'0'"/>
    </xsl:apply-templates>
    </xsl:template> 

    <xsl:template match="field" mode="VALIDATE_DESCENDANT_1D">
    <xsl:apply-templates select="descendant-or-self::field[@data_type='struct_array' or  @data_type='flt_1d_type' or @data_type='FLT_1D'
    or @data_type='int_1d_type' or @data_type='INT_1D'
    or @data_type='cpx_1d_type' or @data_type='CPX_1D']" mode="VALIDATE_DESCENDANT_SINGLE">
    <xsl:with-param name="currpath" select="@path_doc"/>
    <xsl:with-param name="dimension" select="'0'"/>
    </xsl:apply-templates>
    </xsl:template> 

    <xsl:template match="IDS" mode="VALIDATE_DESCENDANT_2D">
    <xsl:apply-templates select=".//field[@data_type='FLT_2D' or @data_type='INT_2D' or @data_type='CPX_2D']" mode="VALIDATE_DESCENDANT_SINGLE">
    <xsl:with-param name="currpath" select="''"/>
    <xsl:with-param name="dimension" select="'0'"/>
    </xsl:apply-templates>
    <xsl:apply-templates select=".//field[@data_type='FLT_2D' or @data_type='INT_2D' or @data_type='CPX_2D']" mode="VALIDATE_DESCENDANT_SINGLE">
    <xsl:with-param name="currpath" select="''"/>
    <xsl:with-param name="dimension" select="'1'"/>
    </xsl:apply-templates>
    </xsl:template> 

    <xsl:template match="field" mode="VALIDATE_DESCENDANT_2D">
    <xsl:apply-templates select="descendant-or-self::field[@data_type='FLT_2D' or @data_type='INT_2D' or @data_type='CPX_2D']" mode="VALIDATE_DESCENDANT_SINGLE_2D">
    <xsl:with-param name="currpath" select="@path_doc"/>
    </xsl:apply-templates>
    </xsl:template> 

    <xsl:template match="IDS" mode="VALIDATE_DESCENDANT_3D">
    <xsl:apply-templates select=".//field[@data_type='FLT_3D' or @data_type='INT_3D' or @data_type='CPX_3D']" mode="VALIDATE_DESCENDANT_SINGLE">
    <xsl:with-param name="currpath" select="''"/>
    <xsl:with-param name="dimension" select="'0'"/>
    </xsl:apply-templates>
    <xsl:apply-templates select=".//field[@data_type='FLT_3D' or @data_type='INT_3D' or @data_type='CPX_3D']" mode="VALIDATE_DESCENDANT_SINGLE">
    <xsl:with-param name="currpath" select="''"/>
    <xsl:with-param name="dimension" select="'1'"/>
    </xsl:apply-templates>
    <xsl:apply-templates select=".//field[@data_type='FLT_3D' or @data_type='INT_3D' or @data_type='CPX_3D']" mode="VALIDATE_DESCENDANT_SINGLE">
    <xsl:with-param name="currpath" select="''"/>
    <xsl:with-param name="dimension" select="'2'"/>
    </xsl:apply-templates>
    </xsl:template> 

    <xsl:template match="field" mode="VALIDATE_DESCENDANT_3D">
    <xsl:apply-templates select="descendant-or-self::field[@data_type='FLT_3D' or @data_type='INT_3D' or @data_type='CPX_3D']" mode="VALIDATE_DESCENDANT_SINGLE_3D">
    <xsl:with-param name="currpath" select="@path_doc"/>
    </xsl:apply-templates>
    </xsl:template>  

    <xsl:template match="IDS" mode="VALIDATE_DESCENDANT_4D">
    <xsl:apply-templates select=".//field[@data_type='FLT_4D' or @data_type='INT_4D' or @data_type='CPX_4D']" mode="VALIDATE_DESCENDANT_SINGLE">
    <xsl:with-param name="currpath" select="''"/>
    <xsl:with-param name="dimension" select="'0'"/>
    </xsl:apply-templates>
    <xsl:apply-templates select=".//field[@data_type='FLT_4D' or @data_type='INT_4D' or @data_type='CPX_4D']" mode="VALIDATE_DESCENDANT_SINGLE">
    <xsl:with-param name="currpath" select="''"/>
    <xsl:with-param name="dimension" select="'1'"/>
    </xsl:apply-templates>
    <xsl:apply-templates select=".//field[@data_type='FLT_4D' or @data_type='INT_4D' or @data_type='CPX_4D']" mode="VALIDATE_DESCENDANT_SINGLE">
    <xsl:with-param name="currpath" select="''"/>
    <xsl:with-param name="dimension" select="'2'"/>
    </xsl:apply-templates>
    <xsl:apply-templates select=".//field[@data_type='FLT_4D' or @data_type='INT_4D' or @data_type='CPX_4D']" mode="VALIDATE_DESCENDANT_SINGLE">
    <xsl:with-param name="currpath" select="''"/>
    <xsl:with-param name="dimension" select="'3'"/>
    </xsl:apply-templates>
    </xsl:template> 

    <xsl:template match="field" mode="VALIDATE_DESCENDANT_4D">
    <xsl:apply-templates select="descendant-or-self::field[@data_type='FLT_4D' or @data_type='INT_4D' or @data_type='CPX_4D']" mode="VALIDATE_DESCENDANT_SINGLE_4D">
    <xsl:with-param name="currpath" select="@path_doc"/>
    </xsl:apply-templates>
    </xsl:template> 

    <xsl:template match="IDS" mode="VALIDATE_DESCENDANT_5D">
    <xsl:apply-templates select=".//field[@data_type='FLT_5D' or @data_type='INT_5D' or @data_type='CPX_5D']" mode="VALIDATE_DESCENDANT_SINGLE">
    <xsl:with-param name="currpath" select="''"/>
    <xsl:with-param name="dimension" select="'0'"/>
    </xsl:apply-templates>
    <xsl:apply-templates select=".//field[@data_type='FLT_5D' or @data_type='INT_5D' or @data_type='CPX_5D']" mode="VALIDATE_DESCENDANT_SINGLE">
    <xsl:with-param name="currpath" select="''"/>
    <xsl:with-param name="dimension" select="'1'"/>
    </xsl:apply-templates>
    <xsl:apply-templates select=".//field[@data_type='FLT_5D' or @data_type='INT_5D' or @data_type='CPX_5D']" mode="VALIDATE_DESCENDANT_SINGLE">
    <xsl:with-param name="currpath" select="''"/>
    <xsl:with-param name="dimension" select="'2'"/>
    </xsl:apply-templates>
    <xsl:apply-templates select=".//field[@data_type='FLT_5D' or @data_type='INT_5D' or @data_type='CPX_5D']" mode="VALIDATE_DESCENDANT_SINGLE">
    <xsl:with-param name="currpath" select="''"/>
    <xsl:with-param name="dimension" select="'3'"/>
    </xsl:apply-templates>
    <xsl:apply-templates select=".//field[@data_type='FLT_5D' or @data_type='INT_5D' or @data_type='CPX_5D']" mode="VALIDATE_DESCENDANT_SINGLE">
    <xsl:with-param name="currpath" select="''"/>
    <xsl:with-param name="dimension" select="'4'"/>
    </xsl:apply-templates>
    </xsl:template> 

    <xsl:template match="field" mode="VALIDATE_DESCENDANT_5D">
    <xsl:apply-templates select="descendant-or-self::field[@data_type='FLT_5D' or @data_type='INT_5D' or @data_type='CPX_5D']" mode="VALIDATE_DESCENDANT_SINGLE_5D">
    <xsl:with-param name="currpath" select="@path_doc"/>
    </xsl:apply-templates>
    </xsl:template> 

    <xsl:template match="IDS" mode="VALIDATE_DESCENDANT_6D">
    <xsl:apply-templates select=".//field[@data_type='FLT_6D' or @data_type='INT_6D' or @data_type='CPX_6D']" mode="VALIDATE_DESCENDANT_SINGLE">
    <xsl:with-param name="currpath" select="''"/>
    <xsl:with-param name="dimension" select="'0'"/>
    </xsl:apply-templates>
    <xsl:apply-templates select=".//field[@data_type='FLT_6D' or @data_type='INT_6D' or @data_type='CPX_6D']" mode="VALIDATE_DESCENDANT_SINGLE">
    <xsl:with-param name="currpath" select="''"/>
    <xsl:with-param name="dimension" select="'1'"/>
    </xsl:apply-templates>
    <xsl:apply-templates select=".//field[@data_type='FLT_6D' or @data_type='INT_6D' or @data_type='CPX_6D']" mode="VALIDATE_DESCENDANT_SINGLE">
    <xsl:with-param name="currpath" select="''"/>
    <xsl:with-param name="dimension" select="'2'"/>
    </xsl:apply-templates>
    <xsl:apply-templates select=".//field[@data_type='FLT_6D' or @data_type='INT_6D' or @data_type='CPX_6D']" mode="VALIDATE_DESCENDANT_SINGLE">
    <xsl:with-param name="currpath" select="''"/>
    <xsl:with-param name="dimension" select="'3'"/>
    </xsl:apply-templates>
    <xsl:apply-templates select=".//field[@data_type='FLT_6D' or @data_type='INT_6D' or @data_type='CPX_6D']" mode="VALIDATE_DESCENDANT_SINGLE">
    <xsl:with-param name="currpath" select="''"/>
    <xsl:with-param name="dimension" select="'4'"/>
    </xsl:apply-templates>
    <xsl:apply-templates select=".//field[@data_type='FLT_6D' or @data_type='INT_6D' or @data_type='CPX_6D']" mode="VALIDATE_DESCENDANT_SINGLE">
    <xsl:with-param name="currpath" select="''"/>
    <xsl:with-param name="dimension" select="'5'"/>
    </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="field" mode="VALIDATE_DESCENDANT_6D">
    <xsl:apply-templates select="descendant-or-self::field[@data_type='FLT_6D' or @data_type='INT_6D' or @data_type='CPX_6D']" mode="VALIDATE_DESCENDANT_SINGLE_6D">
    <xsl:with-param name="currpath" select="@path_doc"/>
    </xsl:apply-templates>
    </xsl:template> 

    <xsl:template match="field" mode="VALIDATE_DESCENDANT_SINGLE_2D">
      <xsl:param name="currpath"/>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'0'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'1'"/>
      </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="field" mode="VALIDATE_DESCENDANT_SINGLE_3D">
      <xsl:param name="currpath"/>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'0'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'1'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'2'"/>
      </xsl:apply-templates>
    </xsl:template> 

    <xsl:template match="field" mode="VALIDATE_DESCENDANT_SINGLE_4D">
      <xsl:param name="currpath"/>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'0'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'1'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'2'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'3'"/>
      </xsl:apply-templates>
    </xsl:template> 

    <xsl:template match="field" mode="VALIDATE_DESCENDANT_SINGLE_5D">
      <xsl:param name="currpath"/>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'0'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'1'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'2'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'3'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'4'"/>
      </xsl:apply-templates>
    </xsl:template> 

    <xsl:template match="field" mode="VALIDATE_DESCENDANT_SINGLE_6D">
      <xsl:param name="currpath"/>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'0'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'1'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'2'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'3'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'4'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="VALIDATE_DESCENDANT_SINGLE">
        <xsl:with-param name="currpath" select="$currpath"/>
        <xsl:with-param name="dimension" select="'5'"/>
      </xsl:apply-templates>
    </xsl:template> 

    <!-- write the check statements to check the <dimension> of the current field -->
    <!-- <currpath> is the deeper comon ancestor of the reference coordinate and the current field -->
    <xsl:template match="field" mode="VALIDATE_DESCENDANT_SINGLE">
      <xsl:param name="currpath"/>
      <xsl:param name="dimension"/>
      <!-- target field coordinate we want to check (specific and relative coordinate) -->
      <xsl:variable name="coord">
      <xsl:apply-templates select="." mode="get_coordinate">
        <xsl:with-param name="dimension" select="$dimension"/>
      </xsl:apply-templates>
      </xsl:variable >
      <!-- target field dimension we want to check -->
      <xsl:variable name="targetdim">
      <xsl:apply-templates select="." mode="get_targetdim">
        <xsl:with-param name="dimension" select="$dimension"/>
      </xsl:apply-templates>
      </xsl:variable >
      <!-- variable to check if the specified coordinate is present or not. 
      this variable is a safeguard that prevents wrong code generation-->
      <xsl:variable name="ispresent">
        <xsl:choose>
        <xsl:when test="$currpath='' and not($coord='') and not(contains($coord, '1...'))">
            <xsl:value-of select="'yes'"/>
        </xsl:when>
        <xsl:when test="contains($coord,'OR')">
        <xsl:apply-templates select="ancestor::field[@path_doc = $currpath]" mode="ISPRESENT_PATH_DOC">
          <xsl:with-param name="path_doc_to_check" select="substring-before($coord,' OR')"/>
        </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="ancestor::field[@path_doc = $currpath]" mode="ISPRESENT_PATH_DOC">
          <xsl:with-param name="path_doc_to_check" select="$coord"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
      </xsl:variable >
      <xsl:variable name="prefix" select="substring-before(@path_doc,concat('/',@name))"/>
      <!-- find the relative coordinate from the current field path and the target field path -->
      <xsl:variable name="relativecoord">
      <xsl:if test="not($currpath='')">
      <xsl:choose>
        <xsl:when test="contains($coord,'OR')">
          <xsl:value-of select="substring-after(substring-before($coord,'OR'),concat($currpath,'/'))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="substring-after($coord,concat($currpath,'/'))"/>
        </xsl:otherwise>
      </xsl:choose>
      </xsl:if>
      <xsl:if test="$currpath=''">
      <xsl:choose>
        <xsl:when test="contains($coord,'OR')">
          <xsl:value-of select="substring-before($coord,'OR')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$coord"/>
        </xsl:otherwise>
      </xsl:choose>
      </xsl:if>
      </xsl:variable >
        <!-- find the relative coordinate from the current field path and the checked field -->
      <!-- <xsl:variable name="relativepath" select="substring-after(concat($prefix,'/',@name),concat($currpath,'/'))"/> -->
      <xsl:variable name="relativepath">
      <xsl:if test="not($currpath='')">
          <xsl:value-of select="substring-after(concat($prefix,'/',@name),concat($currpath,'/'))"/>
      </xsl:if>
      <xsl:if test="$currpath=''">
          <xsl:value-of select="$prefix"/>
      </xsl:if>
      </xsl:variable >
      <xsl:variable name="child">
        <xsl:choose>
            <xsl:when test="contains($relativepath,'/')">
            <xsl:value-of select="substring-before($relativepath,'/')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$relativepath"/>
          </xsl:otherwise>
      </xsl:choose>
      </xsl:variable>
      <!-- verify if the current field is the deeper common ancestor of the target coordinate field and the checked field -->
      <xsl:variable name="test">
        <xsl:choose>
          <!-- validation logic: the time coordinate are passed by argument of each validation routines so no need to check if at level of IDS -->
          <xsl:when test="(contains(@name,'/time') or contains($coord,'/time') or $coord='time' or contains($coord,'IDS:')) and $currpath=''">
            <xsl:value-of select="''"/>
          </xsl:when>
          <xsl:when test="contains($relativecoord,'/')">
            <xsl:value-of select="$child=substring-before($relativecoord,'/')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$child=$relativecoord"/>
          </xsl:otherwise>
      </xsl:choose>
      </xsl:variable> 
      <!-- missing IDS coordinate exception--> 
      <xsl:if test="(starts-with($coord,$currpath) and contains($ispresent,'yes')) or ($coord='time')">
        <xsl:if test="$test='false'">
          <xsl:variable name="newpath">
            <xsl:if test="not($currpath='')">
              <xsl:value-of select="substring-before(@path_doc,concat(ancestor::field[@path_doc = $currpath]/@name,'/'))"/>
            </xsl:if>
            <xsl:if test="$currpath=''">
              <xsl:value-of select="@path_doc"/>
            </xsl:if>
          </xsl:variable>
          <xsl:variable name="root">
            <xsl:if test="not($currpath='')">
              <xsl:value-of select="concat($currpath,'/')"/>
            </xsl:if>
            <xsl:if test="$currpath=''">
              <xsl:value-of select="concat($currpath,'/')"/>
            </xsl:if>
          </xsl:variable>
          if (status.code &gt;= 0) {
          <xsl:apply-templates select="." mode="VALIDATE_PATH_SINGLE">
          <xsl:with-param name="newpath" select="$newpath"/>
          <xsl:with-param name="root" select="$root"/>
          <xsl:with-param name="string" select="''"/>
          <xsl:with-param name="dimension" select="$dimension"/>
          <xsl:with-param name="coord" select="$coord"/>
          <xsl:with-param name="targetdim" select="$targetdim"/>
          <xsl:with-param name="indexlist" select="''"/>
          </xsl:apply-templates>
        }
        </xsl:if>
      </xsl:if>
      </xsl:template>

      <!-- return yes if some field exist like @path_doc equals to the parameter path_doc_to_check -->
    <xsl:template match="field" mode="ISPRESENT_PATH_DOC">
      <xsl:param name="path_doc_to_check"/>
        <xsl:if test="descendant-or-self::field[contains(@path_doc,$path_doc_to_check)]">
          <xsl:value-of select="'yes'"/>
        </xsl:if >
      </xsl:template> 
      <!-- get the target coordinate (if 'as_parent' or not) -->
      <xsl:template match="field" mode="get_coordinate">
      <xsl:param name="dimension"/>
      <xsl:variable name="string_coord">
      <xsl:apply-templates select="." mode="get_coordinate_string">
      <xsl:with-param name="dimension" select="$dimension"/>
      </xsl:apply-templates>
      </xsl:variable>
        <xsl:choose>
          <xsl:when test="not($string_coord='1...N')">
            <xsl:value-of select="$string_coord"/>
          </xsl:when>
        </xsl:choose>
      </xsl:template>
  
  
      <xsl:template match="field" mode="get_coordinate_string">
      <xsl:param name="dimension"/>
        <xsl:choose>
          <xsl:when test="$dimension='0'">
            <xsl:if test="@coordinate1='1...N' and @coordinate1_same_as">
            <xsl:value-of select="@coordinate1_same_as"/>
            </xsl:if>
            <xsl:if test="not(@coordinate1_same_as)">
            <xsl:value-of select="@coordinate1"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="$dimension='1'">
            <xsl:if test="@coordinate2='1...N' and @coordinate2_same_as">
            <xsl:value-of select="@coordinate2_same_as"/>
            </xsl:if>
            <xsl:if test="not(@coordinate2_same_as)">
            <xsl:value-of select="@coordinate2"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="$dimension='2'">
            <xsl:if test="@coordinate3='1...N' and @coordinate3_same_as">
            <xsl:value-of select="@coordinate3_same_as"/>
            </xsl:if>
            <xsl:if test="not(@coordinate3_same_as)">
            <xsl:value-of select="@coordinate3"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="$dimension='3'">
            <xsl:if test="@coordinate4='1...N' and @coordinate4_same_as">
            <xsl:value-of select="@coordinate4_same_as"/>
            </xsl:if>
            <xsl:if test="not(@coordinate4_same_as)">
            <xsl:value-of select="@coordinate4"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="$dimension='4'">
            <xsl:if test="@coordinate5='1...N' and @coordinate5_same_as">
            <xsl:value-of select="@coordinate5_same_as"/>
            </xsl:if>
            <xsl:if test="not(@coordinate5_same_as)">
            <xsl:value-of select="@coordinate5"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="$dimension='5'">
            <xsl:if test="@coordinate6='1...N' and @coordinate6_same_as">
            <xsl:value-of select="@coordinate6_same_as"/>
            </xsl:if>
            <xsl:if test="not(@coordinate6_same_as)">
            <xsl:value-of select="@coordinate6"/>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:template>
  
      <!-- get the target coordinate dimension-->
      <xsl:template match="field" mode="get_targetdim">
      <xsl:param name="dimension"/>
        <xsl:choose>
          <xsl:when test="$dimension='0'">
            <xsl:if test="@coordinate1='1...N' and @coordinate1_same_as">
            <xsl:value-of select="'0'"/>
            </xsl:if>
            <xsl:if test="not(@coordinate1='1...N') and not(@coordinate1_same_as)">
            <xsl:value-of select="'0'"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="$dimension='1'">
            <xsl:if test="@coordinate2='1...N' and @coordinate2_same_as">
            <xsl:value-of select="'1'"/>
            </xsl:if>
            <xsl:if test="not(@coordinate2='1...N') and not(@coordinate2_same_as)">
            <xsl:value-of select="'0'"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="$dimension='2'">
            <xsl:if test="@coordinate3='1...N' and @coordinate3_same_as">
            <xsl:value-of select="'2'"/>
            </xsl:if>
            <xsl:if test="not(@coordinate3='1...N') and not(@coordinate3_same_as)">
            <xsl:value-of select="'0'"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="$dimension='3'">
            <xsl:if test="@coordinate4='1...N' and @coordinate4_same_as">
            <xsl:value-of select="'3'"/>
            </xsl:if>
            <xsl:if test="not(@coordinate4='1...N') and not(@coordinate4_same_as)">
            <xsl:value-of select="'0'"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="$dimension='4'">
            <xsl:if test="@coordinate5='1...N' and @coordinate5_same_as">
            <xsl:value-of select="'4'"/>
            </xsl:if>
            <xsl:if test="not(@coordinate5='1...N') and not(@coordinate5_same_as)">
            <xsl:value-of select="'0'"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="$dimension='5'">
            <xsl:if test="@coordinate6='1...N' and @coordinate6_same_as">
            <xsl:value-of select="'5'"/>
            </xsl:if>
            <xsl:if test="not(@coordinate6='1...N') and not(@coordinate6_same_as)">
            <xsl:value-of select="'0'"/>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:template>
  
      <xsl:template match="field" mode="VALIDATE_PATH_SINGLE">
        <xsl:param name="newpath"/>
        <xsl:param name="root"/>
        <xsl:param name="string"/>
        <xsl:param name="dimension"/>
        <xsl:param name="coord"/>
        <xsl:param name="targetdim"/>
        <xsl:param name="indexlist"/>
  
        <xsl:variable name="istimeslice">
        <xsl:if test="contains($coord,' OR')">
        <xsl:if test="not($root='/')">
          <xsl:if test="contains(substring-before(substring-after($coord,$root),' OR'),'(itime)')">
            <xsl:if test="not(contains(concat($string,@name),'(itime)'))">
              <xsl:value-of select="'yes'"/>
            </xsl:if>
          </xsl:if>
        </xsl:if>
        <xsl:if test="$root='/'">
          <xsl:if test="contains(substring-before($coord,' OR'),'(itime)')">
            <xsl:if test="not(contains(concat($string,@name),'(itime)'))">
              <xsl:value-of select="'yes'"/>
            </xsl:if>
          </xsl:if>
        </xsl:if>
        </xsl:if>
        <xsl:if test="not($root='/')">
        <xsl:if test="not(contains($coord,' OR'))">
          <xsl:if test="contains(substring-after($coord,$root),'(itime)')">
            <xsl:if test="not(contains(concat($string,@name),'(itime)'))">
              <xsl:value-of select="'yes'"/>
            </xsl:if>
          </xsl:if>
        </xsl:if>
        </xsl:if>
        <xsl:if test="$root='/'">
        <xsl:if test="not(contains($coord,' OR'))">
          <xsl:if test="contains($coord,'(itime)')">
            <xsl:if test="not(contains(concat($string,@name),'(itime)'))">
              <xsl:value-of select="'yes'"/>
            </xsl:if>
          </xsl:if>
        </xsl:if>
        </xsl:if>
        </xsl:variable>
        <xsl:if test="not($istimeslice='yes')"> 
        <xsl:variable name="relativepath_doc">
          <xsl:choose>
          <xsl:when test="$root='/'">
          <xsl:value-of select="concat(substring-before(@path_doc,concat(@name,'(:')),@name)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat(substring-before(substring-after(@path_doc,$root),concat(@name,'(:')),@name)"/>
          </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="numbtargets">
        <xsl:apply-templates select="." mode="count-field-coordinates">
              <xsl:with-param name="coord" select="$coord"/>
              <xsl:with-param name="relativepathdoc" select="$root"/> 
              <xsl:with-param name="record" select="'0'"/>
        </xsl:apply-templates>
        </xsl:variable>
        <xsl:if test="not($coord='time') or ($coord='time' and .//field[@path_doc=$coord])"> 
        status = validateCoordinateFromPath(data, idsTimeMode, timeSize,<xsl:if test="$coord='time' or contains($coord,'/time')">true</xsl:if> <xsl:if test="not($coord='time') and not(contains($coord,'/time'))">false</xsl:if>,
                                            "<xsl:value-of select="$root"/>",
                                            "<xsl:value-of select="$relativepath_doc"/>",
                                            <xsl:apply-templates select='.' mode="get-rank"/>,
                                             <xsl:value-of select="number($dimension)+1"/>,
                                             (const char*[]) {<xsl:apply-templates select="." mode="possible-coordinates"><xsl:with-param name="coord" select="$coord"/><xsl:with-param name="relativepathdoc" select="$root"/> </xsl:apply-templates>},
                                             <xsl:value-of select="$numbtargets"/>,
                                            (int[<xsl:value-of select="$numbtargets"/>]){<xsl:apply-templates select="." mode="get-rank-coordinates">
                                            <xsl:with-param name="coord" select="$coord"/>
                                            <xsl:with-param name="numbtargets" select="$numbtargets"/>
                                            </xsl:apply-templates>},
                                             <xsl:value-of select="number($targetdim)+1"/>,
                                            <xsl:apply-templates select="." mode="check-specific-coordinates">
                                              <xsl:with-param name="coord" select="$coord"/>
                                              <xsl:with-param name="relativepathdoc" select="$root"/>
                                              <xsl:with-param name="dimension" select="$dimension"/>
                                              <xsl:with-param name="self" select="concat($string,@name)"/>
                                            </xsl:apply-templates>);
        </xsl:if> 
        <xsl:if test="$coord='time' and not(.//field[@path_doc=$coord])"> 
          pfield = getFieldFromStruct("<xsl:value-of select="@name"/>", data);
          <xsl:if test="$enable-logging = 'yes'">
          printf("<xsl:value-of select="@name"/>: %d %d\n\r",pfield==NULL, (pfield==NULL) ? 0 : mxGetNumberOfElements(pfield));
          </xsl:if> 
          if (pfield != NULL &amp;&amp; !mxIsEmpty(pfield)) {
         mwSize aosArraySize = getDimSize(pfield, <xsl:apply-templates select='.' mode="get-rank"/>, <xsl:value-of select="number($dimension)+1"/>);
          if (aosArraySize != 0) {
          if (idsTimeMode == IDS_TIME_MODE_HOMOGENEOUS ) {
            if(aosArraySize != timeSize) {
              size_t needed = snprintf(NULL, 0,  "Element '<xsl:value-of select="@path"/>' has incorrect shape %s: its coordinate in dimension %d ('time') has size %d.", getShapeStr(pfield,<xsl:apply-templates select='.' mode="get-rank"/>), 1, timeSize);
              char  *buffer = malloc(needed+1);
              sprintf(buffer, "Element '<xsl:value-of select="@path"/>' has incorrect shape %s: its coordinate in dimension %d ('time') has size %d.", getShapeStr(pfield,<xsl:apply-templates select='.' mode="get-rank"/>), 1, timeSize);
              strncpy(status.message, buffer, needed);
              status.code = HLI_ERR;
              free(buffer);
            }
          }
          }
        }
        </xsl:if> 
        </xsl:if> 
        <xsl:if test="$istimeslice='yes' and substring-after($coord,'(itime)/')='time'"> 
          pfield = getFieldFromStruct("<xsl:value-of select="@name"/>", data);
          <xsl:if test="$enable-logging = 'yes'">
          printf("<xsl:value-of select="@name"/>: %d %d\n\r",pfield==NULL, (pfield==NULL) ? 0 : mxGetNumberOfElements(pfield));
          </xsl:if> 
          if (pfield != NULL &amp;&amp; !mxIsEmpty(pfield)) {
            if (status.code &gt;= 0) {
              alStatus = begin_dataTree_array_write("<xsl:value-of select="@name"/>", &amp;aosArraySize);
              status.code = alStatus.code; strncpy(status.message, alStatus.message, MAX_ERR_MSG_LEN);
            }
          if (aosArraySize != 0) {
          if (idsTimeMode == IDS_TIME_MODE_HOMOGENEOUS ) {
            if(aosArraySize != timeSize) {
              size_t needed = snprintf(NULL, 0,  "Element '<xsl:value-of select="@path"/>' has incorrect shape %s: its coordinate in dimension %d ('time') has size %d.", getShapeStr(pfield,<xsl:apply-templates select='.' mode="get-rank"/>), 1, timeSize);
              char  *buffer = malloc(needed+1);
              sprintf(buffer, "Element '<xsl:value-of select="@path"/>' has incorrect shape %s: its coordinate in dimension %d ('time') has size %d.", getShapeStr(pfield,<xsl:apply-templates select='.' mode="get-rank"/>), 1, timeSize);
              strncpy(status.message, buffer, needed);
              status.code = HLI_ERR;
              free(buffer);
            }
          }
          <xsl:if test=".//field[@path_doc=$coord and (@data_type='flt_type' or @data_type='FLT_0D')]">
          if (idsTimeMode == IDS_TIME_MODE_HETEROGENEOUS ) {        
            for (int itime = 0; itime&lt;aosArraySize;itime++) {
              if (status.code &gt;= 0) {
              const mxArray *elem = mxGetCell(pfield, itime); //get the cell of index (itime) 
              <xsl:if test="$enable-logging = 'yes'">
              printf("<xsl:value-of select="@name"/>(%d): %d\n\r",itime,elem==NULL);
              </xsl:if> 
              double scalar_time = EMPTY_DOUBLE;
              if (elem != NULL) {
              ifield = mxGetFieldNumber(elem, "time");
              const mxArray *pfieldelem = mxGetFieldByNumber(elem, (mwIndex) 0, ifield);
              <xsl:if test="$enable-logging = 'yes'">
                printf("<xsl:value-of select="@name"/>(%d)/time: %d\n\r",itime,pfieldelem==NULL);
              </xsl:if> 
              if (pfieldelem != NULL &amp;&amp; status.code &gt;= 0) {
                if (mxIsNumeric(pfieldelem) || mxIsScalar(pfieldelem)) {
                  if (mxIsDouble(pfieldelem)) {
                    scalar_time = *(double *) mxGetData(pfieldelem);
                  }
                }
              }
              }
              if (scalar_time == EMPTY_DOUBLE) { 
                size_t needed = snprintf(NULL, 0, "Time coordinate of '<xsl:value-of select="@name"/>' ('<xsl:value-of select="@name"/>(%d)/time') has empty values.", itime+1);
                char *buffer = malloc(needed + 1);
                sprintf(buffer, "Time coordinate of '<xsl:value-of select="@name"/>' ('<xsl:value-of select="@name"/>(%d)/time') has empty values.", itime+1);
                strncpy(status.message, buffer, needed);
                status.code = HLI_ERR;
                free(buffer);
              }
            }
            }
          }
        </xsl:if>
          }
          if (status.code &gt;= 0) {
              alStatus = end_dataTree_array_action();
              status.code = alStatus.code; strncpy(status.message, alStatus.message, MAX_ERR_MSG_LEN);
            }
        }
        </xsl:if> 


        </xsl:template>


        <xsl:template match='field' mode="possible-coordinates">
        <xsl:param name="coord"/>
        <xsl:param name="relativepathdoc"/>
        <xsl:if test="contains($coord,' OR')">
        <xsl:variable name="target">
            <xsl:if test="not($relativepathdoc='/')">
              <xsl:value-of select="substring-before(substring-after($coord,$relativepathdoc),' OR')"/>
            </xsl:if>
            <xsl:if test="$relativepathdoc='/'">
              <xsl:value-of select="substring-before($coord,' OR')"/>
            </xsl:if>
        </xsl:variable>
        <xsl:if test="not(contains(substring-before($coord,' OR'),'1...'))">
                                            "<xsl:value-of select="$target"/>",
        </xsl:if>
        <xsl:apply-templates select="." mode="possible-coordinates">
          <xsl:with-param name="coord" select="substring-after($coord,' OR')"/>
          <xsl:with-param name="relativepathdoc" select="$relativepathdoc"/>
        </xsl:apply-templates>
        </xsl:if>
        <xsl:if test="not(contains($coord,' OR'))">
        <xsl:variable name="target">
            <xsl:if test="not($relativepathdoc='/')">
              <xsl:value-of select="substring-after($coord,$relativepathdoc)"/>
            </xsl:if>
            <xsl:if test="$relativepathdoc='/'">
              <xsl:value-of select="$coord"/>
            </xsl:if>
        </xsl:variable>
        <xsl:if test="not(contains($coord,'1...'))">
                                            "<xsl:value-of select="$target"/>"
        </xsl:if>
        </xsl:if>
        </xsl:template>


        <xsl:template match='field' mode="get-rank-coordinates">
        <xsl:param name="coord"/>
        <xsl:param name="numbtargets"/>
        <xsl:if test="contains($coord,' OR')">
        <xsl:if test="not(contains(substring-before($coord,' OR'),'1...'))">
                                            <xsl:apply-templates select="." mode="get-rank-from-pathdoc">
                                              <xsl:with-param name="coord" select="substring-before($coord,' OR')"/>
                                            </xsl:apply-templates>
                                            <xsl:if test="not(numbtargets='1')">,</xsl:if>
        </xsl:if>
        <xsl:apply-templates select="." mode="get-rank-coordinates">
          <xsl:with-param name="coord" select="substring-after($coord,' OR ')"/>
          <xsl:with-param name="numbtargets" select="$numbtargets"/>
        </xsl:apply-templates>
        </xsl:if>
        <xsl:if test="not(contains($coord,' OR'))">
        <xsl:if test="not(contains($coord,'1...'))">
                                            <xsl:apply-templates select="." mode="get-rank-from-pathdoc">
                                              <xsl:with-param name="coord" select="$coord"/>
                                            </xsl:apply-templates>
        </xsl:if>
        </xsl:if>
        </xsl:template>


        <xsl:template match='field' mode="get-rank-from-pathdoc">
        <xsl:param name="coord"/>
        <xsl:variable name="targetname">
            <xsl:if test="contains($coord,'/')">
              <xsl:value-of select="tokenize($coord,'/')[last()]"/>
            </xsl:if>
            <xsl:if test="not(contains($coord,'/'))">
              <xsl:value-of select="$coord"/>
            </xsl:if>
        </xsl:variable>
        <!-- <xsl:value-of select="$coord"/>
        <xsl:value-of select="ancestor::IDS//field[starts-with(@path_doc,concat($coord,'('))]/@path_doc"/> -->
        <xsl:if test="ancestor::IDS//field[starts-with(@path_doc,concat($coord,'(')) and (@name = $targetname)]">
        <xsl:apply-templates select="ancestor::IDS//field[starts-with(@path_doc,concat($coord,'(')) and (@name = $targetname)]" mode="get-rank"/>
        </xsl:if>
        <xsl:if test="not(ancestor::IDS//field[starts-with(@path_doc,concat($coord,'(')) and (@name = $targetname)])">
        <xsl:apply-templates select="ancestor::IDS//field[(@name = $targetname)]" mode="get-rank"/>
        </xsl:if>
        </xsl:template> 

        <xsl:template match='field' mode="get-rank">
        <xsl:if test="@data_type='struct_array' or @data_type='flt_1d_type' or @data_type='FLT_1D'
              or @data_type='int_1d_type' or @data_type='INT_1D'
              or @data_type='cpx_1d_type' or @data_type='CPX_1D' or @data_type='STR_1D'">1</xsl:if>
        <xsl:if test="@data_type='FLT_2D' or @data_type='INT_2D' or @data_type='CPX_2D'">2</xsl:if>
        <xsl:if test="@data_type='FLT_3D' or @data_type='INT_3D' or @data_type='CPX_3D'">3</xsl:if>
        <xsl:if test="@data_type='FLT_4D' or @data_type='INT_4D' or @data_type='CPX_4D'">4</xsl:if>
        <xsl:if test="@data_type='FLT_5D' or @data_type='INT_5D' or @data_type='CPX_5D'">5</xsl:if>
        <xsl:if test="@data_type='FLT_6D' or @data_type='INT_6D' or @data_type='CPX_6D'">6</xsl:if>
        </xsl:template>

        <xsl:template match='field' mode="count-field-coordinates">
        <xsl:param name="coord"/>
        <xsl:param name="relativepathdoc"/>
        <xsl:param name="record"/>
        <xsl:if test="contains($coord,' OR')">
        <xsl:variable name="target">
            <xsl:if test="not($relativepathdoc='/')">
              <xsl:value-of select="substring-before(substring-after($coord,$relativepathdoc),' OR')"/>
            </xsl:if>
            <xsl:if test="$relativepathdoc='/'">
              <xsl:value-of select="substring-before($coord,' OR')"/>
            </xsl:if>
        </xsl:variable>
        <xsl:if test="not(contains(substring-before($coord,' OR'),'1...'))">
        <xsl:apply-templates select="." mode="count-field-coordinates">
          <xsl:with-param name="coord" select="substring-after($coord,' OR')"/>
          <xsl:with-param name="relativepathdoc" select="$relativepathdoc"/>
          <xsl:with-param name="record" select="number($record)+1"/>
        </xsl:apply-templates>
         </xsl:if>
        </xsl:if>
        <xsl:if test="not(contains($coord,' OR'))">
        <xsl:variable name="target">
            <xsl:if test="not($relativepathdoc='/')">
              <xsl:value-of select="substring-after($coord,$relativepathdoc)"/>
            </xsl:if>
            <xsl:if test="$relativepathdoc='/'">
              <xsl:value-of select="$coord"/>
            </xsl:if>
        </xsl:variable>
        <xsl:if test="not(contains($coord,'1...'))">
          <xsl:value-of select="number($record)+1"/>
        </xsl:if>
        <xsl:if test="contains($coord,'1...')">
          <xsl:value-of select="number($record)"/>
        </xsl:if>
        </xsl:if>
        </xsl:template>


        <xsl:template match='field' mode="check-specific-coordinates">
      <xsl:param name="coord"/>
      <xsl:param name="relativepathdoc"/>
      <xsl:param name="dimension"/>
      <xsl:param name="self"/>
      <xsl:if test="contains($coord,'1...')">
      <xsl:if test="contains($coord,' OR')">
            <xsl:variable name="target" select="replace(substring-before(substring-after($coord,$relativepathdoc),' OR'),'/','.')"/>
            <xsl:if test="contains(substring-before($coord,' OR'),'1...')">
              <xsl:value-of select="substring-after($coord,'1...')"/>
            </xsl:if>
      <xsl:apply-templates select="." mode="check-specific-coordinates">
        <xsl:with-param name="coord" select="substring-after($coord,' OR')"/>
        <xsl:with-param name="relativepathdoc" select="$relativepathdoc"/>
        <xsl:with-param  name="dimension" select="$dimension"/>
        <xsl:with-param  name="self" select="$self"/>
      </xsl:apply-templates>
      </xsl:if>
      <xsl:if test="not(contains($coord,' OR'))">
            <xsl:variable name="target" select="replace(substring-after($coord,$relativepathdoc),'/','.')"/>
            <xsl:if test="contains($coord,'1...')">
              <xsl:value-of select="substring-after($coord,'1...')"/>
            </xsl:if>
      </xsl:if>
      </xsl:if>
      <xsl:if test="not(contains($coord,'1...'))">
        0
      </xsl:if>
      </xsl:template>

</xsl:stylesheet>
