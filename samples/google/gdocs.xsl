<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:doc="http://www.CraneSoftwrights.com/ns/xslstyle"
                xmlns:gdoc="http://www.fgeorges.org/xslt/google/docs"
                xmlns:gdata="http://www.fgeorges.org/xslt/google/data"
                xmlns:atom="http://www.w3.org/2005/Atom"
                xmlns:os="http://a9.com/-/spec/opensearch/1.1/"
                xmlns:http="http://expath.org/ns/http-client"
                xmlns:impl="urn:X-FGeorges:xslt:google:gdocs:impl"
                xmlns:gd="http://schemas.google.com/g/2005"
                exclude-result-prefixes="#all"
                version="2.0">

   <xsl:import href="gdata.xsl"/>

   <doc:doc filename="gdocs.xsl" internal-ns="impl" global-ns="gdoc" vocabulary="DocBook"
            info="$Id$">
      <doc:title>XSLT module to access Google Documents API.</doc:title>
      <para>
         See Google Documents API documentation at
         <ulink url="http://code.google.com/apis/documents/"/>.
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

   <doc:variable>
      <para>MIME type for Open Document Text files.</para>
   </doc:variable>
   <xsl:variable name="gdoc:odt-mime-type" select="'application/vnd.oasis.opendocument.text'"/>

   <doc:doc>
      <doc:title>Global parameters and variables.</doc:title>
   </doc:doc>

   <doc:variable>
      <para>The name of the Google Documents service.</para>
   </doc:variable>
   <xsl:variable name="impl:docs-service-name" as="xs:string" select="'writely'"/>

   <doc:variable>
      <para>The URI of the feed for all documents of the service's logged in user.</para>
   </doc:variable>
   <xsl:variable name="impl:private-docs-feed" as="xs:string" select="
       'https://docs.google.com/feeds/documents/private/full'"/>


   <!-- ...........................................................................................
      The document service, and various accessors.
      
      - gdoc:make-doc-service($user, $pwd)
      - gdoc:get-folders($service)
      - gdoc:get-folders($service, $params)
      - gdoc:upload-file($service, $href, $content-type, $folder)
      - gdoc:folder-uri($folder)
   -->

   <doc:doc>
      <doc:title>The document service, and various accessors.</doc:title>
   </doc:doc>

   <doc:function>
      <para>Make a new GData service element, for the document service.</para>
      <doc:param name="user">
         <para>The user name to use to authenticate to the service.</para>
      </doc:param>
      <doc:param name="pwd">
         <para>The password to use to authenticate to the service.</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gdoc:make-doc-service" as="element(gdata:service)">
      <xsl:param name="user" as="xs:string"/>
      <xsl:param name="pwd"  as="xs:string"/>
      <xsl:sequence select="gdata:make-service($impl:docs-service-name, $user, $pwd)"/>
   </xsl:function>

   <doc:function>
      <para>Get the list of all folders.</para>
      <doc:param name="service">
         <para>The document service.</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gdoc:get-folders" as="element(atom:feed)*">
      <!-- the service element -->
      <xsl:param name="service" as="element(gdata:service)"/>
      <xsl:sequence select="gdoc:get-folders($service, ())"/>
   </xsl:function>

   <doc:function>
      <para>Get the list of all folders.</para>
      <doc:param name="service">
         <para>The document service.</para>
      </doc:param>
      <doc:param name="params">
         <para>The parameters to use in the query.</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gdoc:get-folders" as="element(atom:feed)*">
      <!-- the service element -->
      <xsl:param name="service" as="element(gdata:service)"/>
      <!-- query parameters -->
      <xsl:param name="params"  as="element(gdata:param)*"/>
      <xsl:variable name="all-params" as="element(gdata:param)+">
         <gdata:param name="category"    value="folder"/>
         <gdata:param name="showfolders" value="true"/>
         <xsl:sequence select="$params"/>
      </xsl:variable>
      <xsl:sequence select="
          gdata:get-all-feeds($service, $impl:private-docs-feed, $all-params)"/>
   </xsl:function>

   <xsl:function name="gdoc:upload-file" as="element(atom:entry)">
      <xsl:param name="service"      as="element(gdata:service)"/>
      <xsl:param name="href"         as="xs:string"/>
      <xsl:param name="content-type" as="xs:string"/>
      <xsl:sequence select="gdoc:upload-file($service, $href, $content-type, ())"/>
   </xsl:function>

   <xsl:function name="gdoc:upload-file" as="element(atom:entry)">
      <xsl:param name="service"      as="element(gdata:service)"/>
      <xsl:param name="href"         as="xs:string"/>
      <xsl:param name="content-type" as="xs:string"/>
      <xsl:param name="title"        as="xs:string?"/>
      <xsl:sequence select="gdoc:upload-file($service, $href, $content-type, $title, ())"/>
   </xsl:function>

   <doc:function>
      <para>Upload a file to the service.</para>
      <doc:param name="service">
         <para>The document service.</para>
      </doc:param>
      <doc:param name="href">
         <para>The URI of the file to upload.</para>
      </doc:param>
      <doc:param name="content-type">
         <para>The MIME media type of the file to upload.</para>
      </doc:param>
      <doc:param name="folder">
         <para>The folder to upload the file to (the folder ID.)  Can
           be the empty sequence to not upload to any particular
           folder.</para>
         <para role="TODO">TODO: We should be able to use either an ID
           or an entry, for the folder!</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gdoc:upload-file" as="element(atom:entry)">
      <xsl:param name="service"      as="element(gdata:service)"/>
      <xsl:param name="href"         as="xs:string"/>
      <xsl:param name="content-type" as="xs:string"/>
      <xsl:param name="title"        as="xs:string?"/>
      <xsl:param name="folder"       as="xs:string?"/>
      <xsl:variable name="uri" as="xs:string" select="
          if ( exists($folder) ) then
            impl:folder-uri($folder)
          else
            $impl:private-docs-feed"/>
      <!-- the HTTP request element -->
      <xsl:variable name="req" as="element(http:request)">
         <http:request method="post" href="{ $uri }">
            <http:header name="GData-Version" value="2"/>
            <http:header name="Authorization"
                         value="GoogleLogin auth={ $service/gdata:auth-token }"/>
            <xsl:variable name="body" as="element()+">
               <http:header name="Slug" value="{ impl:basename($href) }"/>
               <http:body content-type="{ $content-type }" href="{ $href }"/>
            </xsl:variable>
            <xsl:choose>
               <xsl:when test="exists($title)">
                  <http:multipart boundary="-=-=-= i Am ThE bOuNdArY =-=-=-"
                                  content-type="multipart/related">
                     <http:body content-type="application/atom+xml">
                        <atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
                           <atom:category scheme="http://schemas.google.com/g/2005#kind"
                                          term="http://schemas.google.com/docs/2007#document"
                                          label="document"/>
                           <atom:title>
                              <xsl:value-of select="$title"/>
                           </atom:title>
                        </atom:entry>
                     </http:body>
                     <xsl:copy-of select="$body"/>
                  </http:multipart>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:copy-of select="$body"/>
               </xsl:otherwise>
            </xsl:choose>
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
      <xsl:if test="xs:integer($resp[1]/@status) ne 201">
         <xsl:sequence select="gdata:error('HTTPCL006', $resp[1]/@status, $resp[1]/@message)"/>
      </xsl:if>
      <xsl:sequence select="$resp[2]/*"/>
   </xsl:function>

   <doc:function>
      <para>Return the folder ID from a folder entry.</para>
      <doc:param name="folder">
         <para>The folder's Atom entry.</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gdoc:folder-id" as="xs:string">
      <xsl:param name="folder" as="element(atom:entry)"/>
      <xsl:sequence select="impl:stuff-id($folder, 'folder')"/>
   </xsl:function>

   <doc:function>
      <para>Return the document ID from a document entry.</para>
      <doc:param name="doc">
         <para>The document's Atom entry.</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gdoc:document-id" as="xs:string">
      <xsl:param name="doc" as="element(atom:entry)"/>
      <xsl:sequence select="impl:stuff-id($doc, 'document')"/>
   </xsl:function>

   <doc:function>
      <para>Return the spreadsheet ID from a spreadsheet entry.</para>
      <doc:param name="sheet">
         <para>The spreadsheet's Atom entry.</para>
      </doc:param>
   </doc:function>
   <xsl:function name="gdoc:spreadsheet-id" as="xs:string">
      <xsl:param name="sheet" as="element(atom:entry)"/>
      <xsl:sequence select="impl:stuff-id($sheet, 'spreadsheet')"/>
   </xsl:function>

   <doc:function>
      <para>Return the ID from a entry.</para>
      <doc:param name="stuff">
         <para>The Atom entry.</para>
      </doc:param>
   </doc:function>
   <xsl:function name="impl:stuff-id" as="xs:string">
      <xsl:param name="stuff" as="element(atom:entry)"/>
      <xsl:param name="kind"  as="xs:string"/>
      <!-- '%3A' is ':', URI encoded -->
      <xsl:variable name="prefix" select="concat($kind, '%3A')"/>
      <xsl:variable name="id" select="impl:basename($stuff/atom:id)"/>
      <xsl:if test="not(starts-with($id, $prefix))">
         <xsl:sequence select="error((), 'ERROR, TODO: use impl:error() instead!')"/>
      </xsl:if>
      <xsl:sequence select="substring($id, string-length($prefix) + 1)"/>
   </xsl:function>


   <!-- ...........................................................................................
      Utilities.
      
      - impl:basename($href)
      - impl:folder-uri($name)
   -->

   <doc:doc>
      <doc:title>Some utility functions.</doc:title>
   </doc:doc>

   <doc:function>
      <para>Return the basename of an href (the last step, after the
         last '/' if any.)</para>
      <doc:param name="href">
         <para>The href.</para>
      </doc:param>
   </doc:function>
   <xsl:function name="impl:basename" as="xs:string">
      <xsl:param name="href" as="xs:string"/>
      <xsl:variable name="steps" select="tokenize($href, '/')"/>
      <xsl:sequence select="
          if ( exists($steps) ) then
            $steps[last()]
          else
            $href"/>
   </xsl:function>

   <doc:function>
      <para>Return the folder URI given its ID.</para>
      <doc:param name="id">
         <para>The folder id.</para>
      </doc:param>
   </doc:function>
   <xsl:function name="impl:folder-uri" as="xs:string">
      <xsl:param name="id" as="xs:string"/>
      <xsl:variable name="base-uri" select="
          'https://docs.google.com/feeds/folders/private/full/folder%3A'"/>
      <xsl:sequence select="concat($base-uri, encode-for-uri($id))"/>
   </xsl:function>

</xsl:stylesheet>
