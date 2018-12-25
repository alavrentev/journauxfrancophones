<?xml version="1.0"?>
<xsl:stylesheet xmlns:edate="http://exslt.org/dates-and-times"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:tei="http://www.tei-c.org/ns/1.0" 
	xmlns:txm="http://textometrie.org/1.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="#all" version="2.0">
                
	<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" indent="no"/>
	
	<!-- <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" indent="no"  doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/> -->
	
                
                <xsl:strip-space elements="*"/>
                
	<xsl:param name="pagination-element">pb</xsl:param>
	
	<xsl:variable name="word-element">
		<xsl:choose>
			<xsl:when test="//tei:c//txm:form">c</xsl:when>
			<xsl:otherwise>w</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="page-number-adjust" as="xs:integer">
		<xsl:choose>
			<xsl:when test="//tei:c//txm:form">1</xsl:when>
			<xsl:otherwise>2</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	

                <xsl:variable name="inputtype">
                	<xsl:choose>
                		<xsl:when test="//tei:w//txm:form">xmltxm</xsl:when>
                		<xsl:otherwise>xmlw</xsl:otherwise>
                	</xsl:choose>
                </xsl:variable>
	
	<xsl:variable name="filename">
		<xsl:analyze-string select="document-uri(.)" regex="^(.*)/([^/]+)\.[^/]+$">
			<xsl:matching-substring>
				<xsl:value-of select="regex-group(2)"/>
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:variable>
                
                <xsl:template match="/">
                	<html>
                		<head>
                			<title><xsl:choose>
                				<xsl:when test="//tei:text/@id"><xsl:value-of select="//tei:text[1]/@id"/></xsl:when>
                				<xsl:otherwise><xsl:value-of select="$filename"/></xsl:otherwise>
                			</xsl:choose></title>
                			<meta http-equiv="Content-Type" content="text/html;charset=UTF-8"/>
                			<!--<link rel="stylesheet" media="all" type="text/css" href="css/bvhepistemon2014.css" />-->
<!--                			<title>
                				<xsl:if test="$author[not(contains(.,'anonym'))]">
                					<xsl:value-of select="$author"/><xsl:text> : </xsl:text>
                				</xsl:if>
                				<xsl:value-of select="$title-normal"/>
                			</title>                                                                -->
                		</head>
                			<xsl:apply-templates select="descendant::tei:text"/>
                	</html>
                </xsl:template>

<xsl:template match="tei:text">
	<body>
		<xsl:if test="$word-element='w'">
			<a class="txm-page" title="1"  next-word-id="w_0"/>
			<div class="metadata-page">
				<h1><xsl:value-of select="@id"></xsl:value-of></h1>
				<br/>
				<table>
					<xsl:for-each select="@*">
						<tr>
							<td><xsl:value-of select="name()"/></td>
							<td><xsl:value-of select="."/></td>
						</tr>
					</xsl:for-each>
				</table>
			</div>
			
		</xsl:if>
		<xsl:apply-templates/>		
	</body>
</xsl:template>

                <xsl:template match="*">
                                <xsl:choose>
                                	<xsl:when test="descendant::tei:p|descendant::tei:ab">
                                		<div>
                                			<xsl:call-template name="addClass"/>
                                			<xsl:apply-templates/></div>
                                		<xsl:text>&#xa;</xsl:text>
                                	</xsl:when>
                                	<xsl:otherwise><span>
                                		<xsl:call-template name="addClass"/>
                                		<xsl:if test="self::tei:add[@del]">
                                			<xsl:attribute name="title"><xsl:value-of select="@del"/></xsl:attribute>
                                		</xsl:if>
                                		<xsl:apply-templates/></span>
                                	<xsl:call-template name="spacing"/>
                                	</xsl:otherwise>
                                </xsl:choose>
                </xsl:template>
                
                <xsl:template match="@*|processing-instruction()|comment()">
                                <!--<xsl:copy/>-->
                </xsl:template>
                
<!--                <xsl:template match="comment()">
                                <xsl:copy/>
                </xsl:template>
