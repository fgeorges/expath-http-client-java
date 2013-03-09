<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tns="http://www.fgeorges.org/ws/test/weather"
                version="2.0">

   <xsl:import href="weather-compiled.xsl"/>

   <xsl:output indent="yes"/>

   <xsl:template match="/" name="main">
      <xsl:variable name="request" as="element()">
         <tns:weather-by-city-request>
            <tns:city>Prague</tns:city>
            <tns:country>CZ</tns:country>
         </tns:weather-by-city-request>
      </xsl:variable>
      <xsl:sequence select="tns:weather-by-city($request)"/>
   </xsl:template>

</xsl:stylesheet>
