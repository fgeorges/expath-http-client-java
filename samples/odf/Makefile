SAXON=$$HOME/bin/saxon

EZIP=../../saxon/http-client/dist/http-client.jar

OUTPUT=first-try.odt

all: first-try

first-try:
	echo first-try...
	"$(SAXON)" --b --add-cp="$(EZIP)" \
	    -xsl:first-try.xsl -o:first-try.out -it:main output="$(OUTPUT)" \
	    2>&1 | tee first-try.log

.PHONY: all first-try