-->                
                <xsl:template match="text()">
                                <xsl:value-of select="normalize-space(.)"/>
                	<xsl:if test="not(ancestor::tei:w)">
                		<xsl:call-template name="spacing"/>
                	</xsl:if>
                </xsl:template>
                
                <xsl:template name="addClass">
                	<xsl:attribute name="class">
                		<xsl:value-of select="local-name(.)"/>
                		<xsl:if test="@type"><xsl:value-of select="concat('-',@type)"/></xsl:if>
                		<xsl:if test="@subtype"><xsl:value-of select="concat('-',@subtype)"/></xsl:if>
                		<xsl:if test="@rend"><xsl:value-of select="concat('-',@rend)"/></xsl:if>
                	</xsl:attribute>                	
                </xsl:template>
                
                <xsl:template match="tei:p|tei:ab|tei:lg">
                	<p>
                		<xsl:call-template name="addClass"/>
                		<xsl:apply-templates/>
                	</p>
                	<xsl:text>&#xa;</xsl:text>
                </xsl:template>
	
	<xsl:template match="tei:head|tei:ab[@type='h2']">
		<h2>
			<!--<xsl:call-template name="addClass"/>-->
			<xsl:apply-templates/>
		</h2>
	</xsl:template>
                
	<xsl:template match="//tei:lb">
		<xsl:variable name="lbcount">
			<xsl:choose>
				<xsl:when test="ancestor::tei:ab"><xsl:number from="tei:ab" level="any"/></xsl:when>
				<xsl:when test="ancestor::tei:p"><xsl:number from="tei:p" level="any"/></xsl:when>
				<xsl:otherwise>999</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="@rend='hyphen(-)'"><span class="hyphen">-</span></xsl:if>
		<xsl:if test="@rend='hyphen(=)'"><span class="hyphen">=</span></xsl:if>
		<xsl:if test="not($lbcount=1) or preceding-sibling::node()[matches(.,'\S')]"><br/><xsl:text>&#xa;</xsl:text></xsl:if>
