<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:http="http://expath.org/ns/http-client"
                xmlns:h="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all"
                version="2.0">

   <xsl:import href="http://expath.org/ns/http-client.xsl"/>

   <xsl:output indent="yes"/>

   <xsl:template name="main" match="/">
      <root>
         <!-- the request element -->
         <xsl:variable name="request" as="element(http:request)">
            <!--http:request href="http://www.xmlprague.cz/" method="get"/-->
            <http:request href="http://www.balisage.net/" method="get"/>
         </xsl:variable>
         <!-- sending the request -->
         <xsl:variable name="resp" select="http:send-request($request)"/>
         <!-- add the http:response element to the output tree -->
         <xsl:sequence select="$resp[1]"/>
         <!-- add the title of the payload to the output tree -->
         <title>
            <xsl:value-of select="$resp[2]/h:html/h:head/h:title"/>
         </title>
      </root>
   </xsl:template>

</xsl:stylesheet>
