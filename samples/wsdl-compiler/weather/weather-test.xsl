<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:my="http://example.org/this/stylesheet"
                xmlns:tns="http://www.webserviceX.NET"
                version="2.0">

   <xsl:import href="weather.xsl"/>

   <xsl:output indent="yes"/>

   <!-- hand-written wrapper around the generated function -->
   <xsl:function name="my:get-weather" as="xs:string">
      <xsl:param name="city"    as="xs:string"/>
      <xsl:param name="country" as="xs:string"/>
      <xsl:variable name="request" as="element()">
         <tns:GetWeather>
            <tns:CityName>
               <xsl:value-of select="$city"/>
            </tns:CityName>
            <tns:CountryName>
               <xsl:value-of select="$country"/>
            </tns:CountryName>
         </tns:GetWeather>
      </xsl:variable>
      <!-- Returned as plain text, as a serialized XML!?! (that's how this Web service behaves!) -->
      <xsl:sequence select="tns:GetWeather($request)/tns:GetWeatherResult"/>
   </xsl:function>

   <!-- hand-written wrapper around the generated function -->
   <xsl:function name="my:get-cities" as="xs:string">
      <xsl:param name="country" as="xs:string"/>
      <xsl:variable name="request" as="element()">
         <tns:GetCitiesByCountry>
            <tns:CountryName>
               <xsl:value-of select="$country"/>
            </tns:CountryName>
         </tns:GetCitiesByCountry>
      </xsl:variable>
      <!-- Returned as plain text, as a serialized XML!?! (that's how this Web service behaves!) -->
      <xsl:sequence select="tns:GetCitiesByCountry($request)/tns:GetCitiesByCountryResult"/>
   </xsl:function>

   <xsl:template match="/" name="main">
      <cities>
         <xsl:sequence select="my:get-cities('belgium')"/>
      </cities>
      <brussels>
         <xsl:sequence select="my:get-weather('bruxelles', 'belgium')"/>
      </brussels>
   </xsl:template>

</xsl:stylesheet>
