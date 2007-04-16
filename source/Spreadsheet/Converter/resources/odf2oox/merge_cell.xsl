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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  xmlns:pzip="urn:cleverage:xmlns:post-processings:zip"
  xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
  xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
  xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
  exclude-result-prefixes="table">
  
  
  <!-- Variable with Merge Style-->
  
  <xsl:template name="WriteMergeStyle">
    
    <xsl:choose>
      <!-- when the first row is a simple row -->
      <xsl:when test="child::node()[name() != 'table:table-column' and name() != 'table:table-header-columns' ][1][name() = 'table:table-row' ]">
        <xsl:variable name="rowNumber">
          <xsl:choose>
            <xsl:when test="table:table-row[1]/@table:number-rows-repeated">
              <xsl:value-of select="table:table-row[1]/@table:number-rows-repeated"/>
            </xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
          </xsl:choose>  
        </xsl:variable>
        
        <xsl:apply-templates select="table:table-row[1]" mode="mergestyle">
          <xsl:with-param name="rowNumber">
            <xsl:value-of select="$rowNumber"/>
          </xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <!-- when the first row is a header row -->
      <xsl:when test="child::node()[name() != 'table:table-column' and name() != 'table:table-header-columns' ][1][name() = 'table:table-header-rows' ]">
        <xsl:variable name="rowNumber">
          <xsl:choose>
            <xsl:when test="table:table-header-rows/table:table-row[1]/@table:number-rows-repeated">
              <xsl:value-of select="table:table-header-rows/table:table-row[1]/@table:number-rows-repeated"/>
            </xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
          </xsl:choose>  
        </xsl:variable>
        
        <xsl:apply-templates select="table:table-header-rows/table:table-row[1]" mode="mergestyle">
          <xsl:with-param name="rowNumber">
            <xsl:value-of select="$rowNumber"/>
          </xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
    </xsl:choose>
    
  </xsl:template>
  
  <!-- Check if "Merge Cell" exist in row-->
  <xsl:template match="table:table-row" mode="mergestyle">
    <xsl:param name="rowNumber"/>
    
    <xsl:if test="table:table-cell[@table:number-columns-spanned]">   
      
      <xsl:choose>
        <xsl:when test="node()[1][name()='table:covered-table-cell']">          
          <xsl:for-each select="table:covered-table-cell[1]">
            <xsl:call-template name="MergeRowStyle">
              <xsl:with-param name="rowNumber">
                <xsl:value-of select="$rowNumber"/>
              </xsl:with-param>
              <xsl:with-param name="colNumber">1</xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>            
        </xsl:when>          
        <xsl:otherwise>
          <xsl:for-each select="table:table-cell[1]">
            <xsl:call-template name="MergeRowStyle">
              <xsl:with-param name="rowNumber">
                <xsl:value-of select="$rowNumber"/>
              </xsl:with-param>
              <xsl:with-param name="colNumber">1</xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
      
    </xsl:if>
    
    <xsl:choose>
      <!-- next row is a sibling -->
      <xsl:when test="following-sibling::node()[1][name() = 'table:table-row' ]">
        <xsl:apply-templates select="following-sibling::table:table-row[1]" mode="mergestyle">
          <xsl:with-param name="rowNumber">
            <xsl:choose>
              <xsl:when test="following-sibling::table:table-row[1]/@table:number-rows-repeated">
                <xsl:value-of select="$rowNumber + following-sibling::table:table-row[1]/@table:number-rows-repeated"/>    
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$rowNumber + 1"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <!-- next row is inside header rows -->
      <xsl:when test="following-sibling::node()[1][name() = 'table:table-header-rows' ]">
        <xsl:apply-templates select="following-sibling::table:table-header-rows/table:table-row[1]" mode="mergestyle">
          <xsl:with-param name="rowNumber">
            <xsl:choose>
              <xsl:when test="following-sibling::table:table-header-rows/table:table-row[1]/@table:number-rows-repeated">
                <xsl:value-of select="$rowNumber + following-sibling::table:table-header-rows/table:table-row[1]/@table:number-rows-repeated"/>    
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$rowNumber + 1"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <!-- this is last row inside header rows, next row is outside -->
      <xsl:when test="parent::node()[name()='table:table-header-rows'] and not(following-sibling::node()[1][name() = 'table:table-row' ])">
        <xsl:apply-templates select="parent::node()/following-sibling::table:table-row[1]" mode="mergestyle">
          <xsl:with-param name="rowNumber">
            <xsl:choose>
              <xsl:when test="parent::node()/following-sibling::table:table-row[1]/@table:number-rows-repeated">
                <xsl:value-of select="$rowNumber + parent::node()/following-sibling::table:table-row[1]/@table:number-rows-repeated"/>    
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$rowNumber + 1"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <!-- to insert merge cell style -->
  <xsl:template name="MergeRowStyle">
    <xsl:param name="rowNumber"/>
    <xsl:param name="colNumber"/>
    
    
    <!-- Merge Cell-->    
    <xsl:choose>
      <xsl:when test="@table:number-columns-spanned">
        
        <xsl:variable name="CollStartChar">
          <xsl:call-template name="NumbersToChars">
            <xsl:with-param name="num">
              <xsl:value-of select="$colNumber - 1"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="CollEndChar">
          <xsl:call-template name="NumbersToChars">
            <xsl:with-param name="num">
              <xsl:value-of select="@table:number-columns-spanned + $colNumber - 2"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:variable>        
        <xsl:value-of select="concat(concat(concat(concat($CollStartChar,$rowNumber),':'),  @table:style-name), ';')"/>        
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
    
    <!-- Check if next cell exist -->
    
    <xsl:if test="following-sibling::table:table-cell">
      
      <xsl:variable name="ColumnsRepeated">
        <xsl:choose>
          <xsl:when test="@table:number-columns-repeated">
            <xsl:value-of select="$colNumber + @table:number-columns-repeated"/>
          </xsl:when>        
          <xsl:otherwise>
            <xsl:value-of select="$colNumber + 1"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <xsl:choose>
        <xsl:when test="following-sibling::node()[1][name()='table:covered-table-cell']">
          <xsl:for-each select="following-sibling::table:covered-table-cell[1]">
            <xsl:call-template name="MergeRowStyle">
              <xsl:with-param name="rowNumber">
                <xsl:value-of select="$rowNumber"/>
              </xsl:with-param>
              <xsl:with-param name="colNumber">
                <xsl:value-of select="$ColumnsRepeated"/>            
              </xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>    
        </xsl:when>
        
        <xsl:otherwise>
          <xsl:for-each select="following-sibling::table:table-cell[1]">
            <xsl:call-template name="MergeRowStyle">
              <xsl:with-param name="rowNumber">
                <xsl:value-of select="$rowNumber"/>
              </xsl:with-param>
              <xsl:with-param name="colNumber">
                <xsl:value-of select="$ColumnsRepeated"/>            
              </xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>   
      
    </xsl:if>
    
  </xsl:template>
  
  
  
  
  <!-- Variable with Merge Cell -->
  
  <xsl:template name="WriteMergeCell">
    
    <xsl:choose>
      <!-- when the first row is a simple row -->
      <xsl:when test="child::node()[name() != 'table:table-column' and name() != 'table:table-header-columns' ][1][name() = 'table:table-row' ]">
        <xsl:variable name="rowNumber">
          <xsl:choose>
            <xsl:when test="table:table-row[1]/@table:number-rows-repeated">
              <xsl:value-of select="table:table-row[1]/@table:number-rows-repeated"/>
            </xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
          </xsl:choose>  
        </xsl:variable>
        
        <xsl:apply-templates select="table:table-row[1]" mode="merge">
          <xsl:with-param name="rowNumber">
            <xsl:value-of select="$rowNumber"/>
          </xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <!-- when the first row is a header row -->
      <xsl:when test="child::node()[name() != 'table:table-column' and name() != 'table:table-header-columns' ][1][name() = 'table:table-header-rows' ]">
        <xsl:variable name="rowNumber">
          <xsl:choose>
            <xsl:when test="table:table-header-rows/table:table-row[1]/@table:number-rows-repeated">
              <xsl:value-of select="table:table-header-rows/table:table-row[1]/@table:number-rows-repeated"/>
            </xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
          </xsl:choose>  
        </xsl:variable>
        
        <xsl:apply-templates select="table:table-header-rows/table:table-row[1]" mode="merge">
          <xsl:with-param name="rowNumber">
            <xsl:value-of select="$rowNumber"/>
          </xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
    </xsl:choose>
    
  </xsl:template>
  
  <!-- Insert Merge Cells -->
  
  <xsl:template name="InsertMergeCells">
    <xsl:param name="MergeCell"/>
    <xsl:if test="$MergeCell != ''">
    <mergeCells>
      <xsl:attribute name="count">
        <xsl:value-of select="count(table:table-row/table:table-cell[@table:number-columns-spanned])"/>
      </xsl:attribute>
      <xsl:call-template name="InsertMerge">
        <xsl:with-param name="MergeCell">
          <xsl:value-of select="$MergeCell"/>
        </xsl:with-param>
      </xsl:call-template>
    </mergeCells>
    </xsl:if>
  </xsl:template>
  
  <!-- Insert Merge Cell -->
  
  <xsl:template name="InsertMerge">
    <xsl:param name="MergeCell"/>
   
      <mergeCell>      
        <xsl:attribute name="ref">
          <xsl:value-of select="substring-before($MergeCell, ';')"/>
        </xsl:attribute>      
      </mergeCell>
    
    <xsl:if test="substring-after($MergeCell, ';') != ''">
      <xsl:call-template name="InsertMerge">
        <xsl:with-param name="MergeCell">
          <xsl:value-of select="substring-after($MergeCell, ';')"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    
  </xsl:template>
  
  
  <!-- Check if this cell is starting merge cells -->
  <xsl:template name="CheckIfMergeColl">
   <xsl:param name="MergeCell"/>     
    <xsl:param name="colNumber"/>
    <xsl:param name="rowNumber"/>

    <xsl:choose>
      <xsl:when test="$MergeCell != ''">
        
        <xsl:variable name="Merge">
          <xsl:value-of select="concat(';', $MergeCell)"/>
        </xsl:variable>
        
        <xsl:variable name="CollChar">
          <xsl:call-template name="NumbersToChars">
            <xsl:with-param name="num">
              <xsl:value-of select="$colNumber"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="Cell">
          <xsl:value-of select="concat(';', concat(concat($CollChar, $rowNumber), ':'))"/>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="contains($Merge, $Cell)">
            <xsl:text>start</xsl:text>
          </xsl:when>
          <xsl:otherwise>false</xsl:otherwise>
        </xsl:choose>
        
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>false</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  
  <!-- Check if this cell is in merge cells -->
  <xsl:template name="CheckIfInMerge">
    <xsl:param name="MergeCell"/>     
    <xsl:param name="colNumber"/>
    <xsl:param name="rowNumber"/>
    
    <xsl:variable name="ref">
      <xsl:value-of select="substring-before($MergeCell, ';')"/>
    </xsl:variable>
    
    <xsl:variable name="StartMergeCell">
        <xsl:value-of select="substring-before($ref, ':')"/>
    </xsl:variable>
    
    <xsl:variable name="EndMergeCell">
      <xsl:value-of select="substring-after($ref, ':')"/>
    </xsl:variable>
    
    <xsl:variable name="StartColNum">
      <xsl:call-template name="GetColNum">
        <xsl:with-param name="cell">
          <xsl:value-of select="$StartMergeCell"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:variable name="StartRowNum">
      <xsl:call-template name="GetRowNum">
        <xsl:with-param name="cell">
          <xsl:value-of select="$StartMergeCell"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:variable name="EndColNum">
      <xsl:call-template name="GetColNum">
        <xsl:with-param name="cell">
          <xsl:value-of select="$EndMergeCell"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:variable name="EndRowNum">
      <xsl:call-template name="GetRowNum">
        <xsl:with-param name="cell">
          <xsl:value-of select="$EndMergeCell"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
      
      <!-- Checks if this cell is in "Merge Cell" -->
      <xsl:when
        test="($colNumber &gt;= $StartColNum and $EndRowNum &gt;= $colNumber) and ($rowNumber &gt;= $StartRowNum and $EndRowNum &gt;= $rowNumber)">
            <xsl:value-of select="$StartMergeCell"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="substring-after($MergeCell, ';') != ''">
            <xsl:call-template name="CheckIfInMerge">
              <xsl:with-param name="MergeCell">
                <xsl:value-of select="substring-after($MergeCell, ';')"/>
              </xsl:with-param>
              <xsl:with-param name="colNumber">
                <xsl:value-of select="$colNumber"/>
              </xsl:with-param>
              <xsl:with-param name="rowNumber">
                <xsl:value-of select="$rowNumber"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>false</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <!-- Check if "Merge Cell" exist in row-->
  <xsl:template match="table:table-row" mode="merge">
    <xsl:param name="rowNumber"/>

    <xsl:if test="table:table-cell[@table:number-columns-spanned]">   
      
      <xsl:choose>
        <xsl:when test="node()[1][name()='table:covered-table-cell']">          
          <xsl:for-each select="table:covered-table-cell[1]">
            <xsl:call-template name="MergeRow">
              <xsl:with-param name="rowNumber">
                <xsl:value-of select="$rowNumber"/>
              </xsl:with-param>
              <xsl:with-param name="colNumber">1</xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>            
        </xsl:when>          
        <xsl:otherwise>
          <xsl:for-each select="table:table-cell[1]">
            <xsl:call-template name="MergeRow">
              <xsl:with-param name="rowNumber">
                <xsl:value-of select="$rowNumber"/>
              </xsl:with-param>
              <xsl:with-param name="colNumber">1</xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
      
    </xsl:if>
    
    <!-- Check if next row exist -->
    <xsl:choose>
      <!-- next row is a sibling -->
      <xsl:when test="following-sibling::node()[1][name() = 'table:table-row' ]">
        <xsl:apply-templates select="following-sibling::table:table-row[1]" mode="merge">
          <xsl:with-param name="rowNumber">
            <xsl:choose>
              <xsl:when test="following-sibling::table:table-row[1]/@table:number-rows-repeated">
                <xsl:value-of select="$rowNumber + following-sibling::table:table-row[1]/@table:number-rows-repeated"/>    
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$rowNumber + 1"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <!-- next row is inside header rows -->
      <xsl:when test="following-sibling::node()[1][name() = 'table:table-header-rows' ]">
        <xsl:apply-templates select="following-sibling::table:table-header-rows/table:table-row[1]" mode="merge">
          <xsl:with-param name="rowNumber">
            <xsl:choose>
              <xsl:when test="following-sibling::table:table-header-rows/table:table-row[1]/@table:number-rows-repeated">
                <xsl:value-of select="$rowNumber + following-sibling::table:table-header-rows/table:table-row[1]/@table:number-rows-repeated"/>    
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$rowNumber + 1"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <!-- this is last row inside header rows, next row is outside -->
      <xsl:when test="parent::node()[name()='table:table-header-rows'] and not(following-sibling::node()[1][name() = 'table:table-row' ])">
        <xsl:apply-templates select="parent::node()/following-sibling::table:table-row[1]" mode="merge">
          <xsl:with-param name="rowNumber">
            <xsl:choose>
              <xsl:when test="parent::node()/following-sibling::table:table-row[1]/@table:number-rows-repeated">
                <xsl:value-of select="$rowNumber + parent::node()/following-sibling::table:table-row[1]/@table:number-rows-repeated"/>    
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$rowNumber + 1"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
    </xsl:choose>
    
  </xsl:template>
  
  
  <!-- to insert merge cell -->
  <xsl:template name="MergeRow">
    <xsl:param name="rowNumber"/>
    <xsl:param name="colNumber"/>
    
    
    <!-- Merge Cell-->    
    <xsl:choose>
      <xsl:when test="@table:number-columns-spanned">
        
          <xsl:variable name="CollStartChar">
            <xsl:call-template name="NumbersToChars">
              <xsl:with-param name="num">
                <xsl:value-of select="$colNumber - 1"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:variable>
          
          <xsl:variable name="CollEndChar">
            <xsl:call-template name="NumbersToChars">
              <xsl:with-param name="num">
                <xsl:value-of select="@table:number-columns-spanned + $colNumber - 2"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:variable>
         
          <xsl:value-of select="concat(concat(concat(concat($CollStartChar,$rowNumber),':'), concat($CollEndChar, $rowNumber + @table:number-rows-spanned - 1)), ';')"/>
       
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
    
    <!-- Check if next cell exist -->
    
    <xsl:if test="following-sibling::table:table-cell">
      
      <xsl:variable name="ColumnsRepeated">
        <xsl:choose>
          <xsl:when test="@table:number-columns-repeated">
            <xsl:value-of select="$colNumber + @table:number-columns-repeated"/>
          </xsl:when>        
          <xsl:otherwise>
            <xsl:value-of select="$colNumber + 1"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <xsl:choose>
        <xsl:when test="following-sibling::node()[1][name()='table:covered-table-cell']">
          <xsl:for-each select="following-sibling::table:covered-table-cell[1]">
            <xsl:call-template name="MergeRow">
              <xsl:with-param name="rowNumber">
                <xsl:value-of select="$rowNumber"/>
              </xsl:with-param>
              <xsl:with-param name="colNumber">
                <xsl:value-of select="$ColumnsRepeated"/>            
              </xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>    
        </xsl:when>
        
        <xsl:otherwise>
	    <xsl:for-each select="following-sibling::table:table-cell[1]">
            <xsl:call-template name="MergeRow">
              <xsl:with-param name="rowNumber">
                <xsl:value-of select="$rowNumber"/>
              </xsl:with-param>
              <xsl:with-param name="colNumber">
                <xsl:value-of select="$ColumnsRepeated"/>            
              </xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>
		</xsl:otherwise>
      </xsl:choose>   
      
    </xsl:if>
    
  </xsl:template>
  
  
  
</xsl:stylesheet>
