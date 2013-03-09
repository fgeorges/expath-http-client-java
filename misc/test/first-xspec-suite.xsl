<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:my="my"
                exclude-result-prefixes="xs"
                version="2.0">

   <xsl:import href="http://expath.org/ns/http-client.xsl"/>

   <xsl:function name="my:hello">
      <hello>World!</hello>
   </xsl:function>

</xsl:stylesheet>
