declare namespace http = "http://expath.org/ns/http-client";
declare namespace http-java = "java:org.expath.saxon.HttpClient";

(: Saxon passes the proxy if oXygen is configured as such :)
http-java:send-request(
   <http:request href="http://www.xmlprague.cz/" method="get"/>)

(:
==>
(
 <http:response status="200" message="OK">
    <http:header name="Server" value="Apache/1.3.37 (Unix) mod_perl/1.29"/>
    <http:header name="Content-Type" value="text/html; charset=ISO-8859-1"/>
    ...
    <http:body content-type="text/html; charset=ISO-8859-1"/>
 </http:response>
,
 <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
       <title>XML Prague</title>
       ...
)
:)
