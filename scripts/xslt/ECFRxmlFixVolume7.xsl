<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml"
		doctype-system="C:\GSA-Acquisition-Tools\TOOLS\StructureGSA_FAR\xml\EFC\ECFR.dtd"
		indent="yes"/>

	<xsl:template match="@NODE">
		<xsl:attribute name="NODE">
			<xsl:value-of select="translate(., ':\.', '__')"/>
		</xsl:attribute>
	</xsl:template>

	<xsl:variable name="TitleNumber">
		<xsl:value-of select="/DLPSTEXTCLASS/HEADER/FILEDESC/PUBLICATIONSTMT/IDNO"/>
	</xsl:variable>

	<xsl:template match="/DLPSTEXTCLASS/TEXT/BODY/ECFRBRWS[1]"/>
	<xsl:template match="/DLPSTEXTCLASS/TEXT/BODY/ECFRBRWS[2]"/>
	<xsl:template match="/DLPSTEXTCLASS/TEXT/BODY/ECFRBRWS[3]"/>
	<xsl:template match="/DLPSTEXTCLASS/TEXT/BODY/ECFRBRWS[4]"/>
	<xsl:template match="/DLPSTEXTCLASS/TEXT/BODY/ECFRBRWS[5]"/>
	<xsl:template match="/DLPSTEXTCLASS/TEXT/BODY/ECFRBRWS[6]"/>



	<xsl:template match="//DIV1">
		<xsl:variable name="NODEFIXED">
			<xsl:value-of select="translate(@NODE, ':\.', '__')"/>
		</xsl:variable>
		<xsl:variable name="NFIXED">
			<xsl:value-of select="translate(@N, ':§\.()–\ ', '_______')"/>
		</xsl:variable>
		<xsl:variable name="NODECLEANED">
			<xsl:text>Volume_</xsl:text>
			<xsl:value-of select="normalize-space($NFIXED)"/>
		</xsl:variable>
		<DIV1>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="NODE">
				<xsl:choose>
					<xsl:when test="@N = '' or @N = '0'">
						<DIV1 node="$NODEFIXED">"> <xsl:text>tce_</xsl:text><xsl:value-of
								select="normalize-space($NODEFIXED)"/>
						</DIV1>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="normalize-space($NODECLEANED)"/>
						<xsl:text>_T</xsl:text>
						<xsl:value-of select="normalize-space($NODEFIXED)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:apply-templates/>
		</DIV1>
	</xsl:template>

	<xsl:template match="//DIV2">
		<xsl:variable name="NODEFIXED">
			<xsl:value-of select="translate(@NODE, ':\.', '__')"/>
		</xsl:variable>
		<xsl:variable name="NFIXED">
			<xsl:value-of select="translate(@N, ':§\.()–\ ', '_______')"/>
		</xsl:variable>
		<xsl:variable name="NODECLEANED">
			<xsl:text>SubVolume_</xsl:text>
			<xsl:value-of select="normalize-space($NFIXED)"/>
		</xsl:variable>
		<DIV2>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="NODE">
				<xsl:choose>
					<xsl:when test="@N = '' or @N = '0'">
						<xsl:text>tce_</xsl:text>
						<xsl:value-of select="normalize-space($NODEFIXED)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="normalize-space($NODECLEANED)"/>
						<xsl:text>_T</xsl:text>
						<xsl:value-of select="normalize-space($NODEFIXED)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:apply-templates/>
		</DIV2>
	</xsl:template>

	<xsl:template match="//DIV3">
		<xsl:variable name="NODEFIXED">
			<xsl:value-of select="translate(@NODE, ':\.', '__')"/>
		</xsl:variable>
		<xsl:variable name="NFIXED">
			<xsl:value-of select="translate(@N, ':§\.()–\ ', '_______')"/>
		</xsl:variable>
		<xsl:variable name="NODECLEANED">
			<xsl:text>Chapter_</xsl:text>
			<xsl:value-of select="normalize-space($NFIXED)"/>
		</xsl:variable>

		<DIV3>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="NODE">
				<xsl:choose>
					<xsl:when test="@N = '' or @N = '0'">
						<xsl:text>tce_</xsl:text>
						<xsl:value-of select="normalize-space($NODEFIXED)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="normalize-space($NODECLEANED)"/>
						<xsl:text>_T</xsl:text>
						<xsl:value-of select="normalize-space($NODEFIXED)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:apply-templates select="HEAD | P"/>
		
