<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:http="http://expath.org/ns/http-client"
                xmlns:my="my"
                exclude-result-prefixes="#all"
                version="2.0">

   <xsl:output indent="yes"/>

   <xsl:variable name="href-base" as="xs:string" select="
       (: 'http://192.168.88.128:8080/' :)
       'http://www.fgeorges.org/tmp/'"/>

   <xsl:variable name="href-files" as="xs:string+" select="
       'exslt2-http-client-test.txt',
       'exslt2-http-client-test.xml',
       'exslt2-http-client-test.jpg'"/>

   <xsl:function name="my:send-request">
      <xsl:param name="request" as="element(http:request)"/>
      <xsl:sequence select="my:send-request($request, ())"/>
   </xsl:function>

   <xsl:function name="my:send-request">
      <xsl:param name="request" as="element(http:request)"/>
      <xsl:param name="uri"     as="xs:string?"/>
      <xsl:variable name="response" select="http-client:send-request($request, $uri)"
                    xmlns:http-client="java:org.expath.saxon.HttpClient"/>
      <!--xsl:message>
         RESP COUNT: <xsl:value-of select="count($response)"/>
         RESPONSE: <xsl:value-of select="$response"/>
      </xsl:message-->
      <xsl:sequence select="$response"/>
   </xsl:function>

   <xsl:template name="main" match="/">
      <result>
         <!--xsl:for-each select="$href-files">
            <xsl:variable name="request" as="element(http:request)">
               <http:request href="{ concat($href-base, .) }" method="get">
                  <http:header name="Cache-Control" value="no-cache"/>
               </http:request>
            </xsl:variable>
            <file name="{ . }">
               <xsl:copy-of select="my:send-request($request)"/>
            </file>
         </xsl:for-each-->
         <!--https>
            <xsl:variable name="request" as="element(http:request)">
               <http:request href="https://www.fgeorges.org/" method="get"/>
            </xsl:variable>
            <xsl:copy-of select="my:send-request($request)"/>
         </https-->
         <!--htaccess>
            <xsl:variable name="request" as="element(http:request)">
               <http:request href="http://www.fgeorges.org/tmp/xproc-fixed-alternative.mpr-"
                             method="get">
                  <http:header name="Cache-Control" value="no-cache"/>
               </http:request>
            </xsl:variable>
            <xsl:copy-of select="my:send-request($request)"/>
         </htaccess>
         <basic>
            <xsl:message select="'Basic 1...'"/>
            <xsl:variable name="request" as="element(http:request)">
               <http:request href="http://www.fgeorges.org/tmp/line-ok.pdf" method="get"
                             username="yo" password="yo" auth-method="basic">
                  <http:header name="Cache-Control" value="no-cache"/>
               </http:request>
            </xsl:variable>
            <xsl:sequence select="my:send-request($request)"/>
         </basic>
         <digest>
            <xsl:message select="'Digest 1...'"/>
            <xsl:variable name="request" as="element(http:request)">
               <http:request href="http://www.fgeorges.org/tmp/line-truncated.pdf" method="get"
                             username="yo" password="yo" auth-method="digest">
                  <http:header name="Cache-Control" value="no-cache"/>
               </http:request>
            </xsl:variable>
            <xsl:sequence select="my:send-request($request)"/>
         </digest-->
         <xproc id="http-request-001">
            <xsl:call-template name="xproc-001"/>
         </xproc>
         <xproc id="http-request-002">
            <xsl:call-template name="xproc-002"/>
         </xproc>
         <xproc id="http-request-003">
            <xsl:call-template name="xproc-003"/>
         </xproc>
         <xproc id="http-request-004">
            <xsl:call-template name="xproc-004"/>
         </xproc>
         <!-- the response sent by the server is not correct (boundary not prefixed by two dashes) -->
         <xproc id="http-request-005">
            <xsl:call-template name="xproc-005"/>
         </xproc>
         <!-- the response sent by the server is not correct (uses \n instead of \r\n) -->
         <xproc id="http-request-006">
            <xsl:call-template name="xproc-006"/>
         </xproc>
         <xproc id="http-request-007">
            <xsl:call-template name="xproc-007"/>
         </xproc>
         <xproc id="http-request-007-fg">
            <xsl:call-template name="xproc-007-fg"/>
         </xproc>
         <xproc id="http-request-008">
            <xsl:call-template name="xproc-008"/>
         </xproc>
         <xproc id="http-request-009">
            <xsl:call-template name="xproc-009"/>
         </xproc>
         <xproc id="http-request-010">
            <xsl:call-template name="xproc-010"/>
         </xproc>
         <xproc id="http-request-011">
            <xsl:call-template name="xproc-011"/>
         </xproc>
         <xproc id="http-request-011-fg">
            <xsl:call-template name="xproc-011-fg"/>
         </xproc>
         <xproc id="http-request-012">
            <xsl:call-template name="xproc-012"/>
         </xproc>
         <xproc id="http-request-012">
            <xsl:call-template name="xproc-012"/>
         </xproc>
      </result>
   </xsl:template>

   <xsl:template name="xproc-001">
      <xsl:variable name="request" as="element(http:request)">
         <http:request href="http://tests.xproc.org/service/fixed-xml" method="get">
            <http:header name="Cache-Control" value="no-cache"/>
         </http:request>
      </xsl:variable>
      <xsl:sequence select="my:send-request($request)"/>
   </xsl:template>

   <xsl:template name="xproc-002">
      <xsl:variable name="request" as="element(http:request)">
         <http:request href="http://tests.xproc.org/service/fixed-rdf" method="post">
         <!--http:request href="http://192.168.88.128:8080/" method="post"-->
            <http:header name="Cache-Control" value="no-cache"/>
            <http:body content-type="application/xml">
               <content/>
            </http:body>
         </http:request>
      </xsl:variable>
      <xsl:sequence select="my:send-request($request)"/>
   </xsl:template>

   <xsl:template name="xproc-003">
      <xsl:variable name="request" as="element(http:request)">
         <http:request href="http://tests.xproc.org/service/fixed-text" method="post">
            <http:header name="Cache-Control" value="no-cache"/>
            <http:body content-type="application/xml">
               <content/>
            </http:body>
         </http:request>
      </xsl:variable>
      <xsl:sequence select="my:send-request($request)"/>
   </xsl:template>

   <xsl:template name="xproc-004">
      <xsl:variable name="request" as="element(http:request)">
         <http:request href="http://tests.xproc.org/service/fixed-binary" method="get">
            <http:header name="Cache-Control" value="no-cache"/>
         </http:request>
      </xsl:variable>
      <xsl:sequence select="my:send-request($request)"/>
   </xsl:template>

   <xsl:template name="xproc-005">
      <xsl:variable name="request" as="element(http:request)">
         <http:request href="http://tests.xproc.org/service/fixed-multipart" method="get">
            <http:header name="Cache-Control" value="no-cache"/>
         </http:request>
      </xsl:variable>
      <xsl:sequence select="my:send-request($request)"/>
   </xsl:template>

   <xsl:template name="xproc-006">
      <xsl:variable name="request" as="element(http:request)">
         <http:request href="http://tests.xproc.org/service/fixed-alternative" method="get">
            <http:header name="Cache-Control" value="no-cache"/>
         </http:request>
      </xsl:variable>
      <xsl:sequence select="my:send-request($request)"/>
   </xsl:template>

   <xsl:template name="xproc-007">
      <xsl:variable name="request" as="element(http:request)">
         <http:request href="http://tests.xproc.org/service/echo" method="post">
            <http:header name="Cache-Control" value="no-cache"/>
            <http:body content-type="application/xml">
               <doc/>
            </http:body>
         </http:request>
      </xsl:variable>
      <xsl:sequence select="my:send-request($request)"/>
   </xsl:template>

   <xsl:template name="xproc-007-fg">
      <xsl:variable name="request" as="element(http:request)">
         <http:request href="http://tests.xproc.org/service/echo"
                       method="post"
                       override-content-type="text/plain">
            <http:header name="Cache-Control" value="no-cache"/>
            <http:body content-type="application/xml">
               <doc/>
            </http:body>
         </http:request>
      </xsl:variable>
      <xsl:sequence select="my:send-request($request)"/>
   </xsl:template>

   <xsl:template name="xproc-008">
      <xsl:message select="'Basic 2...'"/>
      <xsl:variable name="request" as="element(http:request)">
         <http:request href="http://tests.xproc.org/docs/basic-auth/"
                       method="get" status-only="true">
            <http:header name="Cache-Control" value="no-cache"/>
         </http:request>
      </xsl:variable>
      <xsl:sequence select="my:send-request($request)"/>
   </xsl:template>

   <xsl:template name="xproc-009">
      <xsl:message select="'Basic 3...'"/>
      <xsl:variable name="request" as="element(http:request)">
         <http:request href="http://tests.xproc.org/docs/basic-auth/" method="get"
                       username="testuser" password="testpassword" auth-method="basic">
            <http:header name="Cache-Control" value="no-cache"/>
         </http:request>
      </xsl:variable>
      <xsl:sequence select="my:send-request($request)"/>
   </xsl:template>

   <xsl:template name="xproc-010">
      <xsl:message select="'Basic 4...'"/>
      <xsl:variable name="request" as="element(http:request)">
         <http:request href="http://tests.xproc.org/docs/basic-auth/" method="get"
                       username="testuser" password="testpassword" auth-method="basic"
                       send-authorization="true">
            <http:header name="Cache-Control" value="no-cache"/>
         </http:request>
      </xsl:variable>
      <xsl:sequence select="my:send-request($request)"/>
   </xsl:template>

   <xsl:template name="xproc-011">
      <xsl:variable name="request" as="element(http:request)">
         <http:request href="http://tests.xproc.org/service/echoparams" method="post">
            <http:header name="Cache-Control" value="no-cache"/>
            <http:body content-type="application/x-www-form-urlencoded">
               <xsl:text>name=W3C&amp;spec=XProc</xsl:text>
            </http:body>
         </http:request>
      </xsl:variable>
      <xsl:sequence select="my:send-request($request)"/>
   </xsl:template>

   <!-- To test binary... -->
   <xsl:template name="xproc-011-fg">
      <xsl:variable name="request" as="element(http:request)">
         <http:request href="http://tests.xproc.org/service/echoparams" method="post">
            <http:header name="Cache-Control" value="no-cache"/>
            <http:body content-type="application/octet-stream">
               <xsl:value-of select="
      	            saxon:string-to-base64Binary('name=W3C&amp;spec=XProc', 'UTF-8')"/>
            </http:body>
         </http:request>
      </xsl:variable>
      <xsl:sequence select="my:send-request($request)"/>
   </xsl:template>

   <xsl:template name="xproc-012">
      <xsl:variable name="request" as="element(http:request)">
         <http:request href="http://tests.xproc.org/service/over-here" method="get">
            <http:header name="Cache-Control" value="no-cache"/>
         </http:request>
      </xsl:variable>
      <xsl:variable name="resp" select="my:send-request($request)"/>
      <!-- TODO: FIXME: Should the redirect be handled in the
           extension function, or here?  Or depend on an option or
           attribute? -->
      <xsl:sequence select="
          if ( $resp[1]/xs:integer(@status) eq 302 ) then
            my:send-request($request, $resp[1]/http:header[@name eq 'Location']/@value)
          else
            $resp"/>
   </xsl:template>

</xsl:stylesheet>
