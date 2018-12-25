<!-- The Identity Transformation -->
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all">
  
  
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
  
  <xsl:template match="tei:teiHeader">
    <xsl:copy xml:space="preserve">
      <fileDesc xmlns="http://www.tei-c.org/ns/1.0">
        <titleStmt xmlns="http://www.tei-c.org/ns/1.0">
          <title type="main" xmlns="http://www.tei-c.org/ns/1.0">Journal</title>
          <title type="volume" xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="/tei:TEI/tei:text/tei:body//tei:head[1][matches(.,'Единица хранения')]"/></title>
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
    </xsl:copy>
  </xsl:template>
  
  <!-- on supprime le titre principal (transféré dans l'entête) -->
  <xsl:template match="tei:body/tei:head"/>
  
  <xsl:template match="tei:div">
    <xsl:choose>
      <xsl:when test="matches(tei:head,'\{[^\}]+\}')">
        <xsl:copy>
          <xsl:attribute name="type">jour</xsl:attribute>
          <xsl:attribute name="n"><xsl:value-of select="normalize-space(translate(tei:head,'{}',''))"/></xsl:attribute>
          <xsl:attribute name="order"><xsl:value-of select="@order"/></xsl:attribute>
          <xsl:apply-templates/>
        </xsl:copy>
        <xsl:if test="matches(child::tei:p[last()],'^\s*&lt;\s*([^&gt;|\s]*)\|?([^&gt;\s]*)\s*&gt;\s*$')">
          <xsl:call-template name="pb"><xsl:with-param name="string"><xsl:value-of select="child::p[last()]"/></xsl:with-param></xsl:call-template>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>
  
  <!-- les dates sont transformées en attributs -->
  <xsl:template match="tei:head[matches(.,'\{[^\}]+\}')]"></xsl:template>

<!-- les titres de niveau 2 sont à tokeniser -->
<xsl:template match="tei:body/tei:div/tei:div/tei:head">
  <ab xmlns="http://www.tei-c.org/ns/1.0" type="h2">
    <xsl:apply-templates/>
  </ab>
</xsl:template>

<xsl:template match="tei:note">
  <xsl:copy>
    <xsl:apply-templates select="@*"/>
    <xsl:choose>
      <xsl:when test="matches(.,'^\s*\[au\]')">
        <xsl:attribute name="type">au</xsl:attribute>
      </xsl:when>
      <xsl:when test="matches(.,'^\s*\[temp\]')">
        <xsl:attribute name="type">temp</xsl:attribute>
      </xsl:when>
      <xsl:when test="matches(.,'^\s*\[tr\]')">
        <xsl:attribute name="type">tr</xsl:attribute>
      </xsl:when>      
    </xsl:choose>
    <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>

<!-- Les paragraphes dans les notes sont supprimés -->

<xsl:template match="tei:note/tei:p">
  <xsl:apply-templates/>
</xsl:template>

  <xsl:template match="tei:p[not(parent::tei:note)]">
    <xsl:choose>
      <xsl:when test="matches(.,'^\s*&lt;\s*([^&gt;|\s]*)\|?([^&gt;\s]*)\s*&gt;\s*$')">
        <xsl:choose>
          <xsl:when test="position()=last()"></xsl:when>
          <xsl:otherwise><xsl:call-template name="pb">
            <xsl:with-param name="string"><xsl:value-of select="normalize-space(.)"/></xsl:with-param>
          </xsl:call-template></xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="@rend='Дата1'">
        <xsl:copy>
          <date xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:if test="matches(preceding-sibling::*[1][self::tei:head],'\{[^\}]+\}')">
              <xsl:attribute name="when"><xsl:value-of select="translate(normalize-space(preceding-sibling::tei:head[1]),'{}+','')"/></xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
          </date>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
        <xsl:text>&#xa;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  
  <xsl:template match="tei:hi|tei:seg">
    <xsl:variable name="preceding-text">
      <xsl:if test="matches(preceding-sibling::node()[1][self::text()],'[A-Za-zÀ-ÿ0-9]+$')">
        <xsl:value-of select="replace(preceding-sibling::text()[1],'^.*[^A-Za-zÀ-ÿ0-9]([A-Za-zÀ-ÿ0-9]+)$','$1')"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="following-text">
      <xsl:if test="matches(following-sibling::node()[1][self::text()],'^[A-Za-zÀ-ÿ]+')">
        <xsl:value-of select="replace(following-sibling::text()[1],'^([A-Za-zÀ-ÿ]+)[^A-Za-zÀ-ÿ].*$','$1')"/>
      </xsl:if>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="@rend='Дата1'">
        <date xmlns="http://www.tei-c.org/ns/1.0"><xsl:apply-templates/></date>
      </xsl:when>
      <xsl:when test="@rend='gap'">
        <gap xmlns="http://www.tei-c.org/ns/1.0"/>
      </xsl:when>
      <xsl:when test="@rend='lang-ru'">
        <foreign xml:lang="ru" xmlns="http://www.tei-c.org/ns/1.0"><xsl:apply-templates/></foreign>
      </xsl:when>
      <xsl:when test="@rend='lang-ru-sic-ortho'">
        <foreign xml:lang="ru" xmlns="http://www.tei-c.org/ns/1.0"><sic ana="#err-ortho" xmlns="http://www.tei-c.org/ns/1.0"><xsl:apply-templates/></sic></foreign>
      </xsl:when>      
      <xsl:when test="@rend='persName-lang-ru'">
        <persName xmlns="http://www.tei-c.org/ns/1.0"><foreign xml:lang="ru" xmlns="http://www.tei-c.org/ns/1.0"><xsl:apply-templates/></foreign></persName>
      </xsl:when>
      <xsl:when test="@rend='persName-lang-ru-sic-ortho'">
        <persName xmlns="http://www.tei-c.org/ns/1.0"><foreign xml:lang="ru" xmlns="http://www.tei-c.org/ns/1.0"><sic ana="#err-ortho" xmlns="http://www.tei-c.org/ns/1.0"><xsl:apply-templates/></sic></foreign></persName>
      </xsl:when>
      <xsl:when test="@rend='persName-sic-ortho'">
        <persName xmlns="http://www.tei-c.org/ns/1.0">
          <sic ana="#err-ortho" xmlns="http://www.tei-c.org/ns/1.0"><xsl:apply-templates/></sic>
        </persName>
      </xsl:when>
      <xsl:when test="@rend='placeName'">
        <placeName xmlns="http://www.tei-c.org/ns/1.0"><xsl:apply-templates/></placeName>
      </xsl:when>
      <xsl:when test="@rend='placeName-lang-ru'">
        <placeName xmlns="http://www.tei-c.org/ns/1.0">
          <foreign xml:lang="ru" xmlns="http://www.tei-c.org/ns/1.0"><xsl:apply-templates/></foreign>
        </placeName>
      </xsl:when>
      <xsl:when test="@rend='placeName-lang-ru-sic-ortho'">
        <placeName xmlns="http://www.tei-c.org/ns/1.0">
          <foreign xml:lang="ru" xmlns="http://www.tei-c.org/ns/1.0">
            <sic ana="#err-ortho" xmlns="http://www.tei-c.org/ns/1.0"><xsl:apply-templates/></sic>
          </foreign>
        </placeName>
      </xsl:when>
      <xsl:when test="@rend='placeName-sic-ortho'">
        <placeName xmlns="http://www.tei-c.org/ns/1.0">
          <sic ana="#err-ortho" xmlns="http://www.tei-c.org/ns/1.0"><xsl:apply-templates/></sic>
        </placeName>
      </xsl:when>
      <xsl:when test="@rend='sic-gramm'">
        <sic ana="#err-gramm" xmlns="http://www.tei-c.org/ns/1.0">
          <w xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:call-template name="add-del">
              <xsl:with-param name="string"><xsl:value-of select="$preceding-text"/></xsl:with-param>
            </xsl:call-template>
            <seg type="err-gramm" xmlns="http://www.tei-c.org/ns/1.0"><xsl:apply-templates/></seg>
            <xsl:call-template name="add-del">
              <xsl:with-param name="string"><xsl:value-of select="$following-text"/></xsl:with-param>
            </xsl:call-template>
          </w>
        </sic>
      </xsl:when>
      <xsl:when test="@rend='sic-lex'">
        <sic ana="#err-lex" xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates/>
        </sic>
      </xsl:when>
      <xsl:when test="@rend='sic-ortho'">
        <sic ana="#err-ortho" xmlns="http://www.tei-c.org/ns/1.0">
          <w xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:call-template name="add-del">
              <xsl:with-param name="string"><xsl:value-of select="$preceding-text"/></xsl:with-param>
            </xsl:call-template>
            <seg type="err-ortho" xmlns="http://www.tei-c.org/ns/1.0"><xsl:apply-templates/></seg>
            <xsl:call-template name="add-del">
              <xsl:with-param name="string"><xsl:value-of select="$following-text"/></xsl:with-param>
            </xsl:call-template>
          </w>
        </sic>
      </xsl:when>
      <xsl:when test="@rend='translit'">
        <foreign xml:lang="ru-translit" xmlns="http://www.tei-c.org/ns/1.0">
          <xsl:apply-templates/>
        </foreign>
      </xsl:when>
      <xsl:when test="@rend='unclear'">
        <unclear xmlns="http://www.tei-c.org/ns/1.0">
          <xsl:apply-templates/>
        </unclear>
      </xsl:when>
      <xsl:when test="matches(@rend,'superscript|exposant') and not(ancestor::tei:head or ancestor::tei:note)">
        <w xmlns="http://www.tei-c.org/ns/1.0">
          <xsl:call-template name="add-del">
              <xsl:with-param name="string"><xsl:value-of select="$preceding-text"/></xsl:with-param>
            </xsl:call-template>
          <xsl:copy>
            <xsl:attribute name="rend">superscript</xsl:attribute>
            <xsl:apply-templates/>
          </xsl:copy>
          <xsl:call-template name="add-del">
              <xsl:with-param name="string"><xsl:value-of select="$following-text"/></xsl:with-param>
            </xsl:call-template>
        </w>
      </xsl:when>
      <xsl:when test="@rend='superscript underline' and not(ancestor::tei:head or ancestor::tei:note)">
        <w xmlns="http://www.tei-c.org/ns/1.0">
          <xsl:call-template name="add-del">
              <xsl:with-param name="string"><xsl:value-of select="$preceding-text"/></xsl:with-param>
            </xsl:call-template>
          <xsl:copy>
            <xsl:attribute name="rend">superscript-underline</xsl:attribute>
            <xsl:apply-templates/>
          </xsl:copy>
          <xsl:call-template name="add-del">
              <xsl:with-param name="string"><xsl:value-of select="$following-text"/></xsl:with-param>
            </xsl:call-template>
        </w>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:add|tei:del">
    <xsl:variable name="preceding-text">
      <xsl:if test="matches(preceding-sibling::node()[1][self::text()],'[A-Za-zÀ-ÿ]+$') and not(matches(preceding-sibling::node()[1][self::text()],'^[A-Za-zÀ-ÿ]+$') and preceding-sibling::node()[2][self::tei:add or self::tei:del])">
        <xsl:value-of select="replace(preceding-sibling::text()[1],'^.*[^A-Za-zÀ-ÿ]([A-Za-zÀ-ÿ]+)$','$1')"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="following-text">
      <xsl:if test="matches(following-sibling::node()[1][self::text()],'^[A-Za-zÀ-ÿ]+')">
        <xsl:value-of select="replace(following-sibling::text()[1],'^([A-Za-zÀ-ÿ]+)[^A-Za-zÀ-ÿ].*$','$1')"/>
      </xsl:if>
    </xsl:variable>
    <w xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:call-template name="add-del">
              <xsl:with-param name="string"><xsl:value-of select="$preceding-text"/></xsl:with-param>
            </xsl:call-template>
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates/>
      </xsl:copy>
      <xsl:call-template name="add-del">
              <xsl:with-param name="string"><xsl:value-of select="$following-text"/></xsl:with-param>
            </xsl:call-template>
    </w>
  </xsl:template>


<xsl:template match="text()">
  <xsl:variable name="preceding-tag">
    <xsl:choose>
      <xsl:when test="preceding-sibling::node()[1][self::tei:hi or self::tei:add or self::tei:del]">y</xsl:when>
      <xsl:otherwise>n</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="following-tag">
    <xsl:choose>
      <xsl:when test="following-sibling::node()[1][self::tei:hi or self::tei:add or self::tei:del]">y</xsl:when>
      <xsl:otherwise>n</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="ancestor::tei:note">
      <xsl:value-of select="replace(.,'^\s*\[(au|temp|tr)\]\s*','')"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:analyze-string select="." regex="^([A-Za-zÀ-ÿ]*)(.*[^A-Za-zÀ-ÿ])([A-Za-zÀ-ÿ]*)$">
        <xsl:matching-substring>
<!--          <xsl:choose>
            <xsl:when test="$preceding-tag='y' and matches(regex-group(1),'\S')">
              <!-\-<xsl:comment>Déplacé dans la balise précédente : <xsl:value-of select="regex-group(1)"/></xsl:comment>-\->
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="add-del"><xsl:with-param name="string"><xsl:value-of select="regex-group(1)"/></xsl:with-param></xsl:call-template>
              <!-\-<xsl:text>AAA</xsl:text>-\->              
            </xsl:otherwise>
          </xsl:choose>
          <xsl:call-template name="add-del"><xsl:with-param name="string"><xsl:value-of select="regex-group(2)"/></xsl:with-param></xsl:call-template>
          <!-\-<xsl:call-template name="pb"><xsl:with-param name="string"><xsl:value-of select="regex-group(2)"/></xsl:with-param></xsl:call-template>-\->
          <!-\-<w>[<xsl:value-of select="regex-group(2)"/>]</w>-\->
          <xsl:choose>
            <xsl:when test="$following-tag='y' and matches(regex-group(3),'\S')">
              <!-\-<xsl:comment>Déplacé dans la balise suivante : <xsl:value-of select="regex-group(3)"/></xsl:comment>-\->
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="add-del"><xsl:with-param name="string"><xsl:value-of select="regex-group(3)"/></xsl:with-param></xsl:call-template>
              <!-\-<xsl:text>BBB</xsl:text>-\->
            </xsl:otherwise>
          </xsl:choose>-->
          <xsl:choose>
            <xsl:when test="($preceding-tag='y' and matches(regex-group(1),'\S')) and ($following-tag='y' and matches(regex-group(3),'\S'))">
              <xsl:call-template name="add-del"><xsl:with-param name="string"><xsl:value-of select="regex-group(2)"/></xsl:with-param></xsl:call-template>
            </xsl:when>
            <xsl:when test="not($preceding-tag='y' and matches(regex-group(1),'\S')) and ($following-tag='y' and matches(regex-group(3),'\S'))">
              <xsl:call-template name="add-del"><xsl:with-param name="string"><xsl:value-of select="concat(regex-group(1),regex-group(2))"/></xsl:with-param></xsl:call-template>
            </xsl:when>
            <xsl:when test="($preceding-tag='y' and matches(regex-group(1),'\S')) and not($following-tag='y' and matches(regex-group(3),'\S'))">
              <xsl:call-template name="add-del"><xsl:with-param name="string"><xsl:value-of select="concat(regex-group(2),regex-group(3))"/></xsl:with-param></xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="add-del"><xsl:with-param name="string"><xsl:value-of select="."/></xsl:with-param></xsl:call-template>
            </xsl:otherwise>
            
          </xsl:choose>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <xsl:choose>
            <xsl:when test="matches(.,'^[A-Za-zÀ-ÿ]+$') and ($preceding-tag='y' or $following-tag='y')"/>
            <xsl:otherwise>
              <xsl:call-template name="add-del">
                <xsl:with-param name="string"><xsl:value-of select="."/></xsl:with-param>
              </xsl:call-template>
              <!--<xsl:call-template name="pb"/>-->
            </xsl:otherwise>
          </xsl:choose>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="add-del">
  <xsl:param name="string"><xsl:value-of select="."/></xsl:param>
  <xsl:analyze-string select="$string" regex="^(([^\[]*[^\[\p{{L}}\p{{Mn}}\-])?)([\p{{L}}\p{{Mn}}\-]*)\[\s*([\p{{L}}\p{{Mn}}\d\-.,?:;'’]*)\s*/\s*([\p{{L}}\p{{Mn}}\d\-.,?:;]*['’]?)\s*\](([\p{{L}}\p{{Mn}}\-]|\[[^\]]*\])*['’]?)(.*)$">
  <!--<xsl:analyze-string select="$string" regex="([A-Za-zÀ-ÿ\-]*)\[\s*([\p{{L}}\p{{Mn}}\-.'’]*)\s*/\s*([\p{{L}}\p{{Mn}}\-.]*['’]?)\s*\]([A-Za-zÀ-ÿ\-]*['’]?)">-->
    <xsl:matching-substring>
      <xsl:variable name="before"><xsl:value-of select="regex-group(1)"/></xsl:variable>
      <xsl:variable name="start"><xsl:value-of select="regex-group(3)"/></xsl:variable>
      <xsl:variable name="del"><xsl:value-of select="regex-group(4)"/></xsl:variable>
      <xsl:variable name="add"><xsl:value-of select="regex-group(5)"/></xsl:variable>
      <xsl:variable name="end"><xsl:value-of select="regex-group(6)"/></xsl:variable>
      <xsl:variable name="after"><xsl:value-of select="regex-group(8)"/></xsl:variable>
      <xsl:call-template name="pb"><xsl:with-param name="string"><xsl:value-of select="$before"/></xsl:with-param></xsl:call-template>
      <w xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:value-of select="$start"/>
        <xsl:choose>
          <xsl:when test="matches($del,'.+') and matches($add,'.+')">
            <subst xmlns="http://www.tei-c.org/ns/1.0">
              <del xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="$del"/></del>
              <add xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="$add"/></add>
            </subst>
          </xsl:when>
          <xsl:when test="matches($del,'.+') and matches($add,'^$')">
              <del xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="$del"/></del>
          </xsl:when>
          <xsl:when test="matches($del,'^$') and matches($add,'.+')">
            <add xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="$add"/></add>
          </xsl:when>
          <xsl:otherwise>ERROR!</xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="add-del2"><xsl:with-param name="string"><xsl:value-of select="$end"/></xsl:with-param></xsl:call-template>
      </w>
      <xsl:call-template name="add-del"><xsl:with-param name="string"><xsl:value-of select="$after"/></xsl:with-param></xsl:call-template>
    </xsl:matching-substring>
    <xsl:non-matching-substring>
      <xsl:call-template name="pb">
        <xsl:with-param name="string"><xsl:value-of select="."/></xsl:with-param>
      </xsl:call-template>
    </xsl:non-matching-substring>
  </xsl:analyze-string>
  <!--<w xmlns="http://www.tei-c.org/ns/1.0">==ADD==</w>-->
</xsl:template>
  
  <xsl:template name="add-del2">
    <xsl:param name="string"><xsl:value-of select="."/></xsl:param>
    <xsl:analyze-string select="$string" regex="\[\s*([\p{{L}}\p{{Mn}}\d\-.,?:;'’]*)\s*/\s*([\p{{L}}\p{{Mn}}\d\-.,?:;]*['’]?)\s*\]">
      <xsl:matching-substring>
        <xsl:variable name="del"><xsl:value-of select="regex-group(1)"/></xsl:variable>
        <xsl:variable name="add"><xsl:value-of select="regex-group(2)"/></xsl:variable>
        <xsl:choose>
          <xsl:when test="matches($del,'.+') and matches($add,'.+')">
            <subst xmlns="http://www.tei-c.org/ns/1.0">
              <del xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="$del"/></del>
              <add xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="$add"/></add>
            </subst>
          </xsl:when>
          <xsl:when test="matches($del,'.+') and matches($add,'^$')">
            <del xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="$del"/></del>
          </xsl:when>
          <xsl:when test="matches($del,'^$') and matches($add,'.+')">
            <add xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="$add"/></add>
          </xsl:when>
          <xsl:otherwise>ERROR!</xsl:otherwise>
        </xsl:choose>
      </xsl:matching-substring>
      <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>

<xsl:template name="pb">
  <xsl:param name="string"><xsl:value-of select="."/></xsl:param>
  <xsl:analyze-string select="$string" regex="^(([^&lt;]*[^&lt;\-])?)(-?)&lt;\s*([^&gt;|\s]*)\|?([^&gt;\s]*)\s*&gt;(.*)$">
    <xsl:matching-substring>
      <xsl:value-of select="regex-group(1)"/>
      <pb xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:if test="matches(regex-group(2),'\w$') or matches(regex-group(3),'-')">
          <xsl:attribute name="break">no</xsl:attribute>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="matches(regex-group(4),'\S+') and matches(regex-group(5),'\S+')">
            <xsl:attribute name="n"><xsl:value-of select="concat(regex-group(4),' [',regex-group(5),']')"/></xsl:attribute>
          </xsl:when>
          <xsl:when test="matches(regex-group(4),'\S+') and matches(regex-group(5),'^$')">
            <xsl:attribute name="n"><xsl:value-of select="regex-group(4)"/></xsl:attribute>
          </xsl:when>
          <xsl:when test="matches(regex-group(4),'^$') and matches(regex-group(5),'\S+')">
            <xsl:attribute name="n"><xsl:value-of select="concat('[',regex-group(5),']')"/></xsl:attribute>
          </xsl:when>
        </xsl:choose>
      </pb>
      <xsl:call-template name="pb">
        <xsl:with-param name="string"><xsl:value-of select="regex-group(6)"/></xsl:with-param>
      </xsl:call-template>
    </xsl:matching-substring>
    <xsl:non-matching-substring>
      <xsl:value-of select="$string"/>
    </xsl:non-matching-substring>
  </xsl:analyze-string>  
</xsl:template>

</xsl:stylesheet>