<xsl:for-each select="DIV4">
	<xsl:variable name="NODEFIXED">
		<xsl:value-of select="translate(@NODE, ':\.', '__')"/>
	</xsl:variable>
	<xsl:variable name="NFIXED">
		<xsl:value-of select="translate(@N, ':§\.()–\ ', '_______')"/>
	</xsl:variable>
	<xsl:variable name="NODECLEANED">
		<xsl:text>Subchapter_</xsl:text>
		<xsl:value-of select="normalize-space($NFIXED)"/>
	</xsl:variable>
	<DIV4>
		<xsl:apply-templates select="@*"/>
		<xsl:attribute name="NODE">
			<xsl:choose>
				<xsl:when test="@N = '' or @N = '0'">
					<xsl:text>tce_</xsl:text>
					<xsl:value-of select="normalize-space($NODEFIXED)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space($NODECLEANED)"/>
					<xsl:text>_T</xsl:text>
					<xsl:value-of select="normalize-space($NODEFIXED)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:copy-of select="HEAD[1]"/>
<xsl:apply-templates select="DIV5 | DIV9"/>
	</DIV4>	
</xsl:for-each>
			<xsl:apply-templates select="DIV5"/>
		</DIV3>
	</xsl:template>

	<!--<xsl:template match="//DIV4">
		<xsl:variable name="NODEFIXED">
			<xsl:value-of select="translate(@NODE, ':\.', '__')"/>
		</xsl:variable>
		<xsl:variable name="NFIXED">
			<xsl:value-of select="translate(@N, ':§\.()–\ ', '_______')"/>
		</xsl:variable>
		<xsl:variable name="NODECLEANED">
			<xsl:text>Subchapter_</xsl:text>
			<xsl:value-of select="normalize-space($NFIXED)"/>
		</xsl:variable>
		<DIV4>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="NODE">
				<xsl:choose>
					<xsl:when test="@N = '' or @N = '0'">
						<xsl:text>tce_</xsl:text>
						<xsl:value-of select="normalize-space($NODEFIXED)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="normalize-space($NODECLEANED)"/>
						<xsl:text>_T</xsl:text>
						<xsl:value-of select="normalize-space($NODEFIXED)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:copy-of select="HEAD[1]"/>
			<xsl:choose>
				<xsl:when
					test="ancestor::DIV1/HEAD[contains(text(), '48 - Federal Acquisition Regulations System-\-Volume 1')]">
					<DIV4a NODE="Spacer_{generate-id()}">
						<HEAD>Federal Acquisition Regulation</HEAD>
						<xsl:apply-templates select="DIV5 | DIV9"/>
					</DIV4a>
				</xsl:when>
				<xsl:when
					test="ancestor::DIV1/HEAD[contains(text(), '48 - Federal Acquisition Regulations System-\-Volume 2')]">
					<DIV4a NODE="Spacer_{generate-id()}">
						<HEAD>Federal Acquisition Regulation</HEAD>
						<xsl:apply-templates select="DIV5 | DIV9"/>
					</DIV4a>
				</xsl:when>
				<xsl:otherwise>
					<DIV4a NODE="Spacer_{generate-id()}">
						<HEAD>Powered By GSA Acquisition.Gov</HEAD>
						<xsl:apply-templates select="DIV5 | DIV9"/>
					</DIV4a>
				</xsl:otherwise>
			</xsl:choose>
		</DIV4>
	</xsl:template>-->

	<xsl:template match="//DIV5">
		<xsl:variable name="NODEFIXED">
			<xsl:value-of select="translate(@NODE, ':\.', '__')"/>
		</xsl:variable>
		<xsl:variable name="NFIXED">
			<xsl:value-of select="translate(@N, ':§\.()–\ ', '_______')"/>
		</xsl:variable>
		<xsl:variable name="NODECLEANED">
			<xsl:text>Part_</xsl:text>
			<xsl:value-of select="normalize-space($NFIXED)"/>
		</xsl:variable>
		<DIV5>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="NODE">
				<xsl:choose>
					<xsl:when test="@N = '' or @N = '0'">
						<xsl:text>tce_</xsl:text>
						<xsl:value-of select="normalize-space($NODEFIXED)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="normalize-space($NODECLEANED)"/>
						<xsl:text>_T</xsl:text>
						<xsl:value-of select="normalize-space($NODEFIXED)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:apply-templates/>
		</DIV5>
	</xsl:template>

	<xsl:template match="//DIV6">
		<xsl:variable name="NODEFIXED">
			<xsl:value-of select="translate(@NODE, ':\.', '__')"/>
		</xsl:variable>
		<xsl:variable name="NFIXED">
			<xsl:value-of select="translate(@N, ':§\.()–\ ', '_______')"/>
		</xsl:variable>
		<xsl:variable name="NODECLEANED">
			<xsl:text>Subpart_</xsl:text>
			<xsl:value-of select="normalize-space($NFIXED)"/>
		</xsl:variable>
		<DIV6>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="NODE">
				<xsl:choose>
					<xsl:when test="@N = '' or @N = '0'">
						<xsl:text>tce_</xsl:text>
						<xsl:value-of select="normalize-space($NODEFIXED)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="normalize-space($NODECLEANED)"/>
						<xsl:text>_T</xsl:text>
						<xsl:value-of select="normalize-space($NODEFIXED)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:apply-templates/>
		</DIV6>
	</xsl:template>

	<xsl:template match="//DIV7">
		<xsl:variable name="NODEFIXED">
			<xsl:value-of select="translate(@NODE, ':\.', '__')"/>
		</xsl:variable>
		<xsl:variable name="NFIXED">
			<xsl:value-of select="translate(@N, ':§\.()–\ ', '_______')"/>
		</xsl:variable>
		<xsl:variable name="NODECLEANED">
			<xsl:text>Subtopic_</xsl:text>
			<xsl:value-of select="normalize-space($NFIXED)"/>
		</xsl:variable>
		<DIV7>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="NODE">
				<xsl:choose>
					<xsl:when test="@N = '' or @N = '0'">
						<xsl:text>tce_</xsl:text>
						<xsl:value-of select="normalize-space($NODEFIXED)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="normalize-space($NODECLEANED)"/>
						<xsl:text>_T</xsl:text>
						<xsl:value-of select="normalize-space($NODEFIXED)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:apply-templates/>
		</DIV7>
	</xsl:template>

	<xsl:template match="//DIV8">
		<xsl:variable name="NODEFIXED">
			<xsl:value-of select="translate(@NODE, ':\.', '__')"/>
		</xsl:variable>
		<xsl:variable name="NFIXED">
			<xsl:value-of select="translate(@N, ':§\.()–\ ', '_______')"/>
		</xsl:variable>
		<xsl:variable name="NODENOTCLEANED">
			<xsl:text>Section_</xsl:text>
			<xsl:value-of select="normalize-space($NFIXED)"/>
		</xsl:variable>
		<xsl:variable name="NODECLEANED">
			<xsl:value-of select="translate($NODENOTCLEANED, ':§\.()–\ ', '_')"/>
		</xsl:variable>
		<DIV8>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="NODE">
				<xsl:choose>
					<xsl:when test="@N = '' or @N = '0'">
						<xsl:text>tce_</xsl:text>
						<xsl:value-of select="normalize-space($NODEFIXED)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="normalize-space($NODECLEANED)"/>
						<xsl:text>_T</xsl:text>
						<xsl:value-of select="normalize-space($NODEFIXED)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:apply-templates/>
		</DIV8>
	</xsl:template>

	<xsl:template match="//DIV9">
		<xsl:variable name="NODEFIXED">
			<xsl:value-of select="translate(@NODE, ':\.', '__')"/>
		</xsl:variable>
		<xsl:variable name="NFIXED">
			<xsl:value-of select="translate(@N, ':§\.()–\ ', '_______')"/>
		</xsl:variable>
		<xsl:variable name="NODECLEANED">
			<xsl:text>Appendix_</xsl:text>
			<xsl:value-of select="normalize-space($NFIXED)"/>
		</xsl:variable>

		<DIV9>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="NODE">
				<xsl:choose>
					<xsl:when test="@N = '' or @N = '0'">
						<xsl:text>tce_</xsl:text>
						<xsl:value-of select="normalize-space($NODEFIXED)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="normalize-space($NODECLEANED)"/>
						<xsl:text>_T</xsl:text>
						<xsl:value-of select="normalize-space($NODEFIXED)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:apply-templates/>
		</DIV9>
	</xsl:template>

	<xsl:template match="@* | node() | comment() | processing-instruction()">
		<xsl:param name="topic-number"/>
		<xsl:copy>
			<xsl:apply-templates select="@* | node() | comment() | processing-instruction()">
				<xsl:with-param name="topic-number" select="$topic-number"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="BODY">
		<xsl:copy>
			<xsl:apply-templates select="ECFRBRWS[position() &lt;= 8]"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="TITLE">
		<xsl:copy>
			<xsl:value-of select="translate(., ':', '_')"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="img">
		<xsl:copy>
			<xsl:attribute name="src">
				<xsl:call-template name="getImgSrc">
					<xsl:with-param name="src" select="@src"/>
				</xsl:call-template>
			</xsl:attribute>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="CITA">
		<xsl:choose>
			<xsl:when
				test="ancestor::DIV1/HEAD[contains(text(), 'Title 48 - Federal Acquisition Regulations System-\-Volume 1')]"/>
			<xsl:when
				test="ancestor::DIV1/HEAD[contains(text(), 'Title 48 - Federal Acquisition Regulations System-\-Volume 2')]"/>
			<xsl:otherwise>
				<!--<CITA>
					<xsl:apply-templates select="@*"/>
					<xsl:apply-templates></xsl:apply-templates>
				</CITA>-->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="getImgSrc">
		<xsl:param name="src"/>
		<xsl:choose>
			<xsl:when test="contains($src, '/')">
				<xsl:call-template name="getImgSrc">
					<xsl:with-param name="src">
						<xsl:value-of select="substring-after($src, '/')"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('./Graphics/', $src)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
