<!-- The Identity Transformation -->
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="#all">
  
  
  <!-- Whenever you match any node or any attribute -->
  <xsl:template match="*|comment()|processing-instruction()|@*">
    <!-- Copy the current node -->
    <xsl:copy>
      <!-- Including any attributes it has and any child nodes -->
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="text()">
    <xsl:param name="from-w">no</xsl:param>
    <xsl:choose>
      <xsl:when test="matches($from-w,'y') or ancestor::tei:w">
        <xsl:value-of select="normalize-space(.)"/>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:variable name="filename">
    <xsl:analyze-string select="document-uri(.)" regex="^(.*)/([^/]+)\.[^/]+$">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(2)"/>
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:variable>

<xsl:template match="tei:text">
  <xsl:copy>
    <xsl:apply-templates select="@*"/>
    <xsl:attribute name="version">
      <xsl:choose>
        <xsl:when test="matches($filename,'_or_')">original</xsl:when>
        <xsl:when test="matches($filename,'_cp_')">copie</xsl:when>
        <xsl:otherwise>indeterminé</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>

<xsl:template match="tei:w">
  <xsl:variable name="ref">
    <xsl:text>Davydova, Journal, </xsl:text>
    <xsl:value-of select="ancestor::tei:div[3]/@n"/>
    <xsl:text> (</xsl:text>
    <xsl:value-of select="ancestor::tei:div[2]/@n"/>
    <xsl:text>), p. </xsl:text>
    <xsl:value-of select="preceding::tei:pb[1]/@n"/>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="preceding-sibling::*[1][self::tei:pb[@break='no']]"></xsl:when>
    <xsl:when test="ancestor::tei:w">
      <!-- Patch pour les mots imbriqués -->
      <xsl:apply-templates select="*|text()">
        <xsl:with-param name="from-w">yes</xsl:with-param>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:attribute name="ref"><xsl:value-of select="$ref"/></xsl:attribute>
        <xsl:attribute name="crochets">
          <xsl:apply-templates mode="crochets"/>
          <xsl:if test="following-sibling::*[1][self::tei:pb[@break='no']]">
            <xsl:text>||</xsl:text>
            <xsl:apply-templates select="following::tei:w[1]/node()" mode="crochets"/>
          </xsl:if>
        </xsl:attribute>
        <xsl:attribute name="erreur">
          <xsl:choose>
            <xsl:when test="ancestor::tei:sic[matches(@ana,'^#err-')]"><xsl:value-of select="substring-after(ancestor::tei:sic/@ana,'#err-')"/></xsl:when>
            <xsl:otherwise>non</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:apply-templates/>
        <xsl:if test="following-sibling::*[1][self::tei:pb[@break='no']]">
<!--          <xsl:copy-of select="following-sibling::tei:pb[1]"></xsl:copy-of>-->
          <xsl:apply-templates select="following-sibling::tei:pb[1]">
            <xsl:with-param name="from-w">yes</xsl:with-param>
          </xsl:apply-templates>
          <xsl:apply-templates select="following::tei:w[1]/node()"/>
        </xsl:if>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="tei:pb">
  <xsl:param name="from-w">no</xsl:param>
  <!--<xsl:variable name="page-count">
    <xsl:value-of select="format-number(count(preceding::tei:pb) + 1,'000')"/>
  </xsl:variable>-->
  <xsl:variable name="text-n">
    <xsl:choose>
      <xsl:when test="ancestor::tei:div[@type='book']">
        <xsl:value-of select="ancestor::tei:div[@type='book']/@n"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="following::tei:div[@type='book'][1]/@n"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="pb-n">
    <xsl:value-of select="@n"/>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="@break='no' and $from-w='no' and not(ancestor::tei:w)"/>
    <xsl:otherwise>
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <!-- http://perso.ens-lyon.fr/alexei.lavrentev/img/davydova_601-2-fr/page010.jpg -->
        <xsl:attribute name="facs">
          <xsl:choose>
            <xsl:when test="matches($filename,'_cp_')">
              <xsl:text>http://perso.ens-lyon.fr/alexei.lavrentev/img/davydova_</xsl:text>
              <xsl:value-of select="$text-n"/>
              <xsl:text>-fr/</xsl:text>
              <xsl:value-of select="$page-collation//text[@n=$text-n]/pb[@n=$pb-n]/@facs"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>http://perso.ens-lyon.fr/alexei.lavrentev/img/nofacs.jpg</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
  
  
  <xsl:template match="tei:div[@type='jour']">
    <xsl:variable name="text-n"><xsl:value-of select="parent::tei:div/@n"/></xsl:variable>
<!--    <xsl:variable name="previous-pb" as="xs:integer">
      <xsl:choose>
        <xsl:when test="matches(preceding::tei:pb[1]/@n,'\[\d+\]')">
          <xsl:value-of select="replace(preceding::tei:pb[1]/@n,'^.*\[(\d+)\].*$','$1')"/>
        </xsl:when>
        <xsl:when test="matches(preceding::tei:pb[1]/@n,'\d+')">
          <xsl:value-of select="replace(preceding::tei:pb[1]/@n,'^[^0-9]*\[(\d+)\][^0-9]*$','$1')"/>
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="following-pb" as="xs:integer">
      <xsl:choose>
        <xsl:when test="matches(following::tei:pb[1]/@n,'\[\d+\]')">
          <xsl:value-of select="replace(following::tei:pb[1]/@n,'^.*\[(\d+)\].*$','$1')"/>
        </xsl:when>
        <xsl:when test="matches(following::tei:pb[1]/@n,'\d+')">
          <xsl:value-of select="replace(following::tei:pb[1]/@n,'^[^0-9]*\[(\d+)\][^0-9]*$','$1')"/>
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>-->
    <xsl:variable name="date">
      <xsl:value-of select="replace(@n,'(\d\d\d\d)-(\d\d)-(\d\d)\+?','$3/$2/$1')"/>
      <xsl:if test="matches(@n,'\+')"><xsl:text>et suiv.</xsl:text></xsl:if>
    </xsl:variable>
<xsl:variable name="order1" as="xs:integer">
  <xsl:choose>
    <xsl:when test="preceding::tei:div[@type='jour']">
      <xsl:value-of select="preceding::tei:div[@type='jour'][1]/@order"/>
    </xsl:when>
    <xsl:otherwise>0</xsl:otherwise>
  </xsl:choose>
