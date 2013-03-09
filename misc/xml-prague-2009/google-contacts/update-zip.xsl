<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:impl="urn:X-FGeorges:exslt2:prague:2009:google-contacts"
                xmlns:zip="http://expath.org/ns/zip"
                xmlns:zip-java="java:org.expath.saxon.Zip"
                xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
                xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0"
                exclude-result-prefixes="#all"
                version="2.0">

   <xsl:template name="impl:zip">
      <xsl:param name="pattern"  as="xs:anyURI"/>
      <xsl:param name="output"   as="xs:anyURI"/>
      <xsl:param name="contacts" as="element(contacts)"/>
      <xsl:param name="content"  as="element(office:document-content)"/>
      <xsl:variable name="zip" as="element(zip:file)">
         <zip:file href="{ $pattern }">
            <zip:entry name="content.xml" output="xml">
               <xsl:sequence select="$content"/>
            </zip:entry>
            <zip:entry name="Pictures">
               <xsl:apply-templates select="$contacts//(photo|map)" mode="impl:zip"/>
            </zip:entry>
            <zip:entry name="META-INF">
               <zip:entry name="manifest.xml" output="xml">
                  <xsl:apply-templates mode="impl:manifest" select="
                      zip-java:xml-entry(resolve-uri($pattern), 'META-INF/manifest.xml')">
                     <xsl:with-param name="contacts" select="$contacts" tunnel="yes"/>
                  </xsl:apply-templates>
               </zip:entry>
            </zip:entry>
         </zip:file>
      </xsl:variable>
      <xsl:sequence select="zip-java:update-entries($zip, $output)"/>
   </xsl:template>

   <xsl:template match="photo" mode="impl:zip">
      <zip:entry name="{ generate-id(.) }.photo.png" output="base64">
         <xsl:sequence select="data(.)"/>
      </zip:entry>
   </xsl:template>

   <xsl:template match="map" mode="impl:zip">
      <zip:entry name="{ generate-id(.) }.map.gif" output="base64">
         <xsl:sequence select="data(.)"/>
      </zip:entry>
   </xsl:template>

   <xsl:template match="node()|@*" mode="impl:manifest">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*" mode="impl:manifest"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="manifest:manifest" mode="impl:manifest">
      <xsl:param name="contacts" as="element(contacts)" tunnel="yes"/>
      <xsl:copy>
         <xsl:apply-templates select="node()|@*|$contacts//(photo|map)" mode="impl:manifest"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="photo" mode="impl:manifest">
      <manifest:file-entry
          manifest:media-type="image/png"
          manifest:full-path="Pictures/{ generate-id(.) }.photo.png"/>
   </xsl:template>

   <xsl:template match="map" mode="impl:manifest">
      <manifest:file-entry
          manifest:media-type="image/gif"
          manifest:full-path="Pictures/{ generate-id(.) }.map.gif"/>
   </xsl:template>

</xsl:stylesheet>
