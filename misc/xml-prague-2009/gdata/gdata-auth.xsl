<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:http="http://www.exslt.org/v2/http-client"
                xmlns:http-java="java:org.fgeorges.exslt2.saxon.HttpClient"
                exclude-result-prefixes="#all"
                version="2.0">

   <xsl:output indent="yes"/>

   <!-- the email (user account) -->
   <xsl:param name="user" as="xs:string"/>
   <!-- the password -->
   <xsl:param name="pwd"  as="xs:string"/>

   <!-- the authentication endpoint, as defined by Google -->
   <xsl:variable name="auth-endpoint" as="xs:string" select="
       'https://www.google.com/accounts/ClientLogin'"/>
   <!-- the service name (here, the Contacts service) -->
   <xsl:variable name="service" select="'cp'"/>

   <!-- authenticate against a service -->
   <xsl:template name="main">
      <!-- '@gmail.com' at the end of $user is optional -->
      <xsl:variable name="email" select="
          if ( contains($user, '@') ) then
            $user
          else
            concat($user, '@gmail.com')"/>
      <!-- the authentication HTTP request -->
      <xsl:variable name="request" as="element(http:request)">
         <http:request method="post" href="{ $auth-endpoint }">
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
      <xsl:variable name="resp" select="http-java:send-request($request)"/>
      <!-- add the response element and the paylod to the output tree -->
      <result>
         <xsl:copy-of select="$resp[1]"/>
         <payload>
            <xsl:text>&#10;</xsl:text>
            <xsl:copy-of select="$resp[2]"/>
         </payload>
      </result>
   </xsl:template>

</xsl:stylesheet>
