<!-- The Identity Transformation -->
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all">
  
  <xsl:variable name="current-file-name">
    <xsl:analyze-string select="document-uri(.)" regex="^(.*)/([^/]+)\.[^/]+$">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(2)"/>
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:variable>
  
  <xsl:variable name="current-file-directory">
    <xsl:analyze-string select="document-uri(.)" regex="^(.*)/([^/]+)\.[^/]+$">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(1)"/>
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:variable>
  
  <!-- Whenever you match any node or any attribute -->
  <xsl:template match="*|comment()|processing-instruction()|@*">
    <!-- Copy the current node -->
    <xsl:copy>
      <!-- Including any attributes it has and any child nodes -->
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="processing-instruction('xml-model')"></xsl:template>
  <xsl:template match="processing-instruction('xml-stylesheet')"></xsl:template>

  <xsl:variable name="path">
    <xsl:value-of select="concat($current-file-directory,'/volumes/?select=*.xml;recurse=yes;on-error=warning')"
    />
  </xsl:variable>
  
  <xsl:variable name="files" select="collection($path)"/>
  
  
  <xsl:variable name="document" as="element()">
    <teiCorpus xmlns="http://www.tei-c.org/ns/1.0">
      <teiCorpus xmlns="http://www.tei-c.org/ns/1.0" xml:id="davydova-orig">
        <xsl:for-each select="collection($path)">
          <xsl:variable name="source-file-name">
            <xsl:analyze-string select="document-uri(.)" regex="^(.*)/([^/]+)\.[^/]+$">
              <xsl:matching-substring>
                <xsl:value-of select="regex-group(2)"/>
              </xsl:matching-substring>
            </xsl:analyze-string>
          </xsl:variable>
          <xsl:if test="matches($source-file-name,'davydova_219')">
            <xsl:text>&#xa;</xsl:text>
            <TEI xmlns="http://www.tei-c.org/ns/1.0" xml:id="{$source-file-name}">
              <xsl:for-each select="tei:TEI/child::node()">
                <xsl:copy-of select="."></xsl:copy-of>
              </xsl:for-each>
            </TEI>
            <!--<xsl:copy-of select="."></xsl:copy-of>-->
          </xsl:if>
        </xsl:for-each>
      </teiCorpus>
      <teiCorpus xmlns="http://www.tei-c.org/ns/1.0" xml:id="davydova-copy">
        <xsl:for-each select="collection($path)">
          <xsl:if test="matches(document-uri(.),'davydova_601')">
            <xsl:variable name="source-file-name">
              <xsl:analyze-string select="document-uri(.)" regex="^(.*)/([^/]+)\.[^/]+$">
                <xsl:matching-substring>
                  <xsl:value-of select="regex-group(2)"/>
                </xsl:matching-substring>
              </xsl:analyze-string>
            </xsl:variable>
            <xsl:text>&#xa;</xsl:text>
            <TEI xmlns="http://www.tei-c.org/ns/1.0" xml:id="{$source-file-name}">
              <xsl:for-each select="tei:TEI/child::node()">
                <xsl:copy-of select="."></xsl:copy-of>
              </xsl:for-each>
            </TEI>
            
<!--            <xsl:copy-of select="."></xsl:copy-of>-->
          </xsl:if>
        </xsl:for-each>
      </teiCorpus>
    </teiCorpus>
  </xsl:variable>

  <xsl:template match="/">
