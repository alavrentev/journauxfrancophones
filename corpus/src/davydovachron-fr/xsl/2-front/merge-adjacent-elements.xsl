<!-- The Identity Transformation -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0">

<!-- This stylesheets merges selected adjacent elements (without any space). 
    This may be useful to clean-up XML-TEI documents converted from Word or Writer
    Use elements-to-merge and elements-to-merge-by-rend to select the appropriate elements.
    
    (c) 2017 by Alexei Lavrentiev, UMR IHRIM
    
          This stylesheet is free software; you can redistribute it and/or
      modify it under the terms of the GNU Lesser General Public
      License as published by the Free Software Foundation; either
      version 3 of the License, or (at your option) any later version.
      
      This stylesheet is distributed in the hope that it will be useful,
      but WITHOUT ANY WARRANTY; without even the implied warranty of
      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
      Lesser General Public License for more details.
      
      You should have received a copy of GNU Lesser Public License with
      this stylesheet. If not, see http://www.gnu.org/licenses/lgpl.html

  
  -->

  <!-- Whenever you match any node or any attribute -->
  <xsl:template match="node()|@*">
    <!-- Copy the current node -->
    <xsl:copy>
      <!-- Including any attributes it has and any child nodes -->
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:param name="elements-to-merge">persName|placeName|unclear</xsl:param>
  
  <xsl:param name="elements-to-merge-by-rend">hi|seg</xsl:param>
  

  <xsl:template match="*[matches(local-name(),concat('^(',$elements-to-merge,')$'))]">
  <xsl:variable name="element-name"><xsl:value-of select="name()"/></xsl:variable>
  <xsl:choose>
    <xsl:when test="preceding-sibling::node()[1][self::text()][matches(.,'.+')] or not(preceding-sibling::*[1][name()=$element-name])">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates/>
        <xsl:if test="following-sibling::node()[1][name()=$element-name]">
          <xsl:apply-templates select="following-sibling::*[name()=$element-name][1]" mode="merge"/>
        </xsl:if>
      </xsl:copy>
    </xsl:when>
    <xsl:otherwise/>
  </xsl:choose>
</xsl:template>

  <xsl:template match="*[matches(local-name(),concat('^(',$elements-to-merge,')$'))]" mode="merge">
    <xsl:variable name="element-name">
      <xsl:value-of select="name()"/>
    </xsl:variable>
  <xsl:apply-templates/>
  <xsl:if test="following-sibling::node()[1][name()=$element-name]">
    <xsl:apply-templates select="following-sibling::*[name()=$element-name][1]" mode="merge"/>
  </xsl:if>
</xsl:template>


  <xsl:template match="*[matches(local-name(),concat('^(',$elements-to-merge-by-rend,')$'))]">
    <xsl:variable name="element-name"><xsl:value-of select="name()"/></xsl:variable>
    <xsl:variable name="rend">
      <xsl:value-of select="@rend"/>
    </xsl:variable>
    <xsl:variable name="style">
      <xsl:value-of select="@style"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="preceding-sibling::node()[1][self::text()][matches(.,'.+')] or not(preceding-sibling::*[1][name()=$element-name][@rend=$rend])">
        <xsl:copy>
          <xsl:apply-templates select="@*"/>
          <xsl:apply-templates/>
          <xsl:choose>
            <xsl:when test="following-sibling::node()[1][name()=$element-name][@rend=$rend]">
              <xsl:apply-templates select="following-sibling::*[name()=$element-name][1]" mode="merge">
                <xsl:with-param name="rend"><xsl:value-of select="$rend"/></xsl:with-param>
              </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="following-sibling::node()[1][name()=$element-name][@style=$style]">
              <xsl:apply-templates select="following-sibling::*[name()=$element-name][1]" mode="merge">
                <xsl:with-param name="style"><xsl:value-of select="$style"/></xsl:with-param>
              </xsl:apply-templates>
            </xsl:when>
          </xsl:choose>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="*[matches(local-name(),concat('^(',$elements-to-merge-by-rend,')$'))]" mode="merge">
    <xsl:param name="rend"><xsl:value-of select="@rend"/></xsl:param>
    <xsl:param name="style"><xsl:value-of select="@style"/></xsl:param>
    <xsl:variable name="element-name"><xsl:value-of select="name()"/></xsl:variable>
    <xsl:apply-templates/>
    <xsl:choose>
      <xsl:when test="following-sibling::node()[1][name()=$element-name][@rend=$rend]">
        <xsl:apply-templates select="following-sibling::*[name()=$element-name][1]" mode="merge">
          <xsl:with-param name="rend"><xsl:value-of select="$rend"/></xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="following-sibling::node()[1][name()=$element-name][@style=$style]">
        <xsl:apply-templates select="following-sibling::*[name()=$element-name][1]" mode="merge">
          <xsl:with-param name="style"><xsl:value-of select="$style"/></xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
