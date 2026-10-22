<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tce="http://www.thecontentera.com/" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
	exclude-result-prefixes="tce xs ditaarch">
	<xsl:output method="xml" indent="yes" doctype-public="-//OASIS//DTD DITA Map//EN"
		doctype-system="C:\GSA-Acquisition-tools\TOOLS\StructureGSA_FAR\xml\DITA_1.2\app\technicalContent\dtd\map.dtd"/>

	
	<xsl:template match="DIV1">
		<xsl:for-each select="DIV3">
		<xsl:variable name="href" select="concat(@NODE, '.dita')"/>
		<xsl:variable name="hrefmap" select="concat(@NODE, '.ditamap')"/>
		<xsl:variable name="Cover4Chapterhref" select="concat(Cover4Chapter, @NODE, '.dita')"/>
		<xsl:variable name="hrefVolume4Chapter" select="concat(Volume4Chapter, @NODE, '.dita')"/>
		<xsl:result-document method="xml" href="{$hrefmap}"
			doctype-public="-//OASIS//DTD DITA Map//EN" doctype-system="C:\GSA-Acquisition-tools\TOOLS\StructureGSA_FAR\xml\DITA_1.2\app\technicalContent\dtd\map.dtd">
		<map outputclass="ecfr" otherprops="String2Xref">
			<title>
				<xsl:value-of select="HEAD//text()"/>
			</title>
			<topicref navtitle="Volume Number" href="Volume{$hrefVolume4Chapter}" props="{tce:getPropsText(HEAD[1])}"
			outputclass="Volume">
				<topicref navtitle="Chapter Title" href="{$Cover4Chapterhref}"
					props="{tce:getPropsText(HEAD[1])}"> 
				</topicref>
		</topicref>
			
				<xsl:apply-templates select="DIV4 | DIV5"/>
			
		</map>
		</xsl:result-document>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="DIV4">
		<xsl:variable name="href" select="concat(@NODE, '.dita')"/>
		<xsl:variable name="getprops" select="tce:getPropsText(HEAD[1])"/>
		<topicref navtitle="{HEAD//text()}" href="{$href}" 
			outputclass="SubChapter">
			<xsl:choose>
				<xsl:when test="(contains(HEAD[1]//text(),'-'))"><xsl:attribute name="props"><xsl:value-of select="$getprops"/></xsl:attribute></xsl:when>
				<xsl:otherwise><xsl:attribute name="props">SubChapter <xsl:value-of select="@N"/></xsl:attribute></xsl:otherwise>
			</xsl:choose>
			<!-- <xsl:apply-templates select="DIV4a"/> -->
			<xsl:apply-templates select="DIV5 | DIV9"/>
		</topicref>
	</xsl:template>

	<xsl:template match="DIV4a">
		<xsl:variable name="href" select="concat(@NODE, '.dita')"/>
		<topicref navtitle="{HEAD//text()}" href="{$href}" outputclass="Spacer">
			<xsl:apply-templates select="DIV5 | DIV9"/>
		</topicref>
	</xsl:template>

	<xsl:template match="DIV5">
		<xsl:variable name="href" select="concat(@NODE, '.dita')"/>
		<xsl:variable name="getprops" select="tce:getPropsText(HEAD[1])"/>
		<topicref navtitle="{HEAD//text()}" href="{$href}" 
			outputclass="Part">
			<xsl:choose>
				<xsl:when test="(contains(HEAD[1]//text(),'-'))"><xsl:attribute name="props"><xsl:value-of select="$getprops"/></xsl:attribute></xsl:when>
				<xsl:otherwise><xsl:attribute name="props">Part <xsl:value-of select="@N"/></xsl:attribute></xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="DIV6 | DIV8 | DIV9"/>
		</topicref>
	</xsl:template>

	<xsl:template match="DIV6">
		<xsl:variable name="href" select="concat(@NODE, '.dita')"/>
		<xsl:variable name="getprops" select="tce:getPropsText(HEAD[1])"/>
		<topicref navtitle="{HEAD//text()}" href="{$href}" 
			outputclass="SubPart">
			<xsl:choose>
				<xsl:when test="(contains(HEAD[1]//text(),'-'))"><xsl:attribute name="props"><xsl:value-of select="$getprops"/></xsl:attribute></xsl:when>
				<xsl:otherwise><xsl:attribute name="props">Subpart <xsl:value-of select="@N"/></xsl:attribute></xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="DIV8"/>
		</topicref>
	</xsl:template>

	<xsl:template match="DIV8">
		<xsl:variable name="href" select="concat(@NODE, '.dita')"/>
		<topicref navtitle="{HEAD[last()]//text()}" href="{$href}"
			props="{tce:getPropsText(HEAD[last()])}" outputclass="Section">
		</topicref>
	</xsl:template>

	<xsl:template match="DIV9">
		<xsl:variable name="href" select="concat(@NODE, '.dita')"/>
		<topicref navtitle="{HEAD//text()}" href="{$href}" props="{tce:getPropsText(HEAD[1])}"
			outputclass="Appendix">
		</topicref>
	</xsl:template>

	

	<xsl:template match="HEAD">
		<title class="- topic/title ">
			<xsl:if test="../@TYPE='SUBPART'"><xsl:attribute name="outputclass">Subpart</xsl:attribute></xsl:if>
			<xsl:variable name="text-raw">
				<xsl:value-of select="text()"/>
			</xsl:variable>
			<xsl:variable name="text" select="normalize-space($text-raw)"/>
			<xsl:choose>
				<xsl:when test="matches($text, '^\d+.\d+(\-\d+)?')">
					<ph props="autonumber">
						<xsl:value-of select="replace($text, '^(\d+.\d+(\-\d+)?).*', '$1')"/>
					</ph>
					<xsl:value-of select="replace($text, '^\d+.\d+(\-\d+)?', '')"/>
				</xsl:when>
				<xsl:when test="matches(lower-case($text), '^part\s\d+\s', 'i')">
					<ph props="autonumber">
						<xsl:value-of select="replace($text, '^(^part\s\d+).*', '$1', 'i')"/>
					</ph>
					<xsl:value-of select="replace($text, '^part\s\d+', '', 'i')"/>
				</xsl:when>
				<xsl:when test="matches(lower-case($text), '^subpart\s\d+\.\d+\s', 'i')">
					<ph props="autonumber">
						<xsl:value-of select="replace($text, '^(^subpart\s\d+\.\d+).*', '$1', 'i')"
						/>
					</ph>
					<xsl:value-of select="replace($text, '^subpart\s\d+\.\d+', '', 'i')"/>
				</xsl:when>
				<xsl:when test="matches(lower-case($text), '^subchapter\s[a-z]+\s', 'i')">
					<ph props="autonumber">
						<xsl:value-of select="replace($text, '^(^subchapter\s[a-z]+).*', '$1', 'i')"
						/>
					</ph>
					<xsl:value-of select="replace($text, '^subchapter\s[a-z]+', '', 'i')"/>
				</xsl:when>
				<xsl:when test="matches(lower-case($text), '^chapter\s\d+\s', 'i')">
					<ph props="autonumber">
						<xsl:value-of select="replace($text, '^(^chapter\s\d+).*', '$1', 'i')"/>
					</ph>
					<xsl:value-of select="replace($text, '^chapter\s\d+', '', 'i')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="text()"/>
				</xsl:otherwise>
			</xsl:choose>
		</title>
		
		
	</xsl:template>

	<xsl:template match="AUTH | SOURCE">
		<p>
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<xsl:template match="AUTH/HED | SOURCE/HED">
		<ph class="- topic/ph ">
			<xsl:value-of select="text()"/>
			<xsl:text> </xsl:text>
		</ph>
	</xsl:template>

	<xsl:template match="AUTH/PSPACE | SOURCE/PSPACE">
		<xsl:value-of select="text()"/>
	</xsl:template>

	<xsl:template match="DIV">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:function name="tce:getPropsText" as="xs:string">
		<xsl:param name="item"/>

		<xsl:variable name="item-text">
			<xsl:value-of select="$item//text()"/>
		</xsl:variable>

		<xsl:variable name="text" select="normalize-space($item-text)"/>
		<xsl:variable name="props-text">
			<xsl:choose>
				<xsl:when test="matches($text, '^\d+.\d+(\-\d+)?')">
					<xsl:value-of select="replace($text, '^(\d+.\d+(\-\d+)?).*', '$1')"/>
				</xsl:when>
				<!-- <xsl:when test="matches(lower-case($text), '^part\s\d+\s', 'i')">
					<xsl:value-of select="replace($text, '^(^part\s\d+).*', '$1', 'i')"/>
				</xsl:when>
				<xsl:when test="matches(lower-case($text), '^subpart\s\d+\.\d+\s', 'i')">
					<xsl:value-of select="replace($text, '^(^subpart\s\d+\.\d+).*', '$1', 'i')"/>
				</xsl:when>
				<xsl:when test="matches(lower-case($text), '^subchapter\s[a-z]+\s', 'i')">
					<xsl:value-of select="replace($text, '^(^subchapter\s[a-z]+).*', '$1', 'i')"/>
				</xsl:when>
				<xsl:when test="matches(lower-case($text), '^chapter\s\d+\s', 'i')">
					<xsl:value-of select="replace($text, '^(^chapter\s\d+).*', '$1', 'i')"/>
				</xsl:when> -->
				<xsl:otherwise>
					<xsl:value-of select="$text"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:sequence select="$props-text"/>
	</xsl:function>

	<!--	dropping-->
	<xsl:template
		match="EDNOTE | CFRTOC | SUBJECT | SECTNO | PTHD | PG | XREF | PUBPLACE | PUBLISHER | KEYWORDS | TEXTCLASS | PTHD | PROFILEDESC | FILEDESC"/>

	<!--Beginning of Tom's Additions-->

	<!--Pass through text-->
	<xsl:template match="E">
		<xsl:value-of select="text()"/>
	</xsl:template>
	<!--	Mapping range and elements-->
	<xsl:template match="BR">
		<lines/>
	</xsl:template>
	<xsl:template match="B">
		<b>
			<xsl:value-of select="text()"/>
		</b>
	</xsl:template>
	<xsl:template match="I">
		<i>
			<xsl:value-of select="text()"/>
		</i>
	</xsl:template>
	<xsl:template match="sup">
		<sup>
			<xsl:apply-templates/>
		</sup>
	</xsl:template>
	<xsl:template match="SU">
		<sup>
			<xsl:apply-templates/>
		</sup>
	</xsl:template>
	<xsl:template match="STARS">
		<p outputclass="STARS">* * * * *</p>
	</xsl:template>
	<xsl:template match="P-DASH">
		<p outputclass="P-DASH">
			<xsl:value-of select="text()"/> _______________________</p>
	</xsl:template>

	<!--	<xsl:template match="FRP">
		<p outputclass="FRP">
			<xsl:value-of select="text()"/> -\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-</p>
	</xsl:template>