</xsl:variable>
    <xsl:variable name="order2" as="xs:integer">
      <xsl:value-of select="@order"/>
    </xsl:variable>
    <xsl:variable name="order3" as="xs:integer">
      <xsl:choose>
        <xsl:when test="following::tei:div[@type='jour']">
          <xsl:value-of select="following::tei:div[@type='jour'][1]/@order"/>
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
<!--    <xsl:if test="not($order1 + 1 = $order2) and (descendant::tei:pb or following::tei:pb)">
      <xsl:variable name="pb-n">
        <xsl:choose>
          <xsl:when test="descendant::tei:pb">
            <xsl:analyze-string select="descendant::tei:pb[1]/@n" regex="^((\d+)|\d*\s*\[(\d*)\])">          
              <xsl:matching-substring>
                <xsl:variable name="n1"><xsl:value-of select="regex-group(2)"/></xsl:variable>
                <xsl:variable name="n2"><xsl:value-of select="regex-group(3)"/></xsl:variable>
                <xsl:if test="matches($n1,'\d+')">
                  <xsl:value-of select="$n1 - 1"/>
                </xsl:if>
                <xsl:if test="matches($n1,'\d+') and matches($n2,'\d+')">
                  <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:if test="matches($n2,'\d+')">
                  <xsl:value-of select="concat('[',$n2 - 1,']')"/>
                </xsl:if>
              </xsl:matching-substring>
            </xsl:analyze-string>
          </xsl:when>
          <xsl:otherwise>
            <xsl:analyze-string select="following::tei:pb[1]/@n" regex="^((\d+)|\d*\s*\[(\d*)\])">          
              <xsl:matching-substring>
                <xsl:variable name="n1"><xsl:value-of select="regex-group(2)"/></xsl:variable>
                <xsl:variable name="n2"><xsl:value-of select="regex-group(3)"/></xsl:variable>
                <xsl:if test="matches($n1,'\d+')">
                  <xsl:value-of select="$n1 - 1"/>
                </xsl:if>
                <xsl:if test="matches($n1,'\d+') and matches($n2,'\d+')">
                  <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:if test="matches($n2,'\d+')">
                  <xsl:value-of select="concat('[',$n2 - 1,']')"/>
                </xsl:if>
              </xsl:matching-substring>
            </xsl:analyze-string>
          </xsl:otherwise>
        </xsl:choose>        
      </xsl:variable>
      <pb xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:attribute name="n"><xsl:value-of select="$pb-n"/></xsl:attribute>
        <xsl:attribute name="facs">
          <xsl:choose>
            <xsl:when test="matches($filename,'_cp_')">
              <xsl:text>http://perso.ens-lyon.fr/alexei.lavrentev/img/davydova_</xsl:text>
              <xsl:value-of select="$text-n"/>
              <xsl:text>-fr/</xsl:text>
              <xsl:value-of select="$page-collation//text[@n=$text-n]/pb[@n=$pb-n]/@facs"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>http://perso.ens-lyon.fr/alexei.lavrentev/img/nofacs.jpg</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </pb>
    </xsl:if>-->
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="not($order1 + 1 = $order2) and (descendant::tei:pb or following::tei:pb)">
        <p xmlns="http://www.tei-c.org/ns/1.0" rend="note">
          <xsl:text>[...]</xsl:text>
          <lb xmlns="http://www.tei-c.org/ns/1.0"/>
          <xsl:text>[Ordre des pages modifié]</xsl:text>
        </p>
      </xsl:if>
      <p rend="note" xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="concat(@n,' (',parent::tei:div/@n,')')"/></p>
      <xsl:apply-templates/>
      <xsl:if test="not($order2 + 1 = $order3) and (descendant::tei:pb or following::tei:pb) and following::tei:div[@type='jour']">
        <p xmlns="http://www.tei-c.org/ns/1.0" rend="note">
          <xsl:text>[...]</xsl:text>
          <lb xmlns="http://www.tei-c.org/ns/1.0"/>
          <xsl:text>[Ordre des pages modifié]</xsl:text>
        </p>
      </xsl:if>
      
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:div/@order"/>
  
  
  <!-- Création de l'attribut "crochets" pour la mise en relief des erreurs et des corrections -->
  
  <xsl:template match="*" mode="crochets">
    <!--<xsl:value-of select="normalize-space(.)"/>-->
    <xsl:apply-templates mode="crochets"/>
  </xsl:template>
  
  <xsl:template match="text()" mode="crochets">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  
  <xsl:template match="@*|comment()|processing-instruction()" mode="crochets"/>
  
  <!--<xsl:template match="tei:subst">
    <xsl:apply-templates select="tei:add"/>
  </xsl:template>-->
  
  <xsl:template match="tei:subst" mode="crochets">
    <xsl:text>[</xsl:text>
    <xsl:apply-templates select="tei:del" mode="crochets"/>
    <xsl:text>/</xsl:text>
    <xsl:apply-templates select="tei:add" mode="crochets"/>
    <xsl:text>]</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:add" mode="crochets">
    <xsl:if test="not(parent::tei:subst)">
      <xsl:text>[/</xsl:text>
    </xsl:if>
    <xsl:apply-templates mode="crochets"/>
    <xsl:if test="not(parent::tei:subst) and not(preceding-sibling::*[1][self::tei:del])">
      <xsl:text>]</xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="tei:del"></xsl:template>
  
  <xsl:template match="tei:del" mode="crochets">
    <xsl:if test="not(parent::tei:subst)">
      <xsl:text>[</xsl:text>
    </xsl:if>
    <xsl:apply-templates mode="crochets"/>
    <xsl:if test="not(parent::tei:subst) and not(following-sibling::*[1][self::tei:del])">
      <xsl:text>/]</xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="tei:seg[matches(@type,'^err')]" mode="crochets">
    <xsl:text>{</xsl:text>
    <xsl:apply-templates mode="crochets"/>
    <xsl:text>}</xsl:text>
  </xsl:template>

<xsl:template match="tei:pb" mode="crochets">||</xsl:template>

<xsl:template match="tei:hi[matches(@rend,'^sup')]" mode="crochets">
  <xsl:text>\</xsl:text>
  <xsl:apply-templates mode="crochets"/>
  <xsl:text>/</xsl:text>
</xsl:template>

