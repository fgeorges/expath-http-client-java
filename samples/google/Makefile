SAXON=$$HOME/bin/saxon
HTTPCLIENT.jar=../../saxon/http-client/dist/http-client.jar
TAGSOUP.jar=$$FG_JAVA_LIBS/org/ccil/tagsoup-1.2.jar
AP_CORE=$$FG_JAVA_LIBS/org/apache/httpcomponents-core-4.0/lib/httpcore-4.0.jar
AP_CLIENT=$$FG_JAVA_LIBS/org/apache/httpcomponents-client-4.0-beta2/lib/httpclient-4.0-beta2.jar
AP_LOG=$$FG_JAVA_LIBS/org/apache/commons-logging-1.1.1/commons-logging-1.1.1.jar
AP_CODEC=$$FG_JAVA_LIBS/org/apache/commons-codec-1.3/commons-codec-1.3.jar
LOG_OPT1=-Dorg.apache.commons.logging.Log=org.apache.commons.logging.impl.SimpleLog
LOG_OPT2=-Dorg.apache.commons.logging.simplelog.showdatetime=false
LOG_OPT3=-Dorg.apache.commons.logging.simplelog.log.org.apache.http=info
LOG_OPT4=-Dorg.apache.commons.logging.simplelog.log.org.apache.http.wire=info
LOG_OPT5=-Dorg.apache.commons.logging.simplelog.log.org.fgeorges.exslt2.httpclient=debug

# FIXME: Those example won't use Google Maps, but the example for XML
# Prague will.  Move all that stuff over there.
MAP_KEY=ABQIAAAApauHa22s3jjpFII3xsFOmBQqOhBDBnQJ8Ao-CIne506W8LCJ2BRLlYzn22KelrVOyoJ7EA7OLwsGgw

USER=fgeorges.test
PWD=testtest

all: gcontacts gdocs

gcontacts:
	echo gcontacts...
	"$(SAXON)" --b \
	    --add-cp="$(HTTPCLIENT.jar)" \
	    --add-cp="$(TAGSOUP.jar)" \
	    --add-cp="$(AP_CORE)" \
	    --add-cp="$(AP_CLIENT)" \
	    --add-cp="$(AP_LOG)" \
	    --add-cp="$(AP_CODEC)" \
	    --java="$(LOG_OPT1)" \
	    --java="$(LOG_OPT2)" \
	    --java="$(LOG_OPT3)" \
	    --java="$(LOG_OPT4)" \
	    --java="$(LOG_OPT5)" \
	    -xsl:gcontacts-test.xsl -o:gcontacts-test.out -it:main \
	    user="$(USER)" pwd="$(PWD)" map-key="$(MAP_KEY)" \
	    2>&1 | tee gcontacts-test.log

gdocs:
	echo gdocs...
	"$(SAXON)" --b \
	    --add-cp="$(HTTPCLIENT.jar)" \
	    --add-cp="$(TAGSOUP.jar)" \
	    --add-cp="$(AP_CORE)" \
	    --add-cp="$(AP_CLIENT)" \
	    --add-cp="$(AP_LOG)" \
	    --add-cp="$(AP_CODEC)" \
	    --java="$(LOG_OPT1)" \
	    --java="$(LOG_OPT2)" \
	    --java="$(LOG_OPT3)" \
	    --java="$(LOG_OPT4)" \
	    --java="$(LOG_OPT5)" \
	    -xsl:gdocs-test.xsl -o:gdocs-test.out -it:main \
	    user="$(USER)" pwd="$(PWD)" 2>&1 | tee gdocs-test.log

.PHONY: all gcontacts gdocs