-->
	<xsl:template match="NOTE">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="EFFDNOT">
		<note>
			<xsl:apply-templates/>
		</note>
	</xsl:template>

	<xsl:template match="EFFDNOT/HED">
		<p>
			<b>
				<xsl:value-of select="text()"/>
			</b>
		</p>
	</xsl:template>

	<xsl:template match="EFFDNOT/PSPACE">
		<p>
			<xsl:value-of select="text()"/>
		</p>
	</xsl:template>

	<xsl:template match="NOTE/HED">
		<p>
			<b>
				<xsl:value-of select="text()"/>
			</b>
		</p>
	</xsl:template>

	<!--	<xsl:template match="FP1-2">
		<p outputclass="FP1-2">
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<xsl:template match="FP-2">
		<p outputclass="FP-2">
			<xsl:apply-templates/>
		</p>
	</xsl:template>-->

	<xsl:template
		match="*[not(self::HEAD or self::img or self::EXTRACT or self::NOTE or self::FTNT) and (parent::EXTRACT or parent::DIV8) and not(self::P[@level > 0])]">
		<p outputclass="{name()}">
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<!--<xsl:template match="FP-DASH">
		<xsl:choose>
			<xsl:when test="not(preceding-sibling::*[1]/self::FP-DASH) and not(parent::EXTRACT)">
				<note>
					<p outputclass="FP-DASH">
						<xsl:apply-templates/>
					</p>
					<xsl:if test="following-sibling::*[1][self::FP-DASH or self::FP or self::FRP or self::FP-1]">
						<xsl:apply-templates select="following-sibling::*[1]"/>	
					</xsl:if>
				</note>
			</xsl:when>
			<xsl:otherwise>
				<p outputclass="FP-DASH">
					<xsl:apply-templates/>
				</p>
				<xsl:if test="following-sibling::*[1][self::FP-DASH or self::FP or self::FRP or self::FP-1]">
					<xsl:apply-templates select="following-sibling::*[1]"/>	
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		
		<xsl:if test="following-sibling::*[1][self::HD3]">
			<xsl:apply-templates select="following-sibling::*[1]"/>	
		</xsl:if>
	</xsl:template>-->

	<!--	<xsl:template match="FP[parent::EXTRACT]">
		<xsl:if test="not(preceding-sibling::*) or preceding-sibling::*[1][not(self::FP) and not(self::FP-DASH)]">
		<p outputclass="FP">
			<xsl:apply-templates/>			
		</p>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="FP[not(parent::EXTRACT)]">
		<note>
		<p outputclass="FP">
			<xsl:apply-templates/>
		</p>
		</note>
	</xsl:template>-->

	<xsl:template match="DIV[@class = 'table_foot']">
		<fn>
			<xsl:apply-templates/>
		</fn>
	</xsl:template>

	<!--	<xsl:template match="HD1">
		<p outputclass="HD1">
			<xsl:apply-templates/>
		</p>
	</xsl:template>
	<xsl:template match="HD2">
		<p outputclass="HD2">
			<xsl:apply-templates/>
		</p>
	</xsl:template>
	<xsl:template match="HD3">
		<p outputclass="HD3">
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<xsl:template match="SECHD">
		<p outputclass="SECHD">
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<xsl:template match="FRP">
		<p outputclass="FRP">
			<xsl:apply-templates/>
		</p>
	</xsl:template>
	<xsl:template match="LI">
		<p outputclass="LI">
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<xsl:template match="FTNT">
		<p outputclass="FTNT">
			<xsl:apply-templates/>
		</p>
	</xsl:template>