<!--		<xsl:if test="@n and not(@rend='prose')">
			<xsl:choose>
				<xsl:when test="matches(@n,'^[0-9]*[05]$')">
					<!-\-<a title="{@n}" class="verseline" style="position:relative"> </a>-\->
					<span class="verseline"><span class="verselinenumber"><xsl:value-of select="@n"/></span></span>
				</xsl:when>
				<xsl:when test="matches(@n,'[^0-9]')">
					<!-\-<a title="{@n}" class="verseline" style="position:relative"> </a>-\->
					<span class="verseline"><span class="verselinenumber"><xsl:value-of select="@n"/></span></span>
				</xsl:when>
				<xsl:otherwise>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>-->
		<xsl:if test="@n"><span class="verseline"><span class="verselinenumber"><xsl:value-of select="@n"/></span></span></xsl:if>
	</xsl:template>
	
	<!-- Page breaks -->                
	<xsl:template match="//*[local-name()=$pagination-element]">
		
		<xsl:variable name="next-word-position" as="xs:integer">
			<xsl:choose>
				<xsl:when test="following::*[local-name()=$word-element]">
					<xsl:value-of select="count(following::*[local-name()=$word-element][1]/preceding::*[local-name()=$word-element])"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="next-pb-position" as="xs:integer">
			<xsl:choose>
				<xsl:when test="following::*[local-name()=$pagination-element]">
					<xsl:value-of select="count(following::*[local-name()=$pagination-element][1]/preceding::*[local-name()=$word-element])"/>
				</xsl:when>
				<xsl:otherwise>999999999</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="next-word-id">
			<xsl:choose>
				<xsl:when test="$next-pb-position - $next-word-position = 999999999">w_0</xsl:when>
				<xsl:when test="$next-pb-position &gt; $next-word-position"><xsl:value-of select="following::*[local-name()=$word-element][1]/@id"/></xsl:when>
				<xsl:otherwise>w_0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		
		<xsl:variable name="editionpagetype">
			<xsl:choose>
				<xsl:when test="ancestor::tei:ab">editionpageverse</xsl:when>
				<xsl:otherwise>editionpage</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="pagenumber">
			<xsl:choose>
				<xsl:when test="@n"><xsl:value-of select="@n"/></xsl:when>
				<xsl:when test="@facs"><xsl:value-of select="substring-before(@facs,'.')"/></xsl:when>
				<xsl:otherwise>[NN]</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="page_id"><xsl:value-of select="count(preceding::*[local-name()=$pagination-element])"/></xsl:variable>
		
				
		<xsl:if test="@break='no'"><xsl:text>-</xsl:text></xsl:if>
		
		<!--<xsl:if test="//tei:note[not(@type) or @type='au'][following::*[local-name()=$pagination-element][1][count(preceding::*[local-name()=$pagination-element]) = $page_id]]">
			<xsl:text>&#xa;</xsl:text>
			<br/>
			<br/>			
			<span style="display:block;border-top-style:solid;border-top-width:1px;border-top-color:gray;padding-top:5px">                                                
				<xsl:for-each select="//tei:note[@type='au'][following::*[local-name()=$pagination-element][1][count(preceding::*[local-name()=$pagination-element]) = $page_id]]">
					<xsl:variable name="note_count_au"><xsl:number count="tei:note[@type='au']" from="tei:pb" level="any"/></xsl:variable>
					<xsl:variable name="note_mark_au">
						<xsl:choose>
							<xsl:when test="$note_count_au='0'"></xsl:when>
							<xsl:when test="$note_count_au='1'">*</xsl:when>
							<xsl:when test="$note_count_au='2'">**</xsl:when>
							<xsl:when test="$note_count_au='3'">***</xsl:when>
							<xsl:otherwise>****</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<span class="note">
						<span style="position:absolute;left:-30px"><a href="#noteref_{$note_count_au}" name="note_{$note_count_au}"><xsl:value-of select="$note_mark_au"/></a> </span>
						<xsl:apply-templates mode="#current"/>
					</span>                                                                
				</xsl:for-each>                                                                
			
			<xsl:for-each select="//tei:note[not(@type)][following::*[local-name()=$pagination-element][1][count(preceding::*[local-name()=$pagination-element]) = $page_id]]">
				<xsl:variable name="note_count"><xsl:value-of select="count(preceding::tei:note[not(@type)]) + 1"/></xsl:variable>
				<span class="note">
					<span style="position:absolute;left:-30px"><a href="#noteref_{$note_count}" name="note_{$note_count}"><xsl:value-of select="$note_count"/></a>. </span>
					<xsl:apply-templates mode="#current"/>
				</span>                                                                
			</xsl:for-each></span><xsl:text>&#xa;</xsl:text>
			
		</xsl:if>-->                                
		
		<xsl:if test="$notes_au/span[@page=$page_id] or $notes_gen/span[@page=$page_id] or $notes_tr/span[@page=$page_id]">
			<xsl:text>&#xa;</xsl:text>
			<br/>
			<span class="footnotes">
				<xsl:if test="$notes_au/span[@page=$page_id]">
					<span class="notes_au">
						<xsl:for-each select="$notes_au/span[@page=$page_id]">
							<xsl:copy>
								<xsl:copy-of select="@*[not(name()='page')]"/>
								<xsl:copy-of select="node()"/>
							</xsl:copy>
						</xsl:for-each>
					</span>
				</xsl:if>
				<xsl:if test="$notes_gen/span[@page=$page_id]">
					<span class="notes_gen">
						<xsl:for-each select="$notes_gen/span[@page=$page_id]">
							<xsl:copy>
								<xsl:copy-of select="@*[not(name()='page')]"/>
								<xsl:copy-of select="node()"/>
							</xsl:copy>
						</xsl:for-each>
					</span>
				</xsl:if>
				
				<xsl:if test="$notes_tr/span[@page=$page_id]">
					<span class="notes_tr">
						<xsl:for-each select="$notes_tr/span[@page=$page_id]">
							<xsl:copy>
								<xsl:copy-of select="@*[not(name()='page')]"/>
								<xsl:copy-of select="node()"/>
							</xsl:copy>
						</xsl:for-each>
					</span>
				</xsl:if>
				
			</span><xsl:text>&#xa;</xsl:text>
		</xsl:if>
		
		<xsl:text>&#xa;</xsl:text>
		<br/><xsl:text>&#xa;</xsl:text>
