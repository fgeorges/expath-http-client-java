<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gdata="http://www.fgeorges.org/xslt/google/data"
                xmlns:gc="http://www.fgeorges.org/xslt/google/contacts"
                xmlns:gmap="http://www.fgeorges.org/xslt/google/maps"
                xmlns:gd="http://schemas.google.com/g/2005"
                xmlns:atom="http://www.w3.org/2005/Atom"
                xmlns:impl="urn:X-FGeorges:exslt2:prague:2009:google-contacts"
                exclude-result-prefixes="#all"
                version="2.0">

   <xsl:import href="../../../samples/google/gdata.xsl"/>
   <xsl:import href="../../../samples/google/gcontacts.xsl"/>
   <xsl:import href="../../../samples/google/gmaps.xsl"/>

   <xsl:param name="user"    as="xs:string" required="yes"/>
   <xsl:param name="pwd"     as="xs:string" required="yes"/>
   <xsl:param name="map-key" as="xs:string" required="yes"/>

   <!-- the contacts service -->
   <xsl:variable name="impl:cp-service" as="element(gdata:service)" select="
       gc:make-contact-service($user, $pwd)"/>

   <!-- the maximum number of entries to get in one query -->
   <xsl:variable name="impl:chunck-param" as="element(gdata:param)">
      <gdata:param name="max-results" value="100"/>
   </xsl:variable>

   <!-- the maps service -->
   <xsl:variable name="impl:map-service" as="element(gmap:service)" select="
       gmap:make-maps-service($map-key)"/>

   <!--
      Return all the contact groups as Atom entries.
   -->
   <xsl:function name="impl:get-group-entries" as="element(atom:entry)+">
      <xsl:variable name="feeds" as="element(atom:feed)+" select="
          gc:get-groups($impl:cp-service, (), $impl:chunck-param)"/>
      <xsl:sequence select="$feeds/atom:entry"/>
   </xsl:function>

   <!--
      Select the group 'My Contacts' in all contact groups as Atom entries.
   -->
   <xsl:function name="impl:get-group-my" as="element(atom:entry)">
      <xsl:param name="groups" as="element(atom:entry)+"/>
      <xsl:sequence select="
          gc:group-by-name($groups, 'System Group: My Contacts')"/>
   </xsl:function>

   <!--
      Return the contacts in 'My Contacts' as Atom entries.
   -->
   <xsl:function name="impl:get-contact-entries">
      <xsl:param name="groups"   as="element(atom:entry)+"/>
      <xsl:param name="group-my" as="element(atom:entry)"/>
      <!-- TODO: It seems it is not possible to retreive all contacts
           from a given group, so I have to download all contacts and
           filter them...  Double check that, sounds weird. -->
      <xsl:variable name="all-contacts" as="element(atom:entry)+" select="
          gc:get-contacts($impl:cp-service, (), $impl:chunck-param)/atom:entry"/>
      <xsl:sequence select="
          $all-contacts[gc:contact-groups(., $groups)[. is $group-my]]"/>
   </xsl:function>

   <!--
      Single entry point, return contacts as a 'contacts' element.
   -->
   <xsl:template name="impl:get-contacts" as="element(contacts)">
      <xsl:variable name="groups"   select="impl:get-group-entries()"/>
      <xsl:variable name="group-my" select="impl:get-group-my($groups)"/>
      <xsl:variable name="contacts" select="
          impl:get-contact-entries($groups, $group-my)"/>
      <contacts>
         <xsl:variable name="TODO-DEBUG" select="$contacts[contains(atom:title, 'Olya')], $contacts[contains(atom:title, 'Papa')]"/>
         <xsl:apply-templates select="$TODO-DEBUG, $contacts except $TODO-DEBUG" mode="impl:get-contacts">
            <xsl:with-param name="groups"   select="$groups"/>
            <xsl:with-param name="group-my" select="$group-my"/>
         </xsl:apply-templates>
      </contacts>
   </xsl:template>

   <!--
      Mode impl:get-contacts: format Atom entries to 'contact' elements.
   -->

   <!-- one single contact -->
   <xsl:template match="atom:entry" mode="impl:get-contacts">
      <xsl:param name="groups"     as="element(atom:entry)+"/>
      <xsl:param name="group-my"   as="element(atom:entry)"/>
      <contact>
         <!-- contact details -->
         <xsl:apply-templates mode="impl:get-contacts" select="
             atom:title,
             gd:organization,
             gd:email,
             gd:postalAddress,
             atom:content"/>
         <!-- contact group(s) -->
         <xsl:for-each select="gc:contact-groups(., $groups)[not(. is $group-my)]">
            <group>
               <!-- remove the prefix 'System Group:', if any -->
               <xsl:value-of select="
                   (substring-after(atom:title, 'System Group: '), atom:title)[normalize-space(.)][1]"/>
            </group>
         </xsl:for-each>
         <!-- contact picture, if any -->
         <xsl:variable name="photo" select="gc:get-contact-photo($impl:cp-service, .)"/>
         <xsl:if test="exists($photo)">
            <photo>
               <xsl:sequence select="$photo"/>
            </photo>
         </xsl:if>
      </contact>
   </xsl:template>

   <!-- contact name -->
   <xsl:template match="atom:title" mode="impl:get-contacts">
      <name>
         <xsl:value-of select="."/>
      </name>
   </xsl:template>

   <!-- contact company -->
   <xsl:template match="gd:organization" mode="impl:get-contacts">
      <company>
         <xsl:value-of select="."/>
      </company>
   </xsl:template>

   <!-- contact email -->
   <xsl:template match="gd:email" mode="impl:get-contacts">
      <email>
         <xsl:value-of select="@address"/>
      </email>
   </xsl:template>

   <!-- contact comment -->
   <xsl:template match="atom:content" mode="impl:get-contacts">
      <comment>
         <xsl:value-of select="."/>
      </comment>
   </xsl:template>

   <!-- contact address -->
   <xsl:template match="gd:postalAddress" mode="impl:get-contacts">
      <address>
         <xsl:value-of select="."/>
      </address>
      <!-- resolve the address to coordinates -->
      <xsl:variable name="coord" as="xs:double*" select="
          gmap:address-to-coordinates($impl:map-service, .)"/>
      <xsl:choose>
         <xsl:when test="exists($coord)">
            <!-- if we got coordinates, ask for the map -->
            <map>
               <xsl:variable name="params" as="element(gdata:param)+">
                  <gdata:param name="center" value="{ $coord[2] },{ $coord[1] }"/>
                  <gdata:param name="size"   value="256x128"/>
                  <gdata:param name="zoom"   value="14"/>
               </xsl:variable>
               <xsl:sequence select="gmap:get-static-map($impl:map-service, $params)"/>
            </map>
         </xsl:when>
         <xsl:otherwise>
            <!-- if we didn't get the coordinates, ignore it -->
            <xsl:message>
               <xsl:text>Warning: Unable to get static map for the address:&#10;  "</xsl:text>
               <xsl:value-of select="."/>
               <xsl:text>"</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

</xsl:stylesheet>