-->
	<!--End of Tom's additions-->

	<!--	<xsl:template match="FP-1">
		<xsl:if test="not(preceding-sibling::*) or preceding-sibling::*[1][not(self::FP-1)]">
			<xsl:text disable-output-escaping="yes">
				<![CDATA[<ul>]]>
			</xsl:text>
		</xsl:if>
		<li>
			<xsl:apply-templates/>
		</li>
		<xsl:if test="not(following-sibling::*) or following-sibling::*[1][not(self::FP-1)]">
			<xsl:text disable-output-escaping="yes">
				<![CDATA[</ul>]]>
			</xsl:text>
		</xsl:if>
	</xsl:template>-->

	<xsl:template match="EXTRACT">
		<note>
			<xsl:apply-templates select="node()"/>
		</note>
	</xsl:template>

	<xsl:template name="process-para-text">
		<xsl:param name="item"/>
		<xsl:param name="text"/>
		<xsl:variable name="text-full">
			<xsl:value-of select="$item//text()"/>
		</xsl:variable>
		<xsl:variable name="autonumber"
			select="replace($text-full, '^\s*(\(([a-zA-Z]|[0-9]+|[ivx])+\)).*', '$1', 's')"/>
		<xsl:variable name="para-text"
			select="replace($text-full, '^\s*(\(([a-zA-Z]|[0-9]+|[ivx])+\))\s*', '')"/>
		<ph props="autonumber">
			<xsl:value-of select="concat($autonumber, ' ')"/>
		</ph>
		<xsl:value-of select="$para-text"/>
	</xsl:template>
	<xsl:template match="P">
		<p>
			<!--<xsl:apply-templates select="@*"/>-->
			<xsl:attribute name="outputclass">
				<xsl:choose>
					<xsl:when test="@level > 0">
						<xsl:value-of select="concat('List', @level)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="'Normal'"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:apply-templates select="node()"/>
		</p>
	</xsl:template>

	<xsl:template match="CITA">
		<xsl:choose>
			<xsl:when test="ancestor::DIV1/HEAD[contains(text(),'Title 48 - Federal Acquisition Regulations System--Volume 1')]"></xsl:when>
			<xsl:when test="ancestor::DIV1/HEAD[contains(text(),'Title 48 - Federal Acquisition Regulations System--Volume 1')]"></xsl:when>
			<xsl:otherwise>
