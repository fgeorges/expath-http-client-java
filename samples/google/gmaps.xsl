<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gmap="http://www.fgeorges.org/xslt/google/maps"
                xmlns:kml="http://earth.google.com/kml/2.0"
                xmlns:gdata="http://www.fgeorges.org/xslt/google/data"
                xmlns:http="http://expath.org/ns/http-client"
                xmlns:impl="urn:X-FGeorges:xslt:google:gmaps:impl"
                exclude-result-prefixes="#all"
                version="2.0">

   <xsl:import href="gdata.xsl"/>

   <xsl:function name="gmap:make-maps-service" as="element(gmap:service)">
      <xsl:param name="key" as="xs:string"/>
      <gmap:service name="gmaps">
         <gmap:key escaped="{ encode-for-uri($key) }">
            <xsl:value-of select="$key"/>
         </gmap:key>
      </gmap:service>
   </xsl:function>

   <!--
       Resolve an address and return two or three xs:double if it
       succeeds: longitude, latitude, and altitude (in that order).
       
       * longitude ≥ −180 and <= 180
       * latitude ≥ −90 and ≤ 90
       * altitude values (optional) are in meters above sea level
       
       http://code.google.com/apis/kml/documentation/kmlreference.html#coordinates
       
       The address should be a loosly structured string, with commas,
       semi-commas, or linefeeds as separators (between street, city,
       state...)  In case of ambiguity, simply take the first one.
   -->
   <xsl:function name="gmap:address-to-coordinates" as="xs:double*">
      <xsl:param name="service" as="element(gmap:service)"/>
      <xsl:param name="address" as="xs:string"/>
      <xsl:variable name="params" as="element(gdata:param)+">
         <gdata:param name="q"      value="{
             normalize-space(replace($address, '[;&#10;]', ', ')) }"/>
         <gdata:param name="output" value="xml"/>
         <gdata:param name="oe"     value="utf8"/>
         <gdata:param name="sensor" value="false"/>
         <gdata:param name="key"    value="{ $service/gmap:key }"/>
      </xsl:variable>
      <xsl:variable name="request" as="element(http:request)">
         <http:request method="get" href="{
             gdata:encode-params('http://maps.google.com/maps/geo', $params) }"/>
      </xsl:variable>
      <!-- FIXME: Check result! (HTTP + KML) -->
      <xsl:variable name="response" select="gdata:send-request($request)"/>
      <xsl:variable name="kml-resp" as="element(kml:Response)?" select="
          $response[2]/kml:kml/kml:Response"/>
      <xsl:if test="xs:integer($response[1]/@status) eq 200
                      and $kml-resp/kml:Status/xs:integer(kml:code) eq 200">
         <xsl:variable name="coord" as="element()" select="
             ($kml-resp/kml:Placemark/kml:Point/kml:coordinates)[1]"/>
         <xsl:sequence select="for $t in tokenize($coord, ',') return xs:double($t)"/>
      </xsl:if>
<!-- TMP: else... -->
<xsl:if test="not( xs:integer($response[1]/@status) eq 200
                     and $kml-resp/kml:Status/xs:integer(kml:code) eq 200 )">
   <xsl:message>
      *** FAILED ***
      ADDRESS: <xsl:copy-of select="$address"/>
      <!--
      PARAMS: <xsl:copy-of select="$params"/>
      COORD: <xsl:copy-of select="$response"/-->
   </xsl:message>
</xsl:if>
   </xsl:function>

   <!--
       Get a static map as a GIF in base 64.
   -->
   <xsl:function name="gmap:get-static-map" as="xs:base64Binary">
      <xsl:param name="service" as="element(gmap:service)"/>
      <xsl:param name="params"  as="element(gdata:param)+"/>
      <xsl:variable name="p"  as="element(gdata:param)">
         <xsl:sequence select="$params"/>
         <xsl:if test="exists($params[@name eq 'key'])">
            <!-- TODO: Error handling -->
            <xsl:sequence select="error((), 'key cannot be set manually')"/>
         </xsl:if>
         <gdata:param name="key" value="{ $service/gmap:key }"/>
         <xsl:if test="empty($params[@name eq 'sensor'])">
            <gdata:param name="sensor" value="false"/>
         </xsl:if>
         <xsl:if test="empty($params[@name eq 'oe'])">
            <gdata:param name="oe" value="utf8"/>
         </xsl:if>
      </xsl:variable>
      <xsl:variable name="request" as="element(http:request)">
         <http:request method="get" href="{
             gdata:encode-params('http://maps.google.com/staticmap', $params) }"/>
      </xsl:variable>
      <!-- FIXME: Check result! -->
      <xsl:variable name="response" select="gdata:send-request($request)"/>
      <xsl:sequence select="$response[2]"/>
   </xsl:function>

</xsl:stylesheet>
