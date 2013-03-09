<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:impl="urn:X-FGeorges:exslt2:prague:2009:google-contacts"
                xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
                xmlns:atom="http://www.w3.org/2005/Atom"
                xmlns:gContact="http://schemas.google.com/contact/2008"
                exclude-result-prefixes="#all"
                version="2.0">

   <!--
       1/ get contacts from Google Contacts
       2/ transform it to ODF
            -> get corresponding map thumbnails for addresses
       3/ email a copy and archive it (if email is accessible from APIs)
       4/ upload a copy to Google Docs
   -->

   <xsl:import href="get-contacts.xsl"/>
   <xsl:import href="format-content.xsl"/>
   <xsl:import href="update-zip.xsl"/>

   <xsl:param name="pattern" as="xs:anyURI" required="yes"/> <!-- pattern ZIP file -->
   <xsl:param name="output"  as="xs:anyURI" required="yes"/> <!-- output ZIP file -->

   <xsl:template name="main" match="/">
      <xsl:variable name="contacts" as="element(contacts)">
         <xsl:call-template name="impl:get-contacts"/>
      </xsl:variable>
      <xsl:variable name="content" as="element(office:document-content)">
         <xsl:apply-templates select="$contacts" mode="impl:odt">
            <xsl:with-param name="pattern" select="$pattern"/>
         </xsl:apply-templates>
      </xsl:variable>
      <xsl:call-template name="impl:zip">
         <xsl:with-param name="pattern"  select="$pattern"/>
         <xsl:with-param name="output"   select="$output"/>
         <xsl:with-param name="contacts" select="$contacts"/>
         <xsl:with-param name="content"  select="$content"/>
      </xsl:call-template>
   </xsl:template>

</xsl:stylesheet>
