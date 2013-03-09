<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:http="http://expath.org/ns/http-client"
                exclude-result-prefixes="#all"
                version="2.0">

   <xsl:import href="http://expath.org/ns/http-client.xsl"/>

   <xsl:template match="/" name="main">
      <xsl:variable name="req" as="element(http:request)">
         <http:request method="get" href="http://expath.org/"/>
      </xsl:variable>
      <xsl:sequence select="http:send-request($req)"/>
   </xsl:template>

</xsl:stylesheet>
