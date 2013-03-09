<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:doc="http://www.CraneSoftwrights.com/ns/xslstyle"
                xmlns:gdata="http://www.fgeorges.org/xslt/google/data"
                xmlns:atom="http://www.w3.org/2005/Atom"
                xmlns:os="http://a9.com/-/spec/opensearch/1.1/"
                xmlns:http="http://expath.org/ns/http-client"
                xmlns:impl="urn:X-FGeorges:xslt:google:data:impl"
                exclude-result-prefixes="#all"
                version="2.0">

   <doc:doc filename="gcontacts.xsl" internal-ns="impl" global-ns="gdata" vocabulary="DocBook"
            info="$Id$">
      <doc:title>XSLT module to access Google Data API.</doc:title>
      <para>
         See Google Data API documentation at
         <ulink url="http://code.google.com/apis/gdata/"/>.
      </para>
      <!-- TODO: Full copyright statement should be at the end of the file. -->
      <programlisting>
Copyright (c) 2009 Florent Georges.

DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS COMMENT.

The contents of this file are subject to the Mozilla Public License
Version 1.0 (the "License"); you may not use this file except in
compliance with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/.

Software distributed under the License is distributed on an "AS IS"
basis, WITHOUT WARRANTY OF ANY KIND, either express or implied.  See
the License for the specific language governing rights and limitations
under the License.

The Original Code is: all this file.

The Initial Developer of the Original Code is Florent Georges.