<!--		<xsl:if test="following::tei:pb">-->
			<a class="txm-page" title="{count(preceding::*[local-name()=$pagination-element]) + $page-number-adjust}" next-word-id="{$next-word-id}"/>
		<!--</xsl:if>-->
		<span class="{$editionpagetype}"> <xsl:value-of select="$pagenumber"/> </span><br/><xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	
	<xsl:variable name="notes_au" as="element()">
		<notes_au>
			<xsl:for-each select="//tei:note[@type='au']">
				<xsl:variable name="note_count_au">
					<xsl:number count="tei:note[@type='au']" level="any" from="tei:pb"></xsl:number>
				</xsl:variable>
				<xsl:variable name="note_mark_au">
					<xsl:choose>
						<xsl:when test="$note_count_au='0'"></xsl:when>
						<xsl:when test="$note_count_au='1'">*</xsl:when>
						<xsl:when test="$note_count_au='2'">**</xsl:when>
						<xsl:when test="$note_count_au='3'">***</xsl:when>
						<xsl:otherwise>****</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="page_id" as="xs:integer"><xsl:number count="tei:pb" level="any"/></xsl:variable>
				<span class="note" page="{$page_id}">
					<span class="notemark"><a href="#noteref_au_{$note_count_au}" name="note_au_{$note_count_au}"><xsl:value-of select="$note_mark_au"/></a> </span>
					<xsl:apply-templates/>
				</span>
			</xsl:for-each>
		</notes_au>
	</xsl:variable>
	
	<xsl:variable name="notes_tr" as="element()">
		<notes_tr>
			<xsl:for-each select="//tei:note[@type='tr']">
				<xsl:variable name="note_count_tr" as="xs:integer">
					<xsl:number count="tei:note[@type='tr']" level="any" from="tei:pb"></xsl:number>
				</xsl:variable>
				<xsl:variable name="page_id" as="xs:integer"><xsl:number count="tei:pb" level="any"/></xsl:variable>
				<span class="note" page="{$page_id}">
					<span class="notemark"><a href="#noteref_tr_{$note_count_tr}" name="note_tr_{$note_count_tr}"><xsl:number value="$note_count_tr" format="a"/></a> </span>
					<xsl:apply-templates/>
				</span>
			</xsl:for-each>
		</notes_tr>
	</xsl:variable>
	
	<xsl:variable name="notes_gen" as="element()">
		<notes_gen>
			<xsl:for-each select="//tei:note[not(@type)]">
				<xsl:variable name="note_count">
					<xsl:number count="tei:note[not(@type)]" level="any"></xsl:number>
				</xsl:variable>
				
				<xsl:variable name="page_id" as="xs:integer"><xsl:number count="tei:pb" level="any"/></xsl:variable>
				<span class="note" page="{$page_id}">
					<span class="notemark"><a href="#noteref_{$note_count}" name="note_{$note_count}"><xsl:value-of select="$note_count"/></a> </span>
					<xsl:apply-templates/>
				</span>
			</xsl:for-each>
		</notes_gen>
	</xsl:variable>
	
	
	
	<!-- Notes -->
	<xsl:template match="tei:note">
		<!--<span style="color:violet"> [<b>Note :</b> <xsl:apply-templates/>] </span>-->	
		<xsl:variable name="note_count"><xsl:value-of select="count(preceding::tei:note[not(@type)]) + 1"/></xsl:variable>
		<xsl:variable name="note_count_tr"><xsl:number count="tei:note[@type='tr']" from="tei:pb" level="any"/></xsl:variable>
		<xsl:variable name="note_count_au"><xsl:number count="tei:note[@type='au']" from="tei:pb" level="any"/></xsl:variable>
		<xsl:variable name="note_mark_au">
			<xsl:choose>
				<xsl:when test="$note_count_au='0'"></xsl:when>
				<xsl:when test="$note_count_au='1'">*</xsl:when>
				<xsl:when test="$note_count_au='2'">**</xsl:when>
				<xsl:when test="$note_count_au='3'">***</xsl:when>
				<xsl:otherwise>****</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="note_content">
			<xsl:choose>
				<xsl:when test="descendant::txm:form">
					<xsl:for-each select="descendant::txm:form">						
						<xsl:value-of select="."/>
						<xsl:if test="not(matches(following::txm:form[1],'^[.,\)]')) and not(matches(.,'^\S+[''’]$|^[‘\(]$'))">
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise><xsl:value-of select="normalize-space(.)"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="not(@type)">
				<a title="{$note_content}" style="font-size:75%;position:relative;top:-5px" href="#note_{$note_count}" name="noteref_{$note_count}"><xsl:value-of select="$note_count"/></a>
			</xsl:when>
			<xsl:when test="@type='au'">
				<a title="{$note_content}" style="position:relative;top:-5px" href="#note_au_{$note_count_au}" name="noteref_au_{$note_count_au}"><xsl:value-of select="$note_mark_au"></xsl:value-of></a>
			</xsl:when>
			<xsl:when test="@type='tr'">
				<a title="{$note_content}" style="font-size:75%;position:relative;top:-5px" href="#note_tr_{$note_count_tr}" name="noteref_tr_{$note_count_tr}">[<xsl:number value="$note_count_tr" format="a"/>]</a>
			</xsl:when>
			<xsl:when test="@type='temp'"></xsl:when>
			<xsl:otherwise><span class="noteref" title="Type de note non reconnu : {$note_content}">[•]</span></xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="spacing"/>                                
	</xsl:template>
	
	<xsl:template match="tei:bibl">
		<span class="noteref" title="{normalize-space(.)}">[•]</span>
	</xsl:template>
	
	<xsl:template match="a[@class='txmpageref']">
		<xsl:copy-of select="."/>
	</xsl:template>
	
	<!--<xsl:template match="tei:note[@place='inline']">
		<span class="noteinline">
			<xsl:apply-templates/>
		</span>
	</xsl:template>
   -->             
                <xsl:template match="//tei:w"><span class="w">
                	<xsl:choose>
                		<xsl:when test="descendant::tei:c//txm:form">
                			<xsl:apply-templates select="descendant::tei:c"/>
                		</xsl:when>
                		<xsl:otherwise>
                			<xsl:if test="@id">
                				<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
                			</xsl:if>
                			<xsl:attribute name="title">
                				<xsl:if test="@id">
                					<xsl:value-of select="@id"></xsl:value-of>
                				</xsl:if>
                				<xsl:if test="ancestor::tei:corr">
                					<xsl:value-of select="concat(' sic : ',@sic)"/>
                				</xsl:if>
                				<xsl:if test="ancestor::tei:reg">
                					<xsl:value-of select="concat(' orig : ',@orig)"/>
                				</xsl:if>
                				<xsl:choose>
                					<xsl:when test="descendant::txm:ana">	
                						<xsl:for-each select="descendant::txm:ana">
                							<xsl:value-of select="concat(' ',substring-after(@type,'#'),' : ',.)"/>
                						</xsl:for-each>
                					</xsl:when>
                					<xsl:otherwise>
                						<xsl:for-each select="@*[not(local-name()='id')]">
                							<xsl:value-of select="concat(' ',name(.),' : ',.)"/>
                						</xsl:for-each>                                				
                					</xsl:otherwise>
                				</xsl:choose>
                				<xsl:if test="@*[matches(name(.),'pos$')]">
                				</xsl:if>                                		
                			</xsl:attribute>
                			<xsl:choose>
                				<xsl:when test="descendant::txm:form">
                					<!--<xsl:apply-templates select="txm:form"/>-->
                					<xsl:apply-templates select="descendant::txm:ana[@type='#crochets']"/>
                				</xsl:when>
                				<xsl:otherwise><xsl:apply-templates/></xsl:otherwise>
                			</xsl:choose>
                		</xsl:otherwise>
                	</xsl:choose>
                                </span><xsl:call-template name="spacing"/></xsl:template>
                
