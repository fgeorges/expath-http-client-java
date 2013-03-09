SAXON=$$HOME/bin/saxon-http

MAP_KEY=ABQIAAAApauHa22s3jjpFII3xsFOmBQqOhBDBnQJ8Ao-CIne506W8LCJ2BRLlYzn22KelrVOyoJ7EA7OLwsGgw

USER=****
PWD=****
OUTPUT=google-contacts-test.odt
PATTERN=../contacts-pattern.odt

all: google-contacts

google-contacts:
	echo gcontacts...
	"$(SAXON)" --b \
	    -xsl:google-contacts.xsl -it:main output="$(OUTPUT)" \
	    pattern="$(PATTERN)" user="$(USER)" pwd="$(PWD)" \
	    map-key="$(MAP_KEY)" \
	    2>&1 | tee gcontacts-test.log

.PHONY: all google-contacts
