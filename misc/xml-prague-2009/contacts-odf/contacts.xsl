<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:zip="http://www.exslt.org/v2/zip"
                xmlns:zip-java="java:org.fgeorges.exslt2.saxon.Zip"
                xmlns:impl="urn:X-FGeorges:exslt2:prague:2009:contacts-odf"
                xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
                xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
                xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="#all"
                version="2.0">

   <xsl:param name="pattern" as="xs:anyURI" required="yes"/> <!-- pattern ZIP file -->
   <xsl:param name="output"  as="xs:anyURI" required="yes"/> <!-- output ZIP file -->

   <xsl:template match="/">
      <xsl:variable name="content" as="element(office:document-content)">
         <xsl:variable name="c" as="element(office:document-content)" select="
            zip-java:xml-entry($pattern, 'content.xml')/*"/>
         <xsl:apply-templates mode="impl:odt" select="$c">
            <xsl:with-param name="contacts" select="contacts" tunnel="yes"/>
         </xsl:apply-templates>
      </xsl:variable>
      <xsl:call-template name="impl:zip">
         <xsl:with-param name="content" select="$content"/>
      </xsl:call-template>
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
      <xsl:apply-templates select="$contacts/*"/>
   </xsl:template>

   <xsl:template match="contact">
      <table:table-row>
         <table:table-cell table:style-name="contacts.A2" office:value-type="string"/>
         <table:table-cell table:style-name="contacts.A2" office:value-type="string">
            <xsl:apply-templates select="* except (photo|map|group)"/>
            <xsl:if test="exists(group)">
               <text:p text:style-name="Table_20_Contents">
                  <xsl:text>Group</xsl:text>
                  <xsl:value-of select="'s'[current()/group[2]]"/>
                  <xsl:text>: </xsl:text>
                  <xsl:value-of select="string-join(group, ', ')"/>
               </text:p>
            </xsl:if>
         </table:table-cell>
         <table:table-cell table:style-name="contacts.C2" office:value-type="string"/>
      </table:table-row>
   </xsl:template>

   <xsl:template match="*">
      <text:p text:style-name="Table_20_Contents">
         <xsl:value-of select="."/>
      </text:p>
   </xsl:template>

   <xsl:template match="name">
      <text:p text:style-name="P1">
         <xsl:value-of select="."/>
      </text:p>
   </xsl:template>

   <xsl:template match="comment|address">
      <xsl:analyze-string regex="\n" select=".">
         <xsl:non-matching-substring>
            <text:p text:style-name="Table_20_Contents">
               <xsl:value-of select="."/>
            </text:p>
         </xsl:non-matching-substring>
      </xsl:analyze-string>
   </xsl:template>

   <xsl:template match="email">
      <text:p text:style-name="Table_20_Contents">
         <text:a xlink:type="simple" xlink:href="mailto:email@host.com">
            <xsl:value-of select="."/>
         </text:a>
      </text:p>
   </xsl:template>

   <xsl:template name="impl:zip">
      <xsl:param name="content" as="element(office:document-content)"/>
      <xsl:variable name="zip" as="element(zip:file)">
         <zip:file href="{ $pattern }">
            <zip:entry name="content.xml" output="xml">
               <xsl:sequence select="$content"/>
            </zip:entry>
         </zip:file>
      </xsl:variable>
      <xsl:sequence select="zip-java:update-entries($zip, $output)"/>
   </xsl:template>

</xsl:stylesheet>