<!--    <xsl:copy-of select="$document"/>-->
    <warning message="contenu transféré dans les documents générés"/>
    <xsl:for-each-group select="$document//tei:teiCorpus[@xml:id='davydova-orig']//tei:body/tei:div/tei:div/tei:div" group-by="replace(normalize-space(tei:head),'\s*\{(\d\d\d\d)-.+','$1')">
      <xsl:variable name="main-title">
        <xsl:value-of select="ancestor::tei:TEI/@xml:id"/>
      </xsl:variable>
      <!--<xsl:value-of select="$main-title"/>-->
      <xsl:text>&#xa;</xsl:text>
      <xsl:call-template name="year-file">
        <xsl:with-param name="main-title"><xsl:value-of select="$main-title"/></xsl:with-param>
      </xsl:call-template>
    </xsl:for-each-group>
      <xsl:for-each-group select="$document//tei:teiCorpus[@xml:id='davydova-copy']//tei:body/tei:div/tei:div/tei:div" group-by="replace(normalize-space(tei:head),'\s*\{(\d\d\d\d)-.+','$1')">
        <xsl:variable name="main-title">
          <!--<xsl:value-of select="ancestor::tei:div/tei:head[matches(.,'Единица хранения')]"/>-->
            <xsl:value-of select="ancestor::tei:TEI/@xml:id"/>
        </xsl:variable>
        <!--<xsl:value-of select="$main-title"/>-->
        <xsl:text>&#xa;</xsl:text>
        <xsl:call-template name="year-file">
          <xsl:with-param name="main-title"><xsl:value-of select="$main-title"/></xsl:with-param>
        </xsl:call-template>
      </xsl:for-each-group>
    <!--</warning>-->
  </xsl:template>
  
  <xsl:template name="year-file">
    <xsl:param name="main-title"></xsl:param>
    <xsl:variable name="current-year"><xsl:value-of select="replace(normalize-space(tei:head),'\s*\{(\d\d\d\d)-\d\d.+','$1')"/></xsl:variable>
    <xsl:variable name="lang">
      <xsl:choose>
        <xsl:when test="matches($main-title,'-ru')">ru</xsl:when>
        <xsl:otherwise>fr</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="version">
      <xsl:choose>
        <xsl:when test="matches($main-title,'601')">cp</xsl:when>
        <xsl:when test="matches($main-title,'219')">or</xsl:when>
        <xsl:otherwise><xsl:value-of select="normalize-space($main-title)"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="matches($current-year,'^\d\d\d\d$')">
        <xsl:result-document href="{$current-file-directory}/../davydova_{$version}_{$current-year}-{$lang}.xml">
          <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:comment><xsl:value-of select="$main-title"/></xsl:comment>
            <teiHeader xmlns="http://www.tei-c.org/ns/1.0">
              <fileDesc xmlns="http://www.tei-c.org/ns/1.0">
                <titleStmt xmlns="http://www.tei-c.org/ns/1.0">
                  <title type="main" xmlns="http://www.tei-c.org/ns/1.0">Journal</title>
                  <!--<title type="volume" xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="normalize-space(ancestor::tei:div[2]/tei:head)"/></title>-->
                  <title type="mois"><xsl:value-of select="$current-year"/></title>
                  <author>Olga Orlova-Davydova</author>
                </titleStmt>
                <editionStmt xmlns="http://www.tei-c.org/ns/1.0">
                  <ab xmlns="http://www.tei-c.org/ns/1.0"></ab>
                </editionStmt>
                <publicationStmt xmlns="http://www.tei-c.org/ns/1.0">
                  <publisher xmlns="http://www.tei-c.org/ns/1.0">Unpublished</publisher>
                  <availability xmlns="http://www.tei-c.org/ns/1.0" status="restricted"><licence>CC-BY-NC-SA</licence></availability>
                </publicationStmt>
                <sourceDesc xmlns="http://www.tei-c.org/ns/1.0"><ab xmlns="http://www.tei-c.org/ns/1.0"></ab></sourceDesc>
              </fileDesc>
              <profileDesc xmlns="http://www.tei-c.org/ns/1.0">
                <creation xmlns="http://www.tei-c.org/ns/1.0"/>
                <langUsage xmlns="http://www.tei-c.org/ns/1.0">
                  <language xmlns="http://www.tei-c.org/ns/1.0" ident=""/>
                </langUsage>
              </profileDesc>
            </teiHeader>
            <text xmlns="http://www.tei-c.org/ns/1.0" annee="{$current-year}">
              <xsl:if test="preceding::text()[matches(.,'&lt;\s*([^&gt;|\s]*)\|?([^&gt;\s]*)\s*&gt;')]">
                <pb xmlns="http://www.tei-c.org/ns/1.0">
                  <xsl:attribute name="n">
                    <xsl:analyze-string select="preceding::text()[matches(.,'&lt;\s*([^&gt;|\s]*)\|?([^&gt;\s]*)\s*&gt;')][1]" regex="&lt;\s*([^&gt;|\s]*)\|?([^&gt;\s]*)\s*&gt;">
                      <xsl:matching-substring>
                        <xsl:choose>
                          <xsl:when test="matches(regex-group(1),'\S+') and matches(regex-group(2),'\S+')">
                            <xsl:attribute name="n"><xsl:value-of select="concat(regex-group(1),' [',regex-group(2),']')"/></xsl:attribute>
                          </xsl:when>
                          <xsl:when test="matches(regex-group(1),'\S+') and matches(regex-group(2),'^$')">
                            <xsl:attribute name="n"><xsl:value-of select="regex-group(1)"/></xsl:attribute>
                          </xsl:when>
                          <xsl:when test="matches(regex-group(1),'^$') and matches(regex-group(2),'\S+')">
                            <xsl:attribute name="n"><xsl:value-of select="concat('[',regex-group(2),']')"/></xsl:attribute>
                          </xsl:when>
                        </xsl:choose>
                      </xsl:matching-substring>
                    </xsl:analyze-string>
                  </xsl:attribute>
                </pb>
              </xsl:if>
              <body xmlns="http://www.tei-c.org/ns/1.0">
                <div xmlns="http://www.tei-c.org/ns/1.0" n="{$current-year}">
                  
                  <xsl:apply-templates select="current-group()">
                    <xsl:sort select="normalize-space(tei:head)"/>
                  </xsl:apply-templates>
                  
                </div>
                
              </body>
            </text>
          </TEI>
        </xsl:result-document>
      </xsl:when>
      <xsl:otherwise>
        <error>
          <head>Division non reconnue <xsl:value-of select="replace(ancestor::tei:div[2]/tei:head,'^.*(601-[1-5]).*$','$1')"/>:</head>
          <xsl:copy-of select="."/>
        </error></xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  
<xsl:template match="tei:div/tei:div/tei:div">
  <xsl:variable name="volume">
    
  </xsl:variable>
  <xsl:copy>
    <xsl:apply-templates select="@*"/>
    <xsl:attribute name="n">
      <xsl:value-of select="replace(ancestor::tei:div[2]/tei:head,'^.*(601-[1-5]).*$','$1')"/>
    </xsl:attribute>
    <div xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:attribute name="order"><xsl:number count="tei:div[ancestor::tei:div[2]]" level="any"/></xsl:attribute>
      <xsl:apply-templates/>
    </div>
  </xsl:copy>
</xsl:template>
    
  
  
  
</xsl:stylesheet>
