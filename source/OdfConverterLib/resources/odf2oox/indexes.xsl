<?xml version="1.0" encoding="UTF-8"?>
<!--
 * Copyright (c) 2006, Clever Age
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
 *     * Neither the name of Clever Age nor the names of its contributors 
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
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:v="urn:schemas-microsoft-com:vml"
  xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
  xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0"
  xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
  xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
  xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
  xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
  xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="office text table fo style draw xlink v svg number">


  <xsl:strip-space elements="*"/>
  <xsl:preserve-space elements="text:p"/>
  <xsl:preserve-space elements="text:span"/>


  <xsl:key name="toc" match="text:table-of-content" use="''"/>
  <xsl:key name="indexes" match="text:illustration-index | text:table-index" use="''"/>
  <xsl:key name="index-styles" match="text:table-of-content-source/*" use="@text:style-name"/>

  <!-- Inserts item for all types of index  -->
  <xsl:template name="InsertIndexItem">

    <xsl:variable name="indexElementPosition">
      <xsl:number/>
    </xsl:variable>

    <!-- inserts field code of index to first index element -->
    <xsl:if test="$indexElementPosition = 1">
      <xsl:call-template name="InsertIndexFieldCodeStart"/>
    </xsl:if>

    <xsl:choose>

      <!-- when hyperlink option is on in TOC -->
      <xsl:when test="text:a">
        <xsl:apply-templates select="text:a" mode="paragraph"/>
      </xsl:when>

      <!--default scenario-->
      <xsl:otherwise>
        <xsl:call-template name="InsertIndexItemContent"/>
      </xsl:otherwise>

    </xsl:choose>

    <!-- inserts field code end in last index element -->
    <xsl:if test="(count(following-sibling::text:p) = 0) and parent::text:index-body">
      <xsl:call-template name="InsertIndexFieldCodeEnd"/>
    </xsl:if>

  </xsl:template>

  <xsl:template name="InsertIndexFieldCodeEnd">
    <w:r>
      <w:fldChar w:fldCharType="end"/>
    </w:r>
  </xsl:template>

  <xsl:template name="InsertIndexFieldCodeStart">
    <w:r>
      <w:fldChar w:fldCharType="begin"/>
    </w:r>
    <w:r>
      <xsl:choose>
        <xsl:when test="ancestor::text:table-of-content">
          <xsl:call-template name="InsertTocPrefs"/>
        </xsl:when>
        <xsl:when test="ancestor::text:illustration-index">
          <xsl:call-template name="InsertIllustrationInPrefs"/>
        </xsl:when>
        <xsl:when test="ancestor::text:alphabetical-index">
          <xsl:call-template name="insertAlphabeticalPrefs"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="InsertIndexFiguresPrefs"/>
        </xsl:otherwise>
      </xsl:choose>
    </w:r>
    <w:r>
      <w:fldChar w:fldCharType="separate"/>
    </w:r>
  </xsl:template>

  <xsl:template name="InsertIndexFiguresPrefs">
    <w:instrText xml:space="preserve"> TOC \c "</w:instrText>
    <w:instrText>
      <xsl:value-of
        select="parent::text:index-body/preceding-sibling::text:table-index-source/@text:caption-sequence-name"
      />
    </w:instrText>
    <w:instrText xml:space="preserve">" </w:instrText>
  </xsl:template>

  <!-- alphabetical index -->
  <xsl:template name="insertAlphabeticalPrefs">
    <w:instrText xml:space="preserve">INDEX </w:instrText>

    <!--Right Align Page Number-->
    <xsl:if
      test="key('styles', @text:style-name)/style:paragraph-properties/style:tab-stops/style:tab-stop/@style:type='right' ">
      <w:instrText xml:space="preserve">\e "</w:instrText>
      <w:tab/>
      <w:instrText xml:space="preserve">" </w:instrText>
    </xsl:if>

    <!-- column number -->
    <xsl:choose>
      <xsl:when
        test="key('styles', ancestor-or-self::text:alphabetical-index/@text:style-name)/style:section-properties/style:columns/@fo:column-count >4">
        <xsl:message terminate="no">feedback:Column number of alphabetical index (no more than 4)</xsl:message>
        <w:instrText xml:space="preserve">\c "4" </w:instrText>
      </xsl:when>
      <xsl:when
        test="key('styles', ancestor-or-self::text:alphabetical-index/@text:style-name)/style:section-properties/style:columns/@fo:column-count >1">
        <w:instrText xml:space="preserve">\c "</w:instrText>
        <w:instrText>
          <xsl:value-of
            select="key('styles', ancestor-or-self::text:alphabetical-index/@text:style-name)/style:section-properties/style:columns/@fo:column-count"
          />
        </w:instrText>
        <w:instrText xml:space="preserve">" </w:instrText>
      </xsl:when>
      <xsl:otherwise>
        <w:instrText xml:space="preserve">\c "1" </w:instrText>
      </xsl:otherwise>
    </xsl:choose>

    <!-- language -->
    <xsl:if
      test="ancestor-or-self::text:alphabetical-index/text:alphabetical-index-source/@fo:language">
      <w:instrText xml:space="preserve">\z "</w:instrText>
      <w:instrText>
        <xsl:value-of
          select="ancestor-or-self::text:alphabetical-index/text:alphabetical-index-source/@fo:language"
        />
      </w:instrText>
      <w:instrText xml:space="preserve">"</w:instrText>
    </xsl:if>
  </xsl:template>

  <xsl:template name="InsertIllustrationInPrefs">
    <w:instrText xml:space="preserve"> TOC  \c "</w:instrText>
    <w:instrText>
      <xsl:value-of
        select="parent::text:index-body/preceding-sibling::text:illustration-index-source/@text:caption-sequence-name"
      />
    </w:instrText>
    <w:instrText xml:space="preserve">" </w:instrText>
  </xsl:template>

  <!-- table of content -->
  <xsl:template name="InsertTocPrefs">
    <xsl:variable name="tocSource"
      select="ancestor::text:table-of-content/text:table-of-content-source"/>

    <w:instrText xml:space="preserve"> TOC </w:instrText>
    <!-- outline level -->
    <xsl:if test="$tocSource/@text:outline-level">
      <w:instrText xml:space="preserve">\o "1-</w:instrText>
      <w:instrText>
        <!-- include elements with outline styles up to selected level  -->
        <xsl:choose>
          <xsl:when test="$tocSource/@text:outline-level=10">9</xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$tocSource/@text:outline-level"/>
          </xsl:otherwise>
        </xsl:choose>
      </w:instrText>
      <w:instrText xml:space="preserve">" </w:instrText>
    </xsl:if>

    <!-- separator before page numbering. default is right align, null if no tab-stop defined -->
    <xsl:if test="not($tocSource/text:table-of-content-entry-template/@text:index-entry-tab-stop)">
      <w:instrText xml:space="preserve">\p " " </w:instrText>
    </xsl:if>

    <!--include index marks-->
    <xsl:if test="not($tocSource[@text:use-index-marks = 'false'])">
      <w:instrText xml:space="preserve">\u </w:instrText>
    </xsl:if>

    <!--use hyperlinks -->
    <xsl:if test="text:a">
      <w:instrText xml:space="preserve">\h </w:instrText>
    </xsl:if>

    <!-- include elements with additional styles-->
    <xsl:if
      test="$tocSource/text:index-source-styles or $tocSource/text:table-of-content-entry-template">
      <w:instrText xml:space="preserve">\t "</w:instrText>
      <w:instrText>
        <xsl:call-template name="InsertTOCLevelStyle">
          <xsl:with-param name="tocSource" select="$tocSource"/>
        </xsl:call-template>
      </w:instrText>
      <w:instrText xml:space="preserve">" </w:instrText>
    </xsl:if>
  </xsl:template>


  <xsl:template name="InsertTOCLevelStyle">
    <xsl:param name="level" select="1"/>
    <xsl:param name="tocSource"/>

    <xsl:if test="$level &lt; 10">
      <xsl:variable name="levelStyleName">
        <xsl:choose>
          <xsl:when
            test="$tocSource/text:index-source-styles[@text:outline-level = $level]/@text:style-name">
            <xsl:value-of
              select="$tocSource/text:index-source-styles[@text:outline-level = $level]/@text:style-name"
            />
          </xsl:when>
          <xsl:otherwise>
            <xsl:if
              test="$tocSource/text:table-of-content-entry-template[@text:outline-level = $level]/@text:style-name">
              <xsl:value-of
                select="$tocSource/text:table-of-content-entry-template[@text:outline-level = $level]/@text:style-name"
              />
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:for-each select="document('styles.xml')">
        <xsl:for-each select="key('styles', $levelStyleName)">
          <xsl:choose>
            <xsl:when test="@style:display-name">
              <xsl:value-of select="@style:display-name"/>
              <xsl:text>;</xsl:text>
              <xsl:value-of select="$level"/>
              <xsl:text>;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test="@style:name">
                <xsl:value-of select="@style:name"/>
                <xsl:text>;</xsl:text>
                <xsl:value-of select="$level"/>
                <xsl:text>;</xsl:text>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:for-each>
      <!-- insert next level -->
      <xsl:call-template name="InsertTOCLevelStyle">
        <xsl:with-param name="level" select="$level + 1"/>
        <xsl:with-param name="tocSource" select="$tocSource"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>



  <!--inserts index item content for all types of index-->
  <xsl:template name="InsertIndexItemContent">

    <!-- references to index bookmark id in text -->
    <xsl:param name="tocId" select="count(preceding-sibling::text:p)+1"/>

    <!-- alphabetical index doesn't support page reference link -->

    <!-- insert TOC -->
    <xsl:choose>
      <xsl:when test="self::text:a">
        <xsl:apply-templates mode="paragraph"/>
        <xsl:apply-templates select="parent::text:p/child::node()[not(self::text:a)]"
          mode="paragraph"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="paragraph"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="InsertIndexPageRefEnd">
    <w:r>
      <w:rPr>
        <w:noProof/>
        <w:webHidden/>
      </w:rPr>
      <w:fldChar w:fldCharType="end"/>
    </w:r>
  </xsl:template>

  <xsl:template name="InsertIndexPageRefStart">
    <xsl:param name="tocId"/>

    <w:r>
      <w:rPr>
        <w:noProof/>
        <w:webHidden/>
      </w:rPr>
      <w:fldChar w:fldCharType="begin">
        <w:fldData xml:space="preserve">CNDJ6nn5us4RjIIAqgBLqQsCAAAACAAAAA4AAABfAFQAbwBjADEANAAxADgAMwA5ADIANwA2AAAA</w:fldData>
      </w:fldChar>
    </w:r>
    <w:r>
      <w:rPr>
        <w:noProof/>
        <w:webHidden/>
      </w:rPr>
      <w:instrText xml:space="preserve"><xsl:value-of select="concat('PAGEREF _Toc', $tocId,generate-id(ancestor::node()[child::text:index-body]), ' \h')"/></w:instrText>
    </w:r>
    <w:r>
      <w:rPr>
        <w:noProof/>
        <w:webHidden/>
      </w:rPr>
      <w:fldChar w:fldCharType="separate"/>
    </w:r>
  </xsl:template>

  <!-- insert the bg color in paragraph properties -->
  <xsl:template name="InsertTOCBgColor">
    <xsl:if
      test="key('styles', ancestor::text:table-of-content/@text:style-name)/style:section-properties/@fo:background-color">
      <xsl:variable name="bgColor">
        <xsl:value-of
          select="key('styles', ancestor::text:table-of-content/@text:style-name)/style:section-properties/@fo:background-color"
        />
      </xsl:variable>
      <xsl:if test="$bgColor != 'transparent' ">
        <w:shd w:val="clear" w:color="auto"
          w:fill="{translate(translate(substring-after($bgColor, '#'),'f','F'),'c','C')}"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- empty alphabetical indexes creating mark entry -->
  <xsl:template match="text:alphabetical-index-mark" mode="paragraph">
    <w:r>
      <w:fldChar w:fldCharType="begin"/>
    </w:r>
    <w:r>
      <w:instrText xml:space="preserve"> XE "</w:instrText>
    </w:r>
    <w:r>
      <w:instrText>
        <xsl:value-of select="./@text:string-value"/>
      </w:instrText>
    </w:r>
    <w:r>
      <w:instrText xml:space="preserve">" </w:instrText>
    </w:r>
    <w:r>
      <w:fldChar w:fldCharType="end"/>
    </w:r>
  </xsl:template>

  <!-- alphabetical indexes creating mark entry -->
  <xsl:template match="text:alphabetical-index-mark-end" mode="paragraph">
    <w:r>
      <w:fldChar w:fldCharType="begin"/>
    </w:r>
    <w:r>
      <w:instrText xml:space="preserve"> XE "</w:instrText>
    </w:r>
    <w:r>
      <w:instrText>
        <xsl:variable name="id" select="@text:id"/>
        <xsl:for-each select="preceding-sibling::node()">
          <xsl:if
            test="preceding-sibling::node()[name() = 'text:alphabetical-index-mark-start' and @text:id = $id]">
            <!-- ignore all ...mark-start/end and track-changes -->
            <xsl:if test="not(contains(name(), 'mark-') or contains(name(), 'change-'))">
              <xsl:choose>
                <xsl:when test="self::text()">
                  <xsl:value-of select="."/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="."/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:if>
          </xsl:if>
        </xsl:for-each>
      </w:instrText>
    </w:r>
    <w:r>
      <w:instrText xml:space="preserve">" </w:instrText>
    </w:r>
    <w:r>
      <w:fldChar w:fldCharType="end"/>
    </w:r>
    <!-- <xsl:apply-templates select="text:s" mode="text"></xsl:apply-templates> -->
  </xsl:template>

  <xsl:template match="text()" mode="indexes">
    <xsl:choose>
      <xsl:when test="ancestor::text:index-title">
        <w:t xml:space="preserve"><xsl:value-of select="."/></w:t>
      </xsl:when>
      <xsl:when test="preceding-sibling::text:tab">
        <w:t xml:space="preserve"><xsl:value-of select="."/></w:t>
      </xsl:when>
      <xsl:when test="not(following-sibling::text:tab)">
        <xsl:choose>
          <xsl:when test="parent::text:a|parent::text:span">
            <w:t xml:space="preserve"><xsl:value-of select="."/></w:t>
          </xsl:when>
          <xsl:otherwise>
            <w:t>
              <xsl:value-of select="ancestor::text:p/text()"/>
            </w:t>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <w:t>
          <xsl:value-of select="."/>
        </w:t>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- styles for indexes. They require a particular syntax -->
  <xsl:template name="InsertIndexStyles">
    <xsl:for-each select="document('content.xml')">
      <xsl:for-each select="key('toc', '')">
        <xsl:call-template name="InsertIndexLevelStyle"/>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <!-- there can be only one style for the whole document (all TOCs) -->
  <xsl:template name="InsertIndexLevelStyle">
    <xsl:param name="level" select="1"/>

    <xsl:if test="$level &lt; 10">
      <xsl:variable name="levelStyleName">
        <xsl:value-of
          select="text:table-of-content-source/text:table-of-content-entry-template[@text:outline-level = $level]/@text:style-name"
        />
      </xsl:variable>
      <!-- if hyperlink -->
      <xsl:variable name="levelTextStyleName">
        <xsl:value-of
          select="text:table-of-content-source/text:table-of-content-entry-template[@text:outline-level = $level]/*[self::text:index-entry-link-start or self::text:index-entry-link-end]/@text:style-name"
        />
      </xsl:variable>
      <xsl:for-each select="document('styles.xml')">
        <xsl:for-each select="key('styles', $levelStyleName)">
          <w:style w:styleId="{concat('TOC', $level)}" w:type="paragraph">
            <w:name w:val="{concat('toc ', $level)}"/>
            <w:basedOn w:val="{$levelStyleName}"/>
            <w:autoRedefine/>
            <w:semiHidden/>
            <xsl:if test="$levelTextStyleName != '' ">
              <w:rPr>
                <w:rStyle w:val="{$levelTextStyleName}"/>
                <xsl:for-each select="document('styles.xml')">
                  <xsl:apply-templates select="key('styles', $levelTextStyleName)" mode="rPr"/>
                </xsl:for-each>
              </w:rPr>
            </xsl:if>
          </w:style>
        </xsl:for-each>
      </xsl:for-each>
      <!-- insert next level -->
      <xsl:call-template name="InsertIndexLevelStyle">
        <xsl:with-param name="level" select="$level + 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>


</xsl:stylesheet>
