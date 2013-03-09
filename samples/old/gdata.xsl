<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gdata="http://www.fgeorges.org/xslt/google/data"
                xmlns:atom="http://www.w3.org/2005/Atom"
                xmlns:os="http://a9.com/-/spec/opensearch/1.1/"
                xmlns:http="http://www.exslt.org/v2/http-client"
                xmlns:http-client="java:org.fgeorges.exslt2.httpclient.saxon.HttpClient"
                xmlns:impl="urn:X-FGeorges:xslt:google:data:impl"
                exclude-result-prefixes="#all"
                version="2.0">

   <!--
      Google Data API reference:
      http://code.google.com/apis/gdata/docs/2.0/reference.html#QueryRequests
   -->

   <xsl:function name="impl:send-request">
      <xsl:param name="request" as="element(http:request)"/>
      <xsl:param name="href"    as="xs:string?"/>
      <xsl:param name="content" as="element(atom:entry)?"/>
      <xsl:variable name="response" select="http-client:send-request($request, $href, $content)"/>
      <!--xsl:message xmlns:exslt="http://exslt.org/common">
         COUNT: <xsl:value-of select="count($response)"/>
         1: <xsl:value-of select="exslt:object-type($response[1])"/>
         2: <xsl:value-of select="exslt:object-type($response[2])"/>
      </xsl:message-->
      <xsl:sequence select="$response"/>
   </xsl:function>

   <xsl:function name="impl:send-request">
      <xsl:param name="request" as="element(http:request)"/>
      <xsl:param name="href"    as="xs:string?"/>
      <xsl:sequence select="impl:send-request($request, $href, ())"/>
   </xsl:function>

   <xsl:function name="impl:send-request">
      <xsl:param name="request" as="element(http:request)"/>
      <xsl:sequence select="impl:send-request($request, ())"/>
   </xsl:function>

   <!--
       Utility: check for error in HTTP response.
   -->
   <xsl:function name="impl:check-error">
      <!-- the HTTP response element -->
      <xsl:param name="response" as="element(http:response)"/>
      <!-- message in case of error -->
      <xsl:param name="message" as="xs:string"/>
      <xsl:variable name="code" select="xs:integer($response/@status)"/>
      <xsl:if test="not($code ge 200 and $code le 299)">
         <!-- FIXME: HTTP Client does not have something like 'message' for now!... -->
         <xsl:sequence select="
             error((), concat($message, ': ', $response/@status, ' - ', $response/@message))"/>
      </xsl:if>
   </xsl:function>

   <!--
       The authentication parameters, as simple param elements.
   -->
   <xsl:function name="impl:auth-params" as="element(param)+">
      <!-- the email (user account) -->
      <xsl:param name="email" as="xs:string"/>
      <!-- the password -->
      <xsl:param name="pwd" as="xs:string"/>
      <!-- the service -->
      <xsl:param name="service" as="xs:string"/>
      <!-- $email can be abbreviated if @gmail.com -->
      <xsl:variable name="full-email" select="
          if ( contains($email, '@') ) then
            $email
          else
            concat($email, '@gmail.com')"/>
      <!-- the param elements -->
      <param name="Email">
         <xsl:value-of select="$full-email"/>
      </param>
      <param name="Passwd">
         <xsl:value-of select="$pwd"/>
      </param>
      <param name="source">fgeorges-xsl-google-api-1</param>
      <param name="service">
         <xsl:value-of select="$service"/>
      </param>
      <param name="accountType">
         <xsl:value-of select="
             if ( ends-with($full-email, '@gmail.com') ) then
               'GOOGLE'
             else
               'HOSTED_OR_GOOGLE'"/>
      </param>
   </xsl:function>

   <!--
       Authenticates to the Google server, and returns the
       authentication token.
   -->
   <xsl:function name="gdata:auth-token" as="xs:string">
      <!-- the email (user account) -->
      <xsl:param name="email" as="xs:string"/>
      <!-- the password -->
      <xsl:param name="pwd" as="xs:string"/>
      <!-- the service -->
      <xsl:param name="service" as="xs:string"/>
      <!-- the endpoint -->
      <xsl:variable name="endpoint" as="xs:string" select="
          'https://www.google.com/accounts/ClientLogin'"/>
      <!-- the http request element -->
      <xsl:variable name="request" as="element(http:request)">
         <http:request method="post" href="{ $endpoint }">
            <http:body content-type="application/x-www-form-urlencoded">
               <xsl:for-each select="impl:auth-params($email, $pwd, $service)">
                  <xsl:value-of select="@name"/>
                  <xsl:text>=</xsl:text>
                  <xsl:value-of select="encode-for-uri(.)"/>
                  <xsl:if test="position() ne last()">
                     <xsl:text>&amp;</xsl:text>
                  </xsl:if>
               </xsl:for-each>
            </http:body>
         </http:request>
      </xsl:variable>
      <!-- send the request and get the response -->
      <xsl:variable name="response" select="impl:send-request($request)"/>
      <!-- was the request ok? -->
      <!-- TODO: Check further that count($response) is 2 and that $response[2] instance of xs:string. -->
      <xsl:sequence select="impl:check-error($response[1], 'Error while authenticating')"/>
      <!-- get the auth token in the response -->
      <xsl:sequence select="
          substring-after(
            tokenize($response[2], '&#10;')[substring-before(., '=') eq 'Auth'],
            '=')"/>
   </xsl:function>

   <!--
       Get a simple entry content.
       
       Send to the right endpoint (regarding the entry), a simple HTTP
       GET, with the right HTTP header for authorization (defined by
       Google).  Then check the response, and if everything was ok,
       return the Atom entry.
   -->
   <xsl:function name="gdata:get-entry" as="element(atom:entry)">
      <!-- the authentication token -->
      <xsl:param name="auth"   as="xs:string"/>
      <!-- the feed name -->
      <xsl:param name="id"     as="xs:string"/>
      <!-- the query parameters -->
      <xsl:param name="params" as="element(gdata:param)*"/>
      <xsl:sequence select="impl:get-element($auth, $id, $params)"/>
   </xsl:function>

   <!--
       Get a simple feed content.
       
       Send to the right endpoint (regarding the feed), a simple HTTP
       GET, with the right HTTP header for authorization (defined by
       Google).  Then check the response, and if everything was ok,
       return the Atom feed.
   -->
   <xsl:function name="gdata:get-feed" as="element(atom:feed)">
      <!-- the authentication token -->
      <xsl:param name="auth"   as="xs:string"/>
      <!-- the feed name -->
      <xsl:param name="id"     as="xs:string"/>
      <!-- the query parameters -->
      <xsl:param name="params" as="element(gdata:param)*"/>
      <xsl:sequence select="impl:get-element($auth, $id, $params)"/>
   </xsl:function>

   <!--
       Get a simple Atom element.
       
       Send to the right endpoint a simple HTTP GET, with the right
       HTTP header for authorization (defined by Google).  Then check
       the response, and if everything was ok, return the Atom element.
       
       TODO: Handle "session expired" (not sure what to do, for now an
       error is the better I think) and "redirection required" (retry
       the request to a new endpoint.)
   -->
   <xsl:function name="impl:get-element" as="element()">
      <!-- the authentication token -->
      <xsl:param name="auth"   as="xs:string"/>
      <!-- the feed name -->
      <xsl:param name="id"     as="xs:string"/>
      <!-- the query parameters -->
      <xsl:param name="params" as="element(gdata:param)*"/>
      <!-- the endpoint, including encoded params -->
      <xsl:variable name="endpoint" as="xs:string">
         <xsl:value-of separator="">
            <xsl:sequence select="$id"/>
            <xsl:for-each select="$params">
               <xsl:sequence select="if ( position() eq 1 ) then '?' else '&amp;'"/>
               <xsl:sequence select="@name, '=', encode-for-uri(@value)"/>
            </xsl:for-each>
         </xsl:value-of>
      </xsl:variable>
