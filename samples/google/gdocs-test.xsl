<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gdoc="http://www.fgeorges.org/xslt/google/docs"
                xmlns:gdata="http://www.fgeorges.org/xslt/google/data"
                xmlns:atom="http://www.w3.org/2005/Atom"
                xmlns:os="http://a9.com/-/spec/opensearch/1.1/"
                xmlns:http="http://expath.org/ns/http-client"
                xmlns:gd="http://schemas.google.com/g/2005"
                exclude-result-prefixes="#all"
                version="2.0">

   <xsl:import href="gdata.xsl"/>
   <xsl:import href="gdocs.xsl"/>

   <xsl:output indent="yes"/>

   <xsl:param name="user" as="xs:string" required="yes"/>
   <xsl:param name="pwd"  as="xs:string" required="yes"/>

   <xsl:variable name="service" as="element(gdata:service)" select="
       gdoc:make-doc-service($user, $pwd)"/>
   <xsl:variable name="folders" as="element(atom:entry)+" select="
       gdoc:get-folders($service)/atom:entry"/>
   <xsl:variable name="prague-folder" select="$folders[atom:title eq 'Prague']"/>

   <xsl:template name="main">
      <root>
         <xsl:call-template name="upload"/>
         <xsl:call-template name="folders"/>
      </root>
   </xsl:template>

   <xsl:template name="upload">
      <upload>
         <xsl:variable name="file" select="'../../misc/xml-prague-2009/contacts-odf/contacts.odt'"/>
         <xsl:sequence select="
             gdoc:upload-file($service,
                              $file,
                              $gdoc:odt-mime-type,
                              (),
                              gdoc:folder-id($prague-folder))"/>
      </upload>
      <upload-named>
         <xsl:variable name="file" select="'../../misc/xml-prague-2009/contacts-odf/contacts.odt'"/>
         <xsl:sequence select="
             gdoc:upload-file($service,
                              $file,
                              $gdoc:odt-mime-type,
                              'Balisage contacts',
                              gdoc:folder-id($prague-folder))"/>
      </upload-named>
   </xsl:template>

   <xsl:template name="folders">
      <folders>
         <xsl:sequence select="$folders"/>
      </folders>
   </xsl:template>

</xsl:stylesheet>
