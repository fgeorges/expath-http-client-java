<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:wx="http://www.fgeorges.org/ws-xslt"
                xmlns:tns="http://www.fgeorges.org/ws/test/weather"
                exclude-result-prefixes="#all"
                version="2.0">

   <xsl:template match="tns:weather-by-city-request" mode="wx:operation">
      <tns:weather-by-city-response>
         <tns:place>
            <xsl:value-of select="tns:city"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="tns:country"/>
         </tns:place>
         <tns:detail>
            <tns:day>2008-03-22</tns:day>
            <tns:min-temp>28</tns:min-temp>
            <tns:max-temp>38</tns:max-temp>
            <tns:desc>Sun</tns:desc>
         </tns:detail>
         <tns:detail>
            <tns:day>2008-03-23</tns:day>
            <tns:min-temp>-2</tns:min-temp>
            <tns:max-temp>5</tns:max-temp>
            <tns:desc>Rain</tns:desc>
         </tns:detail>
      </tns:weather-by-city-response>
   </xsl:template>

</xsl:stylesheet>
