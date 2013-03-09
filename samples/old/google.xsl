<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:goog="http://www.fgeorges.org/xslt/google"
                xmlns:atom="http://www.w3.org/2005/Atom"
                xmlns:os="http://a9.com/-/spec/opensearch/1.1/"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:http="http://www.exslt.org/v2/http-client"
                xmlns:http-client="java:org.fgeorges.exslt2.httpclient.saxon.HttpClient"
                exclude-result-prefixes="#all"
                version="2.0">

   <xsl:output indent="yes"/>

   <!-- The account to use (the address email) -->
   <xsl:param name="account" as="xs:string" required="yes"/>
   <!-- The associated password, required -->
   <xsl:param name="pwd"     as="xs:string" required="yes"/>

   <xsl:function name="goog:send-request">
      <xsl:param name="request" as="element(http:request)"/>
      <xsl:variable name="response" select="http-client:send-request($request)"/>
      <xsl:message xmlns:exslt="http://exslt.org/common">
         COUNT: <xsl:value-of select="count($response)"/>
         1: <xsl:value-of select="exslt:object-type($response[1])"/>
         2: <xsl:value-of select="exslt:object-type($response[2])"/>
      </xsl:message>
      <xsl:sequence select="$response"/>
   </xsl:function>

   <!--
       Utility: check for error in HTTP response.
   -->
   <xsl:function name="goog:check-error">
      <!-- the HTTP response element -->
      <xsl:param name="response" as="element()"/>
      <!-- message in case of error -->
      <xsl:param name="message" as="xs:string"/>
      <xsl:variable name="code" select="xs:integer($response/@code)"/>
      <xsl:if test="$code lt 200 or $code gt 299">
         <xsl:sequence select="
             error((), concat($message, ': ', $response/message))"/>
      </xsl:if>
   </xsl:function>

   <!--
       The authentication parameters, as simple param elements.
   -->
   <xsl:function name="goog:auth-params" as="element(param)+">
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
   <xsl:function name="goog:auth-token" as="xs:string">
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
               <xsl:for-each select="goog:auth-params($email, $pwd, $service)">
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
      <xsl:variable name="response" select="goog:send-request($request)"/>
      <!-- was the request ok? -->
      <!-- TODO: Check further that count($response) is 2 and that $response[2] instance of xs:string. -->
      <xsl:sequence select="goog:check-error($response[1], 'Error while authenticating')"/>
      <!-- get the auth token in the response -->
      <xsl:sequence select="
          substring-after(
            tokenize($response[2], '&#10;')[substring-before(., '=') eq 'Auth'],
            '=')"/>
   </xsl:function>

   <!--
       Get a simple feed content.
       
       Send to the right endpoint (regarding the feed), a simple HTTP
       GET, with the right HTTP header for authorization (defined by
       Google).  Then check the response, and if everything was ok,
       parse the XML result.
   -->
   <xsl:function name="goog:get-feed" as="element(atom:feed)">
      <!-- the authentication token -->
      <xsl:param name="auth" as="xs:string"/>
      <!-- the feed name -->
      <xsl:param name="feed" as="xs:string"/>
      <!-- maximum number of result entries -->
      <xsl:param name="max" as="xs:integer?"/>
      <!-- start index -->
      <xsl:param name="start" as="xs:integer?"/>
      <xsl:variable name="params" as="element(p)+">
         <p name="max-results" value="{ $max }"/>
         <p name="start-index" value="{ $start }"/>
      </xsl:variable>
      <!-- the endpoint -->
      <xsl:variable name="endpoint" as="xs:string">
         <xsl:value-of separator="">
            <xsl:sequence select="$feed"/>
            <xsl:for-each select="$params[string(@value)]">
               <xsl:sequence select="if ( position() gt 1 ) then '&amp;' else '?'"/>
               <xsl:sequence select="@name, '=', @value"/>
            </xsl:for-each>
         </xsl:value-of>
      </xsl:variable>
<xsl:message>
   ENDPOINT: <xsl:value-of select="$endpoint"/>
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
      <!-- send the request and get the response -->
      <xsl:variable name="response" select="goog:send-request($request)"/>
<xsl:message>
   RESPONSE: <xsl:value-of select="$response"/>