Contributor(s): none.
      </programlisting>
   </doc:doc>


   <!-- ...........................................................................................
      Global parameters and variables.
   -->

   <doc:doc>
      <doc:title>Global parameters and variables.</doc:title>
   </doc:doc>

   <doc:variable>
      <para>The name of this library, to send to Google for authentification.</para>
   </doc:variable>
   <xsl:variable name="impl:app-name" as="xs:string" select="'fgeorges-xsl-gdata-0.1'"/>


   <!-- ...........................................................................................
      HTTP handling.
      
      Are in gdata: instead of impl:, to enable satelites stylesheets
      (and maybe users) to use it instead of referecing directly the
      HTTP Client Java namespace.  Though this is a semi-public (or
      semi-private) function.
   -->

   <doc:doc>
      <doc:title>HTTP handling.</doc:title>
   </doc:doc>

   <doc:function>
      <para>Wrapper to the EXPath function to send HTTP requests.</para>
      <doc:param name="request">
         <para>The request element, as defined in EXPath.</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gdata:send-request" as="item()+">
      <xsl:param name="request" as="element(http:request)"/>
      <xsl:sequence select="gdata:send-request($request, ())"/>
   </xsl:function>

   <doc:function>
      <para>Wrapper to the EXPath function to send HTTP requests.</para>
      <doc:param name="request">
         <para>The request element, as defined in EXPath.</para>
      </doc:param>
      <doc:param name="href">
         <para>The URI to send the request to.</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gdata:send-request" as="item()+">
      <xsl:param name="request" as="element(http:request)"/>
      <xsl:param name="href"    as="xs:string?"/>
      <xsl:sequence select="gdata:send-request($request, $href, ())"/>
   </xsl:function>

   <doc:function>
      <para>Wrapper to the EXPath function to send HTTP requests.</para>
      <doc:param name="request">
         <para>The request element, as defined in EXPath.</para>
      </doc:param>
      <doc:param name="href">
         <para>The URI to send the request to.</para>
      </doc:param>
      <doc:param name="content">
         <para>The payload of the request, as defined in EXPath.</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gdata:send-request" as="item()+">
      <xsl:param name="request" as="element(http:request)"/>
      <xsl:param name="href"    as="xs:string?"/>
      <!-- TODO: An Atom entry, really?  At this level?  See implications with
           Google Maps service (doesn't strictly use GData Protocol.) -->
      <xsl:param name="content" as="element(atom:entry)?"/>
      <xsl:variable
          name="response"
          xmlns:http-java="java:org.expath.saxon.HttpClient"
          select="http-java:send-request($request, $href, $content)"/>
      <xsl:sequence select="$response"/>
   </xsl:function>

   <doc:function>
      <para>Add the query part to a URI path, based on params.</para>
      <doc:param name="uri-path">
         <para>The URI path (a URI without query part.)</para>
      </doc:param>
      <doc:param name="params">
         <para>The parameters to encode in the URI query part.  Each parameter is an element of
            the form <code>&lt;gdata:param name="..." value="..."/></code>.  Categories are
            treated specially, using the GData "/-/&lt;category>" notation.</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gdata:encode-params" as="xs:string">
      <!-- the URL path (without query nor fragment parts) -->
      <xsl:param name="uri-path" as="xs:string"/>
      <!-- query parameters -->
      <xsl:param name="params"   as="element(gdata:param)*"/>
      <xsl:variable name="categories" as="element(gdata:param)*" select="
          $params[@name eq 'category']"/>
      <xsl:value-of separator="">
         <xsl:sequence select="$uri-path"/>
         <xsl:if test="exists($categories)">
            <xsl:sequence select="'/-'"/>
            <xsl:sequence select="$categories/concat('/', @value)"/>
         </xsl:if>
         <xsl:for-each select="$params except $categories">
            <xsl:sequence select="if ( position() eq 1 ) then '?' else '&amp;'"/>
            <!-- @name should not need to be encoded, but that could prevent
                 some kind of "injection" if @name is not correct... -->
            <xsl:sequence select="encode-for-uri(@name), '=', encode-for-uri(@value)"/>
         </xsl:for-each>
      </xsl:value-of>
   </xsl:function>


   <!-- ...........................................................................................
      Authentication.
   -->

   <doc:doc>
      <doc:title>Authentication.</doc:title>
   </doc:doc>

   <doc:variable>
      <para>The URI to use to authenticate.</para>
   </doc:variable>
   <xsl:variable name="impl:auth-endpoint" as="xs:string" select="
       'https://www.google.com/accounts/ClientLogin'"/>

   <doc:function>
      <para>Make a new service object.</para>
      <doc:param name="service">
         <para>The service name, as defined by each Google service.</para>
      </doc:param>
      <doc:param name="email">
         <para>The email address of the user to authenticate.</para>
      </doc:param>
      <doc:param name="pwd">
         <para>The password of the user.</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gdata:make-service" as="element(gdata:service)">
      <!-- the service name -->
      <xsl:param name="service" as="xs:string"/>
      <!-- the email (user account) -->
      <xsl:param name="email" as="xs:string"/>
      <!-- the password -->
      <xsl:param name="pwd" as="xs:string"/>
      <!-- '@gmail.com' at the end of $email is optional -->
      <xsl:variable name="full-email" select="
          if ( contains($email, '@') ) then
            $email
          else
            concat($email, '@gmail.com')"/>
      <!-- the authentication HTTP request -->
      <xsl:variable name="auth-request" as="element(http:request)">
         <http:request method="post" href="{ $impl:auth-endpoint }">
            <http:header name="GData-Version" value="2"/>
            <http:body content-type="application/x-www-form-urlencoded">
               <xsl:text>Email=</xsl:text>
               <xsl:value-of select="encode-for-uri($full-email)"/>
               <xsl:text>&amp;Passwd=</xsl:text>
               <xsl:value-of select="encode-for-uri($pwd)"/>
               <xsl:text>&amp;source=</xsl:text>
               <xsl:value-of select="encode-for-uri($impl:app-name)"/>
               <xsl:text>&amp;service=</xsl:text>
               <xsl:value-of select="encode-for-uri($service)"/>
               <xsl:text>&amp;accountType=</xsl:text>
               <xsl:value-of select="
                   if ( ends-with($full-email, '@gmail.com') ) then
                     'GOOGLE'
                   else
                     'HOSTED_OR_GOOGLE'"/>
            </http:body>
         </http:request>
      </xsl:variable>
      <!-- the authentication token -->
      <xsl:variable name="auth-token" as="xs:string">
         <!-- ...send the request and get the response -->
         <xsl:variable name="r" select="gdata:send-request($auth-request)"/>
         <!-- ...does the response look ok? -->
         <xsl:if test="count($r) ne 2">
            <xsl:sequence select="gdata:error('HTTPCL001')"/>
         </xsl:if>
         <xsl:if test="not($r[2] instance of xs:string)">
            <xsl:sequence select="gdata:error('HTTPCL002', $r[1]/http:body/@content-type)"/>
         </xsl:if>
         <xsl:if test="xs:integer($r[1]/@status) ne 200">
            <xsl:sequence select="gdata:error('HTTPCL003', $r[1]/@status, $r[1]/@message)"/>
         </xsl:if>
         <!-- ...get the auth token within the response -->
         <xsl:sequence select="
             substring-after(
               tokenize($r[2], '&#10;')[starts-with(., 'Auth=')],
               '=')"/>
      </xsl:variable>
      <!-- the service element to return -->
      <gdata:service name="{ $service }">
         <gdata:user escaped="{ encode-for-uri($full-email) }">
            <xsl:value-of select="$full-email"/>
         </gdata:user>
         <gdata:auth-token>
            <xsl:value-of select="$auth-token"/>
         </gdata:auth-token>
      </gdata:service>
   </xsl:function>


   <!-- ...........................................................................................
      Get feeds and entries.
   -->

   <doc:doc>
      <doc:title>Get feeds and entries.</doc:title>
   </doc:doc>

   <doc:function>
      <para>Get an Atom entry from the service, through HTTP.</para>
      <doc:param name="service">
         <para>The service object to send the request to.</para>
      </doc:param>
      <doc:param name="entry-uri">
         <para>The URI identifying the entry.</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gdata:get-entry" as="element(atom:entry)">
      <!-- the service element -->
      <xsl:param name="service"   as="element(gdata:service)"/>
      <!-- the feed URI -->
      <xsl:param name="entry-uri" as="xs:string"/>
      <!-- delegate -->
      <xsl:sequence select="impl:get-stuff($service, $entry-uri, (), ())"/>
   </xsl:function>

   <doc:function>
      <para>Get an Atom entry from the service, through HTTP.</para>
      <doc:param name="service">
         <para>The service object to send the request to.</para>
      </doc:param>
      <doc:param name="entry-uri">
         <para>The URI identifying the entry.</para>
      </doc:param>
      <doc:param name="params">
         <para>The parameters to use to query the service for the entry.</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gdata:get-entry" as="element(atom:entry)">
      <!-- the service element -->
      <xsl:param name="service"   as="element(gdata:service)"/>
      <!-- the feed URI -->
      <xsl:param name="entry-uri" as="xs:string"/>
      <!-- query parameters -->
      <xsl:param name="params"    as="element(gdata:param)*"/>
      <!-- delegate -->
      <xsl:sequence select="impl:get-stuff($service, $entry-uri, $params, ())"/>
   </xsl:function>

   <doc:function>
      <para>Get an Atom entry from the service, through HTTP.</para>
      <doc:param name="service">
         <para>The service object to send the request to.</para>
      </doc:param>
      <doc:param name="entry-uri">
         <para>The URI identifying the entry.</para>
      </doc:param>
      <doc:param name="params">
         <para>The parameters to use to query the service for the entry.</para>
      </doc:param>
      <doc:param name="since">
         <para>Retrieve the entry only if it was modified since the value of this parameter.
            It can be either an <code>xs:date</code> or an <code>xs:dateTime</code>, or an
            <code>xs:string</code> (in that later case, it is interpreted as an ETag.)</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gdata:get-entry" as="element(atom:entry)?">
      <!-- the service element -->
      <xsl:param name="service"   as="element(gdata:service)"/>
      <!-- the feed URI -->
      <xsl:param name="entry-uri" as="xs:string"/>
      <!-- query parameters -->
      <xsl:param name="params"    as="element(gdata:param)*"/>
      <!-- get if modified since date or ETag -->
      <xsl:param name="since"     as="item()"/>
      <!-- delegate -->
      <xsl:sequence select="impl:get-stuff($service, $entry-uri, $params, $since)"/>
   </xsl:function>

   <doc:function>
      <para>TODO: Bla bla...</para>
      <doc:param name="service">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="feed-uri">
         <para>TODO: Bla bla...</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gdata:get-feed" as="element(atom:feed)">
      <!-- the service element -->
      <xsl:param name="service"  as="element(gdata:service)"/>
      <!-- the feed URI -->
      <xsl:param name="feed-uri" as="xs:string"/>
      <!-- delegate -->
      <xsl:sequence select="impl:get-stuff($service, $feed-uri, (), ())"/>
   </xsl:function>

   <doc:function>
      <para>TODO: Bla bla...</para>
      <doc:param name="service">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="feed-uri">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="params">
         <para>TODO: Bla bla...</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gdata:get-feed" as="element(atom:feed)">
      <!-- the service element -->
      <xsl:param name="service"  as="element(gdata:service)"/>
      <!-- the feed URI -->
      <xsl:param name="feed-uri" as="xs:string"/>
      <!-- query parameters -->
      <xsl:param name="params"   as="element(gdata:param)*"/>
      <!-- delegate -->
      <xsl:sequence select="impl:get-stuff($service, $feed-uri, $params, ())"/>
   </xsl:function>

   <doc:function>
      <para>TODO: Bla bla...</para>
      <doc:param name="service">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="feed-uri">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="params">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="since">
         <para>TODO: Bla bla...</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gdata:get-feed" as="element(atom:feed)">
      <!-- the service element -->
      <xsl:param name="service"  as="element(gdata:service)"/>
      <!-- the feed URI -->
      <xsl:param name="feed-uri" as="xs:string"/>
      <!-- query parameters -->
      <xsl:param name="params"    as="element(gdata:param)*"/>
      <!-- get if modified since date or ETag -->
      <xsl:param name="since"     as="item()"/>
      <!-- delegate -->
      <xsl:sequence select="impl:get-stuff($service, $feed-uri, $params, $since)"/>
   </xsl:function>

   <doc:function>
      <para>TODO: Bla bla...</para>
      <doc:param name="service">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="stuff-uri">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="params">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="since">
         <para>TODO: Bla bla...</para>
      </doc:param>
   </doc:function>
   <xsl:function name="impl:get-stuff" as="element()?">
      <!-- the service element -->
      <xsl:param name="service"   as="element(gdata:service)"/>
      <!-- the feed URI -->
      <xsl:param name="stuff-uri" as="xs:string"/>
      <!-- query parameters -->
      <xsl:param name="params"    as="element(gdata:param)*"/>
      <!-- xs:date, xs:dateTime or xs:string (an ETag) -->
      <xsl:param name="since"     as="item()?"/>
      <!-- the URI, including encoded params -->
      <xsl:variable name="uri" as="xs:string" select="
          gdata:encode-params($stuff-uri, $params)"/>
      <!-- the HTTP request element -->
      <xsl:variable name="req" as="element(http:request)">
         <http:request method="get" href="{ $uri }">
            <http:header name="GData-Version" value="2"/>
            <http:header name="Authorization"
                         value="GoogleLogin auth={ $service/gdata:auth-token }"/>
            <xsl:sequence select="impl:make-since-header($since)"/>
         </http:request>
      </xsl:variable>
      <!-- send the request and get the response -->
      <xsl:variable name="resp" select="gdata:send-request($req)"/>
      <!-- does the response look ok? -->
      <xsl:if test="not(count($resp) = (1, 2))">
         <xsl:sequence select="gdata:error('HTTPCL004')"/>
      </xsl:if>
      <xsl:if test="exists($resp[2]) and not($resp[2] instance of document-node())">
         <xsl:sequence select="gdata:error('HTTPCL005', $resp[1]/http:body/@content-type)"/>
      </xsl:if>
      <xsl:if test="xs:integer($resp[1]/@status) ne 200">
         <xsl:sequence select="gdata:error('HTTPCL006', $resp[1]/@status, $resp[1]/@message)"/>
      </xsl:if>
      <xsl:sequence select="$resp[2]/*"/>
   </xsl:function>

   <doc:function>
      <para>TODO: Bla bla...</para>
      <doc:param name="since">
         <para>TODO: Bla bla...</para>
      </doc:param>
   </doc:function>
   <xsl:function name="impl:make-since-header" as="element(http:header)*">
      <!-- xs:date, xs:dateTime or xs:string (an ETag) -->
      <xsl:param name="since" as="item()?"/>
      <xsl:choose>
         <xsl:when test="empty($since)">
            <!-- nothing -->
         </xsl:when>
         <xsl:when test="$since instance of xs:dateTime">
            <http:header name="If-Modified-Since"
                         value="{ impl:format-datetime-rfc1123($since) }"/>
         </xsl:when>
         <xsl:when test="$since instance of xs:date">
            <http:header name="If-Modified-Since"
                         value="{ impl:format-date-rfc1123($since) }"/>
         </xsl:when>
         <xsl:when test="$since instance of xs:string">
            <http:header name="If-None-Match" value="{ $since }"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="gdata:error('HTTPCL008')"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>

   <doc:function>
      <para>TODO: Bla bla...</para>
      <doc:param name="service">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="feed-uri">
         <para>TODO: Bla bla...</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gdata:get-all-feeds" as="element(atom:feed)+">
      <!-- the service element -->
      <xsl:param name="service"  as="element(gdata:service)"/>
      <!-- the feed URI -->
      <xsl:param name="feed-uri" as="xs:string"/>
      <!-- delegate -->
      <xsl:sequence select="gdata:get-all-feeds($service, $feed-uri, ())"/>
   </xsl:function>

   <doc:function>
      <para>TODO: Bla bla...</para>
      <doc:param name="service">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="feed-uri">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="params">
         <para>TODO: Bla bla...</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gdata:get-all-feeds" as="element(atom:feed)+">
      <!-- the service element -->
      <xsl:param name="service"  as="element(gdata:service)"/>
      <!-- the feed URI -->
      <xsl:param name="feed-uri" as="xs:string"/>
      <!-- query parameters -->
      <xsl:param name="params"   as="element(gdata:param)*"/>
      <!-- start index -->
      <xsl:variable name="start" as="xs:integer" select="
          ( $params[@name eq 'start-index']/@value, 1 )[1]"/>
      <!-- max results (TODO: Default to 25, really?) -->
      <xsl:variable name="max"   as="xs:integer" select="
          ( $params[@name eq 'max-results']/@value, 25 )[1]"/>
      <xsl:variable name="new-params" as="element(gdata:param)+">
         <xsl:sequence select="$params[not(@name eq 'start-index')]"/>
         <xsl:if test="empty($params[@name eq 'max-results'])">
            <gdata:param name="max-results" value="{ $max }"/>
         </xsl:if>
      </xsl:variable>
      <xsl:sequence select="
          impl:get-all-feeds($service, $feed-uri, $start, $max, $new-params)"/>
   </xsl:function>

   <doc:function>
      <para>TODO: Bla bla...</para>
      <doc:param name="service">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="feed-uri">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="start">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="max">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="params">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="since">
         <para>TODO: Bla bla...</para>
      </doc:param>
   </doc:function>
   <xsl:function name="impl:get-all-feeds" as="element(atom:feed)+">
      <!-- the service element -->
      <xsl:param name="service"  as="element(gdata:service)"/>
      <!-- the feed URI -->
      <xsl:param name="feed-uri" as="xs:string"/>
      <!-- start index -->
      <xsl:param name="start"    as="xs:integer"/>
      <!-- max results (must be also present with the same value in $params) -->
      <xsl:param name="max"      as="xs:integer"/>
      <!-- query parameters -->
      <xsl:param name="params"   as="element(gdata:param)*"/>
      <!-- start index as a gdata:param (can not be present in $params) -->
      <xsl:variable name="start-param" as="element(gdata:param)">
         <gdata:param name="start-index" value="{ $start }"/>
      </xsl:variable>
      <!-- one feed -->
      <xsl:variable name="this" select="
          gdata:get-feed($service, $feed-uri, ($params, $start-param))"/>
      <!-- index of the last enry in this feed -->
      <xsl:variable name="last" select="
          xs:integer($this/os:startIndex) + count($this/atom:entry) - 1"/>
      <!-- return this feed -->
      <xsl:sequence select="$this"/>
      <!-- recurse (or not) on following feeds -->
      <xsl:if test="$last lt xs:integer($this/os:totalResults)">
         <xsl:sequence select="
             impl:get-all-feeds($service, $feed-uri, $start + $max, $max, $params)"/>
      </xsl:if>
   </xsl:function>


   <!-- ...........................................................................................
      Create new entries.
   -->

   <doc:doc>
      <doc:title>Create new entries.</doc:title>
      <para role="TODO">
         TODO: Create functions to create entries with GData.  But
         first, the GET functions...  Then base on those...
      </para>
   </doc:doc>


   <!-- ...........................................................................................
      Error handling.
   -->

   <doc:doc>
      <doc:title>Error handling.</doc:title>
   </doc:doc>

   <doc:variable>
      <para>Error codes and messages.</para>
   </doc:variable>
   <xsl:variable name="gdata:errors" as="element(e)+">
      <e code="HTTPCL001">Authentication: wrong HTTP response.</e>
      <e code="HTTPCL002">Authentication: return is not text but '<arg pos="1"/>'.</e>
      <e code="HTTPCL003">Authentication: HTTP server returned error '<arg pos="1"/> - <arg pos="2"/>'.</e>
      <e code="HTTPCL004">Get atom element: wrong HTTP response.</e>
      <e code="HTTPCL005">Get atom element: return is not XML but '<arg pos="1"/>'.</e>
      <e code="HTTPCL006">Get atom element: HTTP server returned error '<arg pos="1"/> - <arg pos="2"/>'.</e>
      <e code="HTTPCL007">Not implemented yet.</e>
      <e code="HTTPCL008">gdata:get-entry-since: wrong entry selector type.</e>
   </xsl:variable>

   <doc:function>
      <para>Front-end error function, without argument to the message.</para>
      <doc:param name="code">
         <para>TODO: Bla bla...</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gdata:error">
      <xsl:param name="code" as="xs:string"/>
      <xsl:call-template name="impl:error">
         <xsl:with-param name="code" select="$code"/>
      </xsl:call-template>
   </xsl:function>

   <doc:function>
      <para>Front-end error function, with 1 argument to the message.</para>
      <doc:param name="code">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="arg-1">
         <para>TODO: Bla bla...</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gdata:error">
      <xsl:param name="code" as="xs:string"/>
      <xsl:param name="arg-1" as="xs:string"/>
      <xsl:call-template name="impl:error">
         <xsl:with-param name="code" select="$code"/>
         <xsl:with-param name="args" select="$arg-1"/>
      </xsl:call-template>
   </xsl:function>

   <doc:function>
      <para>Front-end error function, with 2 arguments to the message.</para>
      <doc:param name="code">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="arg-1">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="arg-2">
         <para>TODO: Bla bla...</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gdata:error">
      <xsl:param name="code" as="xs:string"/>
      <xsl:param name="arg-1" as="xs:string"/>
      <xsl:param name="arg-2" as="xs:string"/>
      <xsl:call-template name="impl:error">
         <xsl:with-param name="code" select="$code"/>
         <xsl:with-param name="args" select="$arg-1, $arg-2"/>
      </xsl:call-template>
   </xsl:function>

   <doc:template>
      <para>Shared implementation for all front-end error functions.</para>
      <doc:param name="code">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="args">
         <para>TODO: Bla bla...</para>
      </doc:param>
   </doc:template>
   <xsl:template name="impl:error">
      <xsl:param name="code" as="xs:string"/>
      <xsl:param name="args" as="xs:string*"/>
      <xsl:variable name="err-qname" as="xs:QName" select="
          QName('http://expath.org/ns/http-client#errors', concat('err:', $code))"/>
      <xsl:variable name="err-msg" as="xs:string+">
         <xsl:variable name="e" as="element(e)" select="$gdata:errors[@code eq $code]"/>
         <xsl:apply-templates select="$e" mode="impl:error">
            <xsl:with-param name="args" select="$args" tunnel="yes"/>
         </xsl:apply-templates>
      </xsl:variable>
      <xsl:sequence select="error($err-qname, string-join($err-msg, ''))"/>
   </xsl:template>

   <doc:template>
      <para>Replace formal arguments with their actual values in error messages.</para>
      <doc:param name="args">
         <para>TODO: Bla bla...</para>
      </doc:param>
   </doc:template>
   <xsl:template match="arg" mode="impl:error" as="xs:string">
      <xsl:param name="args" as="xs:string+" tunnel="yes"/>
      <xsl:sequence select="$args[xs:integer(current()/@pos)]"/>
   </xsl:template>


   <!-- ...........................................................................................
      Utilities.
   -->

   <doc:doc>
      <doc:title>Utilities.</doc:title>
   </doc:doc>

   <doc:function>
      <para>TODO: Bla bla...</para>
      <doc:param name="date">
         <para>TODO: Bla bla...</para>
      </doc:param>
   </doc:function>
   <xsl:function name="impl:format-date-rfc1123">
      <xsl:param name="date" as="xs:date"/>
      <xsl:variable name="month-abbrevs" as="xs:string+" select="
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'"/>
      <xsl:value-of select="format-date($date, '[D] ')"/>
      <xsl:value-of select="$month-abbrevs[month-from-date($date)]"/>
      <xsl:value-of select="format-date($date, ' [Y] 00:00:00 ')"/>
      <xsl:value-of select="impl:format-zone(timezone-from-date($date))"/>
   </xsl:function>

   <doc:function>
      <para>TODO: Bla bla...</para>
      <doc:param name="dt">
         <para>TODO: Bla bla...</para>
      </doc:param>
   </doc:function>
   <xsl:function name="impl:format-datetime-rfc1123">
      <xsl:param name="dt" as="xs:dateTime"/>
      <xsl:variable name="month-abbrevs" as="xs:string+" select="
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'"/>
      <xsl:value-of select="format-dateTime($dt, '[D] ')"/>
      <xsl:value-of select="$month-abbrevs[month-from-dateTime($dt)]"/>
      <xsl:value-of select="format-dateTime($dt, ' [Y] [H01]:[m]:[s] ')"/>
      <xsl:value-of select="impl:format-zone(timezone-from-dateTime($dt))"/>
   </xsl:function>

   <doc:function>
      <para>TODO: Bla bla...</para>
      <doc:param name="zone">
         <para>TODO: Bla bla...</para>
      </doc:param>
   </doc:function>
   <xsl:function name="impl:format-zone" as="xs:string">
      <xsl:param name="zone" as="xs:dayTimeDuration?"/>
      <xsl:variable name="hour" select="hours-from-duration($zone)"/>
      <xsl:variable name="min" select="minutes-from-duration($zone)"/>
      <xsl:choose>
         <xsl:when test="empty($zone) or ($hour eq 0 and $min eq 0)">
            <xsl:sequence select="'Z'"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="
                concat(if ( $hour lt 0 ) then '-' else '+',
                       if ( $hour lt 10 and $hour gt -10 ) then '0' else '',
                       string(abs($hour)),
                       if ( $min lt 10 and $min gt -10 ) then '0' else '',
                       string(abs($min)))"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>

</xsl:stylesheet>
