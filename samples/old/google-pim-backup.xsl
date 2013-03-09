<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gdata="http://www.fgeorges.org/xslt/google/data"
                xmlns:gc="http://www.fgeorges.org/xslt/google/contacts"
                xmlns:gcal="http://www.fgeorges.org/xslt/google/calendar"
                xmlns:atom="http://www.w3.org/2005/Atom"
                exclude-result-prefixes="#all"
                version="2.0">

   <xsl:import href="gdata.xsl"/>
   <xsl:import href="gcontacts.xsl"/>
   <xsl:import href="gcalendar.xsl"/>

   <xsl:output indent="yes"/>

   <!-- The account to use (the address email) -->
   <xsl:param name="account" as="xs:string" required="yes"/>
   <!-- The associated password, required -->
   <xsl:param name="pwd"     as="xs:string" required="yes"/>

   <xsl:template name="main">
      <pim-backup>
         <xsl:variable name="auth-gc" select="gc:auth-token($account, $pwd)"/>
         <contacts>
            <xsl:sequence select="gdata:get-chunked-feeds($auth-gc, $gc:contact-feed, ())"/>
         </contacts>
         <groups>
            <xsl:sequence select="gdata:get-chunked-feeds($auth-gc, $gc:group-feed, ())"/>
         </groups>
         <xsl:variable name="auth-gcal" select="gcal:auth-token($account, $pwd)"/>
         <xsl:variable name="cals" select="gdata:get-chunked-feeds($auth-gcal, $gcal:calendar-feed, ())"/>
         <calendars>
            <xsl:sequence select="$cals"/>
         </calendars>
         <events>
            <xsl:for-each select="$cals/atom:entry">
               <events cal="{ atom:id }">
                  <xsl:sequence select="gdata:get-chunked-feeds($auth-gcal, atom:content/@src, ())"/>
               </events>
               <!-- Get events in the calendar matching ?q=ken.  -->
               <events-ken cal="{ atom:id }">
                  <xsl:variable name="q" as="element(gdata:param)">
                     <gdata:param name="q" value="ken"/>
                  </xsl:variable>
                  <xsl:sequence select="gdata:get-chunked-feeds($auth-gcal, atom:content/@src, $q)"/>
               </events-ken>
            </xsl:for-each>
         </events>
      </pim-backup>
   </xsl:template>

</xsl:stylesheet>