<xsl:message>
   ENDPOINT: <xsl:copy-of select="$endpoint"/>
</xsl:message>
      <!-- the http request element -->
      <xsl:variable name="request" as="element(http:request)">
         <http:request method="get" href="{ $endpoint }">
            <!-- TODO: Is it always 2? -->
            <http:header name="GData-Version" value="2"/>
            <!-- TODO: Could that be implemented by an implementation-defined @authentication-method? -->
            <http:header name="Authorization" value="GoogleLogin auth={ $auth }"/>
         </http:request>
      </xsl:variable>
<xsl:message>
   REQUEST: <xsl:copy-of select="$request"/>
</xsl:message>
      <!-- send the request and get the response -->
      <xsl:variable name="response" select="impl:send-request($request)"/>
<xsl:message>
   RESPONSE: <xsl:copy-of select="$response"/>
</xsl:message>
      <!-- was the request ok? -->
      <!--xsl:sequence select="impl:check-error($response[1], 'Error while getting feed/entry')"/-->
      <xsl:choose>
         <xsl:when test="xs:integer($response[1]/@status) eq 302">
            <xsl:variable name="r" select="impl:send-request($request, $response[1]/http:header[@name eq 'Location']/@value)"/>
<xsl:message>
   R: <xsl:copy-of select="$r"/>
