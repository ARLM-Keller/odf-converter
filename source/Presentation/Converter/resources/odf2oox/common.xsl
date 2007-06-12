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
  xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" 
  xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
  xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
  xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
  xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
  exclude-result-prefixes="style draw fo text">
  <xsl:import href ="BulletsNumbering.xsl"/>
	<xsl:template name ="convertToPoints">
		<xsl:param name ="unit"/>
		<xsl:param name ="length"/>
		<xsl:variable name="lengthVal">
			<xsl:choose>
				<xsl:when test="contains($length,'cm')">
					<xsl:value-of select="substring-before($length,'cm')"/>
				</xsl:when>
				<xsl:when test="contains($length,'pt')">
					<xsl:value-of select="substring-before($length,'pt')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$length"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$lengthVal='0' or $lengthVal='' or ( ($lengthVal &lt; 0) and ($unit != 'cm')) ">
				<xsl:value-of select="0"/>
			</xsl:when>
			<xsl:when test="$unit = 'cm'">
				<xsl:value-of select="concat(format-number($lengthVal * 360000,'#'),'')"/>
			</xsl:when>
			<xsl:when test="$unit = 'mm'">
				<xsl:value-of select="concat(format-number($lengthVal * 25.4 div 72,'#.###'),'mm')"/>
			</xsl:when>
			<xsl:when test="$unit = 'in'">
				<xsl:value-of select="concat(format-number($lengthVal div 72,'#.###'),'in')"/>
			</xsl:when>
			<xsl:when test="$unit = 'pt'">
				<xsl:value-of select="concat(format-number($lengthVal,'#') * 100 ,'')"/>
        <!--Added by lohith - format-number($lengthVal,'#') to make sure that pt will be a int not a real value-->
			</xsl:when>
			<xsl:when test="$unit = 'pica'">
				<xsl:value-of select="concat(format-number($lengthVal div 12,'#.###'),'pica')"/>
			</xsl:when>
			<xsl:when test="$unit = 'dpt'">
				<xsl:value-of select="concat($lengthVal,'dpt')"/>
			</xsl:when>
			<xsl:when test="$unit = 'px'">
				<xsl:value-of select="concat(format-number($lengthVal * 96.19 div 72,'#.###'),'px')"/>
			</xsl:when>
			<xsl:when test="not($lengthVal)">
				<xsl:value-of select="concat(0,'cm')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$lengthVal"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template >
	<xsl:template name ="fontStyles">
		<xsl:param name ="Tid"/>
		<xsl:param name ="prClassName"/>
		<xsl:for-each  select ="document('content.xml')/office:document-content/office:automatic-styles/style:style[@style:name =$Tid ]">
      <!-- Added by lohith :substring-before(style:text-properties/@fo:font-size,'pt')&gt; 0  because sz(font size) shouldnt be zero - 16filesbug-->
      <xsl:if test="style:text-properties/@fo:font-size and substring-before(style:text-properties/@fo:font-size,'pt')&gt; 0 ">
				<xsl:attribute name ="sz">
					<xsl:call-template name ="convertToPoints">
						<xsl:with-param name ="unit" select ="'pt'"/>
						<xsl:with-param name ="length" select ="style:text-properties/@fo:font-size"/>
					</xsl:call-template>
				</xsl:attribute>
			</xsl:if>
      <xsl:if test ="not(style:text-properties/@fo:font-size)">
        <xsl:variable name="GetDefaultFontSizeForShape">
          <xsl:call-template name ="getDefaultFontSize">
            <xsl:with-param name ="className" select ="$prClassName"/>
          </xsl:call-template >
        </xsl:variable>
		<xsl:if test ="substring-before($GetDefaultFontSizeForShape, 'pt') > 0">
			<xsl:attribute name ="sz">
			  <xsl:call-template name ="convertToPoints">
				<xsl:with-param name ="unit" select ="'pt'"/>
				<xsl:with-param name ="length" select ="$GetDefaultFontSizeForShape"/>
			  </xsl:call-template>
			</xsl:attribute>
		 </xsl:if>
      </xsl:if>
			<!--Font bold attribute -->
			<xsl:if test="style:text-properties/@fo:font-weight[contains(.,'bold')]">
				<xsl:attribute name ="b">
					<xsl:value-of select ="'1'"/>
				</xsl:attribute >
			</xsl:if >
			<!-- Font Inclined-->
			<xsl:if test="style:text-properties/@fo:font-style[contains(.,'italic')]">
				<xsl:attribute name ="i">
					<xsl:value-of select ="'1'"/>
				</xsl:attribute >
			</xsl:if >
			<!-- Font underline-->
			
			<xsl:choose >
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'solid')] and
								style:text-properties/@style:text-underline-type[contains(.,'double')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'dbl'"/>						
					</xsl:attribute >
				</xsl:when>
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'solid')] and
								style:text-properties/@style:text-underline-width[contains(.,'bold')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'heavy'"/>
					</xsl:attribute >
				</xsl:when>
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'solid')] and
							style:text-properties/@style:text-underline-width[contains(.,'auto')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'sng'"/>
					</xsl:attribute >
				</xsl:when>
				<!-- Dotted lean and dotted bold under line -->
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'dotted')] and
								style:text-properties/@style:text-underline-width[contains(.,'auto')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'dotted'"/>
					</xsl:attribute >
				</xsl:when>
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'dotted')] and
								style:text-properties/@style:text-underline-width[contains(.,'bold')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'dottedHeavy'"/>
					</xsl:attribute >
				</xsl:when>
				<!-- Dash lean and dash bold underline -->
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'dash')] and
								style:text-properties/@style:text-underline-width[contains(.,'auto')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'dash'"/>
					</xsl:attribute >
				</xsl:when>
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'dash')] and
								style:text-properties/@style:text-underline-width[contains(.,'bold')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'dashHeavy'"/>
					</xsl:attribute >
				</xsl:when>
				<!-- Dash long and dash long bold -->
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'long-dash')] and
								style:text-properties/@style:text-underline-width[contains(.,'auto')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'dashLong'"/>
					</xsl:attribute >
				</xsl:when>
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'long-dash')] and
								style:text-properties/@style:text-underline-width[contains(.,'bold')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'dashLongHeavy'"/>
					</xsl:attribute >
				</xsl:when>

				<!-- dot Dash and dot dash bold -->
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'dot-dash')] and
								style:text-properties/@style:text-underline-width[contains(.,'auto')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'dotDashLong'"/>
					</xsl:attribute >
				</xsl:when>
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'dot-dash')] and
								style:text-properties/@style:text-underline-width[contains(.,'bold')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'dotDashHeavy'"/>
					</xsl:attribute >
				</xsl:when>
				<!-- dot-dot-dash-->
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'dot-dot-dash')] and
								style:text-properties/@style:text-underline-width[contains(.,'auto')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'dotDotDash'"/>
					</xsl:attribute >
				</xsl:when>
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'dot-dot-dash')] and
								style:text-properties/@style:text-underline-width[contains(.,'bold')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'dotDotDashHeavy'"/>
					</xsl:attribute >
				</xsl:when>
				<!-- double Wavy -->
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'wave')] and
								style:text-properties/@style:text-underline-type[contains(.,'double')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'wavyDbl'"/>
					</xsl:attribute >
				</xsl:when>
				<!-- Wavy and Wavy Heavy-->
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'wave')] and
								style:text-properties/@style:text-underline-width[contains(.,'auto')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'wavy'"/>
					</xsl:attribute >
				</xsl:when>
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'wave')] and
								style:text-properties/@style:text-underline-width[contains(.,'bold')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'wavyHeavy'"/>
					</xsl:attribute >
				</xsl:when>
				<xsl:otherwise >
					<xsl:call-template name ="getUnderlineFromStyles">
						<xsl:with-param name ="className" select ="$prClassName"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>			
			<!-- Font Strike through Start-->
			<xsl:choose >
				<xsl:when  test="style:text-properties/@style:text-line-through-type[contains(.,'solid')]">
					<xsl:attribute name ="strike">
						<xsl:value-of select ="'sngStrike'"/>
					</xsl:attribute >
				</xsl:when >
				<xsl:when test="style:text-properties/@style:text-line-through-type[contains(.,'double')]">
					<xsl:attribute name ="strike">
						<xsl:value-of select ="'dblStrike'"/>
					</xsl:attribute >
				</xsl:when >
				<!-- style:text-line-through-style-->
				<xsl:when test="style:text-properties/@style:text-line-through-style[contains(.,'solid')]">
					<xsl:attribute name ="strike">
						<xsl:value-of select ="'sngStrike'"/>
					</xsl:attribute >
				</xsl:when>				
			</xsl:choose>
			<!-- Font Strike through end-->			
			<!--Charector spacing -->
      <!-- Modfied by lohith - @fo:letter-spacing will have a text value 'normal' when no change is required -->
			<xsl:if test ="style:text-properties/@fo:letter-spacing [contains(.,'cm')]">
				<!-- Modfied by lohith - "spc" should be a int value, '#.##'has been replaced by '#'   -->
				<xsl:attribute name ="spc">
					<xsl:if test ="substring-before(style:text-properties/@fo:letter-spacing,'cm')&lt; 0 ">
						<!--<xsl:value-of select ="format-number(substring-before(style:text-properties/@fo:letter-spacing,'cm') * 3.5 *1000 ,'#')"/>-->
						<xsl:value-of select ="format-number(substring-before(style:text-properties/@fo:letter-spacing,'cm') * 7200 div 2.54 ,'#')"/>
					</xsl:if >
					<xsl:if test ="substring-before(style:text-properties/@fo:letter-spacing,'cm')
								&gt; 0 or substring-before(style:text-properties/@fo:letter-spacing,'cm') = 0 ">
						<!--<xsl:value-of select ="format-number((substring-before(style:text-properties/@fo:letter-spacing,'cm') div .035) *100 ,'#')"/>-->
						<xsl:value-of select ="format-number((substring-before(style:text-properties/@fo:letter-spacing,'cm') * 72 div 2.54) *100 ,'#')"/>
					</xsl:if>
				</xsl:attribute>
			</xsl:if >
			<!--Color Node set as standard colors -->
			<xsl:variable name="lcletters">abcdefghijklmnopqrstuvwxyz</xsl:variable>
			<xsl:variable name="ucletters">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
			<xsl:if test ="style:text-properties/@fo:color">
				<a:solidFill>
					<a:srgbClr  >
						<xsl:attribute name ="val">
							<!--<xsl:value-of   select ="substring-after(style:text-properties/@fo:color,'#')"/>-->
							<xsl:value-of select ="translate(substring-after(style:text-properties/@fo:color,'#'),$lcletters,$ucletters)"/>
						</xsl:attribute>
					</a:srgbClr >
				</a:solidFill>
			</xsl:if>

			<!-- Text Shadow fix -->
			<xsl:if test ="style:text-properties/@fo:text-shadow">
				<a:effectLst>
					<a:outerShdw blurRad="38100" dist="38100" dir="2700000" >
						<a:srgbClr val="000000">
							<a:alpha val="43137" />
						</a:srgbClr>
					</a:outerShdw>
				</a:effectLst>
			</xsl:if>

			<xsl:if test ="style:text-properties/@fo:font-family">
				<a:latin charset="0" >
					<xsl:attribute name ="typeface" >
						<!-- fo:font-family-->						
						<xsl:value-of select ="translate(style:text-properties/@fo:font-family, &quot;'&quot;,'')" />
					</xsl:attribute>
				</a:latin >
			</xsl:if>
			<xsl:if test ="not(style:text-properties/@fo:font-family)">
				<a:latin charset="0" >
					<xsl:attribute name ="typeface" >
						<xsl:call-template name ="getDefaultFonaName">
							<xsl:with-param name ="className" select ="$prClassName"/>
						</xsl:call-template >
					</xsl:attribute >
				</a:latin >
			</xsl:if>
			<!-- Underline color -->
			<xsl:if test ="style:text-properties/style:text-underline-color">
				<a:uFill>
					<a:solidFill>
						<a:srgbClr>
							<xsl:attribute name ="val">
								<xsl:value-of select ="substring-after(style:text-properties/style:text-underline-color,'#')"/>
							</xsl:attribute>
						</a:srgbClr>
					</a:solidFill>
				</a:uFill>
			</xsl:if>			
		</xsl:for-each >
	</xsl:template>
	<xsl:template name ="paraProperties" >
    <!--- Code inserted by Vijayeta for Bullets and numbering,For bullet properties-->
		<xsl:param name ="paraId" />
    <xsl:param name ="listId"/>
    <xsl:param name ="isBulleted" />
    <xsl:param name ="level"/>
   
		<xsl:for-each select ="document('content.xml')//style:style[@style:name=$paraId]">
			<a:pPr>
        <!-- Code inserted by Vijayeta for Bullets and numbering,For bullet properties-->
        <xsl:if test ="not($level='0')">
          <xsl:attribute name ="lvl">
            <xsl:value-of select ="$level"/>
          </xsl:attribute>
        </xsl:if>         
       
				<!--marL="first line indent property"-->
				<xsl:if test ="style:paragraph-properties/@fo:text-indent 
							and substring-before(style:paragraph-properties/@fo:text-indent,'cm') &gt; 0">
					<xsl:attribute name ="indent">
						<!--fo:text-indent-->
						<xsl:call-template name ="convertToPoints">
							<xsl:with-param name="length"  select ="style:paragraph-properties/@fo:text-indent"/>
							<xsl:with-param name ="unit" select ="'cm'"/>
						</xsl:call-template>
					</xsl:attribute>
				</xsl:if >
				<xsl:if test ="style:paragraph-properties/@fo:text-align">
					<xsl:attribute name ="algn">
						<!--fo:text-align-->
						<xsl:choose >
							<xsl:when test ="style:paragraph-properties/@fo:text-align='center'">
								<xsl:value-of select ="'ctr'"/>
							</xsl:when>
							<xsl:when test ="style:paragraph-properties/@fo:text-align='end'">
								<xsl:value-of select ="'r'"/>
							</xsl:when>
							<xsl:otherwise >
								<xsl:value-of select ="'l'"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</xsl:if >
				<xsl:if test ="style:paragraph-properties/@fo:margin-left and 
							   substring-before(style:paragraph-properties/@fo:margin-left,'cm') &gt; 0">
					<xsl:attribute name ="marL">
						<!--fo:margin-left-->
						<xsl:call-template name ="convertToPoints">
							<xsl:with-param name="length"  select ="style:paragraph-properties/@fo:margin-left"/>
							<xsl:with-param name ="unit" select ="'cm'"/>
						</xsl:call-template>
					</xsl:attribute>
				</xsl:if >				
        
        <!--Code inserted by Vijayeta For Line Spacing,
            If the line spacing is in terms of Percentage, multiply the value with 1000-->
				<xsl:if test ="style:paragraph-properties/@fo:line-height and 
					substring-before(style:paragraph-properties/@fo:line-height,'%') &gt; 0 and 
					not(substring-before(style:paragraph-properties/@fo:line-height,'%') = 100)">
					<a:lnSpc>
						<a:spcPct>
							<xsl:attribute name ="val">
								<xsl:value-of select ="format-number(substring-before(style:paragraph-properties/@fo:line-height,'%')* 1000,'#.##') "/>
							</xsl:attribute>
						</a:spcPct>
					</a:lnSpc>
				</xsl:if>
				<!--If the line spacing is in terms of Points,multiply the value with 2835-->
				<xsl:if test ="style:paragraph-properties/@style:line-spacing and 
					substring-before(style:paragraph-properties/@style:line-spacing,'cm') &gt; 0">
					<a:lnSpc>
						<a:spcPts>
							<xsl:attribute name ="val">
								<xsl:value-of select ="round(substring-before(style:paragraph-properties/@style:line-spacing,'cm')* 2835) "/>
							</xsl:attribute>
						</a:spcPts>
					</a:lnSpc>
				</xsl:if>
				<xsl:if test ="style:paragraph-properties/@style:line-height-at-least and 
					substring-before(style:paragraph-properties/@style:line-height-at-least,'cm') &gt; 0 ">
					<a:lnSpc>
						<a:spcPts>
							<xsl:attribute name ="val">
								<xsl:value-of select ="round(substring-before(style:paragraph-properties/@style:line-height-at-least,'cm')* 2835) "/>
							</xsl:attribute>
						</a:spcPts>
					</a:lnSpc>
				</xsl:if>
        <!--End of Code inserted by Vijayeta For Line Spacing -->
	    <!-- Code Added by Vijayeta,for Paragraph Spacing, Before and After
             Multiply the value in cm with 2835
			 date: on 01-06-07-->
				<xsl:if test ="style:paragraph-properties/@fo:margin-top and 
						substring-before(style:paragraph-properties/@fo:margin-top,'cm') &gt; 0 ">
					<a:spcBef>
						<a:spcPts>
							<xsl:attribute name ="val">
								<!--fo:margin-top-->
								<xsl:value-of select ="round(substring-before(style:paragraph-properties/@fo:margin-top,'cm')* 2835) "/>
							</xsl:attribute>
						</a:spcPts>
					</a:spcBef >
				</xsl:if>
				<xsl:if test ="style:paragraph-properties/@fo:margin-bottom and 
					    substring-before(style:paragraph-properties/@fo:margin-bottom,'cm') &gt; 0 ">
					<a:spcAft>
						<a:spcPts>
							<xsl:attribute name ="val">
								<!--fo:margin-bottom-->
								<xsl:value-of select ="round(substring-before(style:paragraph-properties/@fo:margin-bottom,'cm')* 2835) "/>
							</xsl:attribute>
						</a:spcPts>
					</a:spcAft>
				</xsl:if >
				<!-- Code Added by Vijayeta,for Paragraph Spacing, Before and After-->
        <xsl:if test ="isBulleted='false'">
				<a:buNone/>
        </xsl:if>
        <xsl:if test ="$isBulleted='true'">
          <xsl:call-template name ="insertBulletsNumbers" >
            <xsl:with-param name ="listId" select ="$listId"/>
            <xsl:with-param name ="level" select ="$level+1"/>
          </xsl:call-template>
        </xsl:if>

        <!--Code Inserted by vijayeta,For Bullets and Numbering,Set Level if present-->
			</a:pPr>
		</xsl:for-each >
	</xsl:template>
	<xsl:template name ="fillColor">
		<xsl:param name ="prId"/>
		<xsl:variable name="lcletters">abcdefghijklmnopqrstuvwxyz</xsl:variable>
		<xsl:variable name="ucletters">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
		<xsl:for-each select ="document('content.xml')/office:document-content/office:automatic-styles/style:style[@style:name=$prId] ">
			<xsl:if test ="style:graphic-properties/@draw:fill-color">
				<a:solidFill>
					<a:srgbClr  >
						<xsl:attribute name ="val">
							<xsl:value-of select ="translate(substring-after(style:graphic-properties/@draw:fill-color,'#'),$lcletters,$ucletters)"/>
						</xsl:attribute>
					</a:srgbClr >
				</a:solidFill>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name ="getClassName">
		<xsl:param name ="clsName"/>
		<xsl:choose >
			<xsl:when test ="$clsName='title'">
				<xsl:value-of select ="'Default-title'"/>
			</xsl:when>
			<xsl:when test ="$clsName='subtitle'">
				<xsl:value-of select ="'Default-subtitle'"/>
			</xsl:when>			
			<xsl:when test ="$clsName='outline'">
				<xsl:value-of select ="'Default-outline1'"/>
			</xsl:when>
			 <xsl:when test="$clsName='standard'">
				<xsl:value-of select ="'standard'"/>
			 </xsl:when>
			 <xsl:otherwise>
				<xsl:value-of select ="$clsName"/>
			 </xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name ="getDefaultFonaName">
		<xsl:param name ="className"/>
		<xsl:variable name ="defaultClsName">
			<xsl:call-template name ="getClassName">
				<xsl:with-param name ="clsName" select="$className"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose >
			<xsl:when test ="document('styles.xml')//style:style[@style:name = $defaultClsName]/style:paragraph-properties/@fo:font-family">
				<xsl:value-of select ="document('styles.xml')//style:style[@style:name = $defaultClsName]/style:paragraph-properties/@fo:font-family"/>
			</xsl:when>
			<xsl:when test ="document('styles.xml')//style:style[@style:name = $defaultClsName]/style:text-properties/@fo:font-family">
				<xsl:value-of select ="document('styles.xml')//style:style[@style:name = $defaultClsName]/style:text-properties/@fo:font-family"/>
			</xsl:when>
			<!-- Added by lohith - to access default Font family-->
			<xsl:when test ="$defaultClsName='standard'">
				<xsl:variable name ="shapeFontName">
					<xsl:value-of select ="document('styles.xml')//style:style[@style:name = $defaultClsName]/style:text-properties/@fo:font-family"/>
				</xsl:variable>
				<xsl:value-of select ="translate($shapeFontName, &quot;'&quot;,'')" />
			</xsl:when>
			<xsl:otherwise >
				<xsl:value-of select ="'Arial'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
  <xsl:template name ="getDefaultFontSize">
    <xsl:param name ="className"/>
    <xsl:variable name ="defaultClsName">
      <xsl:call-template name ="getClassName">
        <xsl:with-param name ="clsName" select="$className"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose >
      <xsl:when test ="document('styles.xml')//style:style[@style:name = $defaultClsName]/style:text-properties/@fo:font-size">
        <xsl:value-of select ="document('styles.xml')//style:style[@style:name = $defaultClsName]/style:text-properties/@fo:font-size" />
      </xsl:when>
	  <xsl:when test ="document('styles.xml')//style:style[@style:name = concat('Standard-',$className)]/style:text-properties/@fo:font-size">
			<xsl:value-of select ="document('styles.xml')//style:style[@style:name = concat('Standard-',$className)]/style:text-properties/@fo:font-size" />
	  </xsl:when>		
		<xsl:when test ="document('styles.xml')//style:style[@style:name = 'Standard-outline1']/style:text-properties/@fo:font-size">
			<xsl:value-of select ="document('styles.xml')//style:style[@style:name = 'Standard-outline1']/style:text-properties/@fo:font-size" />
		</xsl:when>		
      <!-- Added by lohith : sz(font size) shouldnt be zero - 16filesbug-->   
      <xsl:otherwise>
        <xsl:value-of select ="document('styles.xml')//style:style[@style:name = 'standard']/style:text-properties/@fo:font-size" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
	<xsl:template name ="getUnderlineFromStyles" >
		<xsl:param name ="className"/>
		<xsl:variable name ="defaultClsName">
			<xsl:call-template name ="getClassName">
				<xsl:with-param name ="clsName" select="$className"/>
			</xsl:call-template>			
		</xsl:variable>		
		<xsl:for-each select ="document('styles.xml')//style:style[@style:name = $defaultClsName ]">
			<xsl:choose >
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'solid')] and
								style:text-properties/@style:text-underline-type[contains(.,'double')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'dbl'"/>
					</xsl:attribute >
				</xsl:when>
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'solid')] and
							style:text-properties/@style:text-underline-width[contains(.,'auto')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'sng'"/>
					</xsl:attribute >
				</xsl:when>
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'solid')] and
								style:text-properties/@style:text-underline-width[contains(.,'bold')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'heavy'"/>
					</xsl:attribute >
				</xsl:when>
				<!-- Dotted lean and dotted bold under line -->
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'dotted')] and
								style:text-properties/@style:text-underline-width[contains(.,'auto')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'dotted'"/>
					</xsl:attribute >
				</xsl:when>
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'dotted')] and
								style:text-properties/@style:text-underline-width[contains(.,'bold')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'dottedHeavy'"/>
					</xsl:attribute >
				</xsl:when>
				<!-- Dash lean and dash bold underline -->
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'dash')] and
								style:text-properties/@style:text-underline-width[contains(.,'auto')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'dash'"/>
					</xsl:attribute >
				</xsl:when>
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'dash')] and
								style:text-properties/@style:text-underline-width[contains(.,'bold')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'dashHeavy'"/>
					</xsl:attribute >
				</xsl:when>
				<!-- Dash long and dash long bold -->
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'long-dash')] and
								style:text-properties/@style:text-underline-width[contains(.,'auto')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'dashLong'"/>
					</xsl:attribute >
				</xsl:when>
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'long-dash')] and
								style:text-properties/@style:text-underline-width[contains(.,'bold')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'dashLongHeavy'"/>
					</xsl:attribute >
				</xsl:when>
				<!-- dot Dash and dot dash bold -->
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'dot-dash')] and
								style:text-properties/@style:text-underline-width[contains(.,'auto')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'dotDashLong'"/>
					</xsl:attribute >
				</xsl:when>
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'dot-dash')] and
								style:text-properties/@style:text-underline-width[contains(.,'bold')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'dotDashHeavy'"/>
					</xsl:attribute >
				</xsl:when>
				<!-- dot-dot-dash-->
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'dot-dot-dash')] and
								style:text-properties/@style:text-underline-width[contains(.,'auto')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'dotDotDash'"/>
					</xsl:attribute >
				</xsl:when>
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'dot-dot-dash')] and
								style:text-properties/@style:text-underline-width[contains(.,'bold')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'dotDotDashHeavy'"/>
					</xsl:attribute >
				</xsl:when>
				<!-- double Wavy -->
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'wave')] and
								style:text-properties/@style:text-underline-type[contains(.,'double')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'wavyDbl'"/>
					</xsl:attribute >
				</xsl:when>
				<!-- Wavy and Wavy Heavy-->
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'wave')] and
								style:text-properties/@style:text-underline-width[contains(.,'auto')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'wavy'"/>
					</xsl:attribute >
				</xsl:when>
				<xsl:when test="style:text-properties/@style:text-underline-style[contains(.,'wave')] and
								style:text-properties/@style:text-underline-width[contains(.,'bold')]">
					<xsl:attribute name ="u">
						<xsl:value-of select ="'wavyHeavy'"/>
					</xsl:attribute >
				</xsl:when>

			</xsl:choose >
			<!-- Stroke decoration code -->
			<xsl:choose >
				<xsl:when  test="style:text-properties/@style:text-line-through-type[contains(.,'solid')]">
					<xsl:attribute name ="strike">
						<xsl:value-of select ="'sngStrike'"/>
					</xsl:attribute >
				</xsl:when >
				<xsl:when test="style:text-properties/@style:text-line-through-type[contains(.,'double')]">
					<xsl:attribute name ="strike">
						<xsl:value-of select ="'dblStrike'"/>
					</xsl:attribute >
				</xsl:when >
				<!-- style:text-line-through-style-->
				<xsl:when test="style:text-properties/@style:text-line-through-style[contains(.,'solid')]">
					<xsl:attribute name ="strike">
						<xsl:value-of select ="'sngStrike'"/>
					</xsl:attribute >
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
		
	</xsl:template>
	<xsl:template name ="insertTab">
		<xsl:for-each select ="node()">
			<xsl:choose >							
				<xsl:when test ="name()=''">
					<xsl:value-of select ="."/>
				</xsl:when>
				<xsl:when test ="name()='text:tab'">
					<xsl:value-of select ="'&#09;'"/>
				</xsl:when >				
				<xsl:when test ="name()='text:s'">
					<xsl:choose>
						<xsl:when test ="@text:c=1">
							<xsl:value-of  select ="'&#32;'"/>
						</xsl:when>
						<xsl:when test ="@text:c=2">
							<xsl:value-of  select ="'&#32;&#32;'"/>
						</xsl:when>
						<xsl:when test ="@text:c=3">
							<xsl:value-of  select ="'&#32;&#32;&#32;'"/>
						</xsl:when>
						<xsl:when test ="@text:c=4">
							<xsl:value-of  select ="'&#32;&#32;&#32;&#32;'"/>
						</xsl:when>
						<xsl:when test ="@text:c=5">
							<xsl:value-of  select ="'&#32;&#32;&#32;&#32;&#32;'"/>
						</xsl:when>
						<xsl:when test ="@text:c=6">
							<xsl:value-of  select ="'&#32;&#32;&#32;&#32;&#32;&#32;'"/>
						</xsl:when>
						<xsl:when test ="@text:c=7">
							<xsl:value-of  select ="'&#32;&#32;&#32;&#32;&#32;&#32;&#32;'"/>
						</xsl:when>
						<xsl:when test ="@text:c=8">
							<xsl:value-of  select ="'&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;'"/>
						</xsl:when>
						<xsl:when test ="@text:c=9">
							<xsl:value-of  select ="'&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;'"/>
						</xsl:when>
						<xsl:when test ="@text:c=10">
							<xsl:value-of  select ="'&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;'"/>
						</xsl:when>
						<xsl:when test ="@text:c=12">
							<xsl:value-of  select ="'&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;'"/>
						</xsl:when>
						<xsl:when test ="@text:c=13">
							<xsl:value-of  select ="'&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;'"/>
						</xsl:when>
						<xsl:when test ="@text:c=14">
							<xsl:value-of  select ="'&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;'"/>
						</xsl:when>
						<xsl:when test ="@text:c=15">
							<xsl:value-of  select ="'&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;'"/>
						</xsl:when>
						<xsl:when test ="@text:c=16">
							<xsl:value-of  select ="'&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;'"/>
						</xsl:when>
						<xsl:when test ="@text:c=17">
							<xsl:value-of  select ="'&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;'"/>
						</xsl:when>
						<xsl:when test ="@text:c=18">
							<xsl:value-of  select ="'&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;'"/>
						</xsl:when>
						<xsl:when test ="@text:c=19">
							<xsl:value-of  select ="'&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;'"/>
						</xsl:when>
						<xsl:when test ="@text:c=20">
							<xsl:value-of  select ="'&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;'"/>
						</xsl:when>
						<xsl:when test ="@text:c=21">
							<xsl:value-of  select ="'&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;'"/>
						</xsl:when>
						<xsl:otherwise >
							<xsl:value-of  select ="'&#32;'"/>
						</xsl:otherwise>
					</xsl:choose>					
				</xsl:when >
				<xsl:when test =".='' and child::node()">
					<xsl:value-of select ="' '"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select ="."/>
				</xsl:otherwise>
			</xsl:choose> 
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>
