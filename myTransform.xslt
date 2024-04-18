<?xml version="1.0" encoding="UTF-8"?>
<?altova_samplexml file:///C:/Users/aaron/Desktop/Coding/4D2/xmlTemplate.xml?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
	xmlns:l="local"
	xmlns:foaf="http://xmlns.com/foaf/spec/"
	xmlns:vgo="http://purl.org/net/VideoGameOntology#"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:fibo-loan-spc-crd="https://spec.edmcouncil.org/fibo/ontology/master/latest/LOAN/LoansSpecific/CardAccounts/"
	xmlns:schema-org="http://schema.org/">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	
	<xsl:key name="mediaChildren" match="l:Library/l:Media/*" use="name()"/>
	<xsl:variable name="ownerName" select="l:Library/l:Owner/text()"/>

	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="l:Library">
		<rdf:RDF>
			<!-- isInstalled and Series had to be hardcoded since there was no way of doing this with xslt -->
			<rdf:Description rdf:about="isInstalled">
				<rdf:type rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#Property"/>
				<rdf:label>isInstalled</rdf:label>
				<rdf:comment>A boolean property to indicate whether a game is installed on the device.</rdf:comment>
				<rdf:domain rdf:resource="http://schema.org/SoftwareApplication"/>
				<rdf:range rdf:resource="http://www.w3.org/2001/XMLSchema#boolean"/>
			</rdf:Description>
			
			<rdf:Description rdf:about="Series">
				<rdf:type rdf:resource="http://purl.org/dc/terms/Collection"/>
			</rdf:Description>
			
			<rdf:Description rdf:about="Series">
				<dcterms:isRequiredBy rdf:resource="Media"/>
			</rdf:Description>
			
			<rdf:Description rdf:about="Library">
				<rdf:type rdf:resource="http://purl.org/dc/terms/Collection"/>
			</rdf:Description>
			
			<rdf:Description rdf:about="Library">
				<dc:title><xsl:value-of select="$ownerName"/>'s Library</dc:title>
			</rdf:Description>
			
			<rdf:Description rdf:about="Library">
				<dc:creator><xsl:value-of select="$ownerName"/></dc:creator>
			</rdf:Description>
			
			<xsl:for-each select="*">
				<rdf:Description rdf:about="Library">					
					<dcterms:hasPart><xsl:value-of select="name()"/></dcterms:hasPart>
				</rdf:Description>
				
				<rdf:Description rdf:about="Library">					
					<dcterms:requires><xsl:value-of select="name()"/></dcterms:requires>
				</rdf:Description>
			</xsl:for-each>
			
			<xsl:apply-templates/>
		</rdf:RDF>
	</xsl:template>
	
	
	<xsl:template match="l:Media">
		<rdf:Description rdf:about="Media">
			<rdf:type rdf:resource="http://purl.org/dc/terms/Collection"/>
		</rdf:Description>
		
		<rdf:Description rdf:about="Media">
			<dc:creator><xsl:value-of select="$ownerName"/></dc:creator>
		</rdf:Description>

		<rdf:Description rdf:about="Media">
			<dcterms:isRequiredBy rdf:resource="Library"/>
		</rdf:Description>
		
		<xsl:for-each select="*[generate-id() = generate-id(key('mediaChildren', name())[1])]">
			<rdf:Description rdf:about="Media">
				<dcterms:hasPart><xsl:value-of select="name()"/></dcterms:hasPart>
			</rdf:Description>
		</xsl:for-each>
		
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&#x9;</xsl:text>
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="l:Series">
		<xsl:variable name="seriesTitle" select="translate(@seriesTitle, ' ', '_')"/>
		
		<xsl:for-each select="*">
			<rdf:Description rdf:about="{$seriesTitle}">
				<dcterms:hasPart><xsl:value-of select="translate(/l:Title/text(), ' ', '_')"/></dcterms:hasPart>
			</rdf:Description>
		</xsl:for-each>
		
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&#x9;</xsl:text>
		<xsl:apply-templates select="l:Game"/>
	
	</xsl:template>
	
	
	<xsl:template match="l:Game">
		<xsl:variable name="gameTitle" select="translate(./l:Title/text(), ' ', '_')"/>
		
		<rdf:Description rdf:about="{$gameTitle}">
			<rdf:type rdf:resource="http://purl.org/net/VideoGameOntology#Game"/>
		</rdf:Description>
		
		<rdf:Description rdf:about="{$gameTitle}">
			<dcterms:title><xsl:value-of select="$gameTitle"/></dcterms:title>
		</rdf:Description>
		
		
		<xsl:if test="./l:designerNameExtended">
			<rdf:Description rdf:about="{$gameTitle}">
				<vgo:creator><xsl:value-of select="concat(./l:designerNameExtended/l:firstname/text(), ' ', ./l:designerNameExtended/l:middlename/text(), ' ', ./l:designerNameExtended/l:lastname/text())"/></vgo:creator>
			</rdf:Description>
		</xsl:if>
		
		<xsl:if test="./l:designerName">
			<rdf:Description rdf:about="{$gameTitle}">
				<vgo:creator><xsl:value-of select="concat(./l:designerName/l:firstname/text(), ' ', ./l:designerName/l:lastname/text())"/></vgo:creator>
			</rdf:Description>
		</xsl:if>
		
		
		<xsl:variable name="genre" select="translate(./l:genre/text(), ' ', '_')"/>
		<rdf:Description rdf:about="{$gameTitle}">
			<vgo:hasGameGenre rdf:resource="" />
		</rdf:Description>
		
		<xsl:if test="./l:paymentMethod/l:card">
			<rdf:Description rdf:about="{$gameTitle}">
				<fibo-loan-spc-crd:CardIdentificationNumber><xsl:value-of select="substring(l:paymentMethod/l:card/text(), 1,4)"/></fibo-loan-spc-crd:CardIdentificationNumber>
			</rdf:Description>	
		</xsl:if>
		
		<xsl:if test="./l:paymentMethod/l:paypal">
			<rdf:Description rdf:about="{$gameTitle}">
				<foaf:mbox><xsl:value-of select="l:paymentMethod/l:paypal/text()"/></foaf:mbox>
			</rdf:Description>
		</xsl:if>
		
		<rdf:Description rdf:about="{$gameTitle}">
			<schema-org:contentRating><xsl:value-of select="l:esrbRating/text()"/></schema-org:contentRating>
		</rdf:Description>		
		
		<rdf:Description rdf:about="{$gameTitle}">
			<schema-org:price><xsl:value-of select="l:price/text()"/></schema-org:price>
		</rdf:Description>	
		
		<rdf:Description rdf:about="{$gameTitle}">
			<isInstalled><xsl:value-of select="l:isInstalled/text()"/></isInstalled>
		</rdf:Description>
		
		<rdf:Description rdf:about="{$gameTitle}">
			<schema-org:genre><xsl:value-of select="l:genre/text()"/></schema-org:genre>
		</rdf:Description>
		
		<xsl:for-each select="./*">
			<rdf:Description rdf:about="{$gameTitle}">
				<dcterms:hasPart><xsl:value-of select="name()"/></dcterms:hasPart>
			</rdf:Description>
		</xsl:for-each>	
		
		<rdf:Description rdf:about="{$gameTitle}">
			<dcterms:isRequiredBy>Series</dcterms:isRequiredBy>
		</rdf:Description>
		
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&#x9;</xsl:text>
	</xsl:template>
</xsl:stylesheet>