</xsl:message>
      <!-- was the request ok? -->
      <xsl:sequence select="goog:check-error($response[1], 'Error while getting feed')"/>
      <!-- get the response as an xml element -->
      <xsl:sequence select="$response[2]/*"/>
      <!--xsl:sequence select="saxon:parse($response[1]/http:body)/*"/-->
   </xsl:function>

   <xsl:function name="goog:get-chunked-feeds" as="element(atom:feed)+">
      <!-- the authentication token -->
      <xsl:param name="auth" as="xs:string"/>
      <!-- the feed name -->
      <xsl:param name="feed" as="xs:string"/>
      <!-- maximum number of result entries per feed -->
      <xsl:param name="max" as="xs:integer?"/>
      <!-- start index -->
      <xsl:param name="start" as="xs:integer?"/>
      <xsl:variable name="this" select="goog:get-feed($auth, $feed, $max, $start)" as="element(atom:feed)"/>
      <xsl:variable name="total" select="xs:integer($this/os:totalResults)"/>
      <xsl:variable name="count" select="xs:integer($this/os:startIndex) + xs:integer($this/os:itemsPerPage) - 1"/>
      <xsl:if test="$count lt $total">
         <xsl:sequence select="goog:get-chunked-feeds($auth, $feed, $max, ($start, 1)[1] + $max)"/>
      </xsl:if>
      <xsl:sequence select="$this"/>
   </xsl:function>

   <xsl:function name="goog:get-contact-feed" as="element(atom:feed)">
      <!-- the authentication token -->
      <xsl:param name="auth" as="xs:string"/>
      <xsl:sequence select="
          goog:get-feed($auth, 'https://www.google.com/m8/feeds/contacts/default/full', 1000, ())"/>
   </xsl:function>

   <xsl:function name="goog:get-group-feed" as="element(atom:feed)">
      <!-- the authentication token -->
      <xsl:param name="auth" as="xs:string"/>
      <xsl:sequence select="
          goog:get-feed($auth, 'https://www.google.com/m8/feeds/groups/default/full', 1000, ())"/>
   </xsl:function>

   <xsl:function name="goog:get-calendar-feed" as="element(atom:feed)">
      <!-- the authentication token -->
      <xsl:param name="auth" as="xs:string"/>
      <xsl:sequence select="
          goog:get-feed($auth, 'https://www.google.com/calendar/feeds/default/allcalendars/full', 1000, ())"/>
   </xsl:function>

   <!--
       Main template: authenticates, then gets contacts and groups.
   -->
   <xsl:template name="main">
      <contacts-and-groups xmlns:gd="http://schemas.google.com/g/2005"
                           xmlns:gc="http://schemas.google.com/contact/2008">
         <!-- the authentication token for contact API -->
         <xsl:variable name="auth-cp" select="goog:auth-token($account, $pwd, 'cp')"/>
         <!-- the contacts -->
         <!--xsl:apply-templates select="goog:get-feed($auth-cp, 'contacts')" mode="handle"/-->
         <xsl:sequence select="goog:get-contact-feed($auth-cp)"/>
         <!-- the groups -->
         <!--xsl:apply-templates select="goog:get-feed($auth-cp, 'groups')" mode="handle"/-->
         <xsl:sequence select="goog:get-group-feed($auth-cp)"/>
         <!-- the authentication token for calendar API -->
         <xsl:variable name="auth-cl" select="goog:auth-token($account, $pwd, 'cl')"/>
         <!-- the calendars -->
         <xsl:variable name="calendars" select="goog:get-calendar-feed($auth-cl)" as="element(atom:feed)"/>
         <xsl:sequence select="$calendars"/>
         <!-- the events -->
         <xsl:for-each select="$calendars/atom:entry">
            <xsl:sequence select="goog:get-chunked-feeds($auth-cl, atom:content/@src, 10, ())"/>
         </xsl:for-each>
      </contacts-and-groups>
   </xsl:template>

   <!-- Identity Template pattern. -->
   <xsl:template match="@*|node()" mode="handle">
      <xsl:copy copy-namespaces="no">
         <xsl:apply-templates select="@*|node()" mode="handle"/>
      </xsl:copy>
   </xsl:template>

   <!-- Do not copy open search elements. -->
   <xsl:template match="os:*" mode="handle"/>

   <!-- Do not copy link and category elements. -->
   <xsl:template match="atom:link|atom:category" mode="handle"/>

   <!-- Do not copy gd:email/@rel. -->
   <xsl:template match="gd:email/@rel" mode="handle" xmlns:gd="http://schemas.google.com/g/2005"/>

   <!-- Truncate ids. -->
   <xsl:template match="atom:id" mode="handle">
      <xsl:copy copy-namespaces="no">
         <xsl:value-of select="tokenize(., '/')[last()]"/>
      </xsl:copy>
   </xsl:template>

   <!-- Truncate group id refs. -->
   <xsl:template match="gc:groupMembershipInfo" mode="handle" xmlns:gc="http://schemas.google.com/contact/2008">
      <gc:groupMembershipInfo href="{ tokenize(@href, '/')[last()] }">
         <xsl:apply-templates select="(@*|node()) except @href" mode="handle"/>
      </gc:groupMembershipInfo>
   </xsl:template>

</xsl:stylesheet>
