﻿<?xml version="1.0" encoding="UTF-8"?>
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
  xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
  xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
  xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
  xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" exclude-result-prefixes="w">

  <xsl:key name="numId" match="w:num" use="@w:numId"/>
  <xsl:key name="abstractNumId" match="w:abstractNum" use="@w:abstractNumId"/>

  <!--insert num template for each text-list style -->
  
  <xsl:template match="w:num">
    <xsl:variable name="id">
      <xsl:value-of select="@w:numId"/>
    </xsl:variable>
    
    <!-- apply abstractNum template with the same id -->
    <xsl:apply-templates select="key('abstractNumId',w:abstractNumId/@w:val)">
      <xsl:with-param name="id">
        <xsl:value-of select="$id"/>
      </xsl:with-param>
    </xsl:apply-templates>
    
  </xsl:template>

  <!-- insert abstractNum template -->

  <xsl:template match="w:abstractNum">
    <xsl:param name="id"/>
    <text:list-style style:name="{concat('L',$id)}">
      <xsl:for-each select="w:lvl">
        <xsl:variable name="level" select="@w:ilvl"/>
        <xsl:choose>

          <!-- when numbering style is overriden, num template is used -->
          <xsl:when test="key('numId',$id)/w:lvlOverride[@w:ilvl = $level]/w:lvl">
            <xsl:apply-templates
              select="key('numId',$id)/w:lvlOverride[@w:ilvl = $level]/w:lvl[@w:ilvl = $level]"/>
          </xsl:when>

          <xsl:otherwise>
            <xsl:apply-templates select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </text:list-style>
  </xsl:template>

  <xsl:template match="w:lvl">
    <xsl:choose>

      <!--check if it's numbering or bullet -->
      <xsl:when test="w:numFmt[@w:val = 'bullet']">
        <text:list-level-style-bullet text:level="{number(@w:ilvl)+1}"
          text:style-name="Bullet_20_Symbols">
          <xsl:attribute name="text:bullet-char">
            <xsl:call-template name="TextChar"/>
          </xsl:attribute>
          <style:list-level-properties>
            <xsl:call-template name="InsertListLevelProperties"/>
          </style:list-level-properties>
          <style:text-properties style:font-name="StarSymbol"/>
        </text:list-level-style-bullet>
      </xsl:when>
      <xsl:otherwise>
        <text:list-level-style-number text:level="{number(@w:ilvl)+1}">
          <xsl:if test="not(number(substring(w:lvlText/@w:val,string-length(w:lvlText/@w:val))))">
            <xsl:attribute name="style:num-suffix">
              <xsl:value-of select="substring(w:lvlText/@w:val,string-length(w:lvlText/@w:val))"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:attribute name="style:num-format">
            <xsl:if test="w:lvlText/@w:val != ''">
            <xsl:call-template name="NumFormat">
              <xsl:with-param name="format" select="w:numFmt/@w:val"/>
            </xsl:call-template>
            </xsl:if>
          </xsl:attribute>
          <xsl:if test="w:start and w:start/@w:val > 1">
            <xsl:attribute name="text:start-value">
              <xsl:value-of select="w:start/@w:val"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:variable name="display">
            <xsl:call-template name="CountDisplayListLevels">
              <xsl:with-param name="string">
                <xsl:value-of select="./w:lvlText/@w:val"/>
              </xsl:with-param>
              <xsl:with-param name="count">0</xsl:with-param>
            </xsl:call-template>
          </xsl:variable>
          <xsl:if test="$display &gt; 1">
            <xsl:attribute name="text:display-levels">
              <xsl:value-of select="$display"/>
            </xsl:attribute>
          </xsl:if>
          <style:list-level-properties>
            <xsl:call-template name="InsertListLevelProperties"/>
          </style:list-level-properties>
        </text:list-level-style-number>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- numbering format -->

  <xsl:template name="NumFormat">
    <xsl:param name="format"/>
    <xsl:choose>
      <xsl:when test="$format= 'decimal' ">1</xsl:when>
      <xsl:when test="$format= 'lowerRoman' ">i</xsl:when>
      <xsl:when test="$format= 'upperRoman' ">I</xsl:when>
      <xsl:when test="$format= 'lowerLetter' ">a</xsl:when>
      <xsl:when test="$format= 'upperLetter' ">A</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- properties for each list level -->

  <xsl:template name="InsertListLevelProperties">
    <xsl:variable name="Ind" select="w:pPr/w:ind"/>
    <xsl:variable name="tab">
      <xsl:choose>
        <xsl:when test="w:pPr/w:tabs/w:tab">
          <xsl:value-of select="w:pPr/w:tabs/w:tab/@w:pos"/>
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

   	<xsl:variable name="abstractNumId">
      <xsl:value-of select="parent::w:abstractNum/@w:abstractNumId"/>
    </xsl:variable>

    <xsl:variable name="numId">
      <xsl:value-of select="w:num[w:abstractNumId/@w:val=$abstractNumId]/@w:numId"/>
    </xsl:variable>

    <xsl:variable name="StyleId">      
        <xsl:value-of select="w:pStyle/@w:val"/>
    </xsl:variable>
    
    <xsl:variable name="paragraph" select="document('word/document.xml')//descendant::w:p[w:pPr/w:numPr/w:numId=$numId]"/>

    <xsl:variable name="paragraphStyleProperties" select="document('word/styles.xml')//descendant::w:style[@w:styleId = $paragraph/w:pPr/w:pStyle/@w:val]/w:pPr"/>

    <xsl:variable name="paragraphBorder">
      
      <xsl:choose>
        
        <xsl:when test="$paragraph/w:pPr/w:pBdr/w:left/@w:sz">
          <xsl:value-of select="$paragraph/w:pPr/w:pBdr/w:left/@w:sz"/>
        </xsl:when>
        
        <xsl:when test="$paragraphStyleProperties/w:pBdr/w:left/@w:sz">
          <xsl:value-of select="$paragraphStyleProperties/w:pBdr/w:left/@w:sz"/>
        </xsl:when>
        
        <xsl:otherwise>0</xsl:otherwise>
        
      </xsl:choose>
      
    </xsl:variable> 
    
    <xsl:variable name="paragraphPadding">
      
      <xsl:choose>
        
        <xsl:when test="$paragraph/w:pPr/w:pBdr/w:left/@w:space">
          <xsl:value-of select="$paragraph/w:pPr/w:pBdr/w:left/@w:space"/>
        </xsl:when>
        
        <xsl:when test="$paragraphStyleProperties/w:pBdr/w:left/@w:space">
          <xsl:value-of select="$paragraphStyleProperties/w:pBdr/w:left/@w:space"/>
        </xsl:when>
        
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    
    </xsl:variable>
    
    <xsl:variable name="paragraphMargin">
      <xsl:call-template name="GetParagraphIndent"/>
    </xsl:variable>
    
