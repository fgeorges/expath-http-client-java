ROOT=../..

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

weather-test:
	echo WEATHER TEST...
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
	    -xsl:weather-test.xsl -o:weather-test-out.xml -it:main \
	    2>&1 | tee weather-test.log

.PHONY: weather-test
