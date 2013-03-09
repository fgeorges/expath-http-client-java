<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:zip="http://www.exslt.org/v2/zip"
                xmlns:zip-java="java:org.fgeorges.exslt2.saxon.Zip"
                xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
                xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0"
                xmlns:impl="TODO"
                exclude-result-prefixes="xs zip zip-java impl"
                version="2.0">

   <xsl:import href="first-try-content.xsl"/>

   <xsl:param name="output" as="xs:string"/>

   <xsl:variable name="contacts">
      <contacts>
         <contact>
            <name>Michael Kay</name>
            <company>Saxonica</company>
            <email>mike@saxonica.com</email>
            <address>Reading, UK</address>
            <group>System Group: My Contacts</group>
            <group>XSL List</group>
         </contact>
         <contact>
            <name>Florent Georges</name>
            <email>fgeorges.test@gmail.com</email>
            <address>rue de Savoie 73&#10;1060 Brussels</address>
            <group>System Group: My Contacts</group>
            <photo>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</photo>
         </contact>
         <contact>
            <name>Jirka Kosek</name>
            <email>jirka@kosek.cz</email>
            <group>System Group: My Contacts</group>
            <group>XML Prague</group>
            <group>XSL List</group>
            <map>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</map>
         </contact>
         <contact>
            <name>Jim Fuller</name>
            <company>FlameDigital Ltd.</company>
            <email>jim.fuller@xmlprague.cz</email>
            <group>System Group: My Contacts</group>
            <group>XML Prague</group>
            <group>XSL List</group>
         </contact>
      </contacts>
   </xsl:variable>

   <xsl:template name="main">
      <!--
          TODO: Change this ZIP creation by a using a new extension
          function zip:update-entries() that would changes entries in
          an existing ZIP file.  That would enable one to create a
          template ODF file and only update the content.xml file,
          among a few other ones (in this case, content.xml and the
          pictures.)
      -->
      <xsl:variable name="TODO-UPDATE-zip" as="element(zip:file)">
         <zip:file href="{ $output }">
            <zip:entry name="content.xml" output="xml">
               <xsl:apply-templates select="$contacts" mode="c"/>
            </zip:entry>
            <zip:entry name="Pictures">
               <xsl:apply-templates select="$contacts//(photo|map)" mode="z"/>
            </zip:entry>
         </zip:file>
      </xsl:variable>
      <!-- TODO: This extension function does not exist yet... -->
      <!--xsl:sequence select="zip-java:update-entries($TODO-UPDATE-zip)"/-->
      <xsl:variable name="zip" as="element(zip:file)">
         <zip:file href="{ $output }">
            <zip:entry name="content.xml" output="xml">
               <xsl:apply-templates select="$contacts" mode="c"/>
            </zip:entry>
            <zip:entry name="meta.xml" href="contacts-pattern.d/meta.xml"/>
            <zip:entry name="mimetype" href="contacts-pattern.d/mimetype"/>
            <zip:entry name="settings.xml" href="contacts-pattern.d/settings.xml"/>
            <zip:entry name="styles.xml" href="contacts-pattern.d/styles.xml"/>
            <zip:entry name="META-INF">
               <zip:entry name="manifest.xml" output="xml">
                  <xsl:call-template name="manifest"/>
               </zip:entry>
            </zip:entry>
            <zip:entry name="Pictures">
               <zip:entry name="100000000000006000000060C68C003C.jpg" href="contacts-pattern.d/Pictures/100000000000006000000060C68C003C.jpg"/>
               <zip:entry name="100002000000010000000080C16325DA.gif" href="contacts-pattern.d/Pictures/100002000000010000000080C16325DA.gif"/>
               <xsl:apply-templates select="$contacts//(photo|map)" mode="z"/>
            </zip:entry>
            <zip:entry name="Thumbnails">
               <zip:entry name="thumbnail.png" href="contacts-pattern.d/Thumbnails/thumbnail.png"/>
            </zip:entry>
            <zip:entry name="Configurations2">
               <zip:entry name="accelerator">
                  <zip:entry name="current.xml" href="contacts-pattern.d/Configurations2/accelerator/current.xml"/>
               </zip:entry>
               <zip:entry name="floater"/>
               <zip:entry name="images">
                  <zip:entry name="Bitmaps"/>
               </zip:entry>
               <zip:entry name="menubar"/>
               <zip:entry name="popupmenu"/>
               <zip:entry name="progressbar"/>
               <zip:entry name="statusbar"/>
               <zip:entry name="toolbar"/>
            </zip:entry>
         </zip:file>
      </xsl:variable>
      <xsl:sequence select="zip-java:output-file($zip)"/>
   </xsl:template>

   <xsl:template name="manifest">
      <manifest:manifest>
         <manifest:file-entry manifest:media-type="application/vnd.oasis.opendocument.text" manifest:version="1.2" manifest:full-path="/"/>
         <manifest:file-entry manifest:media-type="" manifest:full-path="Configurations2/statusbar/"/>
         <manifest:file-entry manifest:media-type="" manifest:full-path="Configurations2/accelerator/current.xml"/>
         <manifest:file-entry manifest:media-type="" manifest:full-path="Configurations2/accelerator/"/>
         <manifest:file-entry manifest:media-type="" manifest:full-path="Configurations2/floater/"/>
         <manifest:file-entry manifest:media-type="" manifest:full-path="Configurations2/popupmenu/"/>
         <manifest:file-entry manifest:media-type="" manifest:full-path="Configurations2/progressbar/"/>
         <manifest:file-entry manifest:media-type="" manifest:full-path="Configurations2/menubar/"/>
         <manifest:file-entry manifest:media-type="" manifest:full-path="Configurations2/toolbar/"/>
         <manifest:file-entry manifest:media-type="" manifest:full-path="Configurations2/images/Bitmaps/"/>
         <manifest:file-entry manifest:media-type="" manifest:full-path="Configurations2/images/"/>
         <manifest:file-entry manifest:media-type="application/vnd.sun.xml.ui.configuration" manifest:full-path="Configurations2/"/>
         <manifest:file-entry manifest:media-type="image/gif" manifest:full-path="Pictures/100002000000010000000080AECD77CA.gif"/>
         <!--xsl:apply-templates select="$contacts//(photo|map)" mode="m"/-->
         <manifest:file-entry manifest:media-type="" manifest:full-path="Pictures/"/>
         <manifest:file-entry manifest:media-type="text/xml" manifest:full-path="content.xml"/>
         <manifest:file-entry manifest:media-type="text/xml" manifest:full-path="styles.xml"/>
         <manifest:file-entry manifest:media-type="text/xml" manifest:full-path="meta.xml"/>
         <manifest:file-entry manifest:media-type="" manifest:full-path="Thumbnails/thumbnail.png"/>
         <manifest:file-entry manifest:media-type="" manifest:full-path="Thumbnails/"/>
         <manifest:file-entry manifest:media-type="text/xml" manifest:full-path="settings.xml"/>
      </manifest:manifest>
   </xsl:template>

   <!-- TODO: Miss the content type (png, gif, jpg...) !!! -->
   <xsl:function name="impl:photo-filename" as="xs:string">
      <xsl:param name="photo" as="element(photo)"/>
      <xsl:sequence select="concat(generate-id($photo), '.photo.jpg')"/>
   </xsl:function>

   <xsl:function name="impl:map-filename" as="xs:string">
      <xsl:param name="map" as="element(map)"/>
      <xsl:sequence select="concat(generate-id($map), '.map.gif')"/>
   </xsl:function>

   <xsl:template match="photo" mode="z">
      <zip:entry name="{ impl:photo-filename(.) }" output="base64">
         <xsl:sequence select="data(.)"/>
      </zip:entry>
   </xsl:template>

   <xsl:template match="map" mode="z">
      <zip:entry name="{ impl:map-filename(.) }" output="base64">
         <xsl:sequence select="data(.)"/>
      </zip:entry>
   </xsl:template>

   <xsl:template match="photo" mode="m">
      <manifest:file-entry manifest:media-type="image/jpeg" manifest:full-path="Pictures/{ impl:photo-filename(.) }"/>
   </xsl:template>

   <xsl:template match="map" mode="m">
      <manifest:file-entry manifest:media-type="image/gif" manifest:full-path="Pictures/{ impl:map-filename(.) }"/>
   </xsl:template>

</xsl:stylesheet>
