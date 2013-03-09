<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:http="http://www.exslt.org/v2/http-client"
                xmlns:http-java="java:org.fgeorges.exslt2.saxon.HttpClient"
                exclude-result-prefixes="#all"
                version="2.0">

   <xsl:output indent="yes"/>

   <xsl:template name="main" match="/">
      <root>
         <!-- the request element -->
         <xsl:variable name="request" as="element(http:request)">
            <!--http:request href="http://www.fgeorges.org/cgi-bin/display-post" method="post"-->
            <!--http:request href="http://localhost:8080/ws-xslt/debug-mirror" method="post"-->
            <http:request href="http://localhost:8099/" method="post">
               <http:header name="Cache-Control" value="no-cache"/>
               <http:header name="User-Agent" value="EXSLT 2.0 HTTP Client"/>
               <http:multipart content-type="multipart/form-data"
                               boundary="ThIs_Is_tHe_bouNdaRY_$">
                  <http:header name="Content-Disposition" value="form-data; name=service"/>
                  <http:body content-type="text/plain">world</http:body>
                  <http:header name="Content-Disposition"
                               value="form-data; name=archive; filename=some-file.tgz"/>
                  <http:body content-type="text/xml">
                     <hello/>
                  </http:body>
               </http:multipart>
            </http:request>
         </xsl:variable>
         <!-- sending the request -->
         <xsl:variable name="resp" select="http-java:send-request($request)"/>
         <!-- add the http:response element to the output tree -->
         <xsl:sequence select="$resp[1]"/>
         <!-- add the payload to the output tree -->
         <text>
            <xsl:sequence select="$resp[2]"/>
         </text>
      </root>
   </xsl:template>

</xsl:stylesheet>
