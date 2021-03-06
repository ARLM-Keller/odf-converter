<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  xmlns:v="urn:schemas-microsoft-com:vml"
  xmlns:o="urn:schemas-microsoft-com:office:office"
  xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
  xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
  xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"
  xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
  xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
  xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
  xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
  xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
  xmlns:w10="urn:schemas-microsoft-com:office:word"
  xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0"
  xmlns:ooc="urn:odf-converter"
  exclude-result-prefixes="xlink draw svg fo office style text manifest ooc">

  <xsl:key name="automatic-styles" match="office:automatic-styles/style:style" use="@style:name"/>

  <!-- 
  *************************************************************************
  MATCHING TEMPLATES
  *************************************************************************
  -->

  <!--
  Summary: converts internal and external OLE objects
  Author: makz (DIaLOGIKa)
  Date: 7.11.2007
  -->
  <xsl:template match="draw:frame[./draw:object-ole] | draw:frame[./draw:object]" mode="paragraph">
    <!-- insert link to TOC field when required (user indexes) -->
    <xsl:call-template name="InsertTCField"/>

    <xsl:variable name="shapeId" select="@draw:name"/>
    <!-- NOTE: remove any leading './' from the image path -->
    <xsl:variable name="olePicture" select="ooc:RegexReplace(draw:image/@xlink:href, '(^\./)?(.*)', '$2', true())" />
    <xsl:variable name="olePictureType">
      <xsl:call-template name="GetOLEPictureType">
        <xsl:with-param name="olePicture" select="$olePicture" />
      </xsl:call-template>
    </xsl:variable>

    <w:r>
      <w:object w:dxaOrig="{ooc:TwipsFromMeasuredUnit(@svg:width)}" 
                w:dyaOrig="{ooc:TwipsFromMeasuredUnit(@svg:height)}">
        
        <xsl:call-template name="InsertObjectShape">
          <xsl:with-param name="shapeId" select="$shapeId" />
          <xsl:with-param name="olePictureType" select="$olePictureType" />
        </xsl:call-template>

        <xsl:choose>
          <!-- 
          Insert linked object but not embedded ODF object.
          (embedded ODF objects are also draw:object elements)
          -->
          <xsl:when test="draw:object and (contains(draw:object/@xlink:href, ':') or starts-with(draw:object/@xlink:href, '/') or starts-with(draw:object/@xlink:href, '..'))">
            <xsl:call-template name="InsertExternalObject">
              <xsl:with-param name="shapeId" select="$shapeId" />
              <xsl:with-param name="object" select="draw:object" />
              <xsl:with-param name="olePictureType" select="$olePictureType" />
            </xsl:call-template>
          </xsl:when>
          <!-- 
          Insert embedded binary objects 
          -->
          <xsl:when test="draw:object-ole">
            <xsl:call-template name="InsertInternalObject">
              <xsl:with-param name="shapeId" select="$shapeId" />
              <xsl:with-param name="object" select="draw:object-ole" />
              <xsl:with-param name="olePictureType" select="$olePictureType" />
            </xsl:call-template>
          </xsl:when>

        </xsl:choose>

      </w:object>
    </w:r>
  </xsl:template>

  <!-- 
  *************************************************************************
  CALLED TEMPLATES
  *************************************************************************
  -->

  <!--
  Summary: Inserts the shape which contains the preview of the object
  Author: makz (DIaLOGIKa)
  Date: 7.11.2007
  -->
  <xsl:template name="InsertObjectShape">
    <!-- current context is draw:frame -->
    <xsl:param name="shapeId" />
    <xsl:param name="olePictureType" />

    <!-- insert the shape of the OLE object -->
    <v:shapetype id="_x0000_t75" coordsize="21600,21600" o:spt="109" path="m,l,21600r21600,l21600,xe">
      <v:stroke joinstyle="miter"/>
      <v:path gradientshapeok="t" o:connecttype="rect"/>
    </v:shapetype>
    <v:shape o:ole="" type="#_x0000_t75">

      <xsl:variable name="styleName" select="@draw:style-name"/>
      <xsl:variable name="automaticStyle" select="key('automatic-styles', $styleName)"/>
      <xsl:variable name="officeStyle" select="document('styles.xml')/office:document-styles/office:styles/style:style[@style:name = $styleName]"/>
      <xsl:variable name="frameStyle" select="$automaticStyle | $officeStyle"/>

      <xsl:call-template name="FrameToShapeProperties">
        <xsl:with-param name="frameStyle" select="$frameStyle"/>
        <xsl:with-param name="frame" select="."/>
      </xsl:call-template>

      <xsl:call-template name="FrameToShapeWrap">
        <xsl:with-param name="frameStyle" select="$frameStyle"/>
      </xsl:call-template>

      <xsl:if test="draw:image">
        <v:imagedata o:title="" r:id="{generate-id(draw:image)}" />
      </xsl:if>

    </v:shape>
  </xsl:template>


  <!--
  Summary: Inserts a external object (linked to file)
  Author: makz (DIaLOGIKa)
  Date: 9.11.2007
  -->
  <xsl:template name="InsertExternalObject">
    <xsl:param name="shapeId" />
    <xsl:param name="olePictureType" />

    <o:OLEObject Type="Link" ProgID="Package" UpdateMode="Always">

      <xsl:attribute name="ShapeID">
        <xsl:value-of select="$shapeId"/>
      </xsl:attribute>

      <xsl:attribute name="DrawAspect">
        <xsl:choose>
          <xsl:when test="$olePictureType=''">
            <xsl:text>Icon</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>Content</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>

      <xsl:attribute name="r:id">
        <xsl:value-of select="generate-id(draw:object)"/>
      </xsl:attribute>

      <o:LinkType>
        <xsl:text>EnhancedMetaFile</xsl:text>
      </o:LinkType>
      <o:LockedField>
        <xsl:text>false</xsl:text>
      </o:LockedField>
      <o:FieldCodes>
        <xsl:text>\f 0</xsl:text>
      </o:FieldCodes>
    </o:OLEObject>
  </xsl:template>

  <!--
  Summary: Inserts an internal object (embedded in the zip)
  Author: makz (DIaLOGIKa)
  Date: 7.11.2007
  -->
  <xsl:template name="InsertInternalObject">
    <xsl:param name="shapeId" />
    <xsl:param name="olePictureType" />

    <xsl:variable name="oleFile">
      <xsl:call-template name="substring-after-last">
        <xsl:with-param name="string" select="draw:object-ole/@xlink:href" />
        <xsl:with-param name="occurrence" select="'./'" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="oleType" select="document('META-INF/manifest.xml')/manifest:manifest/manifest:file-entry[@manifest:full-path=$oleFile]/@manifest:media-type" />
    <xsl:variable name="suffix" select="translate(substring-after($oleFile, '.'), 
                    'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')" />

    <!-- 
    don't insert internal ODF OLEs 
    internal ODF ole's have application type eg.
    application/vnd.oasis.opendocument.spreadsheet
    -->
    <xsl:choose>
      <xsl:when test="$oleType='application/vnd.sun.star.oleobject'">
        <o:OLEObject Type="Embed" ProgID="Package" ObjectID="_1256106730" >
          <!-- shape id -->
          <xsl:attribute name="ShapeID">
            <xsl:value-of select="$shapeId"/>
          </xsl:attribute>
          <!-- attribute type DrawAspect -->
          <xsl:attribute name="DrawAspect">
            <xsl:choose>
              <xsl:when test="$olePictureType=''">
                <xsl:text>Icon</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>Content</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <!-- r:id -->
          <xsl:attribute name="r:id">
            <xsl:value-of select="generate-id(draw:object-ole)"/>
          </xsl:attribute>
        </o:OLEObject>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="no">translation.odf2oox.oleOdfObject</xsl:message>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

</xsl:stylesheet>