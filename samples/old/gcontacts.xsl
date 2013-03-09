<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gc="http://www.fgeorges.org/xslt/google/contacts"
                xmlns:gdata="http://www.fgeorges.org/xslt/google/data"
                xmlns:atom="http://www.w3.org/2005/Atom"
                exclude-result-prefixes="#all"
                version="2.0">

   <!--
      Google Contacts API developer guide:
      http://code.google.com/apis/contacts/docs/2.0/developers_guide_protocol.html
   -->

   <xsl:import href="gdata.xsl"/>

   <xsl:variable name="gc:contact-service" select="'cp'"/>

   <xsl:variable name="gc:contact-feed" select="
       'https://www.google.com/m8/feeds/contacts/default/full'"/>

   <xsl:variable name="gc:group-feed" select="
       'https://www.google.com/m8/feeds/groups/default/full'"/>

   <xsl:function name="gc:get-contact-feed" as="element(atom:feed)">
      <!-- the authentication token -->
      <xsl:param name="auth" as="xs:string"/>
      <xsl:sequence select="gdata:get-feed($auth, $gc:contact-feed, ())"/>
   </xsl:function>

   <xsl:function name="gc:get-group-feed" as="element(atom:feed)">
      <!-- the authentication token -->
      <xsl:param name="auth" as="xs:string"/>
      <xsl:sequence select="gdata:get-feed($auth, $gc:group-feed, ())"/>
   </xsl:function>

   <!--
       Authenticates to the Google Contacts service.
   -->
   <xsl:function name="gc:auth-token" as="xs:string">
      <!-- the email (user account) -->
      <xsl:param name="email" as="xs:string"/>
      <!-- the password -->
      <xsl:param name="pwd" as="xs:string"/>
      <xsl:sequence select="gdata:auth-token($email, $pwd, $gc:contact-service)"/>
   </xsl:function>

</xsl:stylesheet>
