ROOT=..

include $(ROOT)/Makefile.incl

LOG_OPT1=-Dorg.apache.commons.logging.Log=org.apache.commons.logging.impl.SimpleLog
LOG_OPT2=-Dorg.apache.commons.logging.simplelog.showdatetime=false
#LOG_OPT3=-Dorg.apache.commons.logging.simplelog.log.org.apache.http=info
#LOG_OPT4=-Dorg.apache.commons.logging.simplelog.log.org.apache.http.wire=info
LOG_OPT3=-Dorg.apache.commons.logging.simplelog.log.org.apache.http=debug
LOG_OPT4=-Dorg.apache.commons.logging.simplelog.log.org.apache.http.wire=debug
LOG_OPT5=-Dorg.apache.commons.logging.simplelog.log.org.fgeorges.exslt2=debug
# TODO: Squid used at Sword does not understand HTTP 1.1 chunked encoding.
PROP1=-Dexslt2.hc.http.version=1.0
#PROP1=-Dexslt2.hc.http.version=1.1

samples: simple-get mirror soap pim-backup add-agenda expath xproc-suite

simple-get:
	echo SIMPLE GET...
	"$(SAXON)" --b \
	    --add-cp="$(HTTPCLIENT)" \
	    --add-cp="$(TAGSOUP)" \
	    --add-cp="$(APACHE_CORE)" \
	    --add-cp="$(APACHE_CLIENT)" \
	    --add-cp="$(APACHE_LOG)" \
	    --add-cp="$(APACHE_CODEC)" \
	    --java="$(LOG_OPT1)" \
	    --java="$(LOG_OPT2)" \
	    --java="$(LOG_OPT3)" \
	    --java="$(LOG_OPT4)" \
	    --java="$(LOG_OPT5)" \
	    --java="$(PROP1)" \
	    -xsl:simple-get.xsl -o:simple-get.out -it:main \
	    2>&1 | tee simple-get.log

mirror:
	echo MIRROR...
	"$(SAXON)" --b \
	    --add-cp="$(HTTPCLIENT)" \
	    --add-cp="$(TAGSOUP)" \
	    --add-cp="$(APACHE_CORE)" \
	    --add-cp="$(APACHE_CLIENT)" \
	    --add-cp="$(APACHE_LOG)" \
	    --add-cp="$(APACHE_CODEC)" \
	    --java="$(LOG_OPT1)" \
	    --java="$(LOG_OPT2)" \
	    --java="$(LOG_OPT3)" \
	    --java="$(LOG_OPT4)" \
	    --java="$(LOG_OPT5)" \
	    --java="$(PROP1)" \
	    -xsl:mirror.xsl -o:mirror.out -it:main \
	    2>&1 | tee mirror.log

soap:
	echo SOAP...
	"$(SAXON)" --b \
	    --add-cp="$(HTTPCLIENT)" \
	    --add-cp="$(TAGSOUP)" \
	    --add-cp="$(APACHE_CORE)" \
	    --add-cp="$(APACHE_CLIENT)" \
	    --add-cp="$(APACHE_LOG)" \
	    --add-cp="$(APACHE_CODEC)" \
	    --java="$(LOG_OPT1)" \
	    --java="$(LOG_OPT2)" \
	    --java="$(LOG_OPT3)" \
	    --java="$(LOG_OPT4)" \
	    --java="$(LOG_OPT5)" \
	    --java="$(PROP1)" \
	    -xsl:soap.xsl -o:soap.out -it:main

pim-backup:
	echo OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD
	echo PIM BACKUP...
	"$(SAXON)" --b \
	    --add-cp="$(HTTPCLIENT)" \
	    --add-cp="$(TAGSOUP)" \
	    --add-cp="$(APACHE_CORE)" \
	    --add-cp="$(APACHE_CLIENT)" \
	    --add-cp="$(APACHE_LOG)" \
	    --add-cp="$(APACHE_CODEC)" \
	    --java="$(LOG_OPT1)" \
	    --java="$(LOG_OPT2)" \
	    --java="$(LOG_OPT3)" \
	    --java="$(LOG_OPT4)" \
	    --java="$(LOG_OPT5)" \
	    --java="$(PROP1)" \
	    -xsl:old/google-pim-backup.xsl -o:old/google-pim-backup.out -it:main \
	    account=fgeorges.test pwd=testtest
	echo OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD

add-agenda:
	echo OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD
	echo ADD AGENDA...
	"$(SAXON)" --b \
	    --add-cp="$(HTTPCLIENT)" \
	    --add-cp="$(TAGSOUP)" \
	    --add-cp="$(APACHE_CORE)" \
	    --add-cp="$(APACHE_CLIENT)" \
	    --add-cp="$(APACHE_LOG)" \
	    --add-cp="$(APACHE_CODEC)" \
	    --java="$(LOG_OPT1)" \
	    --java="$(LOG_OPT2)" \
	    --java="$(LOG_OPT3)" \
	    --java="$(LOG_OPT4)" \
	    --java="$(LOG_OPT5)" \
	    --java="$(PROP1)" \
	    -xsl:old/google-add-agenda.xsl -o:old/google-add-agenda.out -it:main \
	    account=fgeorges.test pwd=testtest
	echo OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD

expath:
	echo EXPATH...
	"$(SAXON)" --b \
	    --add-cp="$(HTTPCLIENT)" \
	    --add-cp="$(TAGSOUP)" \
	    --add-cp="$(APACHE_CORE)" \
	    --add-cp="$(APACHE_CLIENT)" \
	    --add-cp="$(APACHE_LOG)" \
	    --add-cp="$(APACHE_CODEC)" \
	    --java="$(LOG_OPT1)" \
	    --java="$(LOG_OPT2)" \
	    --java="$(LOG_OPT3)" \
	    --java="$(LOG_OPT4)" \
	    --java="$(LOG_OPT5)" \
	    --java="$(PROP1)" \
	    -xsl:expath.xsl -o:expath.out -it:main

xproc-suite:
	echo XPROC-SUITE...
	"$(SAXON)" --b \
	    --add-cp="$(HTTPCLIENT)" \
	    --add-cp="$(TAGSOUP)" \
	    --add-cp="$(APACHE_CORE)" \
	    --add-cp="$(APACHE_CLIENT)" \
	    --add-cp="$(APACHE_LOG)" \
	    --add-cp="$(APACHE_CODEC)" \
	    --java="$(LOG_OPT1)" \
	    --java="$(LOG_OPT2)" \
	    --java="$(LOG_OPT3)" \
	    --java="$(LOG_OPT4)" \
	    --java="$(LOG_OPT5)" \
	    --java="$(PROP1)" \
	    -xsl:xproc-suite.xsl -o:xproc-suite.out -it:main \
	    2>&1 | tee xproc-suite.log

.PHONY: samples simple-get mirror soap pim-backup add-agenda expath xproc-suite
