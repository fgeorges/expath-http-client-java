<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:doc="http://www.CraneSoftwrights.com/ns/xslstyle"
                xmlns:gc="http://www.fgeorges.org/xslt/google/contacts"
                xmlns:gdata="http://www.fgeorges.org/xslt/google/data"
                xmlns:atom="http://www.w3.org/2005/Atom"
                xmlns:os="http://a9.com/-/spec/opensearch/1.1/"
                xmlns:http="http://expath.org/ns/http-client"
                xmlns:impl="urn:X-FGeorges:xslt:google:gcontacts:impl"
                xmlns:gd="http://schemas.google.com/g/2005"
                xmlns:gContact="http://schemas.google.com/contact/2008"
                exclude-result-prefixes="#all"
                version="2.0">

   <xsl:import href="gdata.xsl"/>

   <doc:doc filename="gcontacts.xsl" internal-ns="impl" global-ns="gc" vocabulary="DocBook"
            info="$Id$">
      <doc:title>XSLT module to access Google Contacts API.</doc:title>
      <para>
         See Google Contacts API documentation at
         <ulink url="http://code.google.com/apis/contacts/"/>.
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
      <para>TODO: bla bla...</para>
   </doc:variable>
   <xsl:variable name="impl:contact-service-name" as="xs:string" select="'cp'"/>


   <!-- ...........................................................................................
      The contact service, and the feeds URIs.
      
      - gc:make-contact-service($user, $pwd)
      - gc:contact-feed-uri($service)
      - gc:contact-feed-uri($service, $user, $proj)
      - gc:group-feed-uri($service)
      - gc:group-feed-uri($service, $user, $proj)
      - impl:feed-uri($service, $user, $proj, $kind)
   -->

   <doc:doc>
      <doc:title>The contact service, and the feeds URIs.</doc:title>
   </doc:doc>

   <doc:function>
      <para>Make a new GData service element, for the contacts service.</para>
      <doc:param name="user">
         <para>The user name to use to authenticate to the service.</para>
      </doc:param>
      <doc:param name="pwd">
         <para>The password to use to authenticate to the service.</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gc:make-contact-service" as="element(gdata:service)">
      <xsl:param name="user" as="xs:string"/>
      <xsl:param name="pwd"  as="xs:string"/>
      <xsl:sequence select="gdata:make-service($impl:contact-service-name, $user, $pwd)"/>
   </xsl:function>

   <doc:function>
      <para>TODO: Bla bla...</para>
      <doc:param name="service">
         <para>TODO: Bla bla...</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gc:contact-feed-uri" as="xs:string">
      <!-- the service element -->
      <xsl:param name="service" as="element(gdata:service)"/>
      <xsl:sequence select="gc:contact-feed-uri($service, (), ())"/>
   </xsl:function>

   <doc:function>
      <para>TODO: Bla bla...</para>
      <doc:param name="service">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="user">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="proj">
         <para>TODO: Bla bla...</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gc:contact-feed-uri" as="xs:string">
      <!-- the service element -->
      <xsl:param name="service" as="element(gdata:service)"/>
      <!-- the user to use -->
      <xsl:param name="user"    as="xs:string?"/>
      <!-- the projection to use -->
      <xsl:param name="proj"    as="xs:string?"/>
      <xsl:sequence select="
          impl:feed-uri($service, $user, $proj, 'contacts')"/>
   </xsl:function>

   <doc:function>
      <para>TODO: Bla bla...</para>
      <doc:param name="service">
         <para>TODO: Bla bla...</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gc:group-feed-uri" as="xs:string">
      <!-- the service element -->
      <xsl:param name="service" as="element(gdata:service)"/>
      <xsl:sequence select="gc:group-feed-uri($service, (), ())"/>
   </xsl:function>

   <doc:function>
      <para>TODO: Bla bla...</para>
      <doc:param name="service">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="user">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="proj">
         <para>TODO: Bla bla...</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gc:group-feed-uri" as="xs:string">
      <!-- the service element -->
      <xsl:param name="service" as="element(gdata:service)"/>
      <!-- the user to use -->
      <xsl:param name="user"    as="xs:string?"/>
      <!-- the projection to use -->
      <xsl:param name="proj"    as="xs:string?"/>
      <xsl:sequence select="
          impl:feed-uri($service, $user, $proj, 'groups')"/>
   </xsl:function>

   <doc:function>
      <para>TODO: Bla bla...</para>
      <doc:param name="service">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="user">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="proj">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="kind">
         <para>TODO: Bla bla...</para>
      </doc:param>
   </doc:function>
   <xsl:function name="impl:feed-uri" as="xs:string">
      <!-- the service element -->
      <xsl:param name="service" as="element(gdata:service)"/>
      <!-- the user to use -->
      <xsl:param name="user"    as="xs:string?"/>
      <!-- the projection to use -->
      <xsl:param name="proj"    as="xs:string?"/>
      <!-- the kind of feed (contacts or groups) -->
      <xsl:param name="kind"    as="xs:string?"/>
      <xsl:sequence select="
          concat('http://www.google.com/m8/feeds/',
                 $kind,
                 '/',
                 ( $user, $service/gdata:user/@escaped )[1],
                 '/',
                 ( $proj, 'full' )[1])"/>
   </xsl:function>


   <!-- ...........................................................................................
      Various accessors.
      
      - gc:get-contacts($service)
      - gc:get-contacts($service, $feed-uri)
      - gc:get-contacts($service, $feed-uri, $params)
      - gc:get-groups($service)
      - gc:get-groups($service, $feed-uri)
      - gc:get-groups($service, $feed-uri, $params)
      - gc:get-contact-groups($service, $contact)
      - gc:contact-groups($contact, $groups)
      - gc:get-contact-photo($service, $contact)
      - gc:contact-by-name($contacts)
      - gc:group-by-name($groups)
   -->

   <doc:doc>
      <doc:title>Various accessors.</doc:title>
   </doc:doc>

   <doc:function>
      <para>TODO: Bla bla...</para>
      <doc:param name="service">
         <para>TODO: Bla bla...</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gc:get-contacts" as="element(atom:feed)*">
      <!-- the service element -->
      <xsl:param name="service"  as="element(gdata:service)"/>
      <!-- delegate -->
      <xsl:sequence select="gc:get-contacts($service, (), ())"/>
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
   <xsl:function name="gc:get-contacts" as="element(atom:feed)*">
      <!-- the service element -->
      <xsl:param name="service"  as="element(gdata:service)"/>
      <!-- the contact feed URI -->
      <xsl:param name="feed-uri" as="xs:string"/>
      <!-- delegate -->
      <xsl:sequence select="gc:get-contacts($service, $feed-uri, ())"/>
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
   <xsl:function name="gc:get-contacts" as="element(atom:feed)*">
      <!-- the service element -->
      <xsl:param name="service"  as="element(gdata:service)"/>
      <!-- the contact feed URI -->
      <xsl:param name="feed-uri" as="xs:string?"/>
      <!-- query parameters -->
      <xsl:param name="params"   as="element(gdata:param)*"/>
      <!-- the URI to use, defaulted if necessary to the default
           contact feed for the user logged in on the service -->
      <xsl:variable name="uri" as="xs:string" select="
          ( $feed-uri, gc:contact-feed-uri($service) )[1]"/>
      <xsl:sequence select="gdata:get-all-feeds($service, $uri, $params)"/>
   </xsl:function>

   <doc:function>
      <para>TODO: Bla bla...</para>
      <doc:param name="service">
         <para>TODO: Bla bla...</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gc:get-groups" as="element(atom:feed)*">
      <!-- the service element -->
      <xsl:param name="service" as="element(gdata:service)"/>
      <!-- delegate -->
      <xsl:sequence select="gc:get-groups($service, (), ())"/>
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
   <xsl:function name="gc:get-groups" as="element(atom:feed)*">
      <!-- the service element -->
      <xsl:param name="service"  as="element(gdata:service)"/>
      <!-- the group feed URI -->
      <xsl:param name="feed-uri" as="xs:string"/>
      <!-- delegate -->
      <xsl:sequence select="gc:get-groups($service, $feed-uri, ())"/>
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
   <xsl:function name="gc:get-groups" as="element(atom:feed)*">
      <!-- the service element -->
      <xsl:param name="service"  as="element(gdata:service)"/>
      <!-- the group feed URI -->
      <xsl:param name="feed-uri" as="xs:string?"/>
      <!-- query parameters -->
      <xsl:param name="params"   as="element(gdata:param)*"/>
      <!-- the URI to use, defaulted if necessary to the default
           group feed for the user logged in on the service -->
      <xsl:variable name="uri" as="xs:string" select="
          ( $feed-uri, gc:group-feed-uri($service) )[1]"/>
      <xsl:sequence select="gdata:get-all-feeds($service, $uri, $params)"/>
   </xsl:function>

   <doc:function>
      <para>TODO: Bla bla...</para>
      <doc:param name="service">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="contact">
         <para>TODO: Bla bla...</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gc:get-contact-groups" as="element(atom:entry)*">
      <!-- the service element -->
      <xsl:param name="service" as="element(gdata:service)"/>
      <!-- the contact entry -->
      <xsl:param name="contact" as="element(atom:entry)"/>
      <!-- the contact's groups -->
      <xsl:variable name="groups" select="
          $contact/gContact:groupMembershipInfo[not(@deleted/xs:boolean(.))]"/>
      <!-- retrieve the groups -->
      <xsl:sequence select="$groups/gdata:get-entry($service, @href)"/>
   </xsl:function>

   <doc:function>
      <para>TODO: Bla bla...</para>
      <doc:param name="contact">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="groups">
         <para>TODO: Bla bla...</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gc:contact-groups" as="element(atom:entry)*">
      <!-- the contact entry -->
      <xsl:param name="contact" as="element(atom:entry)"/>
      <!-- the group entries -->
      <xsl:param name="groups" as="element(atom:entry)+"/>
      <!-- the contact's group IDs -->
      <xsl:variable name="group-ids" select="
          $contact/gContact:groupMembershipInfo[not(@deleted/xs:boolean(.))]/@href"/>
      <!-- select the groups from $groups -->
      <xsl:sequence select="$groups[atom:id[. = $group-ids]]"/>
   </xsl:function>

   <doc:function>
      <para>TODO: Bla bla...</para>
      <para role="TODO">
         TODO: Factorize such a request sending in <filename>gdata.xsl</filename>
         (more than <function>gdata:send-request($request)</function> [set auth...]
         but less than <function>gdata:get-entry($service, $entry-uri)</function>
         [no check of result type...]) !
      </para>
      <doc:param name="service">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="contact">
         <para>TODO: Bla bla...</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gc:get-contact-photo" as="xs:base64Binary?">
      <!-- the service element -->
      <xsl:param name="service" as="element(gdata:service)"/>
      <!-- the contact entry -->
      <xsl:param name="contact" as="element(atom:entry)"/>
      <!-- the @rel value for photos -->
      <xsl:variable name="rel-uri" select="
          'http://schemas.google.com/contacts/2008/rel#photo'"/>
      <!-- the photo's link (@gd:etag is there iff the user has a photo) -->
      <xsl:variable name="link" select="
          $contact/atom:link[@rel eq $rel-uri][exists(@gd:etag)]"/>
      <xsl:if test="exists($link)">
         <!-- the HTTP request -->
         <xsl:variable name="request" as="element(http:request)">
            <http:request method="get" href="{ $link/@href }">
               <http:header name="GData-Version" value="2"/>
               <http:header name="Authorization"
                            value="GoogleLogin auth={ $service/gdata:auth-token }"/>
            </http:request>
         </xsl:variable>
         <!-- retrieve the photo -->
         <xsl:variable name="response" select="gdata:send-request($request)"/>
         <!-- FIXME: Check response! (better than that, and throw error...) -->
         <xsl:if test="$response[1]/xs:integer(@status) eq 200">
            <xsl:sequence select="$response[2]"/>
         </xsl:if>
      </xsl:if>
   </xsl:function>

   <doc:function>
      <para>TODO: Bla bla...</para>
      <doc:param name="contacts">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="name">
         <para>TODO: Bla bla...</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gc:contact-by-name">
      <!-- the contact entries -->
      <xsl:param name="contacts" as="element(atom:entry)*"/>
      <!-- the name of the contact -->
      <xsl:param name="name"   as="xs:string"/>
      <xsl:sequence select="$contacts[atom:title eq $name]"/>
   </xsl:function>

   <doc:function>
      <para>TODO: Bla bla...</para>
      <doc:param name="groups">
         <para>TODO: Bla bla...</para>
      </doc:param>
      <doc:param name="name">
         <para>TODO: Bla bla...</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gc:group-by-name">
      <!-- the group entries -->
      <xsl:param name="groups" as="element(atom:entry)*"/>
      <!-- the name of the group -->
      <xsl:param name="name"   as="xs:string"/>
      <xsl:sequence select="$groups[atom:title eq $name]"/>
   </xsl:function>

</xsl:stylesheet>
