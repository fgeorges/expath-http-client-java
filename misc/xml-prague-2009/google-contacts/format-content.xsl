<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:zip-java="java:org.expath.saxon.Zip"
                xmlns:impl="urn:X-FGeorges:exslt2:prague:2009:google-contacts"
                xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
                xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
                xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
                xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
                xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="#all"
                version="2.0">

   <!--
       the module that transform the intermediate format to ODT
   -->

   <xsl:template match="contacts" mode="impl:odt">
      <xsl:param name="pattern" as="xs:anyURI"/>
      <xsl:apply-templates select="zip-java:xml-entry($pattern, 'content.xml')/*" mode="impl:odt">
         <xsl:with-param name="contacts" select="." tunnel="yes"/>
      </xsl:apply-templates>
   </xsl:template>

   <xsl:template match="node()" mode="impl:odt">
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates select="node()" mode="impl:odt"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="table:table-row" mode="impl:odt"/>

   <xsl:template match="table:table-row[1]" mode="impl:odt" priority="2">
      <xsl:param name="contacts" as="element(contacts)" tunnel="yes"/>
      <xsl:copy-of select="."/>
      <xsl:apply-templates select="$contacts/*" mode="impl:contacts"/>
   </xsl:template>

   <xsl:template match="contact" mode="impl:contacts">
      <table:table-row>
         <table:table-cell table:style-name="contacts.A2" office:value-type="string">
            <xsl:apply-templates select="photo" mode="impl:contacts"/>
         </table:table-cell>
         <table:table-cell table:style-name="contacts.A2" office:value-type="string">
            <xsl:apply-templates select="* except (photo|map|group)" mode="impl:contacts"/>
            <xsl:if test="exists(group)">
               <text:p text:style-name="Table_20_Contents">
                  <xsl:text>Group</xsl:text>
                  <xsl:value-of select="'s'[current()/group[2]]"/>
                  <xsl:text>: </xsl:text>
                  <xsl:value-of select="string-join(group, ', ')"/>
               </text:p>
            </xsl:if>
         </table:table-cell>
         <table:table-cell table:style-name="contacts.C2" office:value-type="string">
            <xsl:apply-templates select="map" mode="impl:contacts"/>
         </table:table-cell>
      </table:table-row>
   </xsl:template>

   <xsl:template match="*" mode="impl:contacts">
      <text:p text:style-name="Table_20_Contents">
         <xsl:value-of select="."/>
      </text:p>
   </xsl:template>

   <xsl:template match="name" mode="impl:contacts">
      <text:p text:style-name="P1">
         <xsl:value-of select="."/>
      </text:p>
   </xsl:template>

   <xsl:template match="comment|address" mode="impl:contacts">
      <xsl:analyze-string regex="\n" select=".">
         <xsl:non-matching-substring>
            <text:p text:style-name="Table_20_Contents">
               <xsl:value-of select="."/>
            </text:p>
         </xsl:non-matching-substring>
      </xsl:analyze-string>
   </xsl:template>

   <xsl:template match="email" mode="impl:contacts">
      <text:p text:style-name="Table_20_Contents">
         <text:a xlink:type="simple" xlink:href="mailto:email@host.com">
            <xsl:value-of select="."/>
         </text:a>
      </text:p>
   </xsl:template>

   <xsl:template match="photo" mode="impl:contacts">
      <xsl:call-template name="impl:format-picture">
         <xsl:with-param name="suffix" select="'.photo.png'"/>
         <xsl:with-param name="width"  select="'0.84in'"/>
         <xsl:with-param name="height" select="'0.84in'"/>
      </xsl:call-template>
   </xsl:template>

   <xsl:template match="map" mode="impl:contacts">
      <xsl:call-template name="impl:format-picture">
         <xsl:with-param name="suffix" select="'.map.gif'"/>
         <xsl:with-param name="width"  select="'2.15in'"/>
         <xsl:with-param name="height" select="'1.07in'"/>
      </xsl:call-template>
   </xsl:template>

   <xsl:template name="impl:format-picture">
      <xsl:param name="suffix" as="xs:string"/>
      <xsl:param name="width"  as="xs:string"/>
      <xsl:param name="height" as="xs:string"/>
      <xsl:variable name="id" as="xs:string" select="generate-id(.)"/>
      <text:p text:style-name="P2">
         <draw:frame
             draw:style-name="fr1"
             draw:name="{ $id }"
             text:anchor-type="paragraph"
             svg:width="{ $width }"
             svg:height="{ $height }"
             draw:z-index="0">
            <draw:image
                xlink:href="Pictures/{ $id }{ $suffix }"
                xlink:type="simple"
                xlink:show="embed"
                xlink:actuate="onLoad"/>
         </draw:frame>
      </text:p>
   </xsl:template>

</xsl:stylesheet>
