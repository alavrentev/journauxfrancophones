<!-- The Identity Transformation -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all">
  <!-- Whenever you match any node or any attribute -->
  <xsl:template match="node()|@*">
    <!-- Copy the current node -->
    <xsl:copy>
      <!-- Including any attributes it has and any child nodes -->
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:pb">
    <xsl:variable name="n"><xsl:value-of select="@n"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="preceding::tei:pb[1]/@n = $n"/>
      <xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>


