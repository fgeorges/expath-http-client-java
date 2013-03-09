SAXON=$$HOME/bin/saxon

EHTTP=../../saxon/http-client/dist/http-client.jar

TAGSOUP=$$FG_JAVA_LIBS/org/ccil/tagsoup-1.2.jar
AP_CORE=$$FG_JAVA_LIBS/org/apache/httpcomponents-core-4.0/lib/httpcore-4.0.jar
AP_CLIENT=$$FG_JAVA_LIBS/org/apache/httpcomponents-client-4.0-beta2/lib/httpclient-4.0-beta2.jar
AP_LOG=$$FG_JAVA_LIBS/org/apache/commons-logging-1.1.1/commons-logging-1.1.1.jar
AP_CODEC=$$FG_JAVA_LIBS/org/apache/commons-codec-1.3/commons-codec-1.3.jar

LOG_OPT1=-Dorg.apache.commons.logging.Log=org.apache.commons.logging.impl.SimpleLog
LOG_OPT2=-Dorg.apache.commons.logging.simplelog.showdatetime=true
#LOG_OPT3=-Dorg.apache.commons.logging.simplelog.log.org.apache.http=info
#LOG_OPT4=-Dorg.apache.commons.logging.simplelog.log.org.apache.http.wire=info
LOG_OPT3=-Dorg.apache.commons.logging.simplelog.log.org.apache.http=debug
LOG_OPT4=-Dorg.apache.commons.logging.simplelog.log.org.apache.http.wire=debug
LOG_OPT5=-Dorg.apache.commons.logging.simplelog.log.org.fgeorges.exslt2.httpclient=debug
# TODO: Squid used at Sword does not understand HTTP 1.1 chunked encoding.
PROP1=-Dexslt2.hc.http.version=1.0
#PROP1=-Dexslt2.hc.http.version=1.1

MAP_KEY=ABQIAAAApauHa22s3jjpFII3xsFOmBQqOhBDBnQJ8Ao-CIne506W8LCJ2BRLlYzn22KelrVOyoJ7EA7OLwsGgw
USER=fgeorges.test
PWD=testtest
OUTPUT=prague-contacts.odt
PATTERN=contacts-pattern.odt


all: backup-pim contacts gdata

# zip:
# 	"$(SAXON)" --b --add-cp="$(ESAXON)" \
# 	    -xsl:zip.xsl -it:main

backup-pim:
	echo contacts...
	"$(SAXON)" --b --add-cp="$(EHTTP)" \
	    --add-cp="$(TAGSOUP)" \
	    --add-cp="$(AP_CORE)" \
	    --add-cp="$(AP_CLIENT)" \
	    --add-cp="$(AP_LOG)" \
	    --add-cp="$(AP_CODEC)" \
	    --java="$(LOG_OPT1)" \
	    --java="$(LOG_OPT2)" \
	    --java="$(LOG_OPT3)" \
	    --java="$(LOG_OPT4)" \
	    --java="$(LOG_OPT5)" \
	    --java="$(PROP1)" \
	    -xsl:gdata/backup-pim.xsl -o:gdata/backup-pim.out -it:main \
	    user="$(USER)" pwd="$(PWD)" \
	    2>&1 | tee gdata/backup-pim.log

contacts:
	echo contacts...
	"$(SAXON)" --b --add-cp="$(EHTTP)" \
	    --add-cp="$(TAGSOUP)" \
	    --add-cp="$(AP_CORE)" \
	    --add-cp="$(AP_CLIENT)" \
	    --add-cp="$(AP_LOG)" \
	    --add-cp="$(AP_CODEC)" \
	    --java="$(LOG_OPT1)" \
	    --java="$(LOG_OPT2)" \
	    --java="$(LOG_OPT3)" \
	    --java="$(LOG_OPT4)" \
	    --java="$(LOG_OPT5)" \
	    --java="$(PROP1)" \
	    -xsl:prague-contacts.xsl -o:prague-contacts.out -it:main \
	    user="$(USER)" pwd="$(PWD)" map-key="$(MAP_KEY)" \
	    pattern="$(PATTERN)" output="$(OUTPUT)" \
	    2>&1 | tee prague-contacts.log

gdata: gdata-service gdata-contacts gdata-events

gdata-service:
	"$(SAXON)" --b --add-cp="$(EHTTP)" \
	    --add-cp="$(AP_CORE)" \
	    --add-cp="$(AP_CLIENT)" \
	    --add-cp="$(AP_LOG)" \
	    --add-cp="$(AP_CODEC)" \
	    --java="$(LOG_OPT1)" \
	    --java="$(LOG_OPT2)" \
	    --java="$(LOG_OPT3)" \
	    --java="$(LOG_OPT4)" \
	    --java="$(LOG_OPT5)" \
	    --java="$(PROP1)" \
	    -xsl:gdata-test.xsl -o:gdata-test-service.out -it:make-service \
	    user="$(USER)" pwd="$(PWD)" \
	    2>&1 | tee gdata-test-service.log

gdata-contacts:
	"$(SAXON)" --b --add-cp="$(EHTTP)" \
	    --add-cp="$(AP_CORE)" \
	    --add-cp="$(AP_CLIENT)" \
	    --add-cp="$(AP_LOG)" \
	    --add-cp="$(AP_CODEC)" \
	    --java="$(LOG_OPT1)" \
	    --java="$(LOG_OPT2)" \
	    --java="$(LOG_OPT3)" \
	    --java="$(LOG_OPT4)" \
	    --java="$(LOG_OPT5)" \
	    --java="$(PROP1)" \
	    -xsl:gdata-test.xsl -o:gdata-test-contacts.out -it:get-contacts \
	    user="$(USER)" pwd="$(PWD)" \
	    2>&1 | tee gdata-test-contacts.log

gdata-events:
	"$(SAXON)" --b --add-cp="$(EHTTP)" \
	    --add-cp="$(AP_CORE)" \
	    --add-cp="$(AP_CLIENT)" \
	    --add-cp="$(AP_LOG)" \
	    --add-cp="$(AP_CODEC)" \
	    --add-cp="$(TAGSOUP)" \
	    --java="$(LOG_OPT1)" \
	    --java="$(LOG_OPT2)" \
	    --java="$(LOG_OPT3)" \
	    --java="$(LOG_OPT4)" \
	    --java="$(LOG_OPT5)" \
	    --java="$(PROP1)" \
	    -xsl:gdata-test.xsl -o:gdata-test-events.out -it:get-events \
	    user="$(USER)" pwd="$(PWD)" \
	    2>&1 | tee gdata-test-events.log

.PHONY: all backup-pim gdata gdata-service gdata-contacts gdata-events contacts