<xsl:variable name="page-collation" as="element()">
  <corpus>
    <text n="601-1">
      <pb n="[1]" facs="page001.jpg"/>
      <pb n="[2]" facs="page002.jpg"/>
      <pb n="[3]" facs="page003.jpg"/>
      <pb n="[4]" facs="page004.jpg"/>
      <pb n="[5]" facs="page005.jpg"/>
      <pb n="[6]" facs="page006.jpg"/>
      <pb n="[7]" facs="page007.jpg"/>
      <pb n="[8]" facs="page008.jpg"/>
      <pb n="[9]" facs="page009.jpg"/>
      <pb n="[10]" facs="page010.jpg"/>
      <pb n="[11]" facs="page011.jpg"/>
      <pb n="[12]" facs="page012.jpg"/>
      <pb n="[13]" facs="page013.jpg"/>
      <pb n="[14]" facs="page014.jpg"/>
      <pb n="[15]" facs="page015.jpg"/>
      <pb n="[16]" facs="page016.jpg"/>
      <pb n="[17]" facs="page017.jpg"/>
      <pb n="[18]" facs="page018.jpg"/>
      <pb n="[19]" facs="page019.jpg"/>
      <pb n="[20]" facs="page020.jpg"/>
      <pb n="[21]" facs="page021.jpg"/>
      <pb n="[22]" facs="page022.jpg"/>
      <pb n="[23]" facs="page023.jpg"/>
      <pb n="[24]" facs="page024.jpg"/>
      <pb n="[25]" facs="page025.jpg"/>
      <pb n="[26]" facs="page026.jpg"/>
      <pb n="[27]" facs="page027.jpg"/>
      <pb n="[28]" facs="page028.jpg"/>
      <pb n="[29]" facs="page029.jpg"/>
      <pb n="[30]" facs="page030.jpg"/>
      <pb n="[31]" facs="page031.jpg"/>
      <pb n="[32]" facs="page032.jpg"/>
      <pb n="[33]" facs="page033.jpg"/>
      <pb n="[34]" facs="page034.jpg"/>
      <pb n="[35]" facs="page035.jpg"/>
      <pb n="[36]" facs="page036.jpg"/>
      <pb n="[37]" facs="page037.jpg"/>
      <pb n="[38]" facs="page038.jpg"/>
      <pb n="[39]" facs="page039.jpg"/>
      <pb n="[40]" facs="page040.jpg"/>
      <pb n="[41]" facs="page041.jpg"/>
      <pb n="[42]" facs="page042.jpg"/>
      <pb n="[43]" facs="page043.jpg"/>
      <pb n="[44]" facs="page044.jpg"/>
      <pb n="[45]" facs="page045.jpg"/>
      <pb n="[46]" facs="page046.jpg"/>
      <pb n="[47]" facs="page047.jpg"/>
      <pb n="[48]" facs="page048.jpg"/>
      <pb n="[49]" facs="page049.jpg"/>
      <pb n="[50]" facs="page050.jpg"/>
      <pb n="[51]" facs="page051.jpg"/>
      <pb n="[52]" facs="page052.jpg"/>
      <pb n="[53]" facs="page053.jpg"/>
      <pb n="[54]" facs="page054.jpg"/>
      <pb n="[55]" facs="page055.jpg"/>
      <pb n="[56]" facs="page056.jpg"/>
      <pb n="[57]" facs="page057.jpg"/>
      <pb n="[58]" facs="page058.jpg"/>
      <pb n="[59]" facs="page059.jpg"/>
      <pb n="[60]" facs="page060.jpg"/>
      <pb n="[61]" facs="page061.jpg"/>
      <pb n="[62]" facs="page062.jpg"/>
      <pb n="[63]" facs="page063.jpg"/>
      <pb n="[64]" facs="page064.jpg"/>
      <pb n="[65]" facs="page065.jpg"/>
      <pb n="[66]" facs="page066.jpg"/>
      <pb n="[67]" facs="page067.jpg"/>
      <pb n="[68]" facs="page068.jpg"/>
      <pb n="[69]" facs="page069.jpg"/>
      <pb n="[70]" facs="page070.jpg"/>
      <pb n="[71]" facs="page071.jpg"/>
      <pb n="[72]" facs="page072.jpg"/>
      <pb n="[73]" facs="page073.jpg"/>
      <pb n="[74]" facs="page074.jpg"/>
      <pb n="[75]" facs="page075.jpg"/>
      <pb n="[76]" facs="page076.jpg"/>
      <pb n="[77]" facs="page077.jpg"/>
      <pb n="[78]" facs="page078.jpg"/>
      <pb n="[79]" facs="page079.jpg"/>
      <pb n="[80]" facs="page080.jpg"/>
      <pb n="[81]" facs="page081.jpg"/>
      <pb n="[82]" facs="page082.jpg"/>
      <pb n="[83]" facs="page083.jpg"/>
      <pb n="[84]" facs="page084.jpg"/>
      <pb n="[85]" facs="page085.jpg"/>
      <pb n="[86]" facs="page086.jpg"/>
      <pb n="[87]" facs="page087.jpg"/>
      <pb n="[88]" facs="page088.jpg"/>
      <pb n="[89]" facs="page089.jpg"/>
      <pb n="[90]" facs="page090.jpg"/>
      <pb n="[91]" facs="page091.jpg"/>
      <pb n="[92]" facs="page092.jpg"/>
      <pb n="[93]" facs="page093.jpg"/>
      <pb n="[94]" facs="page094.jpg"/>
      <pb n="[95]" facs="page095.jpg"/>
      <pb n="[96]" facs="page096.jpg"/>
      <pb n="[97]" facs="page097.jpg"/>
      <pb n="[98]" facs="page098.jpg"/>
      <pb n="[99]" facs="page099.jpg"/>
      <pb n="[100]" facs="page100.jpg"/>
      <pb n="[101]" facs="page101.jpg"/>
      <pb n="[102]" facs="page102.jpg"/>
      <pb n="[103]" facs="page103.jpg"/>
      <pb n="[104]" facs="page104.jpg"/>
      <pb n="[105]" facs="page105.jpg"/>
      <pb n="[106]" facs="page106.jpg"/>
      <pb n="[107]" facs="page107.jpg"/>
      <pb n="[108]" facs="page108.jpg"/>
      <pb n="[109]" facs="page109.jpg"/>
      <pb n="[110]" facs="page110.jpg"/>
      <pb n="[111]" facs="page111.jpg"/>
      <pb n="[112]" facs="page112.jpg"/>
      <pb n="[113]" facs="page113.jpg"/>
      <pb n="[114]" facs="page114.jpg"/>
      <pb n="[115]" facs="page115.jpg"/>
      <pb n="[116]" facs="page116.jpg"/>
      <pb n="[117]" facs="page117.jpg"/>
      <pb n="[118]" facs="page118.jpg"/>
      <pb n="[119]" facs="page119.jpg"/>
      <pb n="[120]" facs="page120.jpg"/>
      <pb n="[121]" facs="page121.jpg"/>
      <pb n="[122]" facs="page122.jpg"/>
      <pb n="[123]" facs="page123.jpg"/>
      <pb n="[124]" facs="page124.jpg"/>
      <pb n="[125]" facs="page125.jpg"/>
      <pb n="[126]" facs="page126.jpg"/>
      <pb n="[127]" facs="page127.jpg"/>
      <pb n="[128]" facs="page128.jpg"/>
      <pb n="[129]" facs="page129.jpg"/>
      <pb n="[130]" facs="page130.jpg"/>
      <pb n="[131]" facs="page131.jpg"/>
      <pb n="[132]" facs="page132.jpg"/>
      <pb n="[133]" facs="page133.jpg"/>
      <pb n="[134]" facs="page134.jpg"/>
      <pb n="[135]" facs="page135.jpg"/>
      <pb n="[136]" facs="page136.jpg"/>
      <pb n="[137]" facs="page137.jpg"/>
      <pb n="[138]" facs="page138.jpg"/>
      <pb n="[139]" facs="page139.jpg"/>
      <pb n="[140]" facs="page140.jpg"/>
      <pb n="[141]" facs="page141.jpg"/>
      <pb n="[142]" facs="page142.jpg"/>
      <pb n="[143]" facs="page143.jpg"/>
      <pb n="[144]" facs="page144.jpg"/>
      <pb n="[145]" facs="page145.jpg"/>
      <pb n="[146]" facs="page146.jpg"/>
      <pb n="[147]" facs="page147.jpg"/>
      <pb n="[148]" facs="page148.jpg"/>
      <pb n="[149]" facs="page149.jpg"/>
      <pb n="[150]" facs="page150.jpg"/>
      <pb n="[151]" facs="page151.jpg"/>
      <pb n="[152]" facs="page152.jpg"/>
      <pb n="[153]" facs="page153.jpg"/>
      <pb n="[154]" facs="page154.jpg"/>
      <pb n="[155]" facs="page155.jpg"/>
      <pb n="[156]" facs="page156.jpg"/>
      <pb n="[157]" facs="page157.jpg"/>
      <pb n="[158]" facs="page158.jpg"/>
      <pb n="[159]" facs="page159.jpg"/>
      <pb n="[160]" facs="page160.jpg"/>
      <pb n="[161]" facs="page161.jpg"/>
      <pb n="[162]" facs="page162.jpg"/>
      <pb n="[163]" facs="page163.jpg"/>
      <pb n="[164]" facs="page164.jpg"/>
      <pb n="[165]" facs="page165.jpg"/>
      <pb n="[166]" facs="page166.jpg"/>
      <pb n="[167]" facs="page167.jpg"/>
      <pb n="[168]" facs="page168.jpg"/>
      <pb n="[169]" facs="page169.jpg"/>
      <pb n="[170]" facs="page170.jpg"/>
      <pb n="[171]" facs="page171.jpg"/>
      <pb n="[172]" facs="page172.jpg"/>
      <pb n="[173]" facs="page173.jpg"/>
      <pb n="[174]" facs="page174.jpg"/>
      <pb n="[175]" facs="page175.jpg"/>
      <pb n="[176]" facs="page176.jpg"/>
      <pb n="[177]" facs="page177.jpg"/>
      <pb n="[178]" facs="page178.jpg"/>
      <pb n="[179]" facs="page179.jpg"/>
      <pb n="[180]" facs="page180.jpg"/>
      <pb n="[181]" facs="page181.jpg"/>
      <pb n="[182]" facs="page182.jpg"/>
      <pb n="[183]" facs="page183.jpg"/>
      <pb n="[184]" facs="page184.jpg"/>
      <pb n="[185]" facs="page185.jpg"/>
      <pb n="[186]" facs="page186.jpg"/>
      <pb n="[187]" facs="page187.jpg"/>
      <pb n="[188]" facs="page188.jpg"/>
      <pb n="[189]" facs="page189.jpg"/>
      <pb n="[190]" facs="page190.jpg"/>
      <pb n="[191]" facs="page191.jpg"/>
      <pb n="[192]" facs="page192.jpg"/>
      <pb n="[193]" facs="page193.jpg"/>
      <pb n="[194]" facs="page194.jpg"/>
      <pb n="[195]" facs="page195.jpg"/>
      <pb n="[196]" facs="page196.jpg"/>
      <pb n="[197]" facs="page197.jpg"/>
      <pb n="[198]" facs="page198.jpg"/>
      <pb n="[199]" facs="page199.jpg"/>
      <pb n="[200]" facs="page200.jpg"/>
      <pb n="[201]" facs="page201.jpg"/>
      <pb n="[202]" facs="page202.jpg"/>
      <pb n="[203]" facs="page203.jpg"/>
      <pb n="[204]" facs="page204.jpg"/>
      <pb n="[205]" facs="page205.jpg"/>
      <pb n="[206]" facs="page206.jpg"/>
      <pb n="[207]" facs="page207.jpg"/>
      <pb n="[208]" facs="page208.jpg"/>
      <pb n="[209]" facs="page209.jpg"/>
      <pb n="[210]" facs="page210.jpg"/>
      <pb n="[211]" facs="page211.jpg"/>
      <pb n="[212]" facs="page212.jpg"/>
      <pb n="[213]" facs="page213.jpg"/>
      <pb n="[214]" facs="page214.jpg"/>
      <pb n="[215]" facs="page215.jpg"/>
      <pb n="[216]" facs="page216.jpg"/>
      <pb n="[217]" facs="page217.jpg"/>
      <pb n="[218]" facs="page218.jpg"/>
      <pb n="[219]" facs="page219.jpg"/>
      <pb n="[220]" facs="page220.jpg"/>
      <pb n="[221]" facs="page221.jpg"/>
      <pb n="[222]" facs="page222.jpg"/>
      <pb n="[223]" facs="page223.jpg"/>
      <pb n="[224]" facs="page224.jpg"/>
      <pb n="[225]" facs="page225.jpg"/>
      <pb n="[226]" facs="page226.jpg"/>
      <pb n="[227]" facs="page227.jpg"/>
      <pb n="[228]" facs="page228.jpg"/>
      <pb n="[229]" facs="page229.jpg"/>
      <pb n="[230]" facs="page230.jpg"/>
      <pb n="[231]" facs="page231.jpg"/>
      <pb n="[232]" facs="page232.jpg"/>
      <pb n="[233]" facs="page233.jpg"/>
      <pb n="[234]" facs="page234.jpg"/>
      <pb n="[235]" facs="page235.jpg"/>
      <pb n="[236]" facs="page236.jpg"/>
      <pb n="[237]" facs="page237.jpg"/>
      <pb n="[238]" facs="page238.jpg"/>
      <pb n="[239]" facs="page239.jpg"/>
      <pb n="[240]" facs="page240.jpg"/>
      <pb n="[241]" facs="page241.jpg"/>
      <pb n="[242]" facs="page242.jpg"/>
      <pb n="[243]" facs="page243.jpg"/>
      <pb n="[244]" facs="page244.jpg"/>
      <pb n="[245]" facs="page245.jpg"/>
      <pb n="[246]" facs="page246.jpg"/>
      <pb n="[247]" facs="page247.jpg"/>
      <pb n="[248]" facs="page248.jpg"/>
    </text>
    <text n="601-2">
      <pb n="1" facs="page001.jpg"/>
      <pb n="[1a]" facs="page002.jpg"/>
      <pb n="2" facs="page003.jpg"/>
      <pb n="3" facs="page004.jpg"/>
      <pb n="4" facs="page005.jpg"/>
      <pb n="5" facs="page006.jpg"/>
      <pb n="6" facs="page007.jpg"/>
      <pb n="7" facs="page008.jpg"/>
      <pb n="8" facs="page009.jpg"/>
      <pb n="9" facs="page010.jpg"/>
      <pb n="10" facs="page011.jpg"/>
      <pb n="11" facs="page012.jpg"/>
      <pb n="12" facs="page013.jpg"/>
      <pb n="13" facs="page014.jpg"/>
      <pb n="14" facs="page015.jpg"/>
      <pb n="15" facs="page016.jpg"/>
      <pb n="16" facs="page017.jpg"/>
      <pb n="17" facs="page018.jpg"/>
      <pb n="18" facs="page019.jpg"/>
      <pb n="19" facs="page020.jpg"/>
      <pb n="20" facs="page021.jpg"/>
      <pb n="21" facs="page022.jpg"/>
      <pb n="22" facs="page023.jpg"/>
      <pb n="23" facs="page024.jpg"/>
      <pb n="24" facs="page025.jpg"/>
      <pb n="25" facs="page026.jpg"/>
      <pb n="26" facs="page027.jpg"/>
      <pb n="27" facs="page028.jpg"/>
      <pb n="28" facs="page029.jpg"/>
      <pb n="29" facs="page030.jpg"/>
      <pb n="30" facs="page031.jpg"/>
      <pb n="31" facs="page032.jpg"/>
      <pb n="32" facs="page033.jpg"/>
      <pb n="33" facs="page034.jpg"/>
      <pb n="34" facs="page035.jpg"/>
      <pb n="35" facs="page036.jpg"/>
      <pb n="36" facs="page037.jpg"/>
      <pb n="37" facs="page038.jpg"/>
      <pb n="38" facs="page039.jpg"/>
      <pb n="39" facs="page040.jpg"/>
      <pb n="40" facs="page041.jpg"/>
      <pb n="41" facs="page042.jpg"/>
      <pb n="42" facs="page043.jpg"/>
      <pb n="43" facs="page044.jpg"/>
      <pb n="44" facs="page045.jpg"/>
      <pb n="45" facs="page046.jpg"/>
      <pb n="46" facs="page047.jpg"/>
      <pb n="47" facs="page048.jpg"/>
      <pb n="48" facs="page049.jpg"/>
      <pb n="49" facs="page050.jpg"/>
      <pb n="50" facs="page051.jpg"/>
      <pb n="51" facs="page052.jpg"/>
      <pb n="52" facs="page053.jpg"/>
      <pb n="53" facs="page054.jpg"/>
      <pb n="54" facs="page055.jpg"/>
      <pb n="55" facs="page056.jpg"/>
      <pb n="56" facs="page057.jpg"/>
      <pb n="57" facs="page058.jpg"/>
      <pb n="58" facs="page059.jpg"/>
      <pb n="59" facs="page060.jpg"/>
      <pb n="60" facs="page061.jpg"/>
      <pb n="61" facs="page062.jpg"/>
      <pb n="62" facs="page063.jpg"/>
      <pb n="63" facs="page064.jpg"/>
      <pb n="64" facs="page065.jpg"/>
      <pb n="65" facs="page066.jpg"/>
      <pb n="66" facs="page067.jpg"/>
      <pb n="67" facs="page068.jpg"/>
      <pb n="68" facs="page069.jpg"/>
      <pb n="69" facs="page070.jpg"/>
      <pb n="70" facs="page071.jpg"/>
      <pb n="71" facs="page072.jpg"/>
      <pb n="72" facs="page073.jpg"/>
      <pb n="73" facs="page074.jpg"/>
      <pb n="74" facs="page075.jpg"/>
      <pb n="75" facs="page076.jpg"/>
      <pb n="76" facs="page077.jpg"/>
      <pb n="77" facs="page078.jpg"/>
      <pb n="78" facs="page079.jpg"/>
      <pb n="79" facs="page080.jpg"/>
      <pb n="80" facs="page081.jpg"/>
      <pb n="81" facs="page082.jpg"/>
      <pb n="82" facs="page083.jpg"/>
      <pb n="83" facs="page084.jpg"/>
      <pb n="84" facs="page085.jpg"/>
      <pb n="85" facs="page086.jpg"/>
      <pb n="86" facs="page087.jpg"/>
      <pb n="87" facs="page088.jpg"/>
      <pb n="88" facs="page089.jpg"/>
      <pb n="89" facs="page090.jpg"/>
      <pb n="90" facs="page091.jpg"/>
      <pb n="91" facs="page092.jpg"/>
      <pb n="92" facs="page093.jpg"/>
      <pb n="93" facs="page094.jpg"/>
      <pb n="94" facs="page095.jpg"/>
      <pb n="95" facs="page096.jpg"/>
      <pb n="96" facs="page097.jpg"/>
      <pb n="97" facs="page098.jpg"/>
      <pb n="98" facs="page099.jpg"/>
      <pb n="99" facs="page100.jpg"/>
      <pb n="100" facs="page101.jpg"/>
      <pb n="101" facs="page102.jpg"/>
      <pb n="102" facs="page103.jpg"/>
      <pb n="103" facs="page104.jpg"/>
      <pb n="104" facs="page105.jpg"/>
      <pb n="105" facs="page106.jpg"/>
      <pb n="106" facs="page107.jpg"/>
      <pb n="107" facs="page108.jpg"/>
      <pb n="108" facs="page109.jpg"/>
      <pb n="109" facs="page110.jpg"/>
      <pb n="110" facs="page111.jpg"/>
      <pb n="111" facs="page112.jpg"/>
      <pb n="112" facs="page113.jpg"/>
      <pb n="113" facs="page114.jpg"/>
      <pb n="114" facs="page115.jpg"/>
      <pb n="115" facs="page116.jpg"/>
      <pb n="116" facs="page117.jpg"/>
      <pb n="117" facs="page118.jpg"/>
      <pb n="118" facs="page119.jpg"/>
      <pb n="119" facs="page120.jpg"/>
      <pb n="120" facs="page121.jpg"/>
      <pb n="121" facs="page122.jpg"/>
      <pb n="122" facs="page123.jpg"/>
      <pb n="123" facs="page124.jpg"/>
      <pb n="124" facs="page125.jpg"/>
      <pb n="125" facs="page126.jpg"/>
      <pb n="126" facs="page127.jpg"/>
      <pb n="127" facs="page128.jpg"/>
      <pb n="128" facs="page129.jpg"/>
      <pb n="129" facs="page130.jpg"/>
      <pb n="130" facs="page131.jpg"/>
      <pb n="131" facs="page132.jpg"/>
      <pb n="132" facs="page133.jpg"/>
      <pb n="133" facs="page134.jpg"/>
      <pb n="134" facs="page135.jpg"/>
      <pb n="135" facs="page136.jpg"/>
      <pb n="136" facs="page137.jpg"/>
      <pb n="137" facs="page138.jpg"/>
      <pb n="138" facs="page139.jpg"/>
      <pb n="139" facs="page140.jpg"/>
      <pb n="140" facs="page141.jpg"/>
      <pb n="141" facs="page142.jpg"/>
      <pb n="142" facs="page143.jpg"/>
      <pb n="143" facs="page144.jpg"/>
      <pb n="144" facs="page145.jpg"/>
      <pb n="145" facs="page146.jpg"/>
      <pb n="146" facs="page147.jpg"/>
      <pb n="147" facs="page148.jpg"/>
      <pb n="148" facs="page149.jpg"/>
      <pb n="149" facs="page150.jpg"/>
      <pb n="150" facs="page151.jpg"/>
      <pb n="151" facs="page152.jpg"/>
      <pb n="152" facs="page153.jpg"/>
      <pb n="153" facs="page154.jpg"/>
      <pb n="154" facs="page155.jpg"/>
      <pb n="155" facs="page156.jpg"/>
      <pb n="156" facs="page157.jpg"/>
      <pb n="157" facs="page158.jpg"/>
      <pb n="158" facs="page159.jpg"/>
      <pb n="159" facs="page160.jpg"/>
      <pb n="160" facs="page161.jpg"/>
      <pb n="161" facs="page162.jpg"/>
      <pb n="162" facs="page163.jpg"/>
      <pb n="163" facs="page164.jpg"/>
      <pb n="164" facs="page165.jpg"/>
      <pb n="165" facs="page166.jpg"/>
      <pb n="166" facs="page167.jpg"/>
      <pb n="167" facs="page168.jpg"/>
      <pb n="168" facs="page169.jpg"/>
      <pb n="169" facs="page170.jpg"/>
      <pb n="170" facs="page171.jpg"/>
      <pb n="171" facs="page172.jpg"/>
      <pb n="172" facs="page173.jpg"/>
      <pb n="173" facs="page174.jpg"/>
      <pb n="174" facs="page175.jpg"/>
      <pb n="175" facs="page176.jpg"/>
      <pb n="176" facs="page177.jpg"/>
      <pb n="177" facs="page178.jpg"/>
      <pb n="178" facs="page179.jpg"/>
      <pb n="179" facs="page180.jpg"/>
      <pb n="180" facs="page181.jpg"/>
      <pb n="181" facs="page182.jpg"/>
      <pb n="182" facs="page183.jpg"/>
      <pb n="183" facs="page184.jpg"/>
      <pb n="184" facs="page185.jpg"/>
      <pb n="185" facs="page186.jpg"/>
      <pb n="186" facs="page187.jpg"/>
      <pb n="187" facs="page188.jpg"/>
      <pb n="188" facs="page189.jpg"/>
      <pb n="189" facs="page190.jpg"/>
      <pb n="190" facs="page191.jpg"/>
      <pb n="191" facs="page192.jpg"/>
      <pb n="192" facs="page193.jpg"/>
      <pb n="193" facs="page194.jpg"/>
      <pb n="194" facs="page195.jpg"/>
      <pb n="195" facs="page196.jpg"/>
      <pb n="196" facs="page197.jpg"/>
      <pb n="197" facs="page198.jpg"/>
      <pb n="198" facs="page199.jpg"/>
      <pb n="199" facs="page200.jpg"/>
      <pb n="200" facs="page201.jpg"/>
      <pb n="201" facs="page202.jpg"/>
      <pb n="202" facs="page203.jpg"/>
      <pb n="203" facs="page204.jpg"/>
      <pb n="204" facs="page205.jpg"/>
      <pb n="205" facs="page206.jpg"/>
      <pb n="206" facs="page207.jpg"/>
      <pb n="207" facs="page208.jpg"/>
      <pb n="208" facs="page209.jpg"/>
      <pb n="209" facs="page210.jpg"/>
      <pb n="210" facs="page211.jpg"/>
      <pb n="211" facs="page212.jpg"/>
      <pb n="212" facs="page213.jpg"/>
      <pb n="213" facs="page214.jpg"/>
      <pb n="214" facs="page215.jpg"/>
      <pb n="215" facs="page216.jpg"/>
      <pb n="216" facs="page217.jpg"/>
      <pb n="217" facs="page218.jpg"/>
      <pb n="218" facs="page219.jpg"/>
      <pb n="219" facs="page220.jpg"/>
      <pb n="220" facs="page221.jpg"/>
      <pb n="221" facs="page222.jpg"/>
      <pb n="222" facs="page223.jpg"/>
      <pb n="223" facs="page224.jpg"/>
      <pb n="224" facs="page225.jpg"/>
      <pb n="225" facs="page226.jpg"/>
      <pb n="226" facs="page227.jpg"/>
      <pb n="227" facs="page228.jpg"/>
      <pb n="228" facs="page229.jpg"/>
      <pb n="229" facs="page230.jpg"/>
      <pb n="230" facs="page231.jpg"/>
      <pb n="231" facs="page232.jpg"/>
      <pb n="232" facs="page233.jpg"/>
      <pb n="233" facs="page234.jpg"/>
      <pb n="234" facs="page235.jpg"/>
      <pb n="235" facs="page236.jpg"/>
      <pb n="236" facs="page237.jpg"/>
      <pb n="237" facs="page238.jpg"/>
      <pb n="238" facs="page239.jpg"/>
      <pb n="239" facs="page240.jpg"/>
      <pb n="240" facs="page241.jpg"/>
      <pb n="241" facs="page242.jpg"/>
      <pb n="242" facs="page243.jpg"/>
      <pb n="243" facs="page244.jpg"/>
      <pb n="244" facs="page245.jpg"/>
      <pb n="245" facs="page246.jpg"/>
      <pb n="246" facs="page247.jpg"/>
      <pb n="247" facs="page248.jpg"/>
    </text>
    <text n="601-3">
      <pb n="1" facs="page001.jpg"/>
      <pb n="2" facs="page002.jpg"/>
      <pb n="3" facs="page003.jpg"/>
      <pb n="4" facs="page004.jpg"/>
      <pb n="5" facs="page005.jpg"/>
      <pb n="6" facs="page006.jpg"/>
      <pb n="7" facs="page007.jpg"/>
      <pb n="8" facs="page008.jpg"/>
      <pb n="9" facs="page009.jpg"/>
      <pb n="10" facs="page010.jpg"/>
      <pb n="11" facs="page011.jpg"/>
      <pb n="12" facs="page012.jpg"/>
      <pb n="13" facs="page013.jpg"/>
      <pb n="14" facs="page014.jpg"/>
      <pb n="15" facs="page015.jpg"/>
      <pb n="16" facs="page016.jpg"/>
      <pb n="17" facs="page017.jpg"/>
      <pb n="18" facs="page018.jpg"/>
      <pb n="19" facs="page019.jpg"/>
      <pb n="20" facs="page020.jpg"/>
      <pb n="21" facs="page021.jpg"/>
      <pb n="22" facs="page022.jpg"/>
      <pb n="23" facs="page023.jpg"/>
      <pb n="24" facs="page024.jpg"/>
      <pb n="25" facs="page025.jpg"/>
      <pb n="26" facs="page026.jpg"/>
      <pb n="27" facs="page027.jpg"/>
      <pb n="28" facs="page028.jpg"/>
      <pb n="29" facs="page029.jpg"/>
      <pb n="30" facs="page030.jpg"/>
      <pb n="31" facs="page031.jpg"/>
      <pb n="32" facs="page032.jpg"/>
      <pb n="33" facs="page033.jpg"/>
      <pb n="34" facs="page034.jpg"/>
      <pb n="35" facs="page035.jpg"/>
      <pb n="36" facs="page036.jpg"/>
      <pb n="37" facs="page037.jpg"/>
      <pb n="38" facs="page038.jpg"/>
      <pb n="39" facs="page039.jpg"/>
      <pb n="40" facs="page040.jpg"/>
      <pb n="41" facs="page041.jpg"/>
      <pb n="42" facs="page042.jpg"/>
      <pb n="43" facs="page043.jpg"/>
      <pb n="44" facs="page044.jpg"/>
      <pb n="45" facs="page045.jpg"/>
      <pb n="46" facs="page046.jpg"/>
      <pb n="47" facs="page047.jpg"/>
      <pb n="48" facs="page048.jpg"/>
      <pb n="49" facs="page049.jpg"/>
      <pb n="50" facs="page050.jpg"/>
      <pb n="51" facs="page051.jpg"/>
      <pb n="52" facs="page052.jpg"/>
      <pb n="53" facs="page053.jpg"/>
      <pb n="54" facs="page054.jpg"/>
      <pb n="55" facs="page055.jpg"/>
      <pb n="56" facs="page056.jpg"/>
      <pb n="57" facs="page057.jpg"/>
      <pb n="58" facs="page058.jpg"/>
      <pb n="59" facs="page059.jpg"/>
      <pb n="60" facs="page060.jpg"/>
      <pb n="61" facs="page061.jpg"/>
      <pb n="62" facs="page062.jpg"/>
      <pb n="63" facs="page063.jpg"/>
      <pb n="64" facs="page064.jpg"/>
      <pb n="65" facs="page065.jpg"/>
      <pb n="66" facs="page066.jpg"/>
      <pb n="67" facs="page067.jpg"/>
      <pb n="68" facs="page068.jpg"/>
      <pb n="69" facs="page069.jpg"/>
      <pb n="70" facs="page070.jpg"/>
      <pb n="71" facs="page071.jpg"/>
      <pb n="72" facs="page072.jpg"/>
      <pb n="73" facs="page073.jpg"/>
      <pb n="74" facs="page074.jpg"/>
      <pb n="75" facs="page075.jpg"/>
      <pb n="76" facs="page076.jpg"/>
      <pb n="77" facs="page077.jpg"/>
      <pb n="78" facs="page078.jpg"/>
      <pb n="79" facs="page079.jpg"/>
      <pb n="80" facs="page080.jpg"/>
      <pb n="81" facs="page081.jpg"/>
      <pb n="82" facs="page082.jpg"/>
      <pb n="83" facs="page083.jpg"/>
      <pb n="84" facs="page084.jpg"/>
      <pb n="85" facs="page085.jpg"/>
      <pb n="86" facs="page086.jpg"/>
      <pb n="87" facs="page087.jpg"/>
      <pb n="88" facs="page088.jpg"/>
      <pb n="89" facs="page089.jpg"/>
      <pb n="90" facs="page090.jpg"/>
      <pb n="91" facs="page091.jpg"/>
      <pb n="92" facs="page092.jpg"/>
      <pb n="93" facs="page093.jpg"/>
      <pb n="94" facs="page094.jpg"/>
      <pb n="85" facs="page095.jpg"/>
      <pb n="96" facs="page096.jpg"/>
      <pb n="97" facs="page097.jpg"/>
      <pb n="98" facs="page098.jpg"/>
      <pb n="99" facs="page099.jpg"/>
      <pb n="100" facs="page100.jpg"/>
      <pb n="101" facs="page101.jpg"/>
      <pb n="102" facs="page102.jpg"/>
      <pb n="103" facs="page103.jpg"/>
      <pb n="104" facs="page104.jpg"/>
      <pb n="105" facs="page105.jpg"/>
      <pb n="106" facs="page106.jpg"/>
      <pb n="107" facs="page107.jpg"/>
      <pb n="108" facs="page108.jpg"/>
      <pb n="109" facs="page109.jpg"/>
      <pb n="109" facs="page110.jpg"/>
      <pb n="111" facs="page111.jpg"/>
      <pb n="112" facs="page112.jpg"/>
      <pb n="113" facs="page113.jpg"/>
      <pb n="114" facs="page114.jpg"/>
      <pb n="115" facs="page115.jpg"/>
      <pb n="116" facs="page116.jpg"/>
      <pb n="117" facs="page117.jpg"/>
      <pb n="118" facs="page118.jpg"/>
      <pb n="119" facs="page119.jpg"/>
      <pb n="120" facs="page120.jpg"/>
      <pb n="121" facs="page121.jpg"/>
      <pb n="122" facs="page122.jpg"/>
      <pb n="123" facs="page123.jpg"/>
      <pb n="124" facs="page124.jpg"/>
      <pb n="125" facs="page125.jpg"/>
      <pb n="126" facs="page126.jpg"/>
      <pb n="127" facs="page127.jpg"/>
      <pb n="128" facs="page128.jpg"/>
      <pb n="129" facs="page129.jpg"/>
      <pb n="130" facs="page130.jpg"/>
      <pb n="131" facs="page131.jpg"/>
      <pb n="132" facs="page132.jpg"/>
      <pb n="133" facs="page133.jpg"/>
      <pb n="134" facs="page134.jpg"/>
      <pb n="135" facs="page135.jpg"/>
      <pb n="136" facs="page136.jpg"/>
      <pb n="137" facs="page137.jpg"/>
      <pb n="138" facs="page138.jpg"/>
      <pb n="139" facs="page139.jpg"/>
      <pb n="140" facs="page140.jpg"/>
      <pb n="141" facs="page141.jpg"/>
      <pb n="142" facs="page142.jpg"/>
      <pb n="143" facs="page143.jpg"/>
      <pb n="144" facs="page144.jpg"/>
      <pb n="145" facs="page145.jpg"/>
      <pb n="146" facs="page146.jpg"/>
      <pb n="147" facs="page147.jpg"/>
      <pb n="148" facs="page148.jpg"/>
      <pb n="149" facs="page149.jpg"/>
      <pb n="150" facs="page150.jpg"/>
      <pb n="151" facs="page151.jpg"/>
      <pb n="152" facs="page152.jpg"/>
      <pb n="153" facs="page153.jpg"/>
      <pb n="154" facs="page154.jpg"/>
      <pb n="155" facs="page155.jpg"/>
      <pb n="156" facs="page156.jpg"/>
      <pb n="157" facs="page157.jpg"/>
      <pb n="158" facs="page158.jpg"/>
      <pb n="159" facs="page159.jpg"/>
      <pb n="160" facs="page160.jpg"/>
      <pb n="161" facs="page161.jpg"/>
      <pb n="162" facs="page162.jpg"/>
      <pb n="163" facs="page163.jpg"/>
      <pb n="164" facs="page164.jpg"/>
      <pb n="165" facs="page165.jpg"/>
      <pb n="166" facs="page166.jpg"/>
      <pb n="167" facs="page167.jpg"/>
      <pb n="168" facs="page168.jpg"/>
      <pb n="169" facs="page169.jpg"/>
      <pb n="170" facs="page170.jpg"/>
      <pb n="171" facs="page171.jpg"/>
      <pb n="172" facs="page172.jpg"/>
      <pb n="173" facs="page173.jpg"/>
      <pb n="174" facs="page174.jpg"/>
      <pb n="175" facs="page175.jpg"/>
      <pb n="176" facs="page176.jpg"/>
      <pb n="177" facs="page177.jpg"/>
      <pb n="178" facs="page178.jpg"/>
      <pb n="179" facs="page179.jpg"/>
      <pb n="180" facs="page180.jpg"/>
      <pb n="181" facs="page181.jpg"/>
      <pb n="182" facs="page182.jpg"/>
      <pb n="183" facs="page183.jpg"/>
      <pb n="184" facs="page184.jpg"/>
      <pb n="185" facs="page185.jpg"/>
      <pb n="186" facs="page186.jpg"/>
      <pb n="187" facs="page187.jpg"/>
      <pb n="188" facs="page188.jpg"/>
      <pb n="189" facs="page189.jpg"/>
      <pb n="190" facs="page190.jpg"/>
      <pb n="191" facs="page191.jpg"/>
      <pb n="192" facs="page192.jpg"/>
      <pb n="193" facs="page193.jpg"/>
      <pb n="194" facs="page194.jpg"/>
      <pb n="195" facs="page195.jpg"/>
      <pb n="196" facs="page196.jpg"/>
      <pb n="197" facs="page197.jpg"/>
      <pb n="198" facs="page198.jpg"/>
      <pb n="199" facs="page199.jpg"/>
      <pb n="200" facs="page200.jpg"/>
      <pb n="201" facs="page201.jpg"/>
      <pb n="202" facs="page202.jpg"/>
      <pb n="203" facs="page203.jpg"/>
      <pb n="204" facs="page204.jpg"/>
      <pb n="205" facs="page205.jpg"/>
      <pb n="206" facs="page206.jpg"/>
      <pb n="207" facs="page207.jpg"/>
      <pb n="208" facs="page208.jpg"/>
      <pb n="209" facs="page209.jpg"/>
      <pb n="210" facs="page210.jpg"/>
      <pb n="211" facs="page211.jpg"/>
      <pb n="212" facs="page212.jpg"/>
      <pb n="213" facs="page213.jpg"/>
      <pb n="214" facs="page214.jpg"/>
      <pb n="215" facs="page215.jpg"/>
      <pb n="215" facs="page216.jpg"/>
      <pb n="215" facs="page217.jpg"/>
      <pb n="216" facs="page218.jpg"/>
      <pb n="217" facs="page219.jpg"/>
      <pb n="220" facs="page220.jpg"/>
      <pb n="221" facs="page221.jpg"/>
      <pb n="222" facs="page222.jpg"/>
      <pb n="223" facs="page223.jpg"/>
      <pb n="224" facs="page224.jpg"/>
      <pb n="225" facs="page225.jpg"/>
      <pb n="226" facs="page226.jpg"/>
      <pb n="227" facs="page227.jpg"/>
      <pb n="228" facs="page228.jpg"/>
      <pb n="229" facs="page229.jpg"/>
      <pb n="230" facs="page230.jpg"/>
      <pb n="231" facs="page231.jpg"/>
      <pb n="232" facs="page232.jpg"/>
      <pb n="233" facs="page233.jpg"/>
      <pb n="234" facs="page234.jpg"/>
      <pb n="235" facs="page235.jpg"/>
      <pb n="236" facs="page236.jpg"/>
      <pb n="237" facs="page237.jpg"/>
      <pb n="238" facs="page238.jpg"/>
      <pb n="239" facs="page239.jpg"/>
      <pb n="240" facs="page240.jpg"/>
      <pb n="241" facs="page241.jpg"/>
      <pb n="242" facs="page242.jpg"/>
      <pb n="243" facs="page243.jpg"/>
      <pb n="244" facs="page244.jpg"/>
      <pb n="245" facs="page245.jpg"/>
      <pb n="246" facs="page246.jpg"/>
      <pb n="247" facs="page247.jpg"/>
      <pb n="248" facs="page248.jpg"/>
      <pb n="249" facs="page249.jpg"/>
      <pb n="250" facs="page250.jpg"/>
      <pb n="251" facs="page251.jpg"/>
      <pb n="252" facs="page252.jpg"/>
      <pb n="253" facs="page253.jpg"/>
      <pb n="254" facs="page254.jpg"/>
    </text>
    <text n="601-4">
      <pb n="1" facs="page001.jpg"/>
      <pb n="2" facs="page002.jpg"/>
      <pb n="3" facs="page003.jpg"/>
      <pb n="4" facs="page004.jpg"/>
      <pb n="5" facs="page005.jpg"/>
      <pb n="6" facs="page006.jpg"/>
      <pb n="7" facs="page007.jpg"/>
      <pb n="8" facs="page008.jpg"/>
      <pb n="9" facs="page009.jpg"/>
      <pb n="10" facs="page010.jpg"/>
      <pb n="11" facs="page011.jpg"/>
      <pb n="12" facs="page012.jpg"/>
      <pb n="13" facs="page013.jpg"/>
      <pb n="14" facs="page014.jpg"/>
      <pb n="15" facs="page015.jpg"/>
      <pb n="16" facs="page016.jpg"/>
      <pb n="17" facs="page017.jpg"/>
      <pb n="18" facs="page018.jpg"/>
      <pb n="19" facs="page019.jpg"/>
      <pb n="20" facs="page020.jpg"/>
      <pb n="21" facs="page021.jpg"/>
      <pb n="22" facs="page022.jpg"/>
      <pb n="23" facs="page023.jpg"/>
      <pb n="24" facs="page024.jpg"/>
      <pb n="25" facs="page025.jpg"/>
      <pb n="26" facs="page026.jpg"/>
      <pb n="27" facs="page027.jpg"/>
      <pb n="28" facs="page028.jpg"/>
      <pb n="29" facs="page029.jpg"/>
      <pb n="30" facs="page030.jpg"/>
      <pb n="31" facs="page031.jpg"/>
      <pb n="32" facs="page032.jpg"/>
      <pb n="33" facs="page033.jpg"/>
      <pb n="34" facs="page034.jpg"/>
      <pb n="35" facs="page035.jpg"/>
      <pb n="36" facs="page036.jpg"/>
      <pb n="37" facs="page037.jpg"/>
      <pb n="38" facs="page038.jpg"/>
      <pb n="39" facs="page039.jpg"/>
      <pb n="40" facs="page040.jpg"/>
      <pb n="41" facs="page041.jpg"/>
      <pb n="42" facs="page042.jpg"/>
      <pb n="43" facs="page043.jpg"/>
      <pb n="44" facs="page044.jpg"/>
      <pb n="45" facs="page045.jpg"/>
      <pb n="46" facs="page046.jpg"/>
      <pb n="47" facs="page047.jpg"/>
      <pb n="48" facs="page048.jpg"/>
      <pb n="49" facs="page049.jpg"/>
      <pb n="50" facs="page050.jpg"/>
      <pb n="51" facs="page051.jpg"/>
      <pb n="52" facs="page052.jpg"/>
      <pb n="53" facs="page053.jpg"/>
      <pb n="54" facs="page054.jpg"/>
      <pb n="55" facs="page055.jpg"/>
      <pb n="56" facs="page056.jpg"/>
      <pb n="57" facs="page057.jpg"/>
      <pb n="58" facs="page058.jpg"/>
      <pb n="59" facs="page059.jpg"/>
      <pb n="60" facs="page060.jpg"/>
      <pb n="61" facs="page061.jpg"/>
      <pb n="62" facs="page062.jpg"/>
      <pb n="63" facs="page063.jpg"/>
      <pb n="64" facs="page064.jpg"/>
      <pb n="65" facs="page065.jpg"/>
      <pb n="66" facs="page066.jpg"/>
      <pb n="67" facs="page067.jpg"/>
      <pb n="68" facs="page068.jpg"/>
      <pb n="69" facs="page069.jpg"/>
      <pb n="70" facs="page070.jpg"/>
      <pb n="71" facs="page071.jpg"/>
      <pb n="72" facs="page072.jpg"/>
      <pb n="73" facs="page073.jpg"/>
      <pb n="74" facs="page074.jpg"/>
      <pb n="75" facs="page075.jpg"/>
      <pb n="76" facs="page076.jpg"/>
      <pb n="77" facs="page077.jpg"/>
      <pb n="78" facs="page078.jpg"/>
      <pb n="79" facs="page079.jpg"/>
      <pb n="80" facs="page080.jpg"/>
      <pb n="81" facs="page081.jpg"/>
      <pb n="82" facs="page082.jpg"/>
      <pb n="83" facs="page083.jpg"/>
      <pb n="84" facs="page084.jpg"/>
      <pb n="85" facs="page085.jpg"/>
      <pb n="86" facs="page086.jpg"/>
      <pb n="87" facs="page087.jpg"/>
      <pb n="88" facs="page088.jpg"/>
      <pb n="89" facs="page089.jpg"/>
      <pb n="90" facs="page090.jpg"/>
      <pb n="91" facs="page091.jpg"/>
      <pb n="92" facs="page092.jpg"/>
      <pb n="93" facs="page093.jpg"/>
      <pb n="94" facs="page094.jpg"/>
      <pb n="95" facs="page095.jpg"/>
      <pb n="96" facs="page096.jpg"/>
      <pb n="97" facs="page097.jpg"/>
      <pb n="98" facs="page098.jpg"/>
      <pb n="99" facs="page099.jpg"/>
      <pb n="100" facs="page100.jpg"/>
      <pb n="101" facs="page101.jpg"/>
      <pb n="102" facs="page102.jpg"/>
      <pb n="103" facs="page103.jpg"/>
      <pb n="104" facs="page104.jpg"/>
      <pb n="105" facs="page105.jpg"/>
      <pb n="106" facs="page106.jpg"/>
      <pb n="107" facs="page107.jpg"/>
      <pb n="108" facs="page108.jpg"/>
      <pb n="109" facs="page109.jpg"/>
      <pb n="110" facs="page110.jpg"/>
      <pb n="111" facs="page111.jpg"/>
      <pb n="112" facs="page112.jpg"/>
      <pb n="113" facs="page113.jpg"/>
      <pb n="114" facs="page114.jpg"/>
      <pb n="115" facs="page115.jpg"/>
      <pb n="116" facs="page116.jpg"/>
      <pb n="117" facs="page117.jpg"/>
      <pb n="118" facs="page118.jpg"/>
      <pb n="119" facs="page119.jpg"/>
      <pb n="120" facs="page120.jpg"/>
      <pb n="121" facs="page121.jpg"/>
      <pb n="122" facs="page122.jpg"/>
      <pb n="123" facs="page123.jpg"/>
      <pb n="124" facs="page124.jpg"/>
      <pb n="125" facs="page125.jpg"/>
      <pb n="126" facs="page126.jpg"/>
      <pb n="127" facs="page127.jpg"/>
      <pb n="128" facs="page128.jpg"/>
      <pb n="129" facs="page129.jpg"/>
      <pb n="130" facs="page130.jpg"/>
      <pb n="131" facs="page131.jpg"/>
      <pb n="132" facs="page132.jpg"/>
      <pb n="133" facs="page133.jpg"/>
      <pb n="134" facs="page134.jpg"/>
      <pb n="135" facs="page135.jpg"/>
      <pb n="136" facs="page136.jpg"/>
      <pb n="137" facs="page137.jpg"/>
      <pb n="138" facs="page138.jpg"/>
      <pb n="139" facs="page139.jpg"/>
      <pb n="140" facs="page140.jpg"/>
      <pb n="141" facs="page141.jpg"/>
      <pb n="142" facs="page142.jpg"/>
      <pb n="143" facs="page143.jpg"/>
      <pb n="144" facs="page144.jpg"/>
      <pb n="145" facs="page145.jpg"/>
      <pb n="146" facs="page146.jpg"/>
      <pb n="147" facs="page147.jpg"/>
      <pb n="148" facs="page148.jpg"/>
      <pb n="149" facs="page149.jpg"/>
      <pb n="150" facs="page150.jpg"/>
      <pb n="151" facs="page151.jpg"/>
      <pb n="152" facs="page152.jpg"/>
      <pb n="153" facs="page153.jpg"/>
      <pb n="154" facs="page154.jpg"/>
      <pb n="155" facs="page155.jpg"/>
      <pb n="156" facs="page156.jpg"/>
      <pb n="157" facs="page157.jpg"/>
      <pb n="158" facs="page158.jpg"/>
      <pb n="159" facs="page159.jpg"/>
      <pb n="160" facs="page160.jpg"/>
      <pb n="161" facs="page161.jpg"/>
      <pb n="162" facs="page162.jpg"/>
      <pb n="163" facs="page163.jpg"/>
      <pb n="164" facs="page164.jpg"/>
      <pb n="165" facs="page165.jpg"/>
      <pb n="166" facs="page166.jpg"/>
      <pb n="167" facs="page167.jpg"/>
      <pb n="168" facs="page168.jpg"/>
      <pb n="169" facs="page169.jpg"/>
      <pb n="170" facs="page170.jpg"/>
      <pb n="171" facs="page171.jpg"/>
      <pb n="172" facs="page172.jpg"/>
      <pb n="173" facs="page173.jpg"/>
      <pb n="174" facs="page174.jpg"/>
      <pb n="175" facs="page175.jpg"/>
      <pb n="176" facs="page176.jpg"/>
      <pb n="177" facs="page177.jpg"/>
      <pb n="178" facs="page178.jpg"/>
      <pb n="179" facs="page179.jpg"/>
      <pb n="180" facs="page180.jpg"/>
      <pb n="181" facs="page181.jpg"/>
      <pb n="182" facs="page182.jpg"/>
      <pb n="183" facs="page183.jpg"/>
      <pb n="184" facs="page184.jpg"/>
      <pb n="185" facs="page185.jpg"/>
      <pb n="186" facs="page186.jpg"/>
      <pb n="187" facs="page187.jpg"/>
      <pb n="188" facs="page188.jpg"/>
      <pb n="189" facs="page189.jpg"/>
      <pb n="190" facs="page190.jpg"/>
      <pb n="191" facs="page191.jpg"/>
      <pb n="192" facs="page192.jpg"/>
      <pb n="193" facs="page193.jpg"/>
      <pb n="194" facs="page194.jpg"/>
      <pb n="195" facs="page195.jpg"/>
      <pb n="196" facs="page196.jpg"/>
      <pb n="197" facs="page197.jpg"/>
      <pb n="198" facs="page198.jpg"/>
      <pb n="199" facs="page199.jpg"/>
      <pb n="200" facs="page200.jpg"/>
      <pb n="201" facs="page201.jpg"/>
      <pb n="202" facs="page202.jpg"/>
      <pb n="203" facs="page203.jpg"/>
      <pb n="204" facs="page204.jpg"/>
      <pb n="205" facs="page205.jpg"/>
      <pb n="206" facs="page206.jpg"/>
      <pb n="207" facs="page207.jpg"/>
      <pb n="208" facs="page208.jpg"/>
      <pb n="209" facs="page209.jpg"/>
      <pb n="210" facs="page210.jpg"/>
      <pb n="211" facs="page211.jpg"/>
      <pb n="212" facs="page212.jpg"/>
      <pb n="213" facs="page213.jpg"/>
      <pb n="214" facs="page214.jpg"/>
      <pb n="215" facs="page215.jpg"/>
      <pb n="216" facs="page216.jpg"/>
      <pb n="217" facs="page217.jpg"/>
      <pb n="218" facs="page218.jpg"/>
      <pb n="219" facs="page219.jpg"/>
      <pb n="220" facs="page220.jpg"/>
      <pb n="221" facs="page221.jpg"/>
      <pb n="222" facs="page222.jpg"/>
      <pb n="223" facs="page223.jpg"/>
      <pb n="224" facs="page224.jpg"/>
      <pb n="225" facs="page225.jpg"/>
      <pb n="226" facs="page226.jpg"/>
      <pb n="226" facs="page227.jpg"/>
      <pb n="227" facs="page228.jpg"/>
      <pb n="228" facs="page229.jpg"/>
      <pb n="229" facs="page230.jpg"/>
      <pb n="230" facs="page231.jpg"/>
      <pb n="231" facs="page232.jpg"/>
      <pb n="232" facs="page233.jpg"/>
      <pb n="233" facs="page234.jpg"/>
      <pb n="234" facs="page235.jpg"/>
      <pb n="235" facs="page236.jpg"/>
      <pb n="236" facs="page237.jpg"/>
      <pb n="237" facs="page238.jpg"/>
      <pb n="238" facs="page239.jpg"/>
      <pb n="239" facs="page240.jpg"/>
      <pb n="240" facs="page241.jpg"/>
      <pb n="241" facs="page242.jpg"/>
      <pb n="242" facs="page243.jpg"/>
      <pb n="243" facs="page244.jpg"/>
      <pb n="244" facs="page245.jpg"/>
      <pb n="245" facs="page246.jpg"/>
      <pb n="246" facs="page247.jpg"/>
    </text>
    <text n="601-5">
      <pb n="1" facs="page001.jpg"/>
      <pb n="2" facs="page002.jpg"/>
      <pb n="3" facs="page003.jpg"/>
      <pb n="4" facs="page004.jpg"/>
      <pb n="5" facs="page005.jpg"/>
      <pb n="6" facs="page006.jpg"/>
      <pb n="7" facs="page007.jpg"/>
      <pb n="8" facs="page008.jpg"/>
      <pb n="9" facs="page009.jpg"/>
      <pb n="10" facs="page010.jpg"/>
      <pb n="11" facs="page011.jpg"/>
      <pb n="12" facs="page012.jpg"/>
      <pb n="13" facs="page013.jpg"/>
      <pb n="14" facs="page014.jpg"/>
      <pb n="15" facs="page015.jpg"/>
      <pb n="16" facs="page016.jpg"/>
      <pb n="17" facs="page017.jpg"/>
      <pb n="18" facs="page018.jpg"/>
      <pb n="19" facs="page019.jpg"/>
      <pb n="20" facs="page020.jpg"/>
      <pb n="21" facs="page021.jpg"/>
      <pb n="22" facs="page022.jpg"/>
      <pb n="23" facs="page023.jpg"/>
      <pb n="24" facs="page024.jpg"/>
      <pb n="25" facs="page025.jpg"/>
      <pb n="26" facs="page026.jpg"/>
      <pb n="27" facs="page027.jpg"/>
      <pb n="28" facs="page028.jpg"/>
      <pb n="29" facs="page029.jpg"/>
      <pb n="30" facs="page030.jpg"/>
      <pb n="31" facs="page031.jpg"/>
      <pb n="32" facs="page032.jpg"/>
      <pb n="33" facs="page033.jpg"/>
      <pb n="34" facs="page034.jpg"/>
      <pb n="35" facs="page035.jpg"/>
      <pb n="36" facs="page036.jpg"/>
      <pb n="37" facs="page037.jpg"/>
      <pb n="38" facs="page038.jpg"/>
      <pb n="39" facs="page039.jpg"/>
      <pb n="40" facs="page040.jpg"/>
      <pb n="41" facs="page041.jpg"/>
      <pb n="42" facs="page042.jpg"/>
      <pb n="43" facs="page043.jpg"/>
      <pb n="44" facs="page044.jpg"/>
      <pb n="45" facs="page045.jpg"/>
      <pb n="46" facs="page046.jpg"/>
      <pb n="47" facs="page047.jpg"/>
      <pb n="48" facs="page048.jpg"/>
      <pb n="49" facs="page049.jpg"/>
      <pb n="50" facs="page050.jpg"/>
      <pb n="51" facs="page051.jpg"/>
      <pb n="52" facs="page052.jpg"/>
      <pb n="53" facs="page053.jpg"/>
      <pb n="54" facs="page054.jpg"/>
      <pb n="55" facs="page055.jpg"/>
      <pb n="56" facs="page056.jpg"/>
      <pb n="57" facs="page057.jpg"/>
      <pb n="58" facs="page058.jpg"/>
      <pb n="59" facs="page059.jpg"/>
      <pb n="60" facs="page060.jpg"/>
      <pb n="61" facs="page061.jpg"/>
      <pb n="62" facs="page062.jpg"/>
      <pb n="63" facs="page063.jpg"/>
      <pb n="64" facs="page064.jpg"/>
      <pb n="65" facs="page065.jpg"/>
      <pb n="66" facs="page066.jpg"/>
      <pb n="67" facs="page067.jpg"/>
      <pb n="68" facs="page068.jpg"/>
      <pb n="69" facs="page069.jpg"/>
      <pb n="70" facs="page070.jpg"/>
      <pb n="71" facs="page071.jpg"/>
      <pb n="72" facs="page072.jpg"/>
      <pb n="73" facs="page073.jpg"/>
      <pb n="74" facs="page074.jpg"/>
      <pb n="75" facs="page075.jpg"/>
      <pb n="76" facs="page076.jpg"/>
      <pb n="77" facs="page077.jpg"/>
      <pb n="78" facs="page078.jpg"/>
      <pb n="79" facs="page079.jpg"/>
      <pb n="80" facs="page080.jpg"/>
    </text>
      </corpus>
</xsl:variable>

</xsl:stylesheet>