<!--                <xsl:template match="//txm:form">
                                <xsl:apply-templates/>
                </xsl:template>
-->                
	
	<xsl:template match="txm:ana[@type='#crochets']">
		<xsl:choose>
			<xsl:when test="matches(.,'\|\|')">
				<xsl:call-template name="superscript"><xsl:with-param name="string"><xsl:value-of select="substring-before(.,'||')"/></xsl:with-param></xsl:call-template>
				<xsl:apply-templates select="preceding-sibling::txm:form//tei:pb"/>
				<xsl:call-template name="superscript"><xsl:with-param name="string"><xsl:value-of select="substring-after(.,'||')"/></xsl:with-param></xsl:call-template>
			</xsl:when>
			<xsl:otherwise><xsl:call-template name="superscript"><xsl:with-param name="string"><xsl:value-of select="."/></xsl:with-param></xsl:call-template></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
<xsl:template name="superscript">
	<xsl:param name="string">
		<xsl:value-of select="."/>
	</xsl:param>
	<xsl:analyze-string select="$string" regex="\\([^/]*)/">
		<xsl:matching-substring>
			<span class="hi-sup"><xsl:call-template name="crochets"><xsl:with-param name="string"><xsl:value-of select="regex-group(1)"/></xsl:with-param></xsl:call-template></span>
		</xsl:matching-substring>
		<xsl:non-matching-substring>
			<xsl:call-template name="crochets"/>
		</xsl:non-matching-substring>
	</xsl:analyze-string>
	
