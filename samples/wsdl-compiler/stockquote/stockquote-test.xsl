<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:my="http://example.org/this/stylesheet"
                xmlns:tns="http://www.webserviceX.NET/"
                version="2.0">

   <xsl:import href="stockquote.xsl"/>

   <xsl:output indent="yes"/>

   <!-- hand-written wrapper around the generated function -->
   <xsl:function name="my:get-quote" as="xs:string">
      <xsl:param name="symbol" as="xs:string"/>
      <xsl:variable name="request" as="element()">
         <tns:GetQuote>
            <tns:symbol>
               <xsl:value-of select="$symbol"/>
            </tns:symbol>
         </tns:GetQuote>
      </xsl:variable>
      <!-- Returned as plain text, as a serialized XML!?! (that's how this Web service behaves!) -->
      <xsl:sequence select="tns:GetQuote($request)/tns:GetQuoteResult"/>
   </xsl:function>

   <xsl:template match="/" name="main">
      <xsl:sequence select="my:get-quote('MSFT')"/>
   </xsl:template>

</xsl:stylesheet>
