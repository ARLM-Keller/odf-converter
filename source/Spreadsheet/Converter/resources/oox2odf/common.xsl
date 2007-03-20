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
  xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
  xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
  xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
  xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
  xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
  xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  xmlns:e="http://schemas.openxmlformats.org/spreadsheetml/2006/main" exclude-result-prefixes="e r">

  <!-- gets a column number from cell coordinates -->
  <xsl:template name="GetColNum">
    <xsl:param name="cell"/>
    <xsl:param name="columnId"/>

    <xsl:choose>
      <!-- when whole literal column id has been extracted than convert alphabetic index to number -->
      <xsl:when test="number(substring($cell,1,1))">
        <xsl:call-template name="GetAlphabeticPosition">
          <xsl:with-param name="literal" select="$columnId"/>
        </xsl:call-template>
      </xsl:when>
      <!--  recursively extract literal column id (i.e if $cell='GH15' it will return 'GH') -->
      <xsl:otherwise>
        <xsl:call-template name="GetColNum">
          <xsl:with-param name="cell" select="substring-after($cell,substring($cell,1,1))"/>
          <xsl:with-param name="columnId" select="concat($columnId,substring($cell,1,1))"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- gets a row number from cell coordinates -->
  <xsl:template name="GetRowNum">
    <xsl:param name="cell"/>

    <xsl:choose>
      <xsl:when test="number($cell)">
        <xsl:value-of select="$cell"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="GetRowNum">
          <xsl:with-param name="cell" select="substring-after($cell,substring($cell,1,1))"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- translates literal index to number -->
  <xsl:template name="GetAlphabeticPosition">
    <xsl:param name="literal"/>
    <xsl:param name="number" select="0"/>
    <xsl:param name="level" select="0"/>

    <xsl:variable name="lastCharacter">
      <xsl:value-of select="substring($literal,string-length($literal),1)"/>
    </xsl:variable>

    <xsl:variable name="lastCharacterPosition">
      <xsl:call-template name="CharacterToPosition">
        <xsl:with-param name="character" select="$lastCharacter"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="power">
      <xsl:call-template name="Power">
        <xsl:with-param name="base" select="26"/>
        <xsl:with-param name="exponent" select="$level"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="string-length($literal)>1">
        <xsl:call-template name="GetAlphabeticPosition">
          <xsl:with-param name="literal" select="substring($literal,0,string-length($literal))"/>
          <xsl:with-param name="level" select="$level+1"/>
          <xsl:with-param name="number">
            <xsl:value-of select="$lastCharacterPosition*$power + $number"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$lastCharacterPosition*$power + $number"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- returns position in alphabet of a single character-->
  <xsl:template name="CharacterToPosition">
    <xsl:param name="character"/>

    <xsl:choose>
      <xsl:when test="$character='A'">1</xsl:when>
      <xsl:when test="$character='B'">2</xsl:when>
      <xsl:when test="$character='C'">3</xsl:when>
      <xsl:when test="$character='D'">4</xsl:when>
      <xsl:when test="$character='E'">5</xsl:when>
      <xsl:when test="$character='F'">6</xsl:when>
      <xsl:when test="$character='G'">7</xsl:when>
      <xsl:when test="$character='H'">8</xsl:when>
      <xsl:when test="$character='I'">9</xsl:when>
      <xsl:when test="$character='J'">10</xsl:when>
      <xsl:when test="$character='K'">11</xsl:when>
      <xsl:when test="$character='L'">12</xsl:when>
      <xsl:when test="$character='M'">13</xsl:when>
      <xsl:when test="$character='N'">14</xsl:when>
      <xsl:when test="$character='O'">15</xsl:when>
      <xsl:when test="$character='P'">16</xsl:when>
      <xsl:when test="$character='Q'">17</xsl:when>
      <xsl:when test="$character='R'">18</xsl:when>
      <xsl:when test="$character='S'">19</xsl:when>
      <xsl:when test="$character='T'">20</xsl:when>
      <xsl:when test="$character='U'">21</xsl:when>
      <xsl:when test="$character='V'">22</xsl:when>
      <xsl:when test="$character='W'">23</xsl:when>
      <xsl:when test="$character='X'">24</xsl:when>
      <xsl:when test="$character='Y'">25</xsl:when>
      <xsl:when test="$character='Z'">26</xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- calculates power function -->
  <xsl:template name="Power">
    <xsl:param name="base"/>
    <xsl:param name="exponent"/>
    <xsl:param name="value1" select="$base"/>

    <xsl:choose>
      <xsl:when test="$exponent = 0">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$exponent &gt; 1">
            <xsl:call-template name="Power">
              <xsl:with-param name="base">
                <xsl:value-of select="$base"/>
              </xsl:with-param>
              <xsl:with-param name="exponent">
                <xsl:value-of select="$exponent -1"/>
              </xsl:with-param>
              <xsl:with-param name="value1">
                <xsl:value-of select="$value1 * $base"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$value1"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- conversion based on http://support.microsoft.com/kb/29240 -->
  <xsl:template name="RGBtoHLS">
    <xsl:param name="rgb"/>

    <xsl:variable name="HLSMAX" select="255"/>
    <xsl:variable name="RGBMAX" select="255"/>
    <xsl:variable name="UNDEFINED">
      <xsl:value-of select="$HLSMAX * 2 div 3"/>
    </xsl:variable>

    <xsl:variable name="r">
      <xsl:call-template name="HexToDec">
        <xsl:with-param name="number">
          <xsl:value-of select="substring($rgb,1,2)"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="g">
      <xsl:call-template name="HexToDec">
        <xsl:with-param name="number">
          <xsl:value-of select="substring($rgb,3,2)"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="b">
      <xsl:call-template name="HexToDec">
        <xsl:with-param name="number">
          <xsl:value-of select="substring($rgb,5,2)"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="max">
      <xsl:choose>
        <xsl:when test="$r &gt; $g">
          <xsl:choose>
            <xsl:when test="$r &gt; $b">
              <xsl:value-of select="$r"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$b"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$g &gt; $b">
              <xsl:value-of select="$g"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$b"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="min">
      <xsl:choose>
        <xsl:when test="$r &lt; $g">
          <xsl:choose>
            <xsl:when test="$r &lt; $b">
              <xsl:value-of select="$r"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$b"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$g &lt; $b">
              <xsl:value-of select="$g"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$b"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="l">
      <xsl:value-of select="floor(( (($max + $min) * $HLSMAX) + $RGBMAX ) div (2 * $RGBMAX))"/>
    </xsl:variable>

    <xsl:variable name="s">
      <xsl:choose>
        <xsl:when test="$max = $min">
          <xsl:text>0</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="($l &lt; ($HLSMAX div 2)) or ($l = ($HLSMAX div 2))">
              <xsl:value-of
                select="floor(( (($max - $min) * $HLSMAX) + (($max + $min) div 2) ) div ($max + $min))"
              />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of
                select="floor(( (($max - $min) * $HLSMAX) + ((2 * $RGBMAX - $max - $min) div 2) ) div (2 * $RGBMAX - $max - $min))"
              />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="Rdelta">
      <xsl:value-of
        select="( (($max - $r) * ($HLSMAX div 6)) + (($max - $min) div 2) ) div ($max - $min)"/>
    </xsl:variable>
    <xsl:variable name="Gdelta">
      <xsl:value-of
        select="( (($max - $g) * ($HLSMAX div 6)) + (($max - $min) div 2) ) div ($max - $min)"/>
    </xsl:variable>
    <xsl:variable name="Bdelta">
      <xsl:value-of
        select="( (($max - $b) * ($HLSMAX div 6)) + (($max - $min) div 2) ) div ($max - $min)"/>
    </xsl:variable>

    <xsl:variable name="h_part">
      <xsl:choose>
        <xsl:when test="$max = $min">
          <xsl:value-of select="$UNDEFINED"/>
        </xsl:when>
        <xsl:when test="$r = $max">
          <xsl:value-of select="$Bdelta - $Gdelta"/>
        </xsl:when>
        <xsl:when test="$g = $max">
          <xsl:value-of select="($HLSMAX div 3) + $Rdelta - $Bdelta"/>
        </xsl:when>
        <xsl:when test="$b = $max">
          <xsl:value-of select="((2 * $HLSMAX) div 3) + $Gdelta - $Rdelta"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="h">
      <xsl:choose>
        <xsl:when test="$h_part &lt; 0">
          <xsl:value-of select="floor($h_part + $HLSMAX)"/>
        </xsl:when>
        <xsl:when test="$h_part &gt; $HLSMAX">
          <xsl:value-of select="floor($h_part - $HLSMAX)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="floor($h_part)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:value-of select="concat($h,',',$l,',',$s)"/>
  </xsl:template>

  <!-- conversion based on http://support.microsoft.com/kb/29240 -->
  <xsl:template name="HueToRGB">
    <xsl:param name="n1"/>
    <xsl:param name="n2"/>
    <xsl:param name="hue"/>

    <xsl:variable name="HLSMAX" select="255"/>

    <xsl:variable name="h">
      <xsl:choose>
        <xsl:when test="$hue &lt; 0">
          <xsl:value-of select="$hue + $HLSMAX"/>
        </xsl:when>
        <xsl:when test="$hue &gt; $HLSMAX">
          <xsl:value-of select="$hue - $HLSMAX"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$hue"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$h &lt; ($HLSMAX div 6)">
        <xsl:value-of select="$n1 + ((($n2 - $n1) * $h + ($HLSMAX div 12)) div ($HLSMAX div 6))"/>
      </xsl:when>
      <xsl:when test="$h &lt; ($HLSMAX div 2)">
        <xsl:value-of select="$n2"/>
      </xsl:when>
      <xsl:when test="$h &lt; (($HLSMAX * 2) div 3)">
        <xsl:value-of
          select="$n1 + ((($n2 - $n1) * ((($HLSMAX * 2) div 3) - $h) + ($HLSMAX div 12)) div ($HLSMAX div 6))"
        />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$n1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- conversion based on http://support.microsoft.com/kb/29240 -->
  <xsl:template name="HLStoRGB">
    <xsl:param name="hls"/>

    <xsl:variable name="HLSMAX" select="255"/>
    <xsl:variable name="RGBMAX" select="255"/>

    <xsl:variable name="hue">
      <xsl:value-of select="substring-before($hls,',')"/>
    </xsl:variable>
    <xsl:variable name="lum">
      <xsl:value-of select="substring-before(substring-after($hls,','),',')"/>
    </xsl:variable>
    <xsl:variable name="sat">
      <xsl:value-of select="substring-after(substring-after($hls,','),',')"/>
    </xsl:variable>

    <xsl:variable name="magic2">
      <xsl:choose>
        <xsl:when test="$lum &gt; $HLSMAX div 2">
          <xsl:value-of select="$lum + $sat - (($lum * $sat) + ($HLSMAX div 2)) div $HLSMAX"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="($lum * ($HLSMAX + $sat) + ($HLSMAX div 2)) div $HLSMAX"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="magic1">
      <xsl:value-of select="2 * $lum - $magic2"/>
    </xsl:variable>

    <xsl:variable name="red">
      <xsl:choose>
        <xsl:when test="$sat = 0">
          <xsl:value-of select="($lum * $RGBMAX) div $HLSMAX"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="hueR">
            <xsl:call-template name="HueToRGB">
              <xsl:with-param name="n1">
                <xsl:value-of select="$magic1"/>
              </xsl:with-param>
              <xsl:with-param name="n2">
                <xsl:value-of select="$magic2"/>
              </xsl:with-param>
              <xsl:with-param name="hue">
                <xsl:value-of select="$hue + ($HLSMAX div 3)"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:variable>
          <xsl:value-of select="($hueR * $RGBMAX + ($HLSMAX div 2)) div $HLSMAX"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="green">
      <xsl:choose>
        <xsl:when test="$sat = 0">
          <xsl:value-of select="($lum * $RGBMAX) div $HLSMAX"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="hueG">
            <xsl:call-template name="HueToRGB">
              <xsl:with-param name="n1">
                <xsl:value-of select="$magic1"/>
              </xsl:with-param>
              <xsl:with-param name="n2">
                <xsl:value-of select="$magic2"/>
              </xsl:with-param>
              <xsl:with-param name="hue">
                <xsl:value-of select="$hue"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:variable>
          <xsl:value-of select="($hueG * $RGBMAX + ($HLSMAX div 2)) div $HLSMAX"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="blue">
      <xsl:choose>
        <xsl:when test="$sat = 0">
          <xsl:value-of select="($lum * $RGBMAX) div $HLSMAX"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="hueB">
            <xsl:call-template name="HueToRGB">
              <xsl:with-param name="n1">
                <xsl:value-of select="$magic1"/>
              </xsl:with-param>
              <xsl:with-param name="n2">
                <xsl:value-of select="$magic2"/>
              </xsl:with-param>
              <xsl:with-param name="hue">
                <xsl:value-of select="$hue - ($HLSMAX div 3)"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:variable>
          <xsl:value-of select="($hueB * $RGBMAX + ($HLSMAX div 2)) div $HLSMAX"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:value-of select="concat(floor($red),',',floor($green),',',floor($blue))"/>
  </xsl:template>

  <xsl:template name="CalculateTintedColor">
    <xsl:param name="color"/>
    <xsl:param name="tint"/>

    <xsl:variable name="HLSMAX" select="255"/>

    <xsl:variable name="hls">
      <xsl:call-template name="RGBtoHLS">
        <xsl:with-param name="rgb" select="$color"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="hue">
      <xsl:value-of select="substring-before($hls,',')"/>
    </xsl:variable>
    <xsl:variable name="lum">
      <xsl:value-of select="substring-before(substring-after($hls,','),',')"/>
    </xsl:variable>
    <xsl:variable name="sat">
      <xsl:value-of select="substring-after(substring-after($hls,','),',')"/>
    </xsl:variable>

    <xsl:variable name="newLum">
      <xsl:choose>
        <xsl:when test="$tint &lt; 0">
          <xsl:value-of select="floor($lum * (1 + $tint))"/>
        </xsl:when>
        <xsl:when test="$tint > 0">
          <xsl:value-of select="floor($lum * (1 - $tint) + ($HLSMAX - $HLSMAX * (1 - $tint)))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$lum"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="rgb">
      <xsl:call-template name="HLStoRGB">
        <xsl:with-param name="hls">
          <xsl:value-of select="concat($hue,',',$newLum,',',$sat)"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="red">
      <xsl:call-template name="DecToHex">
        <xsl:with-param name="number">
          <xsl:value-of select="substring-before($rgb,',')"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="green">
      <xsl:call-template name="DecToHex">
        <xsl:with-param name="number">
          <xsl:value-of select="substring-before(substring-after($rgb,','),',')"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="blue">
      <xsl:call-template name="DecToHex">
        <xsl:with-param name="number">
          <xsl:value-of select="substring-after(substring-after($rgb,','),',')"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>

    <xsl:value-of select="concat($red,$green,$blue)"/>

  </xsl:template>

  <!-- Convert hex to decimal -->
  <xsl:template name="DecToHex">
    <xsl:param name="number"/>

    <xsl:variable name="high">
      <xsl:call-template name="HexMap">
        <xsl:with-param name="value">
          <xsl:value-of select="floor($number div 16)"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="low">
      <xsl:call-template name="HexMap">
        <xsl:with-param name="value">
          <xsl:value-of select="$number mod 16"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>

    <xsl:value-of select="concat($high,$low)"/>
  </xsl:template>

  <xsl:template name="HexMap">
    <xsl:param name="value"/>
    <xsl:choose>
      <xsl:when test="$value = 10">
        <xsl:text>A</xsl:text>
      </xsl:when>
      <xsl:when test="$value = 11">
        <xsl:text>B</xsl:text>
      </xsl:when>
      <xsl:when test="$value = 12">
        <xsl:text>C</xsl:text>
      </xsl:when>
      <xsl:when test="$value = 13">
        <xsl:text>D</xsl:text>
      </xsl:when>
      <xsl:when test="$value = 14">
        <xsl:text>E</xsl:text>
      </xsl:when>
      <xsl:when test="$value = 15">
        <xsl:text>F</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$value"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="ConvertScientific">
    <xsl:param name="value"/>

    <xsl:variable name="base">
      <xsl:value-of select="substring-before($value,'E')"/>
    </xsl:variable>
    <!-- after E- or E+ -->
    <xsl:variable name="exponent">
      <xsl:value-of select="substring(substring-after($value,'E'),2)"/>
    </xsl:variable>
    <xsl:variable name="sign">
      <xsl:value-of select="substring(substring-after($value,'E'),1,1)"/>
    </xsl:variable>

    <xsl:variable name="factor">
      <xsl:call-template name="Power">
        <xsl:with-param name="base" select="10"/>
        <xsl:with-param name="exponent" select="$exponent"/>
      </xsl:call-template>
    </xsl:variable>

  <xsl:choose>
    <xsl:when test="$sign = '+'">
      <xsl:value-of select="$base * $factor"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$base div $factor"/>
    </xsl:otherwise>
  </xsl:choose>
    
  </xsl:template>
  
  <xsl:template name="GetBuildInColor">
    <xsl:param name="index"/>      
      <xsl:choose>
        <xsl:when test="$index=0"><xsl:text>000000</xsl:text></xsl:when>
        <xsl:when test="$index=1"><xsl:text>FFFFFF</xsl:text></xsl:when>
        <xsl:when test="$index=2"><xsl:text>FF0000</xsl:text></xsl:when>
        <xsl:when test="$index=3"><xsl:text>00FF00</xsl:text></xsl:when>
        <xsl:when test="$index=4"><xsl:text>0000FF</xsl:text></xsl:when>
        <xsl:when test="$index=5"><xsl:text>FFFF00</xsl:text></xsl:when>
        <xsl:when test="$index=6"><xsl:text>FF00FF</xsl:text></xsl:when>
        <xsl:when test="$index=7"><xsl:text>00FFFF</xsl:text></xsl:when>
        <xsl:when test="$index=8"><xsl:text>000000</xsl:text></xsl:when>
        <xsl:when test="$index=9"><xsl:text>FFFFFF</xsl:text></xsl:when>
        <xsl:when test="$index=10"><xsl:text>FF0000</xsl:text></xsl:when>
        <xsl:when test="$index=11"><xsl:text>00FF00</xsl:text></xsl:when>
        <xsl:when test="$index=12"><xsl:text>0000FF</xsl:text></xsl:when>
        <xsl:when test="$index=13"><xsl:text>FFFF00</xsl:text></xsl:when>
        <xsl:when test="$index=14"><xsl:text>FF00FF</xsl:text></xsl:when>
        <xsl:when test="$index=15"><xsl:text>00FFFF</xsl:text></xsl:when>
        <xsl:when test="$index=16"><xsl:text>800000</xsl:text></xsl:when>
        <xsl:when test="$index=17"><xsl:text>008000</xsl:text></xsl:when>
        <xsl:when test="$index=18"><xsl:text>000080</xsl:text></xsl:when>
        <xsl:when test="$index=19"><xsl:text>808000</xsl:text></xsl:when>
        <xsl:when test="$index=20"><xsl:text>800080</xsl:text></xsl:when>
        <xsl:when test="$index=21"><xsl:text>008080</xsl:text></xsl:when>
        <xsl:when test="$index=22"><xsl:text>C0C0C0</xsl:text></xsl:when>
        <xsl:when test="$index=23"><xsl:text>808080</xsl:text></xsl:when>
        <xsl:when test="$index=24"><xsl:text>8080FF</xsl:text></xsl:when>
        <xsl:when test="$index=25"><xsl:text>802060</xsl:text></xsl:when>
        <xsl:when test="$index=26"><xsl:text>FFFFC0</xsl:text></xsl:when>
        <xsl:when test="$index=27"><xsl:text>A0E0E0</xsl:text></xsl:when>
        <xsl:when test="$index=28"><xsl:text>600080</xsl:text></xsl:when>
        <xsl:when test="$index=29"><xsl:text>FF8080</xsl:text></xsl:when>
        <xsl:when test="$index=30"><xsl:text>0080C0</xsl:text></xsl:when>
        <xsl:when test="$index=31"><xsl:text>C0C0FF</xsl:text></xsl:when>
        <xsl:when test="$index=32"><xsl:text>000080</xsl:text></xsl:when>
        <xsl:when test="$index=33"><xsl:text>FF00FF</xsl:text></xsl:when>
        <xsl:when test="$index=34"><xsl:text>FFFF00</xsl:text></xsl:when>
        <xsl:when test="$index=35"><xsl:text>00FFFF</xsl:text></xsl:when>
        <xsl:when test="$index=36"><xsl:text>800080</xsl:text></xsl:when>
        <xsl:when test="$index=37"><xsl:text>800000</xsl:text></xsl:when>
        <xsl:when test="$index=38"><xsl:text>008080</xsl:text></xsl:when>
        <xsl:when test="$index=39"><xsl:text>0000FF</xsl:text></xsl:when>
        <xsl:when test="$index=40"><xsl:text>00CCFF</xsl:text></xsl:when>
        <xsl:when test="$index=41"><xsl:text>69FFFF</xsl:text></xsl:when>
        <xsl:when test="$index=42"><xsl:text>CCFFCC</xsl:text></xsl:when>
        <xsl:when test="$index=43"><xsl:text>FFFF99</xsl:text></xsl:when>
        <xsl:when test="$index=44"><xsl:text>A6CAF0</xsl:text></xsl:when>
        <xsl:when test="$index=45"><xsl:text>CC9CCC</xsl:text></xsl:when>
        <xsl:when test="$index=46"><xsl:text>CC99FF</xsl:text></xsl:when>
        <xsl:when test="$index=47"><xsl:text>E3E3E3</xsl:text></xsl:when>
        <xsl:when test="$index=48"><xsl:text>3366FF</xsl:text></xsl:when>
        <xsl:when test="$index=49"><xsl:text>33CCCC</xsl:text></xsl:when>
        <xsl:when test="$index=50"><xsl:text>339933</xsl:text></xsl:when>
        <xsl:when test="$index=51"><xsl:text>999933</xsl:text></xsl:when>
        <xsl:when test="$index=52"><xsl:text>996633</xsl:text></xsl:when>
        <xsl:when test="$index=53"><xsl:text>996666</xsl:text></xsl:when>
        <xsl:when test="$index=54"><xsl:text>666699</xsl:text></xsl:when>
        <xsl:when test="$index=55"><xsl:text>969696</xsl:text></xsl:when>
        <xsl:when test="$index=56"><xsl:text>3333CC</xsl:text></xsl:when>
        <xsl:when test="$index=57"><xsl:text>336666</xsl:text></xsl:when>
        <xsl:when test="$index=58"><xsl:text>003300</xsl:text></xsl:when>
        <xsl:when test="$index=59"><xsl:text>333300</xsl:text></xsl:when>
        <xsl:when test="$index=60"><xsl:text>663300</xsl:text></xsl:when>
        <xsl:when test="$index=61"><xsl:text>993366</xsl:text></xsl:when>
        <xsl:when test="$index=62"><xsl:text>333399</xsl:text></xsl:when>
        <xsl:when test="$index=63"><xsl:text>424242</xsl:text></xsl:when>
      </xsl:choose>
  </xsl:template>
  
  <xsl:template name="ConvertFromCharacters">
    <xsl:param name="value"/>
    
    <!-- strange but true: the best result is when you WON'T convert average digit width from pt to px-->
    <xsl:variable name="defaultFontSize">
      <xsl:for-each select="document('xl/styles.xml')">
        <xsl:choose>
          <xsl:when test="e:styleSheet/e:fonts/e:font">
            <xsl:value-of select="e:styleSheet/e:fonts/e:font[1]/e:sz/@val"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>11</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>
    
    <!-- for proportional fonts average digit width is 2/3 of font size-->
    <xsl:variable name="avgDigitWidth">
      <xsl:value-of select="round($defaultFontSize * 2 div 3)"/>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="$avgDigitWidth * $value = 0">
        <xsl:text>0cm</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="ConvertToCentimeters">
          <xsl:with-param name="length">
            <xsl:value-of select="concat(($avgDigitWidth * $value),'px')"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>