</xsl:message>
            <xsl:sequence select="$r[2]/*"/>
         </xsl:when>
         <xsl:otherwise>
            <!-- get the response as an xml element -->
            <xsl:sequence select="$response[2]/*"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>

   <xsl:function name="gdata:get-chunked-feeds" as="element(atom:feed)+">
      <!-- the authentication token -->
      <xsl:param name="auth"   as="xs:string"/>
      <!-- the feed name -->
      <xsl:param name="feed"   as="xs:string"/>
      <!-- the query parameters -->
      <xsl:param name="params" as="element(gdata:param)*"/>
      <!-- start index -->
      <xsl:variable name="start" as="xs:integer" select="($params[@name eq 'start-index']/@value, 1)[1]"/>
      <!-- max results (TODO: Default of 25, really?) -->
      <xsl:variable name="max"   as="xs:integer" select="($params[@name eq 'max-results']/@value, 25)[1]"/>
      <xsl:variable name="new-params" as="element(gdata:param)+">
         <xsl:sequence select="$params[not(@name eq 'start-index')]"/>
         <xsl:if test="empty($params[@name eq 'max-results'])">
            <gdata:param name="max-results" value="{ $max }"/>
         </xsl:if>
      </xsl:variable>
      <xsl:sequence select="impl:get-chunked-feeds($auth, $feed, $start, $max, $new-params)"/>
   </xsl:function>

   <xsl:function name="impl:get-chunked-feeds" as="element(atom:feed)+">
      <!-- the authentication token -->
      <xsl:param name="auth"   as="xs:string"/>
      <!-- the feed name -->
      <xsl:param name="feed"   as="xs:string"/>
      <!-- start index -->
      <xsl:param name="start"  as="xs:integer"/>
      <!-- max results (must be also present with the same value in $params) -->
      <xsl:param name="max"    as="xs:integer"/>
      <!-- the query parameters -->
      <xsl:param name="params" as="element(gdata:param)*"/>
      <!-- start index as a gdata:param (can not be present in $params) -->
      <xsl:variable name="start-param" as="element(gdata:param)">
         <gdata:param name="start-index" value="{ $start }"/>
      </xsl:variable>
      <!-- one feed -->
      <xsl:variable name="this" select="gdata:get-feed($auth, $feed, ($params, $start-param))"/>
      <!-- index of the last enry in this feed -->
      <xsl:variable name="last" select="xs:integer($this/os:startIndex) + count($this/atom:entry) - 1"/>
      <!-- return this feed -->
      <xsl:sequence select="$this"/>
      <!-- recurse (or not) on following feeds -->
      <xsl:if test="$last lt xs:integer($this/os:totalResults)">
         <xsl:sequence select="impl:get-chunked-feeds($auth, $feed, $start + $max, $max, $params)"/>
      </xsl:if>
   </xsl:function>

   <xsl:function name="gdata:post-entry" as="element(atom:entry)">
      <!-- the authentication token -->
      <xsl:param name="auth"  as="xs:string"/>
      <!-- the feed name -->
      <xsl:param name="feed"  as="xs:string"/>
      <!-- the query parameters -->
      <xsl:param name="entry" as="element(atom:entry)"/>
      <!-- the endpoint -->
      <xsl:variable name="endpoint" as="xs:string" select="$feed"/>
      <!-- the http request element -->
      <xsl:variable name="request" as="element(http:request)">
         <http:request method="post" href="{ $endpoint }">
            <!-- TODO: Is it always 2? -->
            <http:header name="GData-Version" value="2"/>
            <!-- TODO: Could that be implemented by an implementation-defined @authentication-method? -->
            <http:header name="Authorization" value="GoogleLogin auth={ $auth }"/>
            <!-- DEBUG: ... -->
            <!--http:body content-type="application/atom+xml"/-->
            <http:body content-type="application/atom+xml">
               <xsl:sequence select="$entry"/>
            </http:body>
         </http:request>
      </xsl:variable>
<!--xsl:message>
   REQUEST: <xsl:copy-of select="$request"/>
</xsl:message-->
      <!-- send the request and get the response -->
      <!-- DEBUG: ... -->
      <!--xsl:variable name="response" select="impl:send-request($request, (), $entry)"/-->
      <xsl:variable name="response" select="impl:send-request($request)"/>
<!--xsl:message>
   RESPONSE: <xsl:copy-of select="$response"/>
</xsl:message-->
      <!-- was the request ok? -->
      <!--xsl:sequence select="impl:check-error($response[1], 'Error while getting feed')"/-->
      <xsl:choose>
         <xsl:when test="xs:integer($response[1]/@status) eq 302">
            <xsl:variable name="r" select="impl:send-request($request, $response[1]/http:header[@name eq 'Location']/@value)"/>
<!--xsl:message>
   R: <xsl:copy-of select="$r"/>
</xsl:message-->
            <xsl:sequence select="$r[2]/*"/>
         </xsl:when>
         <xsl:otherwise>
            <!-- get the response as an xml element -->
            <xsl:sequence select="$response[2]/*"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>

</xsl:stylesheet>