<!--         <msgblock outputclass="CITA" xml:space="preserve" class="+ topic/pre sw-d/msgblock ">
					<xsl:value-of select="text()"/>
		</msgblock>-->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="SECAUTH">
		<msgblock outputclass="SECAUTH" xml:space="preserve" class="+ topic/pre sw-d/msgblock ">
					<xsl:value-of select="text()"/>
				</msgblock>
	</xsl:template>
	<xsl:template match="TH | TD">
		<xsl:variable name="name" select="name()"/>
		<entry colname="{count(preceding-sibling::*[name() = $name]) + 1}">
			<xsl:if test="@align">
				<xsl:attribute name="align">
					<xsl:value-of select="@align"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</entry>
	</xsl:template>
	<xsl:template match="TR">
		<row>
			<xsl:apply-templates/>
		</row>
	</xsl:template>
	<!--			<xsl:template match="MATH">
				<xsl:apply-templates/>
				<xsl:if test="following-sibling::*[1][self::img or self::MATH or (self::DIV and DIV/TABLE)]">
					<xsl:apply-templates select="following-sibling::*[1]"/>
				</xsl:if>
			</xsl:template>-->
	<xsl:template match="img">
		<fig frame="all">
			<image href="Graphics/{replace(@src, '^.*/','')}" placement="inline"/>
		</fig>
		<xsl:if test="following-sibling::*[1][self::img or self::MATH or (self::DIV and DIV/TABLE)]">
			<xsl:apply-templates select="following-sibling::*[1]"/>
		</xsl:if>
	</xsl:template>
	<xsl:template match="DIV[@class = 'table_head']"/>

	<xsl:template match="table | tgroup | colspec | row | thead | tbody | entry">
		<xsl:element name="{name()}">
			<xsl:copy-of select="@* | node()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="TABLE">
		<xsl:variable name="cols">
			<xsl:for-each select="TR">
				<xsl:sort select="sum(TD/@colspan) + count(TD[not(@colspan)])" data-type="number"/>
				<xsl:if test="position() = last()">
					<xsl:value-of select="sum(TD/@colspan) + count(TD[not(@colspan)])"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<table>
			<xsl:if test="../preceding-sibling::DIV[@class = 'table_head']">
				<title>
					<xsl:value-of select="../preceding-sibling::DIV[@class = 'table_head']//text()"
					/>
				</title>
			</xsl:if>
			<!--<xsl:variable name="cols" select="count(TR[1]/*)"/>-->

			<tgroup cols="{$cols}" outputclass="FormatA">
				<xsl:for-each select="1 to $cols">
					<colspec colnum="{current()}" colname="{current()}" colsep="0"/>
				</xsl:for-each>
				<xsl:if test="TR[1][TH]">
					<thead>
						<xsl:apply-templates select="TR[1]"/>
					</thead>
				</xsl:if>
				<tbody>
					<xsl:apply-templates select="TR[TD]"/>
				</tbody>
			</tgroup>
		</table>
		<xsl:apply-templates select="*[not(self::DIV | self::TR | self::TD | self::TH)]"/>
	</xsl:template>
	<xsl:template match="ECFRBRWS">
		<xsl:apply-templates select="DIV1"/>
	</xsl:template>
	<xsl:template match="HEADER/FILEDESC/TITLESTMT/TITLE">
		<title>
			<xsl:value-of select="text()"/>
		</title>
	</xsl:template>
	<xsl:template match="DLPSTEXTCLASS">
		<map>
			<xsl:apply-templates select="HEADER/FILEDESC/TITLESTMT/TITLE"/>
			<xsl:apply-templates select="TEXT/BODY/ECFRBRWS"/>
		</map>
	</xsl:template>
</xsl:stylesheet>
