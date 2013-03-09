<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gdata="http://www.fgeorges.org/xslt/google/data"
                xmlns:gcal="http://www.fgeorges.org/xslt/google/calendar"
                xmlns:atom="http://www.w3.org/2005/Atom"
                xmlns:gd="http://schemas.google.com/g/2005"
                exclude-result-prefixes="#all"
                version="2.0">

   <xsl:import href="gdata.xsl"/>
   <xsl:import href="gcalendar.xsl"/>

   <xsl:output indent="yes"/>

   <!-- The account to use (the address email) -->
   <xsl:param name="account" as="xs:string" required="yes"/>
   <!-- The associated password, required -->
   <xsl:param name="pwd"     as="xs:string" required="yes"/>

   <xsl:variable name="agenda" as="element(atom:entry)">
      <atom:entry>
         <atom:category scheme="http://schemas.google.com/g/2005#kind"
                        term="http://schemas.google.com/g/2005#event"/>
         <atom:title type="text">Coffee break</atom:title>
         <atom:content type="text">Brought to you by ...</atom:content>
         <gd:transparency value="http://schemas.google.com/g/2005#event.opaque"/>
         <gd:eventStatus value="http://schemas.google.com/g/2005#event.confirmed"/>
         <gd:where valueString="Prague"/>
         <gd:when startTime="2009-02-10T10:45:00.000Z"
                  endTime="2009-02-10T11:00:00.000Z"/>
      </atom:entry>
   </xsl:variable>

   <xsl:template name="main">
      <add-agenda>
         <xsl:variable name="auth" select="gcal:auth-token($account, $pwd)"/>
         <!-- DEBUG: Just to see if a read action works... (and it does) -->
         <!--xsl:variable name="some-event-id" select="
             'http://www.google.com/calendar/feeds/fgeorges.test%40gmail.com/private/full/184n0ofbcocpmfjga6esd0ctjo'"/>
         <xsl:sequence select="gdata:get-entry($auth, $some-event-id, ())"/-->
         <xsl:sequence select="gcal:post-calendar-entry($auth, $agenda)"/>
         <xsl:sequence select="gcal:post-calendar-entry($auth, $agenda)"/>
      </add-agenda>
   </xsl:template>

</xsl:stylesheet>
