<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
    <!ENTITY collections "http://swan.mindinformatics.org/ontologies/1.2/collections/" >
    <!ENTITY xsd "http://www.w3.org/2001/XMLSchema#" >
]>
<xsl:stylesheet version="2.0" exclude-result-prefixes="xs f"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:earmark="http://www.essepuntato.it/2008/12/earmark#"
	xmlns:overlaptricks="http://www.rolfini.it/semanticweb/overlaptricksEAR#"
	xmlns:collections="http://swan.mindinformatics.org/ontologies/1.2/collections/"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:SWWEx="http://www.essepuntato.it/2010/04/SWWEx#"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:f="http://www.essepuntato.it/XSLT/fuction">

	<xsl:output encoding="UTF-8" method="xml" indent="no"/>

	<xsl:param name="base" select="'http://www.essepuntato.it/2010/04/SWWEx'" as="xs:string"/>
	<xsl:param name="considerEmptyText" as="xs:boolean" select="false()"/>
	<!-- Whether true, I do not normalize the spaces of each text node; otherwise,
    I do -->
	<xsl:param name="simplify" as="xs:boolean" select="true()"/>
	<!-- Whether true, I use the minimum number of RDF statements I need, leaving a lot of
    deduction to the reasoner. Otherwise, I specify everything -->
	<xsl:param name="checkSameStringAs" as="xs:boolean" select="true()"/>
	<!-- if true, I search for the first next range with the same string, and 
    	assert the property hasSameStringAs accordingly -->

	<xsl:variable name="attributeDocuverse" as="xs:string"
		select="if ($considerEmptyText) then 
										f:getAllTextContentAttribute(root())
									 else 
									 	normalize-space(f:getAllTextContentAttribute(root()))"/>
	<xsl:variable name="commentDocuverse" as="xs:string"
		select="if ($considerEmptyText) then 
										f:getAllTextContentComment(root())
									else 
										normalize-space(f:getAllTextContentComment(root()))"/>
	<xsl:variable name="docuverse" as="xs:string"
		select="if ($considerEmptyText) then 
										f:getAllTextContent(root())
									 else 
									 	normalize-space(f:getAllTextContent(root()))"/>

	<!-- ROOT -->
	<xsl:template match="/">
		<rdf:RDF xml:base="{$base}">
			<owl:Ontology rdf:about="{$base}">
				<xsl:if test="not($simplify)">
					<owl:imports rdf:resource="http://www.essepuntato.it/2008/12/earmark"/>
				</xsl:if>
			</owl:Ontology>
			<xsl:call-template name="docuverse"/>
			<xsl:apply-templates select="comment()|element()"/>
		</rdf:RDF>
	</xsl:template>

	<!-- DOCUVERSE -->
	<xsl:template name="docuverse">
		<!-- Document content -->
		<xsl:if test="$docuverse">
			<earmark:StringDocuverse rdf:about="#{f:getId(/,'d_text')}">
				<earmark:hasContent rdf:datatype="&xsd;string">
					<xsl:value-of select="$docuverse"/>
				</earmark:hasContent>
			</earmark:StringDocuverse>
		</xsl:if>

		<!-- Attribute content -->
		<xsl:if test="$attributeDocuverse">
			<earmark:StringDocuverse rdf:about="#{f:getId(/,'a_text')}">
				<earmark:hasContent rdf:datatype="&xsd;string">
					<xsl:value-of select="$attributeDocuverse"/>
				</earmark:hasContent>
			</earmark:StringDocuverse>
		</xsl:if>
		
		<!-- Comment content -->
		<xsl:if test="$commentDocuverse">
			<earmark:StringDocuverse rdf:about="#{f:getId(/,'c_text')}">
				<earmark:hasContent rdf:datatype="&xsd;string">
					<xsl:value-of select="$commentDocuverse"/>
				</earmark:hasContent>
			</earmark:StringDocuverse>
		</xsl:if>
	</xsl:template>
	<!-- end of DOCUVERSE -->


	<!-- MARKUP ITEM -->
	<xsl:template name="generate.markupitem.assetion">
		<xsl:variable name="ns" select="namespace-uri()" as="xs:anyURI"/>
		<earmark:hasGeneralIdentifier rdf:datatype="&xsd;string">
			<xsl:value-of select="local-name()"/>
		</earmark:hasGeneralIdentifier>
		<xsl:if test="$ns != ''">
			<earmark:hasNamespace rdf:datatype="&xsd;anyURI">
				<xsl:value-of select="namespace-uri()"/>
			</earmark:hasNamespace>
		</xsl:if>
	</xsl:template>

	<xsl:template name="generate.set.assertion">
		<xsl:param name="r_id" as="xs:string"/>
		<rdf:type rdf:resource="&collections;Set"/>

		<xsl:call-template name="generate.markupitem.assetion"/>

		<xsl:choose>
			<xsl:when test="$considerEmptyText or normalize-space() != ''">
				<collections:element rdf:resource="#{$r_id}"/>
				<xsl:if test="not($simplify)">
					<collections:size>1</collections:size>
				</xsl:if>
			</xsl:when>
			<xsl:when test="not($simplify)">
				<collections:size>0</collections:size>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="generate.set.range">
		<xsl:param name="d_id" as="xs:string"/>
		<xsl:param name="r_id" as="xs:string"/>
		<xsl:param name="docuverse" as="xs:string" />

		<xsl:if test="$considerEmptyText or normalize-space() != ''">
			<earmark:PointerRange rdf:about="#{$r_id}">
				<earmark:begins rdf:datatype="http://www.w3.org/2001/XMLSchema#nonNegativeInteger">
					<xsl:value-of select="f:stringBegins(.,$docuverse)"/>
				</earmark:begins>
				<earmark:ends rdf:datatype="http://www.w3.org/2001/XMLSchema#nonNegativeInteger">
					<xsl:value-of select="f:stringEnds(.,$docuverse)"/>
				</earmark:ends>
				<earmark:refersTo rdf:resource="#{f:getId(/,$d_id)}"/>
			</earmark:PointerRange>
		</xsl:if>
	</xsl:template>
	<!-- end of MARKUP ITEM -->

	<!-- ELEMENT -->
	<xsl:template match="element()">
		<xsl:variable name="item.name" select="local-name()" as="xs:string"/>
		<xsl:variable name="id" select="f:generateId(.)" as="xs:string"/>
		<xsl:variable name="children"
			select="(element()|(text()|attribute()|comment())[if ($considerEmptyText) then true() else normalize-space() != ''])"
			as="item()*"/>

		<earmark:Element rdf:about="#{$id}">
			<xsl:call-template name="generate.markupitem.assetion"/>

			<xsl:variable name="size" select="count(element()|(text()|attribute()|comment())[if ($considerEmptyText) then true() else normalize-space() != ''])" />
			<xsl:choose>
				<xsl:when test="not($simplify)">
					<rdf:type rdf:resource="&collections;List"/>
					<collections:size>
						<xsl:value-of select="$size" />
					</collections:size>
				</xsl:when>
				<xsl:when test="$size = 0">
					<rdf:type rdf:resource="&collections;List"/>
				</xsl:when>
			</xsl:choose>
			
			<xsl:if test="not($simplify)">
				<rdf:type rdf:resource="&collections;List"/>
				<collections:size>
					<xsl:value-of
						select="count(element()|(text()|attribute()|comment())[if ($considerEmptyText) then true() else normalize-space() != ''])"
					/>
				</collections:size>
			</xsl:if>

			<xsl:for-each select="$children">
				<xsl:variable name="li_id" as="xs:string"
					select="f:getId(.,concat('li',position(),'_of_',$id))"/>
				<xsl:variable name="pos" select="position()" as="xs:integer"/>
				<xsl:variable name="l" select="last()" as="xs:integer"/>
				<xsl:choose>
					<xsl:when test="$pos = 1">
						<collections:firstItem>
							<xsl:call-template name="generate.item">
								<xsl:with-param name="li_id" select="$li_id" as="xs:string"/>
								<xsl:with-param name="pos" select="$pos" as="xs:integer"/>
								<xsl:with-param name="l" select="$l" as="xs:integer"/>
								<xsl:with-param name="children" select="$children" as="item()*"/>
								<xsl:with-param name="id" select="$id" as="xs:string"/>
							</xsl:call-template>
						</collections:firstItem>

						<xsl:if test="$pos = $l and not($simplify)">
							<collections:lastItem rdf:resource="{$li_id}"/>
						</xsl:if>
					</xsl:when>
					<xsl:when test="not($simplify)">
						<xsl:choose>
							<xsl:when test="$pos = $l">
								<collections:lastItem>
									<xsl:call-template name="generate.item">
										<xsl:with-param name="li_id" select="$li_id" as="xs:string"/>
										<xsl:with-param name="pos" select="$pos" as="xs:integer"/>
										<xsl:with-param name="l" select="$l" as="xs:integer"/>
										<xsl:with-param name="children" select="$children"
											as="item()*"/>
										<xsl:with-param name="id" select="$id" as="xs:string"/>
									</xsl:call-template>
								</collections:lastItem>
							</xsl:when>
							<xsl:otherwise>
								<collections:item>
									<xsl:call-template name="generate.item">
										<xsl:with-param name="li_id" select="$li_id" as="xs:string"/>
										<xsl:with-param name="pos" select="$pos" as="xs:integer"/>
										<xsl:with-param name="l" select="$l" as="xs:integer"/>
										<xsl:with-param name="children" select="$children"
											as="item()*"/>
										<xsl:with-param name="id" select="$id" as="xs:string"/>
									</xsl:call-template>
								</collections:item>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>
		</earmark:Element>

		<xsl:apply-templates select="$children"/>
	</xsl:template>

	<xsl:template name="generate.item">
		<xsl:param name="pos" as="xs:integer"/>
		<xsl:param name="l" as="xs:integer"/>
		<xsl:param name="children" as="item()*"/>
		<xsl:param name="li_id" as="xs:string"/>
		<xsl:param name="id" as="xs:string"/>

		<rdf:Description>
			<xsl:if test="not($simplify)">
				<xsl:attribute name="rdf:nodeID" select="$li_id" />
			</xsl:if>
			<collections:itemContent rdf:resource="#{f:generateId(.)}"/>
			<xsl:if test="$pos != $l">
				<xsl:choose>
					<xsl:when test="$simplify">
						<xsl:call-template name="recursiveNext">
							<xsl:with-param name="pos" select="$pos" as="xs:integer"/>
							<xsl:with-param name="l" select="$l" as="xs:integer" tunnel="yes"/>
							<xsl:with-param name="children" select="$children" as="item()*"
								tunnel="yes"/>
							<xsl:with-param name="id" select="$id" as="xs:string" tunnel="yes"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<collections:nextItem
							rdf:nodeID="{f:getId(.,concat('li',$pos + 1,'_of_',$id))}"
						/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>

			<xsl:if test="not($simplify)">
				<rdf:type rdf:resource="&collections;ListItem"/>
				<xsl:if test="$pos != 1">
					<collections:previousItem
						rdf:nodeID="{f:getId(.,concat(f:generateId(.),'_li',$pos - 1,'_of_',$id))}"
					/>
				</xsl:if>
			</xsl:if>
		</rdf:Description>
	</xsl:template>

	<xsl:template name="recursiveNext">
		<xsl:param name="pos" as="xs:integer"/>
		<xsl:param name="l" as="xs:integer" tunnel="yes"/>
		<xsl:param name="children" as="item()*" tunnel="yes"/>
		<xsl:param name="id" as="xs:string" tunnel="yes"/>

		<xsl:if test="$pos &lt;= $l">
			<xsl:if test="$pos != 1">
				<collections:itemContent rdf:resource="#{f:generateId($children[$pos])}"/>
			</xsl:if>

			<xsl:if test="$pos != $l">
				<collections:nextItem>
					<rdf:Description>
						<xsl:if test="not($simplify)">
							<xsl:attribute name="rdf:nodeID" select="f:getId(.,concat('li',$pos + 1,'_of_',$id))" />
						</xsl:if>
						<xsl:call-template name="recursiveNext">
							<xsl:with-param name="pos" select="$pos + 1" as="xs:integer"/>
						</xsl:call-template>
					</rdf:Description>
				</collections:nextItem>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	<!-- end of ELEMENT -->

	<!-- ATTRIBUTE -->
	<xsl:template match="attribute()">
		<xsl:variable name="id" as="xs:string" select="f:generateId(.)"/>
		<xsl:variable name="r_id" as="xs:string" select="f:getId(.,concat($id,'_r'))"/>

		<earmark:Attribute rdf:about="#{$id}">
			<xsl:call-template name="generate.set.assertion">
				<xsl:with-param name="r_id" select="$r_id" as="xs:string"/>
			</xsl:call-template>
		</earmark:Attribute>

		<!-- Handle the range related to the attribute -->
		<xsl:call-template name="generate.set.range">
			<xsl:with-param name="d_id" select="'a_text'" as="xs:string"/>
			<xsl:with-param name="r_id" select="$r_id" as="xs:string"/>
			<xsl:with-param name="docuverse" select="$attributeDocuverse" />
		</xsl:call-template>
	</xsl:template>
	<!-- end of ATTRIBUTE -->

	<!-- COMMENT -->
	<xsl:template match="comment()">
		<xsl:variable name="item.name" select="local-name()" as="xs:string"/>
		<xsl:variable name="ns" select="namespace-uri()" as="xs:anyURI"/>
		<xsl:variable name="id" as="xs:string" select="f:generateId(.)"/>
		<xsl:variable name="li_id" as="xs:string" select="f:getId(.,concat($id,'_r_li'))"/>
		<xsl:variable name="r_id" as="xs:string" select="f:getId(.,concat($id,'_r'))"/>

		<earmark:Comment rdf:about="#{f:generateId(.)}">
			<xsl:call-template name="generate.set.assertion">
				<xsl:with-param name="r_id" select="$r_id" as="xs:string"/>
			</xsl:call-template>
		</earmark:Comment>

		<!-- Handle the range related to the comment -->
		<xsl:call-template name="generate.set.range">
			<xsl:with-param name="d_id" select="'c_text'" as="xs:string"/>
			<xsl:with-param name="r_id" select="$r_id" as="xs:string"/>
			<xsl:with-param name="docuverse" select="$commentDocuverse" />
		</xsl:call-template>
	</xsl:template>
	<!-- end of COMMENT -->

	<!-- RANGE -->
	<xsl:template match="text()[if ($considerEmptyText) then true() else normalize-space() != '']">
		<earmark:PointerRange rdf:about="#{f:generateId(.)}">
			<earmark:begins rdf:datatype="&xsd;nonNegativeInteger">
				<xsl:value-of select="f:stringBegins(.,$docuverse)"/>
			</earmark:begins>
			<earmark:ends rdf:datatype="&xsd;nonNegativeInteger">
				<xsl:value-of select="f:stringEnds(.,$docuverse)"/>
			</earmark:ends>
			<earmark:refersTo rdf:resource="#{f:getId(/,'d_text')}"/>
		</earmark:PointerRange>
	</xsl:template>
	<!-- end of RANGE -->


	<!-- FUNCTION -->
	<!-- This function generates a unique id for the node (comment, element, attribute, text) specified as input -->
	<xsl:function name="f:generateId" as="xs:string">
		<xsl:param name="item" as="node()"/>
		<xsl:variable name="item.name" select="local-name($item)" as="xs:string"/>
		<xsl:choose>
			<xsl:when test="$item/self::element()[exists(@xml:id)]">
				<xsl:value-of select="$item/@xml:id"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$item/self::element()">
						<xsl:variable name="curId" as="xs:string"
							select="concat('e_',$item.name,'_',count(($item/preceding::element()|$item/ancestor-or-self::element())[local-name() = $item.name]))"/>
						<xsl:value-of select="f:getId($item,$curId)"/>
					</xsl:when>
					<xsl:when test="$item/self::attribute()">
						<xsl:variable name="curId" as="xs:string"
							select="concat('a_',$item.name,'_',count(($item/preceding::element()|$item/ancestor-or-self::element())[some $a in attribute() satisfies local-name($a) = $item.name]))"/>
						<xsl:value-of select="f:getId($item,$curId)"/>
					</xsl:when>
					<xsl:when test="$item/self::comment()">
						<xsl:variable name="curId" as="xs:string"
							select="concat('c_',count($item/preceding::comment()) + 1)"/>
						<xsl:value-of select="f:getId($item,$curId)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="curId" as="xs:string"
							select="concat('r_',f:stringBegins($item,$docuverse),'-',f:stringEnds($item,$docuverse))"/>
						<xsl:value-of select="f:getId($item,$curId)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- This function returns the id specified if it is unique, otherwise it adds some text at the end of it
    in order to generate a new unique id -->
	<xsl:function name="f:getId" as="xs:string">
		<xsl:param name="item" as="node()"/>
		<xsl:param name="curId" as="xs:string"/>
		<xsl:choose>
			<xsl:when test="some $id in root($item)//@xml:id satisfies $id = $curId">
				<xsl:value-of select="f:adjustId($item,$curId,1)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$curId"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- This function creates a unique id adding an integer value at the end of the id specified -->
	<xsl:function name="f:adjustId" as="xs:string">
		<xsl:param name="item" as="node()"/>
		<xsl:param name="curId" as="xs:string"/>
		<xsl:param name="start" as="xs:integer"/>
		<xsl:choose>
			<xsl:when test="exists(root($item)//@xml:id[. = concat($curId,'_',$start)])">
				<xsl:value-of select="f:adjustId($item,$curId,$start + 1)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$curId"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="f:precedingAttributes" as="attribute()*">
		<xsl:param name="attr" as="attribute()" />
		<xsl:param name="seq" as="attribute()*" />
		<xsl:param name="result" as="attribute()*" />
		
		<xsl:choose>
			<xsl:when test="empty($seq)">
				<xsl:sequence select="()" />
			</xsl:when>
			<xsl:when test="$attr is $seq[1]">
				<xsl:sequence select="$result" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="f:precedingAttributes($attr, subsequence($seq, 2), ($result, $seq[1]))" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- This function return a string containing the text content of the entire document -->
	<xsl:function name="f:getAllTextContent" as="xs:string">
		<xsl:param name="item" as="node()+"/>
		<xsl:value-of select="string-join($item//(text()),' ')"/>
	</xsl:function>
	<xsl:function name="f:getAllTextContentAttribute" as="xs:string">
		<xsl:param name="item" as="node()+"/>
		<xsl:value-of select="string-join($item//(attribute()),' ')"/>
	</xsl:function>
	<xsl:function name="f:getAllTextContentComment" as="xs:string">
		<xsl:param name="item" as="node()+"/>
		<xsl:value-of select="string-join($item//(comment()),' ')"/>
	</xsl:function>

	<xsl:function name="f:stringBegins" as="xs:integer">
		<xsl:param name="string" as="node()"/>
		<xsl:param name="docuverse" as="xs:string"/>
		
		<xsl:variable name="precedings" select="if ($string/self::text()) then $string/preceding::text() else if ($string/self::attribute()) then ($string/(preceding::attribute() | parent::element()/(preceding::element()|ancestor::element())/attribute()),f:precedingAttributes($string, $string/parent::element()/attribute(),())) else if ($string/self::comment()) then $string/preceding::comment() else ()" as="node()*" />
		 
		<xsl:variable name="previousRanges" select="string-join(for $r in $precedings[if ($considerEmptyText) then true() else normalize-space() != ''] return if ($considerEmptyText) then $r else normalize-space($r), ' ')" as="xs:string" />
			
		<xsl:variable name="dv" select="substring-after($docuverse, $previousRanges)" as="xs:string" />
		<xsl:value-of select="if ($previousRanges) then string-length($previousRanges) + 1 else 0" />
	</xsl:function>
	
	<xsl:function name="f:stringEnds" as="xs:integer">
		<xsl:param name="string" as="node()"/>
		<xsl:param name="docuverse" as="xs:string"/>
		
		<xsl:variable name="precedings" select="(if ($string/self::text()) then $string/preceding::text() else if ($string/self::attribute()) then ($string/parent::element()/(preceding::element()|ancestor::element())/attribute(), f:precedingAttributes($string, $string/parent::element()/attribute(),())) else if ($string/self::comment()) then $string/preceding::comment() else ()), $string" as="node()*" />
		
		<xsl:variable name="previousRanges" select="string-join(for $r in $precedings[if ($considerEmptyText) then true() else normalize-space() != ''] return if ($considerEmptyText) then $r else normalize-space($r), ' ')" as="xs:string" />
		<xsl:variable name="dv" select="substring-after($docuverse, $previousRanges)" as="xs:string" />
		
		<xsl:value-of select="string-length($previousRanges)" />
	</xsl:function>
	<!-- end of FUNCTION -->
</xsl:stylesheet>
