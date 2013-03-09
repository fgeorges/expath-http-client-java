<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:atom="http://www.w3.org/2005/Atom"
                xmlns:http="http://www.exslt.org/v2/http-client"
                xmlns:http-java="java:org.fgeorges.exslt2.saxon.HttpClient"
                xmlns:impl="urn:X-FGeorges:exslt2:prague:2009:gdata"
                exclude-result-prefixes="#all"
                version="2.0">

   <xsl:output indent="yes"/>

   <!-- the email (user account) -->
   <xsl:param name="user" as="xs:string"/>
   <!-- the password -->
   <xsl:param name="pwd"  as="xs:string"/>

   <!-- '@gmail.com' at the end of $user is optional -->
   <xsl:variable name="email" as="xs:string" select="
       if ( contains($user, '@') ) then
         $user
       else
         concat($user, '@gmail.com')"/>

   <xsl:template name="main">
      <xsl:variable name="cp-auth" as="xs:string" select="impl:authenticate('cp')"/>
      <xsl:variable name="cl-auth" as="xs:string" select="impl:authenticate('cl')"/>
      <backup-pim>
         <contacts>
            <xsl:copy-of select="impl:get-feed($cp-auth, $impl:contacts-endpoint)"/>
         </contacts>
         <groups>
            <xsl:copy-of select="impl:get-feed($cp-auth, $impl:groups-endpoint)"/>
         </groups>
         <agenda>
            <xsl:copy-of select="impl:get-feed($cl-auth, $impl:agenda-endpoint)"/>
         </agenda>
      </backup-pim>
   </xsl:template>

   <!-- the authentication endpoint, as defined by Google -->
   <xsl:variable name="impl:auth-endpoint" as="xs:string" select="
       'https://www.google.com/accounts/ClientLogin'
       (: 'http://localhost:8080/tools/gdata/auth' :)"/>

   <xsl:function name="impl:authenticate" as="xs:string">
      <xsl:param name="service" as="xs:string"/>
      <!-- the authentication HTTP request -->
      <xsl:variable name="request" as="element(http:request)">
         <http:request method="post" href="{ $impl:auth-endpoint }">
            <http:header name="GData-Version" value="2"/>
            <http:body content-type="application/x-www-form-urlencoded">
               <xsl:text>Email=</xsl:text>
               <xsl:value-of select="encode-for-uri($email)"/>
               <xsl:text>&amp;Passwd=</xsl:text>
               <xsl:value-of select="encode-for-uri($pwd)"/>
               <xsl:text>&amp;source=fgeorges-xsl-gdata-0.1</xsl:text>
               <xsl:text>&amp;service=</xsl:text>
               <xsl:value-of select="encode-for-uri($service)"/>
               <xsl:text>&amp;accountType=</xsl:text>
               <xsl:value-of select="
                   if ( ends-with($email, '@gmail.com') ) then
                     'GOOGLE'
                   else
                     'HOSTED_OR_GOOGLE'"/>
            </http:body>
         </http:request>
      </xsl:variable>
      <!-- send the request and get the response -->
      <xsl:variable name="r" select="http-java:send-request($request)"/>
      <!-- ...does the response look ok? -->
      <xsl:if test="count($r) ne 2">
         <xsl:sequence select="error((), 'Authentication: wrong HTTP response.')"/>
      </xsl:if>
      <xsl:if test="not($r[2] instance of xs:string)">
         <xsl:sequence select="error((), 'Authentication: return is not text.')"/>
      </xsl:if>
      <xsl:if test="xs:integer($r[1]/@status) ne 200">
         <xsl:sequence select="error((), 'Authentication: HTTP server returned error.')"/>
      </xsl:if>
      <!-- ...get the auth token within the response -->
      <xsl:sequence select="
          substring-after(
            tokenize($r[2], '&#13;?&#10;')[starts-with(., 'Auth=')],
            '=')"/>
   </xsl:function>

   <!-- the contacts feed endpoint, as defined by Google -->
   <xsl:variable name="impl:contacts-endpoint" as="xs:string" select="
       concat('http://www.google.com/m8/feeds/contacts/',
              encode-for-uri($email),
              '/full')
        (: 'http://localhost:8080/tools/gdata/contacts' :)"/>

   <!-- the groups feed endpoint, as defined by Google -->
   <xsl:variable name="impl:groups-endpoint" as="xs:string" select="
       concat('http://www.google.com/m8/feeds/groups/',
              encode-for-uri($email),
              '/full')
        (: 'http://localhost:8080/tools/gdata/groups' :)"/>

   <!-- the calendar entries feed endpoint, as defined by Google -->
   <xsl:variable name="impl:agenda-endpoint" as="xs:string" select="
       'https://www.google.com/calendar/feeds/default/private/full'
       (: 'http://localhost:8080/tools/gdata/cal-entries' :)"/>

   <xsl:function name="impl:get-feed" as="element(atom:feed)">
      <xsl:param name="auth-token"    as="xs:string"/>
      <xsl:param name="feed-endpoint" as="xs:string"/>
      <!-- the authentication HTTP request -->
      <xsl:variable name="request" as="element(http:request)">
         <http:request method="get" href="{ $feed-endpoint }?max-results=1000">
            <http:header name="GData-Version" value="2"/>
            <http:header name="Authorization" value="GoogleLogin auth={ $auth-token }"/>
         </http:request>
      </xsl:variable>
      <!-- send the request and get the response -->
      <xsl:variable name="r" select="http-java:send-request($request)"/>
      <!-- ...does the response look ok? -->
      <xsl:if test="count($r) ne 2">
         <xsl:sequence select="error((), 'Authentication: wrong HTTP response.')"/>
      </xsl:if>
      <xsl:if test="xs:integer($r[1]/@status) ne 200">
         <xsl:sequence select="error((), 'Authentication: HTTP server returned error.')"/>
      </xsl:if>
      <!-- ...get the auth token within the response -->
      <xsl:sequence select="$r[2]/*"/>
   </xsl:function>

</xsl:stylesheet>