<xsl:variable name="paragraphIndent" select="$paragraphBorder+$paragraphPadding+$paragraphMargin"/>
    
<xsl:variable name="WLeft">
  <xsl:choose>    
    <xsl:when test="$Ind/@w:left">
    <xsl:value-of select="$Ind/@w:left"/>
    </xsl:when>
    <xsl:otherwise>0</xsl:otherwise>
</xsl:choose>
</xsl:variable>
    
<xsl:variable name="WHanging">
  <xsl:choose>
    <xsl:when test="$Ind/@w:hanging">
      <xsl:value-of select="$Ind/@w:hanging"/>
    </xsl:when>
    <xsl:otherwise>0</xsl:otherwise>
 </xsl:choose>
</xsl:variable>
    
<xsl:variable name="WFirstLine">
    <xsl:choose>
      <xsl:when test="$Ind/@w:firstLine">
        <xsl:value-of select="$Ind/@w:firstLine"/>
      </xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
 </xsl:variable>
    
    <xsl:choose>
      
      <xsl:when test="$Ind/@w:hanging">
        <xsl:attribute name="text:space-before">
          <xsl:call-template name="ConvertTwips">
            <xsl:with-param name="length">
              <xsl:choose>
                <xsl:when test="w:pPr/w:outlineLvl/@w:val or document('word/styles.xml')/w:styles/w:style[@w:styleId=$StyleId]/w:pPr/w:outlineLvl/@w:val">
                  <xsl:value-of select="$WLeft - $WHanging" />    
                </xsl:when>
                <xsl:when test="number($WLeft) - number($WHanging) = 0">0</xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$WLeft - $WHanging - $paragraphIndent" />    
                </xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="unit">cm</xsl:with-param>
          </xsl:call-template>          
        </xsl:attribute>
        <xsl:attribute name="text:min-label-width">
          <xsl:call-template name="ConvertTwips">
            <xsl:with-param name="length">
              <xsl:choose>
                <xsl:when test="w:suff/@w:val='nothing'">0</xsl:when>
                <xsl:when test="w:suff/@w:val='space'">350</xsl:when>
                <xsl:when test="number($tab)>(number($WLeft) - ($WHanging)) and (number($WHanging) > (number($tab) - number($WLeft) + number($WHanging)))">
                  <xsl:value-of select="$tab - $WLeft + $WHanging"/>
                </xsl:when>
                <xsl:when test="$paragraph/w:pPr/w:ind/@w:hanging">
                  <xsl:value-of select="$paragraph/w:pPr/w:ind/@w:hanging"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$Ind/@w:hanging"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="unit">cm</xsl:with-param>
          </xsl:call-template>
        </xsl:attribute>
        <xsl:attribute name="text:min-label-distance">
          <xsl:choose>
            <xsl:when test="w:suff/@w:val='nothing'">0</xsl:when>
            <xsl:when test="w:suff/@w:val='space'">350</xsl:when>            
            <xsl:when test="$paragraph/w:pPr/w:ind/@w:hanging">
              <xsl:call-template name="ConvertTwips">
                <xsl:with-param name="length">
                  <xsl:value-of select="$paragraph/w:pPr/w:ind/@w:hanging"/>
                </xsl:with-param>
                <xsl:with-param name="unit">cm</xsl:with-param>
              </xsl:call-template>         
            </xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="text:space-before">
          <xsl:call-template name="ConvertTwips">
            <xsl:with-param name="length">
              <xsl:choose>
                <xsl:when test="w:pPr/w:outlineLvl/@w:val or document('word/styles.xml')/w:styles/w:style[@w:styleId=$StyleId]/w:pPr/w:outlineLvl/@w:val">
                  <xsl:value-of select="number($WLeft) + number($WFirstLine)"/>    
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="number($WLeft) + number($WFirstLine) - $paragraphIndent"/>    
                </xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="unit">cm</xsl:with-param>
          </xsl:call-template>
          
        </xsl:attribute>
       
        <xsl:attribute name="text:min-label-width">
            <xsl:call-template name="ConvertTwips">
              <xsl:with-param name="length">
                <xsl:choose>
                  <xsl:when test="../w:multiLevelType/@w:val='multilevel' and number($tab) > (number($WLeft) - number($WFirstLine))">                
                    <xsl:value-of select="$tab - number($WLeft) - number($WFirstLine)"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="number($WFirstLine)"/>
                  </xsl:otherwise>
                  </xsl:choose>
              </xsl:with-param>
              <xsl:with-param name="unit">cm</xsl:with-param>
            </xsl:call-template>
        </xsl:attribute>
        <xsl:attribute name="text:min-label-distance">
          <xsl:choose>
            <xsl:when
              test="(3 * number($WFirstLine)) &lt; (number($tab) - number($WLeft)) ">
              <xsl:value-of
                select="number($tab) - number($WLeft) - (2 * number($WFirstLine))"/>
            </xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- types of bullets -->

  <xsl:template name="TextChar">
    <xsl:choose>
      <xsl:when test="w:lvlText[@w:val = ''] "></xsl:when>
      <xsl:when test="w:lvlText[@w:val = '' ]"></xsl:when>
      <xsl:when test="w:lvlText[@w:val = '' ]">☑</xsl:when>
      <xsl:when test="w:lvlText[@w:val = '•' ]">•</xsl:when>
      <xsl:when test="w:lvlText[@w:val = '' ]">●</xsl:when>
      <xsl:when test="w:lvlText[@w:val = '' ]">➢</xsl:when>
      <xsl:when test="w:lvlText[@w:val = '' ]">✔</xsl:when>
      <xsl:when test="w:lvlText[@w:val = '' ]">■</xsl:when>
      <xsl:when test="w:lvlText[@w:val = 'o' ]">○</xsl:when>
      <xsl:when test="w:lvlText[@w:val = '' ]">➔</xsl:when>
      <xsl:when test="w:lvlText[@w:val = '' ]">✗</xsl:when>
      <xsl:when test="w:lvlText[@w:val = '-' ]">–</xsl:when>
      <xsl:when test="w:lvlText[@w:val = '–' ]">–</xsl:when>
      <xsl:when test="w:lvlText[@w:val = '' ]">–</xsl:when>
      <xsl:otherwise>•</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- checks for list numPr properties (numid or level) in styles hierarchy -->
  <xsl:template name="GetListStyleProperty">
    <xsl:param name="style"/>
    <xsl:param name="property"/>

    <xsl:choose>
      <xsl:when test="$style/descendant::w:numPr">
        <xsl:choose>
          <xsl:when test="$property = 'w:ilvl' ">
            <xsl:choose>
              <xsl:when
                test="$style/descendant::w:numPr/w:numId and not($style/descendant::w:numPr/w:ilvl)">
                <xsl:text>0</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of
                  select="$style/descendant::w:numPr/child::node()[name() = $property]/@w:val"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of
              select="$style/descendant::w:numPr/child::node()[name() = $property]/@w:val"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="w:basedOn">
          <xsl:variable name="parentStyle"
            select="document('word/styles.xml')/w:styles/w:style[@w:styleId = w:basedOn/@w:val]"/>
          <xsl:call-template name="GetListStyleProperty">
            <xsl:with-param name="style" select="$parentStyle"/>
            <xsl:with-param name="property" select="$property"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- checks for list numPr properties (numid or level) for given element  -->
  <xsl:template name="GetListProperty">
    <xsl:param name="node"/>
    <xsl:param name="property"/>

    <xsl:choose>
      <xsl:when test="$node/descendant::w:numPr">
        <xsl:value-of select="$node/descendant::w:numPr/child::node()[name() = $property]/@w:val"/>
      </xsl:when>

      <xsl:when test="$node/descendant::w:pStyle">
        <xsl:variable name="styleId" select="$node/descendant::w:pStyle/@w:val"/>

        <xsl:variable name="pStyle"
          select="document('word/styles.xml')/w:styles/w:style[@w:styleId = $styleId]"/>
        <xsl:variable name="propertyValue">
          <xsl:call-template name="GetListStyleProperty">
            <xsl:with-param name="style" select="$pStyle"/>
            <xsl:with-param name="property" select="$property"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$propertyValue"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- heading list display levels  -->
  <xsl:template name="CountDisplayListLevels">
    <xsl:param name="string"/>
    <xsl:param name="count"/>
    <xsl:choose>
      <xsl:when test="string-length(substring-after($string,'%')) &gt; 0">
        <xsl:call-template name="CountDisplayListLevels">
          <xsl:with-param name="string">
            <xsl:value-of select="substring-after($string,'%')"/>
          </xsl:with-param>
          <xsl:with-param name="count">
            <xsl:value-of select="$count +1"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$count"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>



  <!-- paragraph which is the first element in list level-->
  <xsl:template match="w:p" mode="list">
    <xsl:param name="numId"/>
    <xsl:param name="level"/>
    <xsl:param name="listLevel"/>

    <xsl:variable name="isFirstListItem">
      <xsl:call-template name="IsFirstListItem">
        <xsl:with-param name="node" select="."/>
        <xsl:with-param name="numId" select="$numId"/>
        <xsl:with-param name="listLevel" select="$listLevel"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:if test="$isFirstListItem = 'true'">
      <text:list text:style-name="{concat('L',$numId)}">

        <!--  TODO - continue numbering-->
        <xsl:attribute name="text:continue-numbering">true</xsl:attribute>

        <xsl:variable name="currentListLevel">
          <xsl:call-template name="GetGeneratedListLevel">
            <xsl:with-param name="listLevel" select="$listLevel"/>
          </xsl:call-template>
        </xsl:variable>

        <xsl:call-template name="InsertListLevel">
          <xsl:with-param name="level" select="$level"/>
          <xsl:with-param name="numId" select="$numId"/>
          <xsl:with-param name="listLevel" select="$currentListLevel"/>
        </xsl:call-template>
      </text:list>
    </xsl:if>
  </xsl:template>

  <!--gets actually generated list level-->
  <xsl:template name="GetGeneratedListLevel">
    <xsl:param name="listLevel"/>
    <xsl:choose>
      <xsl:when test="$listLevel = ''">
        <xsl:text>0</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$listLevel"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- converts element as list item and insert nested level if there is any -->
  <xsl:template name="InsertListLevel">
    <xsl:param name="node" select="."/>
    <xsl:param name="level"/>
    <xsl:param name="numId"/>
    <xsl:param name="listLevel"/>

    <xsl:variable name="isNestedList">
      <xsl:call-template name="IsNestedList">
        <xsl:with-param name="node" select="$node"/>
        <xsl:with-param name="level" select="$level"/>
        <xsl:with-param name="listLevel" select="$listLevel"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:apply-templates select="$node" mode="list-item">
      <xsl:with-param name="numId" select="$numId"/>
      <xsl:with-param name="level" select="$level"/>
      <xsl:with-param name="listLevel" select="$listLevel"/>
      <xsl:with-param name="isNestedList" select="$isNestedList"/>
    </xsl:apply-templates>

    <xsl:choose>
      <xsl:when test="$isNestedList = 'true'">
        <xsl:call-template name="InsertCurrentLevel">
          <xsl:with-param name="node" select="$node"/>
          <xsl:with-param name="level" select="$listLevel"/>
          <xsl:with-param name="numId" select="$numId"/>
          <xsl:with-param name="listLevel" select="$listLevel"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="InsertFollowingLevel">
          <xsl:with-param name="node" select="$node"/>
          <xsl:with-param name="level" select="$listLevel"/>
          <xsl:with-param name="numId" select="$numId"/>
          <xsl:with-param name="listLevel" select="$listLevel"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- insert lists element content and nested list if there is following element is on differeynt level -->
  <xsl:template match="w:p" mode="list-item">
    <xsl:param name="numId"/>
    <xsl:param name="level"/>
    <xsl:param name="listLevel"/>
    <xsl:param name="isNestedList"/>

    <text:list-item>
      <xsl:variable name="followingParagraph" select="self::node()[1]/following-sibling::w:p[1]"/>

      <xsl:choose>
        <xsl:when test="$listLevel = $level">

          <xsl:call-template name="InsertListItemContent">
            <xsl:with-param name="node" select="self::node()[1]"/>
          </xsl:call-template>

          <xsl:if test="$isNestedList = 'true' ">
            <xsl:variable name="followingLevel">
              <xsl:call-template name="GetListProperty">
                <xsl:with-param name="node" select="$followingParagraph"/>
                <xsl:with-param name="property">w:ilvl</xsl:with-param>
              </xsl:call-template>
            </xsl:variable>

            <xsl:apply-templates select="$followingParagraph" mode="list">
              <xsl:with-param name="numId" select="$numId"/>
              <xsl:with-param name="level" select="$followingLevel"/>
              <xsl:with-param name="listLevel" select="$listLevel + 1"/>
            </xsl:apply-templates>
          </xsl:if>
        </xsl:when>

        <xsl:when test="$isNestedList = 'true' ">
          <xsl:apply-templates select="self::node()" mode="list">
            <xsl:with-param name="numId" select="$numId"/>
            <xsl:with-param name="level" select="$level"/>
            <xsl:with-param name="listLevel" select="$listLevel + 1"/>
          </xsl:apply-templates>
        </xsl:when>
      </xsl:choose>
    </text:list-item>
  </xsl:template>

  <xsl:template name="InsertListItemContent">
    <xsl:param name="node"/>

    <xsl:variable name="outlineLevel">
      <xsl:call-template name="GetOutlineLevel">
        <xsl:with-param name="node" select="$node"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$outlineLevel != ''">
        <xsl:apply-templates select="$node" mode="heading"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="$node" mode="paragraph"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--inserts following list item if its level is higher-->
  <xsl:template name="InsertFollowingLevel">
    <xsl:param name="node"/>
    <xsl:param name="numId"/>
    <xsl:param name="level"/>
    <xsl:param name="listLevel"/>

    <xsl:variable name="followingParagraph" select="$node/following-sibling::w:p[1]"/>

    <xsl:variable name="followingNumId">
      <xsl:call-template name="GetListProperty">
        <xsl:with-param name="node" select="$followingParagraph"/>
        <xsl:with-param name="property">w:numId</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="followingLevel">
      <xsl:call-template name="GetListProperty">
        <xsl:with-param name="node" select="$followingParagraph"/>
        <xsl:with-param name="property">w:ilvl</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="isHigherLevel">
      <xsl:call-template name="isHigherLevelItem">
        <xsl:with-param name="numId" select="$numId"/>
        <xsl:with-param name="followingNumId" select="$followingNumId"/>
        <xsl:with-param name="level" select="$level"/>
        <xsl:with-param name="followingLevel" select="$followingLevel"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:if test="$isHigherLevel = 'true'">
      <xsl:call-template name="InsertListLevel">
        <xsl:with-param name="node" select="$followingParagraph"/>
        <xsl:with-param name="level" select="$followingLevel"/>
        <xsl:with-param name="numId" select="$followingNumId"/>
        <xsl:with-param name="listLevel" select="$listLevel"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!--  inserts the remaining items on given level when following item is nested list element-->
  <xsl:template name="InsertCurrentLevel">
    <xsl:param name="node"/>
    <xsl:param name="numId"/>
    <xsl:param name="level"/>
    <xsl:param name="listLevel"/>

    <xsl:variable name="followingParagraphId">
      <xsl:call-template name="GetCurrentLevelItem">
        <xsl:with-param name="node" select="$node"/>
        <xsl:with-param name="level" select="$listLevel"/>
        <xsl:with-param name="numId" select="$numId"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:if test="$followingParagraphId != ''">

      <xsl:variable name="followingParagraphOnLevel"
        select="$node/following-sibling::w:p[generate-id() = $followingParagraphId]"/>

      <xsl:call-template name="InsertListLevel">
        <xsl:with-param name="node" select="$followingParagraphOnLevel"/>
        <xsl:with-param name="level" select="$listLevel"/>
        <xsl:with-param name="numId" select="$numId"/>
        <xsl:with-param name="listLevel" select="$listLevel"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!--checks list element level-->
  <xsl:template name="isHigherLevelItem">
    <xsl:param name="numId"/>
    <xsl:param name="followingNumId"/>
    <xsl:param name="level"/>
    <xsl:param name="followingLevel"/>

    <xsl:choose>
      <xsl:when test="$followingLevel &gt;= $level and $numId = $followingNumId">
        <xsl:text>true</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>false</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--  ckecks element is first on given list level-->
  <xsl:template name="IsFirstListItem">
    <xsl:param name="node"/>
    <xsl:param name="numId"/>
    <xsl:param name="listLevel"/>

    <xsl:choose>
      <xsl:when test="$listLevel != '' ">
        <xsl:text>true</xsl:text>
      </xsl:when>
      <xsl:when test="$node/preceding-sibling::node()[1]/descendant::w:numPr">
        <xsl:choose>
          <xsl:when
            test="$node/preceding-sibling::node()[1]/descendant::w:numPr/w:numId/@w:val = $numId">
            <xsl:text>false</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>true</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="pStyle"
          select="document('word/styles.xml')/w:styles/w:style[@w:styleId = $node/preceding-sibling::node()[1]/descendant::w:pStyle/@w:val]"/>
        <xsl:variable name="precedingNumId">
          <xsl:call-template name="GetListProperty">
            <xsl:with-param name="node" select="$node/preceding-sibling::node()[1]"/>
            <xsl:with-param name="property">w:numId</xsl:with-param>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$precedingNumId = $numId">
            <xsl:text>false</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>true</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- checks if given element should be generated as nested list)....-->
  <xsl:template name="IsNestedList">
    <xsl:param name="node"/>
    <xsl:param name="level"/>
    <xsl:param name="listLevel"/>

    <xsl:for-each select="$node">
      <xsl:if test="$level &gt; 0 and $level != $listLevel">
        <xsl:text>true</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- searches for following list item on given level -->
  <xsl:template name="GetCurrentLevelItem">
    <xsl:param name="node"/>
    <xsl:param name="level"/>
    <xsl:param name="numId"/>

    <xsl:variable name="nodePosition">
      <xsl:for-each select="$node">
        <xsl:value-of select="position()"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="followingParagraph" select="$node/following-sibling::w:p[1]"/>

    <xsl:variable name="followingNumId">
      <xsl:call-template name="GetListProperty">
        <xsl:with-param name="node" select="$followingParagraph"/>
        <xsl:with-param name="property">w:numId</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="followingLevel">
      <xsl:call-template name="GetListProperty">
        <xsl:with-param name="node" select="$followingParagraph"/>
        <xsl:with-param name="property">w:ilvl</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$followingNumId = $numId and $followingLevel = $level">
        <xsl:value-of select="generate-id($followingParagraph)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$followingLevel &gt;= $level">
          <xsl:call-template name="GetCurrentLevelItem">
            <xsl:with-param name="node" select="$followingParagraph"/>
            <xsl:with-param name="level" select="$level"/>
            <xsl:with-param name="numId" select="$numId"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- inserts automatic list styles with empty num format for elements which has non-existent w:num attached -->
  <xsl:template name="InsertDefaultListStyle">
    <xsl:param name="numId"/>
    <xsl:variable name="listName" select="concat('L',$numId)"/>
    <text:list-style style:name="{$listName}">
      <xsl:call-template name="InsertDefaultLevelProperties">
        <xsl:with-param name="levelNum" select="'1'"/>
      </xsl:call-template>
    </text:list-style>
  </xsl:template>

  <!-- inserts level with empty num format for elements which has non-existent w:num attached -->
  <xsl:template name="InsertDefaultLevelProperties">
    <xsl:param name="levelNum"/>
    <text:list-level-style-number text:level="{$levelNum}" style:num-format=""/> 
    <xsl:if test="$levelNum &lt; 9">
      <xsl:call-template name="InsertDefaultLevelProperties">
        <xsl:with-param name="levelNum" select="$levelNum+1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <!-- inserts automatic list styles with empty num format for elements which has non-existent w:num attached -->
  <xsl:template match="w:numId" mode="automaticstyles">
    <xsl:variable name="numId" select="@w:val"/>
    <xsl:for-each select="document('word/numbering.xml')">
      <xsl:if test="key('numId',@w:val) = ''">
        <xsl:call-template name="InsertDefaultListStyle">
          <xsl:with-param name="numId" select="$numId"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
