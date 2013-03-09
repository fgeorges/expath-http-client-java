<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
                xmlns:wsx="http://www.webservicex.net"
                xmlns:http="http://www.exslt.org/v2/http-client"
                xmlns:http-client="java:org.fgeorges.exslt2.saxon.HttpClient"
                exclude-result-prefixes="xs xsi soap wsx http http-client"
                version="2.0">

   <!-- The result is text -->
   <xsl:output method="text"/>

   <!-- To serialize with saxon:serialize() -->
   <xsl:output name="default" indent="yes" omit-xml-declaration="yes"/>

   <!-- The Web service endpoint -->
   <xsl:param name="endpoint" as="xs:string" select="
       'http://www.webservicex.net/WeatherForecast.asmx'"/>

   <!-- The SOAP envelope -->
   <xsl:variable name="soap-request">
      <soap:Envelope>
         <soap:Header/>
         <soap:Body>
            <wsx:GetWeatherByPlaceName>
               <wsx:PlaceName>PRAGUE</wsx:PlaceName>
            </wsx:GetWeatherByPlaceName>
         </soap:Body>
      </soap:Envelope>
   </xsl:variable>

   <!-- The element representing the HTTP request -->
   <xsl:variable name="http-request" as="element(http:request)">
      <http:request method="post" href="{ $endpoint }">
         <http:header name="SOAPAction" value="http://www.webservicex.net/GetWeatherByPlaceName"/>
         <http:body content-type="text/xml"/>
      </http:request>
   </xsl:variable>

   <!-- The main template -->
   <xsl:template match="/" name="main">
      <!-- Send the HTTP request and get the result back -->
      <xsl:variable name="response" select="
          http-client:send-request($http-request, $endpoint, $soap-request)"/>
      <!-- Check for error in the HTTP layer -->
      <xsl:if test="$response[1]/number(@status) ne 200">
         <xsl:sequence select="
             error((), $response[1]/concat('HTTP error: ', @status, ' ', @message))"/>
      </xsl:if>
      <!-- Apply templates to the SOAP's payload -->
      <xsl:apply-templates select="$response[2]/soap:Envelope/soap:Body/*/*"/>
   </xsl:template>

   <!-- Handle the payload -->
   <xsl:template match="wsx:GetWeatherByPlaceNameResult">
      <xsl:text>Place: </xsl:text>
      <xsl:value-of select="wsx:PlaceName"/>
      <xsl:text>&#10;</xsl:text>
      <xsl:apply-templates select="wsx:Details/*"/>
   </xsl:template>

   <!-- Handle a single forecast -->
   <xsl:template match="wsx:WeatherData[*]">
      <xsl:text>  - </xsl:text>
      <xsl:value-of select="wsx:Day"/>
      <xsl:text>:&#09;</xsl:text>
      <xsl:value-of select="wsx:MinTemperatureC"/>
      <xsl:text> - </xsl:text>
      <xsl:value-of select="wsx:MaxTemperatureC"/>
      <xsl:text>&#10;</xsl:text>
   </xsl:template>

</xsl:stylesheet>
