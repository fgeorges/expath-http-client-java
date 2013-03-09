<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ax_="http://www.w3.org/1999/XSL/Transform#Alias"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/"
                xmlns:http="http://schemas.xmlsoap.org/wsdl/http/"
                xmlns:mime="http://schemas.xmlsoap.org/wsdl/mime/"
                xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/"
                xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"
                xmlns:hc="http://expath.org/ns/http-client"
                xmlns:fg="http://www.fgeorges.org/xslt/wsdl"
                exclude-result-prefixes="#all"
                version="2.0">

   <!--
      For a sample: http://www.webservicex.com/stockquote.asmx?op=GetQuote
      
      TODO: Make a first pass to resolve wsdl:include elements...
   -->

   <xsl:output indent="yes"/>

   <xsl:namespace-alias stylesheet-prefix="ax_" result-prefix="xsl"/>

   <xsl:param name="port-name" as="xs:string?"/>
   <xsl:param name="endpoint"  as="xs:string?"/>

   <xsl:variable name="mime-form-encoded" select="'application/x-www-form-urlencoded'"/>
   <xsl:variable name="xsd-uri"           select="'http://www.w3.org/2001/XMLSchema'"/>

   <xsl:variable name="defs" select="/wsdl:definitions"/>
   <xsl:variable name="tns-uri" select="$defs/@targetNamespace"/>
   <xsl:variable name="tns-prefix" as="item()">
      <xsl:variable name="in-wsdl" select="
          in-scope-prefixes($defs)[namespace-uri-for-prefix(., $defs) eq $tns-uri][1]"/>
      <xsl:sequence select="if ( exists($in-wsdl) ) then $in-wsdl else 'tns'"/>
   </xsl:variable>

   <xsl:function name="fg:path" as="xs:string">
      <xsl:param name="node" as="node()"/>
      <xsl:variable name="steps" as="xs:string+">
         <xsl:apply-templates mode="fg:path" select="$node/ancestor-or-self::*"/>
      </xsl:variable>
      <xsl:sequence select="string-join(for $s in $steps return concat('/', $s), '')"/>
   </xsl:function>

   <xsl:template match="*" mode="fg:path" as="xs:string">
      <xsl:variable name="name" as="xs:QName" select="node-name(.)"/>
      <xsl:choose>
         <!-- more than one sibling (besides .) with the same name? -->
         <xsl:when test="exists(../*[node-name(.) eq $name][2])">
            <xsl:sequence select="
                concat(
                    name(.),
                    '[',
                    count(preceding-sibling::*[node-name(.) eq $name]) + 1,
                    ']'
                )"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="name(.)"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template match="wsdl:binding|wsdl:portType" mode="fg:path" as="xs:string">
      <xsl:sequence select="concat(name(.), '[@name eq ''', @name, ''']')"/>
   </xsl:template>

   <xsl:function name="fg:qname" as="xs:QName">
      <xsl:param name="node" as="node()"/>
      <xsl:variable name="name" select="xs:string($node)"/>
      <xsl:choose>
         <xsl:when test="not(contains($name, ':'))">
            <xsl:sequence select="QName($tns-uri, $name)"/>
         </xsl:when>
         <xsl:when test="$node instance of element()">
            <xsl:sequence select="resolve-QName($name, $node)"/>
         </xsl:when>
         <xsl:when test="$node instance of attribute()">
            <xsl:sequence select="resolve-QName($name, $node/..)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="error((), 'TODO: Other node kinds interesting?')"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>

   <xsl:function name="fg:get-named" as="element()?">
      <xsl:param name="elems" as="element()*"/>
      <xsl:param name="name" as="node()"/>
      <xsl:variable name="qname" select="fg:qname($name)"/>
      <xsl:sequence select="$elems[fg:qname(@name) eq $qname]"/>
   </xsl:function>

   <!--
       Create an xsl:value-of instruction to URL-encode parameters.
       
       The parameter $iface-oper is a wsdl:portType/wsdl:operation.
       From there, the function get the corresponding input
       wsdl:message, and use it to construct the xsl:value-of.  The
       instruction will access variables the name of which will be the
       message's parts name (so those variable should have been
       created in the context where the instruction will be put).
   -->
   <xsl:function name="fg:url-encode-input" as="element(xsl:value-of)">
      <xsl:param name="iface-oper" as="element(wsdl:operation)"/>
      <ax_:value-of>
         <xsl:variable name="msg" select="
             $iface-oper/wsdl:input/fg:get-named(/*/wsdl:message, @message)"/>
         <xsl:for-each select="$msg/wsdl:part">
            <ax_:text>
               <xsl:value-of select="@name"/>
            </ax_:text>
            <ax_:text>=</ax_:text>
            <ax_:value-of select="encode-for-uri(${ @name })"/>
            <xsl:if test="position() ne last()">
               <ax_:text>&amp;</ax_:text>
            </xsl:if>
         </xsl:for-each>
      </ax_:value-of>
   </xsl:function>

   <xsl:template match="/">
      <ax_:stylesheet version="2.0">
         <!-- Ensure the EXPath HTTP Client namespace binding to 'hc' (as it
              is used only in content in the generated stylesheet...) -->
         <xsl:namespace name="hc" select="'http://expath.org/ns/http-client'"/>
         <!-- Ensure the SOAP Envelope namespace binding to 'soap-env' (as it
              is used only in content in the generated stylesheet...) -->
         <xsl:namespace name="soap-env" select="'http://schemas.xmlsoap.org/soap/envelope/'"/>
         <!-- Ensure the XML Schema namespace binding to 'xs' (as it is used
              only in content in the generated stylesheet...) -->
         <xsl:namespace name="xs" select="'http://www.w3.org/2001/XMLSchema'"/>
         <!-- Create a namespace binding for the (one of the possibly
              several) prefix bound to TNS on wsdl:definitions, if
              any.  It has a good chance to be used all over the
              WSDL. -->
         <xsl:if test="exists($tns-prefix)">
            <xsl:namespace name="{ $tns-prefix }" select="$tns-uri"/>
         </xsl:if>
         <xsl:text>&#10;&#10;</xsl:text>
         <ax_:import href="http://expath.org/ns/http-client.xsl"/>
         <xsl:text>&#10;&#10;</xsl:text>
         <xsl:apply-templates select="wsdl:definitions/wsdl:service"/>
      </ax_:stylesheet>
   </xsl:template>

   <xsl:template match="wsdl:service">
      <xsl:variable name="port" as="element(wsdl:port)" select="
          if ( $port-name ) then
            wsdl:port[@name eq $port-name]
          else
            (: TODO: By default, use the SOAP port, but make that configurable! :)
            wsdl:port[soap:address]"/>
      <xsl:apply-templates select="fg:get-named(/*/wsdl:binding, $port/@binding)">
         <xsl:with-param name="endpoint" tunnel="yes" select="
             (: *:address works for both soap:address and http:address... :)
             ($endpoint, $port/*:address/@location)[1]"/>
      </xsl:apply-templates>
   </xsl:template>

   <xsl:template match="wsdl:binding">
      <xsl:apply-templates select="wsdl:operation">
         <xsl:with-param name="iface" select="fg:get-named(/*/wsdl:portType, @type)"/>
      </xsl:apply-templates>
   </xsl:template>

   <!--
       TODO: Document the changed I've just made (according the DONE:
       here below).
       
       DONE: Loop instead on the *binding* operation.  A high-priority
       catch-all template rule for binding operation get the portType
       and the corresponding operation, put the overall structure (the
       comment, the function name, etc.) then use next-match... (with
       lower priority, of course, but that match different bindings:
       soap, http-get, http-post...)
   -->
   <xsl:template match="wsdl:binding/wsdl:operation">
      <xsl:param name="iface" as="element(wsdl:portType)"/>
      <!-- The corresponding wsdl:portType/wsdl:operation. -->
      <xsl:variable name="oper" as="element(wsdl:operation)" select="
          fg:get-named($iface/wsdl:operation, @name)"/>
      <!-- The comment before the function. -->
      <xsl:text>   </xsl:text>
      <xsl:comment>
         <xsl:text>&#10;       </xsl:text>
         <xsl:value-of select="$tns-prefix"/>
         <xsl:text>:</xsl:text>
         <xsl:value-of select="@name"/>
         <xsl:text>()&#10;&#10;       (in </xsl:text>
         <xsl:value-of select="$tns-uri"/>
         <xsl:text>)</xsl:text>
         <xsl:if test="$oper/wsdl:documentation">
            <xsl:text>&#10;&#10;       </xsl:text>
            <xsl:value-of select="$oper/wsdl:documentation"/>
         </xsl:if>
         <xsl:if test="wsdl:documentation">
            <xsl:text>&#10;&#10;       </xsl:text>
            <xsl:value-of select="wsdl:documentation"/>
         </xsl:if>
         <xsl:text>&#10;   </xsl:text>
      </xsl:comment>
      <xsl:text>&#10;   </xsl:text>
      <!-- TODO: See if it would be worth adding @as when possible (in
           notification or request-response and solicit-response if no
           fault, see http://www.w3.org/TR/wsdl#A4.1) -->
      <ax_:function name="{ $tns-prefix }:{ @name }">
         <xsl:namespace name="{ $tns-prefix }" select="$tns-uri"/>
         <!-- TODO: Take into account things like wsdl:input/soap:body/@parts... -->
         <xsl:apply-templates select="wsdl:input" mode="decl">
            <xsl:with-param name="iface-oper" select="$oper"/>
         </xsl:apply-templates>
         <ax_:variable name="function" as="element()">
            <xsl:element name="{ $tns-prefix }:{ @name }" namespace="{ $tns-uri }"/>
         </ax_:variable>
         <!-- the body content -->
         <ax_:variable name="body" as="item()*">
            <ax_:apply-templates select="$function" mode="make-body">
               <xsl:apply-templates select="wsdl:input" mode="apply">
                  <xsl:with-param name="iface-oper" select="$oper"/>
               </xsl:apply-templates>
            </ax_:apply-templates>
         </ax_:variable>
         <!-- the request element -->
         <ax_:variable name="request" as="element(hc:request)">
            <ax_:apply-templates select="$function" mode="make-request">
               <ax_:with-param name="body" select="$body"/>
            </ax_:apply-templates>
         </ax_:variable>
         <!-- invoke the operation on the service -->
         <ax_:variable name="response" as="item()+">
            <ax_:apply-templates select="$function" mode="invoke">
               <ax_:with-param name="request" select="$request"/>
               <ax_:with-param name="body"    select="$body"/>
            </ax_:apply-templates>
         </ax_:variable>
         <!-- check the response -->
         <ax_:apply-templates select="$function" mode="check">
            <ax_:with-param name="response" select="$response"/>
         </ax_:apply-templates>
         <!-- extract the return value from the response -->
         <ax_:apply-templates select="$function" mode="return">
            <ax_:with-param name="response" select="$response"/>
         </ax_:apply-templates>
      </ax_:function>
      <xsl:text>&#10;&#10;</xsl:text>
      <!-- TODO: ... -->
      <xsl:apply-templates select="." mode="body">
         <xsl:with-param name="iface-oper" select="$oper"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="request">
         <xsl:with-param name="iface-oper" select="$oper"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="invoke">
         <xsl:with-param name="iface-oper" select="$oper"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="check">
         <xsl:with-param name="iface-oper" select="$oper"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="return">
         <xsl:with-param name="iface-oper" select="$oper"/>
      </xsl:apply-templates>
   </xsl:template>

   <xsl:template match="wsdl:binding[soap:binding]/wsdl:operation" mode="body">
      <xsl:param name="iface-oper" as="element(wsdl:operation)"/>
      <!-- check the transport -->
      <!-- The WSDL 1.1 REC makes @transport optional, but doesn't
           give a default.  We assume the default is HTTP. -->
      <xsl:variable name="trans" select="../soap:binding/@transport"/>
      <xsl:if test="empty($trans)">
         <xsl:message>
            <xsl:text>Warning: transport attribute not there, assume HTTP, on: </xsl:text>
            <xsl:value-of select="../soap:binding/fg:path(.)"/>
         </xsl:message>
      </xsl:if>
      <xsl:if test="$trans ne 'http://schemas.xmlsoap.org/soap/http'">
         <xsl:sequence select="
             error((), concat('Only SOAP HTTP transport supported, got: ', $trans))"/>
      </xsl:if>
      <!-- check the style -->
      <!-- 'document' is the default -->
      <xsl:variable name="style" select="(soap:operation/@style, ../soap:binding/@style)[1]"/>
      <xsl:if test="$style ne 'document'">
         <xsl:sequence select="
             error((), concat('Only SOAP document style supported, got: ', $style))"/>
      </xsl:if>
      <!-- check the use -->
      <xsl:variable name="body" as="element()" select="wsdl:input/soap:body"/>
      <xsl:if test="not($body/@use eq 'literal')">
         <xsl:sequence select="
             error((), concat('Only literal use is supported, got: ', $body/@use,
                              ' on: ', $body/fg:path(.)))"/>
      </xsl:if>
      <!-- create the template rule -->
      <ax_:template match="{ $tns-prefix }:{ @name }" as="element(soap-env:Envelope)"
                    mode="make-body">
         <xsl:namespace name="{ $tns-prefix }" select="$tns-uri"/>
         <!-- the template rule's parameters -->
         <!-- TODO: Take into account things like wsdl:input/soap:body/@parts... -->
         <xsl:apply-templates select="wsdl:input" mode="decl">
            <xsl:with-param name="iface-oper" select="$iface-oper"/>
         </xsl:apply-templates>
         <!-- the SOAP envelope, result of the template rule -->
         <soap-env:Envelope>
            <soap-env:Header/>
            <soap-env:Body>
               <xsl:apply-templates select="$iface-oper/wsdl:input" mode="use"/>
            </soap-env:Body>
         </soap-env:Envelope>
      </ax_:template>
      <xsl:text>&#10;&#10;</xsl:text>
   </xsl:template>

   <xsl:template match="wsdl:binding[http:binding[@verb eq 'GET']]
                          / wsdl:operation[wsdl:input/http:urlEncoded]"
                 mode="body">
      <xsl:param name="iface-oper" as="element(wsdl:operation)"/>
      <!-- create the template rule -->
      <ax_:template match="{ $tns-prefix }:{ @name }" as="xs:string" mode="make-body">
         <xsl:namespace name="{ $tns-prefix }" select="$tns-uri"/>
         <!-- the template rule's parameters -->
         <!-- TODO: Take into account things like wsdl:input/soap:body/@parts... -->
         <xsl:apply-templates select="wsdl:input" mode="decl">
            <xsl:with-param name="iface-oper" select="$iface-oper"/>
         </xsl:apply-templates>
         <xsl:sequence select="fg:url-encode-input($iface-oper)"/>
      </ax_:template>
      <xsl:text>&#10;&#10;</xsl:text>
   </xsl:template>

   <xsl:template match="wsdl:binding[http:binding[@verb eq 'GET']]
                          / wsdl:operation[wsdl:input/http:urlReplacement]"
                 mode="body">
      <xsl:param name="iface-oper" as="element(wsdl:operation)"/>
      <!-- create the template rule -->
      <ax_:template match="{ $tns-prefix }:{ @name }" as="xs:string" mode="make-body">
         <xsl:namespace name="{ $tns-prefix }" select="$tns-uri"/>
         <!-- the template rule's parameters -->
         <!-- TODO: Take into account things like wsdl:input/soap:body/@parts... -->
         <xsl:apply-templates select="wsdl:input" mode="decl">
            <xsl:with-param name="iface-oper" select="$iface-oper"/>
         </xsl:apply-templates>
         <ax_:value-of>
            <xsl:variable name="msg" select="
                $iface-oper/wsdl:input/fg:get-named(/*/wsdl:message, @message)"/>
            <xsl:analyze-string select="http:operation/@location" regex="\(([\i-[:]][\c-[:]]*)\)">
               <xsl:matching-substring>
                  <xsl:variable name="part" select="$msg/wsdl:part[@name eq regex-group(1)]"/>
                  <xsl:if test="empty($part)">
                     <xsl:sequence select="
                         error((), concat('No message part correspond to: ', regex-group(1)))"/>
                  </xsl:if>
                  <ax_:sequence select="encode-for-uri(${ $part/@name })"/>
               </xsl:matching-substring>
               <xsl:non-matching-substring>
                  <ax_:text>
                     <xsl:sequence select="."/>
                  </ax_:text>
               </xsl:non-matching-substring>
            </xsl:analyze-string>
         </ax_:value-of>
      </ax_:template>
      <xsl:text>&#10;&#10;</xsl:text>
   </xsl:template>

   <xsl:template match="wsdl:binding[http:binding[@verb eq 'POST']]
                          / wsdl:operation[wsdl:input/mime:content/@type eq $mime-form-encoded]"
                 mode="body">
      <xsl:param name="iface-oper" as="element(wsdl:operation)"/>
      <!-- create the template rule -->
      <ax_:template match="{ $tns-prefix }:{ @name }" as="xs:string" mode="make-body">
         <xsl:namespace name="{ $tns-prefix }" select="$tns-uri"/>
         <!-- the template rule's parameters -->
         <!-- TODO: Take into account things like wsdl:input/soap:body/@parts... -->
         <xsl:apply-templates select="wsdl:input" mode="decl">
            <xsl:with-param name="iface-oper" select="$iface-oper"/>
         </xsl:apply-templates>
         <xsl:sequence select="fg:url-encode-input($iface-oper)"/>
      </ax_:template>
      <xsl:text>&#10;&#10;</xsl:text>
   </xsl:template>

   <xsl:template match="wsdl:binding/wsdl:operation" priority="0" mode="body">
      <xsl:sequence select="error((), concat('Binding not supported: ', fg:path(.)))"/>
   </xsl:template>

   <xsl:template match="wsdl:binding[soap:binding]/wsdl:operation" mode="request">
      <xsl:param name="iface-oper" as="element(wsdl:operation)"/>
      <xsl:param name="endpoint" as="xs:string" tunnel="yes"/>
      <!-- check the soap action -->
      <xsl:if test="empty(soap:operation/@soapAction)">
         <xsl:sequence select="
             error((), concat('SOAPAction is required for SOAP HTTP binding but is not on: ',
                              (soap:operation, .)[1]/fg:path(.)))"/>
      </xsl:if>
      <!-- create the template rule -->
      <ax_:template match="{ $tns-prefix }:{ @name }" as="element(hc:request)"
                    mode="make-request">
         <!-- the HTTP request, result of the template rule -->
         <hc:request method="post" href="{ $endpoint }">
            <hc:header name="SOAPAction" value="{ soap:operation/@soapAction }"/>
            <hc:body media-type="text/xml; charset=utf-8"/>
         </hc:request>
      </ax_:template>
      <xsl:text>&#10;&#10;</xsl:text>
   </xsl:template>

   <xsl:template match="wsdl:binding[http:binding[@verb eq 'GET']]
                          / wsdl:operation[wsdl:input/http:urlEncoded]"
                 mode="request">
      <xsl:param name="iface-oper" as="element(wsdl:operation)"/>
      <xsl:param name="endpoint" as="xs:string" tunnel="yes"/>
      <!-- create the template rule -->
      <ax_:template match="{ $tns-prefix }:{ @name }" as="element(hc:request)"
                    mode="make-request">
         <ax_:param name="body" as="xs:string"/>
         <!-- the HTTP request, result of the template rule -->
         <hc:request method="get" href="{ $endpoint }{ http:operation/@location }?{{ $body }}"/>
      </ax_:template>
      <xsl:text>&#10;&#10;</xsl:text>
   </xsl:template>

   <xsl:template match="wsdl:binding[http:binding[@verb eq 'GET']]
                          / wsdl:operation[wsdl:input/http:urlReplacement]"
                 mode="request">
      <xsl:param name="iface-oper" as="element(wsdl:operation)"/>
      <xsl:param name="endpoint" as="xs:string" tunnel="yes"/>
      <!-- create the template rule -->
      <ax_:template match="{ $tns-prefix }:{ @name }" as="element(hc:request)"
                    mode="make-request">
         <ax_:param name="body" as="xs:string"/>
         <!-- the HTTP request, result of the template rule -->
         <hc:request method="get" href="{ $endpoint }{{ $body }}"/>
      </ax_:template>
      <xsl:text>&#10;&#10;</xsl:text>
   </xsl:template>

   <xsl:template match="wsdl:binding[http:binding[@verb eq 'POST']]/wsdl:operation" mode="request">
      <xsl:param name="iface-oper" as="element(wsdl:operation)"/>
      <xsl:param name="endpoint" as="xs:string" tunnel="yes"/>
      <!-- create the template rule -->
      <ax_:template match="{ $tns-prefix }:{ @name }" as="element(hc:request)"
                    mode="make-request">
         <ax_:param name="body" as="xs:string"/>
         <!-- the HTTP request, result of the template rule -->
         <hc:request method="post" href="{ $endpoint }{ http:operation/@location }">
            <hc:body media-type="{ $mime-form-encoded }"/>
         </hc:request>
      </ax_:template>
      <xsl:text>&#10;&#10;</xsl:text>
   </xsl:template>

   <xsl:template match="wsdl:binding/wsdl:operation" priority="0" mode="request">
      <xsl:sequence select="error((), concat('Binding not supported: ', fg:path(.)))"/>
   </xsl:template>

   <xsl:template mode="invoke" priority="2" match="
       wsdl:binding[soap:binding|http:binding[@verb eq 'POST']]/wsdl:operation">
      <xsl:param name="iface-oper" as="element(wsdl:operation)"/>
      <!-- create the template rule -->
      <ax_:template match="{ $tns-prefix }:{ @name }" as="item()+" mode="invoke">
         <ax_:param name="request" as="element(hc:request)"/>
         <ax_:param name="body"    as="item()"/>
         <ax_:sequence select="hc:send-request($request, (), $body)"/>
      </ax_:template>
      <xsl:text>&#10;&#10;</xsl:text>
   </xsl:template>

   <xsl:template match="wsdl:binding/wsdl:operation" mode="invoke">
      <xsl:param name="iface-oper" as="element(wsdl:operation)"/>
      <!-- create the template rule -->
      <ax_:template match="{ $tns-prefix }:{ @name }" as="item()+" mode="invoke">
         <ax_:param name="request" as="element(hc:request)"/>
         <ax_:sequence select="hc:send-request($request)"/>
      </ax_:template>
      <xsl:text>&#10;&#10;</xsl:text>
   </xsl:template>

   <xsl:template match="wsdl:binding/wsdl:operation" mode="check">
      <xsl:param name="iface-oper" as="element(wsdl:operation)"/>
      <!-- create the template rule -->
      <ax_:template match="{ $tns-prefix }:{ @name }" mode="check">
         <ax_:param name="response" as="item()+"/>
         <ax_:variable name="code" select="xs:integer($response[1]/@status)"/>
         <!-- TODO: Improve reporting... (include service and
              operation name, function name, etc.) -->
         <ax_:if test="$code ne 200">
            <ax_:sequence>
               <xsl:attribute name="select">
                  <xsl:text>error((), </xsl:text>
                  <xsl:text>$response[1]/concat('HTTP error: ', @code, ' ', hc:message)</xsl:text>
                  <xsl:text>)</xsl:text>
               </xsl:attribute>
            </ax_:sequence>
         </ax_:if>
      </ax_:template>
      <xsl:text>&#10;&#10;</xsl:text>
   </xsl:template>

   <xsl:template match="wsdl:binding[soap:binding]/wsdl:operation" mode="return">
      <xsl:param name="iface-oper" as="element(wsdl:operation)"/>
      <!-- create the template rule -->
      <ax_:template match="{ $tns-prefix }:{ @name }" mode="return">
         <ax_:param name="response" as="item()+"/>
         <!-- TODO: The way to get the result from the envelope depends
              on the type of WSDL.  And what to do in case of fault?  Etc. -->
         <ax_:sequence select="$response[2]/soap-env:Envelope/soap-env:Body/*"/>
      </ax_:template>
      <xsl:text>&#10;&#10;</xsl:text>
   </xsl:template>

   <xsl:template match="wsdl:binding[http:binding]/wsdl:operation[wsdl:output/mime:mimeXml]"
                 mode="return">
      <xsl:param name="iface-oper" as="element(wsdl:operation)"/>
      <!-- create the template rule -->
      <ax_:template match="{ $tns-prefix }:{ @name }" mode="return">
         <ax_:param name="response" as="item()+"/>
         <ax_:variable name="xml" select="$response[2]/*"/>
         <xsl:variable name="msg" select="
             $iface-oper/wsdl:output/fg:get-named(/*/wsdl:message, @message)"/>
         <xsl:variable name="part" as="element(wsdl:part)?" select="
             $msg/wsdl:part[@name eq current()/wsdl:output/mime:mimeXml/@part]"/>
         <xsl:choose>
            <xsl:when test="exists($part/@element)">
               <xsl:variable name="qname" select="fg:qname($part/@element)"/>
               <xsl:variable name="uri"   select="namespace-uri-from-QName($qname)"/>
               <xsl:variable name="local" select="local-name-from-QName($qname)"/>
               <ax_:sequence select="$xml[node-name(.) eq QName('{ $uri }', '{ $local }')]"/>
            </xsl:when>
            <xsl:when test="exists($part/@type)">
               <ax_:sequence select="
                   $xml[node-name(.) eq QName('{ $tns-uri }', '{ $part/@name }')]"/>
            </xsl:when>
            <xsl:when test="exists(wsdl:output/mime:mimeXml/@part)">
               <xsl:sequence select="
                   error((), concat('No part correponding to: ', wsdl:output/mime:mimeXml/@part,
                                    ' in ', wsdl:output/fg:path(.)))"/>
            </xsl:when>
            <xsl:otherwise>
               <ax_:sequence select="$xml"/>
            </xsl:otherwise>
         </xsl:choose>
      </ax_:template>
      <xsl:text>&#10;&#10;</xsl:text>
   </xsl:template>

   <xsl:template match="wsdl:binding/wsdl:operation" priority="0" mode="return">
      <xsl:sequence select="error((), concat('Binding not supported: ', fg:path(.)))"/>
   </xsl:template>

   <xsl:template match="wsdl:portType">
      <xsl:apply-templates select="wsdl:operation"/>
   </xsl:template>

   <xsl:template match="wsdl:binding/wsdl:operation/wsdl:input" mode="decl">
      <xsl:param name="iface-oper" as="element(wsdl:operation)?"/>
      <xsl:variable name="op" as="element(wsdl:operation)" select="
          if ( exists($iface-oper) ) then
            $iface-oper
          else
            fg:get-named(
                fg:get-named(/*/wsdl:portType, ../../@name)/wsdl:operation,
                ../@name
              )"/>
      <xsl:apply-templates mode="decl" select="$op/exactly-one(wsdl:input)"/>
   </xsl:template>

   <xsl:template match="wsdl:portType/wsdl:operation/wsdl:input" mode="decl">
      <xsl:apply-templates mode="decl" select="
          fg:get-named(/*/wsdl:message, @message)"/>
   </xsl:template>

   <xsl:template match="wsdl:message" mode="decl">
      <xsl:apply-templates mode="decl" select="wsdl:part"/>
   </xsl:template>

   <xsl:template match="wsdl:part[@element]" mode="decl">
      <ax_:param name="{ @name }" as="element({ @element })">
         <xsl:variable name="qname"  select="resolve-QName(@element, .)"/>
         <xsl:variable name="prefix" select="prefix-from-QName($qname)"/>
         <xsl:variable name="uri"    select="namespace-uri-from-QName($qname)"/>
         <xsl:if test="exists($prefix) and string($uri)">
            <xsl:namespace name="{ $prefix }" select="$uri"/>
         </xsl:if>
      </ax_:param>
   </xsl:template>

   <!-- Ok for HTTP params, with standard simple types... -->
   <xsl:template match="wsdl:part[@type]" mode="decl">
      <ax_:param name="{ @name }">
         <!-- Is it an XSDL simple type? (if not, requires an SA processor) -->
         <xsl:if test="namespace-uri-from-QName(resolve-QName(@type, .)) eq $xsd-uri">
            <!-- TODO: Make sure the prefix of the QName in @type is
                 bound to the correct URI. -->
            <xsl:attribute name="as" select="@type"/>
         </xsl:if>
         <xsl:variable name="qname"  select="resolve-QName(@type, .)"/>
         <xsl:variable name="prefix" select="prefix-from-QName($qname)"/>
         <xsl:variable name="uri"    select="namespace-uri-from-QName($qname)"/>
         <xsl:if test="exists($prefix) and string($uri)">
            <xsl:namespace name="{ $prefix }" select="$uri"/>
         </xsl:if>
      </ax_:param>
   </xsl:template>

   <xsl:template match="node()" mode="decl" priority="-1">
      <xsl:message terminate="yes">
         <xsl:text>Not supported in DECL: </xsl:text>
         <xsl:value-of select="fg:path(.)"/>
      </xsl:message>
   </xsl:template>

   <xsl:template match="wsdl:binding/wsdl:operation/wsdl:input" as="element(xsl:with-param)+"
                 mode="apply">
      <xsl:param name="iface-oper" as="element(wsdl:operation)?"/>
      <xsl:variable name="op" as="element(wsdl:operation)" select="
          if ( exists($iface-oper) ) then
            $iface-oper
          else
            fg:get-named(
                fg:get-named(/*/wsdl:portType, ../../@name)/wsdl:operation,
                ../@name
              )"/>
      <xsl:apply-templates mode="apply" select="$op/exactly-one(wsdl:input)"/>
   </xsl:template>

   <xsl:template match="wsdl:portType/wsdl:operation/wsdl:input" as="element(xsl:with-param)+"
                 mode="apply">
      <xsl:apply-templates mode="apply" select="
          fg:get-named(/*/wsdl:message, @message)"/>
   </xsl:template>

   <xsl:template match="wsdl:message" as="element(xsl:with-param)+" mode="apply">
      <xsl:apply-templates mode="apply" select="wsdl:part"/>
   </xsl:template>

   <xsl:template match="wsdl:part" as="element(xsl:with-param)" mode="apply">
      <ax_:with-param name="{ @name }" select="${ @name }"/>
   </xsl:template>

   <xsl:template match="node()" mode="apply" priority="-1">
      <xsl:message terminate="yes">
         <xsl:text>Not supported in APPLY: </xsl:text>
         <xsl:value-of select="fg:path(.)"/>
      </xsl:message>
   </xsl:template>

   <xsl:template match="wsdl:input" mode="use">
      <xsl:apply-templates mode="use" select="
          fg:get-named(/*/wsdl:message, @message)"/>
   </xsl:template>

   <xsl:template match="wsdl:message" mode="use">
      <xsl:apply-templates mode="use" select="wsdl:part"/>
   </xsl:template>

   <!-- TODO: Should be the same for part w/o @element.  Check... -->
   <xsl:template match="wsdl:part[@element]" mode="use">
      <ax_:sequence select="${ @name }"/>
   </xsl:template>

   <!-- FIXME: To check! -->
   <xsl:template match="wsdl:part[@type]" mode="use">
      <ax_:sequence select="${ @name }"/>
   </xsl:template>

   <xsl:template match="node()" mode="use" priority="-1">
      <xsl:message terminate="yes">
         <xsl:text>Not supported in USE: </xsl:text>
         <xsl:value-of select="fg:path(.)"/>
      </xsl:message>
   </xsl:template>

</xsl:stylesheet>
