<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gdata="http://www.fgeorges.org/xslt/google/data"
                xmlns:gc="http://www.fgeorges.org/xslt/google/contacts"
                xmlns:atom="http://www.w3.org/2005/Atom"
                xmlns:os="http://a9.com/-/spec/opensearch/1.1/"
                xmlns:http="http://www.exslt.org/v2/http-client"
                exclude-result-prefixes="#all"
                version="2.0">

   <xsl:import href="../../samples/google/gdata.xsl"/>
   <xsl:import href="../../samples/google/gcontacts.xsl"/>

   <xsl:output indent="yes"/>

   <xsl:param name="user" as="xs:string" required="yes"/>
   <xsl:param name="pwd"  as="xs:string" required="yes"/>

   <xsl:template name="main">
      <xsl:call-template name="make-service"/>
      <xsl:call-template name="get-contacts"/>
      <xsl:call-template name="get-events"/>
   </xsl:template>

   <xsl:template name="make-service">
      <make-service>
         <xsl:sequence select="gdata:make-service('cp', $user, $pwd)"/>
      </make-service>
   </xsl:template>

   <xsl:template name="get-contacts">
      <xsl:variable name="cp-service" as="element(gdata:service)" select="
          gc:make-contact-service($user, $pwd)"/>
      <get-contacts>
         <one-single-feed>
            <xsl:sequence select="
                gdata:get-feed($cp-service, gc:contact-feed-uri($cp-service))"/>
         </one-single-feed>
         <all-contacts>
            <xsl:sequence select="gc:get-contacts($cp-service)"/>
         </all-contacts>
      </get-contacts>
   </xsl:template>

   <xsl:template name="get-events">
      <xsl:variable name="entry-url" select="
          'https://www.google.com/calendar/feeds/fgeorges.test%40gmail.com/private/full/184n0ofbcocpmfjga6esd0ctjo'"/>
      <xsl:variable name="entry-etag" select="'&quot;EEULQQNDdyp7I2A6WhVU&quot;'"/>
      <xsl:variable name="entry-date" select="xs:dateTime('2009-02-21T13:38:50.000Z')"/>
      <xsl:variable name="events-url" select="
          'https://www.google.com/calendar/feeds/fgeorges.test%40gmail.com/private/full'"/>
      <xsl:variable name="cl-service" as="element(gdata:service)" select="
          gdata:make-service('cl', $user, $pwd)"/>
      <get-events>
         <first>
            <xsl:sequence select="gdata:get-feed($cl-service, $events-url)"/>
         </first>
         <second>
            <xsl:sequence select="gdata:get-feed($cl-service, $events-url)"/>
         </second>
         <third>
            <xsl:sequence select="gdata:get-entry($cl-service, $entry-url, (), $entry-date)"/>
         </third>
      </get-events>
   </xsl:template>

</xsl:stylesheet>
