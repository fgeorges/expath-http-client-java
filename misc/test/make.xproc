<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:xs="http://www.w3.org/2001/XMLSchema"
            xmlns:t="http://www.jenitennison.com/xslt/xspec"
            name="xspec"
            type="t:xspec">

   <p:documentation>
      <p>This pipeline executes an XSpec test.</p>
      <p><b>Primary input:</b> A XSpec test document.</p>
      <p><b>Primary output:</b> A formatted HTML XSpec report.</p>
   </p:documentation>

   <p:serialization port="result" encoding="utf-8" method="html"/>

   <p:xslt name="compile">
      <p:input port="stylesheet">
         <!-- TODO: use catalogs -->
         <p:document href="../../../../xspec/trunk/generate-xspec-tests.xsl"/>
      </p:input>
   </p:xslt>

   <p:store href="_compiled.xsl"/>

   <p:xslt name="run" template-name="t:main">
      <p:input port="source">
         <p:pipe step="xspec" port="source"/>
      </p:input>
      <p:input port="stylesheet">
         <p:pipe step="compile" port="result"/>
      </p:input>
   </p:xslt>

   <p:store href="_report.xml"/>

   <p:xslt name="format">
      <p:input port="source">
         <p:pipe step="run" port="result"/>
      </p:input>
      <p:input port="stylesheet">
         <!-- TODO: use catalogs -->
         <p:document href="../../../../xspec/trunk/format-xspec-report.xsl"/>
      </p:input>
   </p:xslt>

   <p:store href="_report.html"/>

   <p:identity>
      <p:input port="source">
         <p:pipe step="format" port="result"/>
      </p:input>
   </p:identity>

</p:pipeline>
