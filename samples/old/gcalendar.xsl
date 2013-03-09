<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gcal="http://www.fgeorges.org/xslt/google/calendar"
                xmlns:gdata="http://www.fgeorges.org/xslt/google/data"
                xmlns:atom="http://www.w3.org/2005/Atom"
                exclude-result-prefixes="#all"
                version="2.0">

   <!--
      Google Calendar API developer guide:
      http://code.google.com/apis/calendar/docs/2.0/developers_guide_protocol.html
   -->

   <xsl:import href="gdata.xsl"/>

   <xsl:variable name="gcal:calendar-service" select="'cl'"/>

   <xsl:variable name="gcal:calendar-feed" select="
       'https://www.google.com/calendar/feeds/default/allcalendars/full'"/>

   <xsl:variable name="gcal:calendar-entry" select="
       'https://www.google.com/calendar/feeds/default/private/full'"/>

   <xsl:function name="gcal:get-calendar-feed" as="element(atom:feed)">
      <!-- the authentication token -->
      <xsl:param name="auth" as="xs:string"/>
      <xsl:sequence select="gdata:get-feed($auth, $gcal:calendar-feed, ())"/>
   </xsl:function>

   <xsl:function name="gcal:post-calendar-entry" as="element(atom:entry)">
      <!-- the authentication token -->
      <xsl:param name="auth" as="xs:string"/>
      <!-- the authentication token -->
      <xsl:param name="entry" as="element(atom:entry)"/>
      <xsl:sequence select="gdata:post-entry($auth, $gcal:calendar-entry, $entry)"/>
   </xsl:function>

   <!--
       Authenticates to the Google Calendar service.
   -->
   <xsl:function name="gcal:auth-token" as="xs:string">
      <!-- the email (user account) -->
      <xsl:param name="email" as="xs:string"/>
      <!-- the password -->
      <xsl:param name="pwd" as="xs:string"/>
      <xsl:sequence select="gdata:auth-token($email, $pwd, $gcal:calendar-service)"/>
   </xsl:function>

</xsl:stylesheet>
