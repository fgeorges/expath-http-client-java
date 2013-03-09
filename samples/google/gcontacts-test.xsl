<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gdata="http://www.fgeorges.org/xslt/google/data"
                xmlns:gc="http://www.fgeorges.org/xslt/google/contacts"
                xmlns:gmap="http://www.fgeorges.org/xslt/google/maps"
                xmlns:atom="http://www.w3.org/2005/Atom"
                xmlns:os="http://a9.com/-/spec/opensearch/1.1/"
                xmlns:impl="urn:X-FGeorges:xslt:google:gcontacts:test"
                xmlns:gContact="http://schemas.google.com/contact/2008"
                xmlns:gd="http://schemas.google.com/g/2005"
                exclude-result-prefixes="#all"
                version="2.0">

   <xsl:import href="gcontacts.xsl"/>

   <xsl:output indent="yes"/>

   <xsl:param name="user"    as="xs:string" required="yes"/>
   <xsl:param name="pwd"     as="xs:string" required="yes"/>
   <xsl:param name="map-key" as="xs:string" required="yes"/>

   <xsl:variable name="impl:service" as="element(gdata:service)" select="
       gc:make-contact-service($user, $pwd)"/>

   <xsl:template name="main" match="/">
      <root>
         <xsl:call-template name="dump-all"/>
         <xsl:call-template name="first-test"/>
      </root>
   </xsl:template>

   <xsl:template name="dump-all">
      <xsl:variable name="groups"   as="element(atom:entry)+" select="
          gc:get-groups($impl:service)/atom:entry"/>
      <xsl:variable name="contacts" as="element(atom:entry)+" select="
          gc:get-contacts($impl:service)/atom:entry"/>
      <dump-all>
         <groups>
            <xsl:sequence select="$groups"/>
         </groups>
         <contacts>
            <xsl:sequence select="$contacts"/>
         </contacts>
      </dump-all>
   </xsl:template>

   <xsl:template name="first-test">
      <xsl:variable name="groups"   as="element(atom:entry)+" select="
          gc:get-groups($impl:service)/atom:entry"/>
      <xsl:variable name="contacts" as="element(atom:entry)+" select="
          gc:get-contacts($impl:service)/atom:entry"/>
      <xsl:variable name="james"    as="element(atom:entry)"  select="
          gc:contact-by-name($contacts, 'Jim Fuller')"/>
      <first-test>
         <groups>
            <xsl:sequence select="$groups"/>
         </groups>
         <prague>
            <xsl:sequence select="gc:group-by-name($groups, 'XML Prague')"/>
         </prague>
         <contacts>
            <xsl:sequence select="$contacts"/>
         </contacts>
         <jim-groups>
            <xsl:sequence select="gc:get-contact-groups($impl:service, $james)"/>
         </jim-groups>
         <jim-groups-local>
            <xsl:sequence select="gc:contact-groups($james, $groups)"/>
         </jim-groups-local>
      </first-test>
   </xsl:template>

</xsl:stylesheet>
