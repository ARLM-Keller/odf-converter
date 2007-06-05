<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<!--
Copyright (c) 2007, Sonata Software Limited
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of Sonata Software Limited nor the names of its contributors
*       may be used to endorse or promote products derived from this software
*       without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE REGENTS AND CONTRIBUTORS BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE
-->
<xsl:stylesheet version="1.0" 
  xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:odf="urn:odf"
  xmlns:pzip="urn:cleverage:xmlns:post-processings:zip"  
  xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" 
  xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
  xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0"
  xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
  xmlns:page="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
  exclude-result-prefixes="odf style text number draw page">

  <xsl:import href="docprops.xsl"/>
  <xsl:import href ="slides.xsl"/>
  <xsl:import href="presentation.xsl"/>
  <xsl:import href ="theme.xsl"/>
  <xsl:import href ="slideMasters.xsl"/>
  <xsl:import href="slideLayouts.xsl"/>

  <xsl:strip-space elements="*"/>
  <xsl:preserve-space elements="text:p text:span number:text"/>

  <xsl:param name="outputFile"/>
  <xsl:output method="xml" encoding="UTF-8"/>


  <xsl:variable name="app-version">1.00</xsl:variable>

  <!-- existence of docProps/custom.xml file -->
  <xsl:variable name="docprops-custom-file"
    select="count(document('meta.xml')/office:document-meta/office:meta/meta:user-defined)"
    xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
    xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"/>

  <xsl:template match="/odf:source">
    <xsl:processing-instruction name="mso-application">progid="ppt.Document</xsl:processing-instruction>

    <pzip:archive pzip:target="{$outputFile}">

      <!-- Document core properties -->
      <pzip:entry pzip:target="docProps/core.xml">
        <xsl:call-template name="docprops-core"/>
      </pzip:entry>
      <!--Document app properties-->
      <pzip:entry pzip:target="docProps/app.xml">
        <xsl:call-template name="docprops-app"/>
      </pzip:entry>
      <!--Document custom properties-->
      <!--<xsl:if test="$docprops-custom-file > 0">
				<pzip:entry pzip:target="docProps/custom.xml">
					<xsl:call-template name="docprops-custom"/>
				</pzip:entry>
			</xsl:if>-->
      <!--Main content-->

      <pzip:entry pzip:target="ppt/presProps.xml">
        <xsl:call-template name="presProps"/>
      </pzip:entry>

      <pzip:entry pzip:target="ppt/tableStyles.xml">
        <xsl:call-template name="tabStyles"/>
      </pzip:entry>
      <pzip:entry pzip:target="ppt/viewProps.xml">
        <xsl:call-template name="InsetViewPropsDotXML"/>
      </pzip:entry>
      <pzip:entry pzip:target="ppt/presentation.xml">
        <xsl:call-template name="presentation"/>
      </pzip:entry>
      <pzip:entry pzip:target="ppt/_rels/presentation.xml.rels">
        <xsl:call-template name="presentationRel"/>
      </pzip:entry>
      <pzip:entry pzip:target="ppt/slideLayouts/slideLayout1.xml">
        <xsl:call-template name="InsertSlideLayout1"/>
      </pzip:entry>
      <pzip:entry pzip:target="ppt/slideLayouts/slideLayout2.xml">
        <xsl:call-template name="InsertSlideLayout2"/>
      </pzip:entry>
      <pzip:entry pzip:target="ppt/slideLayouts/slideLayout3.xml">
        <xsl:call-template name="InsertSlideLayout3"/>
      </pzip:entry>
      <pzip:entry pzip:target="ppt/slideLayouts/slideLayout4.xml">
        <xsl:call-template name="InsertSlideLayout4"/>
      </pzip:entry>
      <pzip:entry pzip:target="ppt/slideLayouts/slideLayout5.xml">
        <xsl:call-template name="InsertSlideLayout5"/>
      </pzip:entry>
      <pzip:entry pzip:target="ppt/slideLayouts/slideLayout6.xml">
        <xsl:call-template name="InsertSlideLayout6"/>
      </pzip:entry>
      <pzip:entry pzip:target="ppt/slideLayouts/slideLayout7.xml">
        <xsl:call-template name="InsertSlideLayout7"/>
      </pzip:entry>
      <pzip:entry pzip:target="ppt/slideLayouts/slideLayout8.xml">
        <xsl:call-template name="InsertSlideLayout8"/>
      </pzip:entry>
      <pzip:entry pzip:target="ppt/slideLayouts/slideLayout9.xml">
        <xsl:call-template name="InsertSlideLayout9"/>
      </pzip:entry>
      <pzip:entry pzip:target="ppt/slideLayouts/slideLayout10.xml">
        <xsl:call-template name="InsertSlideLayout10"/>
      </pzip:entry>
      <pzip:entry pzip:target="ppt/slideLayouts/slideLayout11.xml">
        <xsl:call-template name="InsertSlideLayout11"/>
      </pzip:entry>
      <pzip:entry pzip:target="ppt/slideLayouts/_rels/slideLayout1.xml.rels">
        <xsl:call-template name="InsertSlideLayout1DotXmlRels"/>
      </pzip:entry>
      <pzip:entry pzip:target="ppt/slideLayouts/_rels/slideLayout2.xml.rels">
        <xsl:call-template name="InsertSlideLayout2DotXmlRels"/>
      </pzip:entry>
      <pzip:entry pzip:target="ppt/slideLayouts/_rels/slideLayout3.xml.rels">
        <xsl:call-template name="InsertSlideLayout3DotXmlRels"/>
      </pzip:entry>
      <pzip:entry pzip:target="ppt/slideLayouts/_rels/slideLayout4.xml.rels">
        <xsl:call-template name="InsertSlideLayout4DotXmlRels"/>
      </pzip:entry>
      <pzip:entry pzip:target="ppt/slideLayouts/_rels/slideLayout5.xml.rels">
        <xsl:call-template name="InsertSlideLayout5DotXmlRels"/>
      </pzip:entry>
      <pzip:entry pzip:target="ppt/slideLayouts/_rels/slideLayout6.xml.rels">
        <xsl:call-template name="InsertSlideLayout6DotXmlRels"/>
      </pzip:entry>
      <pzip:entry pzip:target="ppt/slideLayouts/_rels/slideLayout7.xml.rels">
        <xsl:call-template name="InsertSlideLayout7DotXmlRels"/>
      </pzip:entry>
      <pzip:entry pzip:target="ppt/slideLayouts/_rels/slideLayout8.xml.rels">
        <xsl:call-template name="InsertSlideLayout8DotXmlRels"/>
      </pzip:entry>
      <pzip:entry pzip:target="ppt/slideLayouts/_rels/slideLayout9.xml.rels">
        <xsl:call-template name="InsertSlideLayout9DotXmlRels"/>
      </pzip:entry>
      <pzip:entry pzip:target="ppt/slideLayouts/_rels/slideLayout10.xml.rels">
        <xsl:call-template name="InsertSlideLayout10DotXmlRels"/>
      </pzip:entry>
      <pzip:entry pzip:target="ppt/slideLayouts/_rels/slideLayout11.xml.rels">
        <xsl:call-template name="InsertSlideLayout11DotXmlRels"/>
      </pzip:entry>
      <pzip:entry pzip:target="[Content_Types].xml">
        <xsl:call-template name="content"/>
      </pzip:entry>
      <pzip:entry pzip:target="ppt/theme/theme1.xml">
        <xsl:call-template name="theme"/>
      </pzip:entry>
      <pzip:entry pzip:target="ppt/slideMasters/slideMaster1.xml">
        <xsl:call-template name="slideMaster1"/>
      </pzip:entry>
      <pzip:entry pzip:target="ppt/slideMasters/_rels/slideMaster1.xml.rels">
        <xsl:call-template name="slideMaster1Rel"/>
      </pzip:entry>

      <xsl:for-each select ="document('content.xml')
				/office:document-content/office:body/office:presentation/draw:page">
        <xsl:variable name ="SlideName">
          <xsl:value-of select ="concat(concat('Slide',position()),'.xml')"/>
        </xsl:variable>
        <pzip:entry pzip:target="{concat('ppt/slides/',$SlideName)}">
          <!--<xsl:call-template name="slides" />-->
          <xsl:apply-templates select ="." mode="slide" >
            <xsl:with-param name ="pageNo" select ="position()"/>
          </xsl:apply-templates >
        </pzip:entry>
        <pzip:entry pzip:target="{concat(concat('ppt/slides/_rels/',$SlideName), '.rels')}">
          <xsl:call-template name="slidesRel"/>
        </pzip:entry>
      </xsl:for-each>
      <!--<pzip:entry pzip:target="ppt/slides/_rels/slide1.xml.rels">
				<xsl:call-template name="slidesRel"/>
			</pzip:entry>-->
      <pzip:entry pzip:target="_rels/.rels">
        <xsl:call-template name="Rels"/>
      </pzip:entry>
    </pzip:archive>
  </xsl:template>
  <xsl:template name ="content" >
    <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
      <!-- Added By Vijayeta,Extensions of the images,to be added in package-->
      <Default Extension="jpeg" ContentType="image/jpeg"/>
      <Default Extension="jpg" ContentType="image/jpeg"/>
      <Default Extension="gif" ContentType="image/gif"/>
      <Default Extension="png" ContentType="image/png"/>
      <!-- Added By Vijayeta,Extensions of the images,to be added in package-->
      <Override PartName="/ppt/slideMasters/slideMaster1.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideMaster+xml"/>
      <Override PartName="/ppt/theme/theme1.xml" ContentType="application/vnd.openxmlformats-officedocument.theme+xml"/>
      <Override PartName="/ppt/slideLayouts/slideLayout1.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml"/>
      <Override PartName="/ppt/slideLayouts/slideLayout2.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml"/>
      <Override PartName="/ppt/slideLayouts/slideLayout3.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml"/>
      <Override PartName="/ppt/slideLayouts/slideLayout4.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml"/>
      <Override PartName="/ppt/slideLayouts/slideLayout5.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml"/>
      <Override PartName="/ppt/slideLayouts/slideLayout6.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml"/>
      <Override PartName="/ppt/slideLayouts/slideLayout7.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml"/>
      <Override PartName="/ppt/slideLayouts/slideLayout8.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml"/>
      <Override PartName="/ppt/slideLayouts/slideLayout9.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml"/>
      <Override PartName="/ppt/slideLayouts/slideLayout10.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml"/>
      <Override PartName="/ppt/slideLayouts/slideLayout11.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml"/>
      <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
      <Default Extension="xml" ContentType="application/xml"/>
      <Default Extension="wav" ContentType="audio/wav"/>
      <Override PartName="/ppt/presentation.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml"/>
      <Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>
      <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
      <Override PartName="/ppt/tableStyles.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.tableStyles+xml"/>
      <Override PartName="/ppt/viewProps.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.viewProps+xml"/>
      <Override PartName="/ppt/presProps.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.presProps+xml"/>
      <xsl:for-each select ="document('content.xml')
			/office:document-content/office:body/office:presentation/draw:page">
        <Override ContentType="application/vnd.openxmlformats-officedocument.presentationml.slide+xml">
          <xsl:attribute name ="PartName">
            <xsl:value-of select ="concat(concat('/ppt/slides/slide',position()),'.xml')"/>
          </xsl:attribute>
        </Override>
        <!--<Override PartName="/ppt/slides/slide1.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slide+xml"/>
				<Override PartName="/ppt/slides/slide2.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slide+xml"/>-->
      </xsl:for-each>
    </Types>
  </xsl:template>
  <xsl:template name ="Rels">
    <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
      <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
      <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
      <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="ppt/presentation.xml"/>
    </Relationships>
  </xsl:template>
  <!-- InsetViewPropsDotXML Added by Lohith- Temp fix -->
  <xsl:template name="InsetViewPropsDotXML">
    <p:viewPr xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">
      <p:normalViewPr showOutlineIcons="0">
        <p:restoredLeft sz="15620"/>
        <p:restoredTop sz="94660"/>
      </p:normalViewPr>
      <p:slideViewPr>
        <p:cSldViewPr>
          <p:cViewPr varScale="1">
            <p:scale>
              <a:sx n="59" d="100"/>
              <a:sy n="59" d="100"/>
            </p:scale>
            <p:origin x="-780" y="-78"/>
          </p:cViewPr>
          <p:guideLst>
            <p:guide orient="horz" pos="2160"/>
            <p:guide pos="2880"/>
          </p:guideLst>
        </p:cSldViewPr>
      </p:slideViewPr>
      <p:notesTextViewPr>
        <p:cViewPr>
          <p:scale>
            <a:sx n="100" d="100"/>
            <a:sy n="100" d="100"/>
          </p:scale>
          <p:origin x="0" y="0"/>
        </p:cViewPr>
      </p:notesTextViewPr>
      <p:gridSpacing cx="78028800" cy="78028800"/>
    </p:viewPr>

  </xsl:template>
</xsl:stylesheet>