</xsl:template>

<xsl:template name="crochets">
	<xsl:param name="string">
		<xsl:value-of select="."/>
	</xsl:param>
	<xsl:analyze-string select="$string" regex="\[([^\]]*)/([^\]]*)\]">
		<xsl:matching-substring>
			<xsl:if test="matches(regex-group(1),'\S')">
				<span class="del"><xsl:call-template name="accolades"><xsl:with-param name="string"><xsl:value-of select="regex-group(1)"/></xsl:with-param></xsl:call-template></span>
			</xsl:if>
			<xsl:if test="matches(regex-group(2),'\S')">
				<span class="add"><xsl:call-template name="accolades"><xsl:with-param name="string"><xsl:value-of select="regex-group(2)"/></xsl:with-param></xsl:call-template></span>
			</xsl:if>
		</xsl:matching-substring>
		<xsl:non-matching-substring>
			<xsl:call-template name="accolades"/>
		</xsl:non-matching-substring>
	</xsl:analyze-string>
</xsl:template>

<xsl:template name="accolades">
	<xsl:param name="string"><xsl:value-of select="."/></xsl:param>
	<xsl:value-of select="translate($string,'{}','')"/>
</xsl:template>

	<xsl:template name="spacing">
		<xsl:choose>
			<xsl:when test="$inputtype='xmltxm'">
				<xsl:call-template name="spacing-xmltxm"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="spacing-xmlw"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="spacing-xmlw">
		<xsl:choose>
			<xsl:when test="ancestor::tei:w"/>
			<xsl:when test="following::tei:w[1][matches(.,'^\s*[.,)\]]+\s*$')]"/>
			<xsl:when test="following::tei:w[1][matches(.,'^\s*-[A-Za-z]')]"/> <!-- les clitiques -->
			<xsl:when test="matches(.,'^\s*[(\[‘]+$|\w(''|’)\s*$')"></xsl:when>
			<xsl:when test="position()=last() and (ancestor::tei:choice or ancestor::tei:supplied[not(@rend='multi_s')])"></xsl:when>
			<xsl:when test="following-sibling::*[1][self::tei:note]"></xsl:when>
			<xsl:when test="following::tei:w[1][matches(.,'^\s*[:;!?]+\s*$')]">
				<xsl:text>&#xa0;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text> </xsl:text>
			</xsl:otherwise>
		</xsl:choose>                
	</xsl:template>

	<xsl:template name="spacing-xmltxm">
		<xsl:choose>
			<xsl:when test="ancestor::tei:w"/>
			<xsl:when test="following::tei:w[1][matches(descendant::txm:form[1],'^[.,)\]]+$')]"/>
			<xsl:when test="following::tei:w[1][matches(descendant::txm:form[1],'^-[A-Za-z]')]"/> <!-- les clitiques -->
			<xsl:when test="matches(descendant::txm:form[1],'^[(\[‘]+$|\w(''|’)$')"></xsl:when>
			<xsl:when test="position()=last() and (ancestor::tei:choice or ancestor::tei:supplied[not(@rend='multi_s')])"></xsl:when>
			<xsl:when test="following-sibling::*[1][self::tei:note]"></xsl:when>
			<xsl:when test="following::tei:w[1][matches(descendant::txm:form[1],'^[:;!?]+$')]">
				<xsl:text>&#xa0;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text> </xsl:text>
			</xsl:otherwise>
		</xsl:choose>                
	</xsl:template>

                
</xsl:stylesheet>
