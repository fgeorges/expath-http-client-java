JAVA.ver  := 0.5.0dev
JAVA.mod  := expath-http-client-java
JAVA.root := $(JAVA.mod)-$(JAVA.ver)
JAVA.prj  := ../http-client-java
JAVA.jar  := $(JAVA.prj)/dist/http-client-java.jar

# WARNING: Change /package/@version accordingly in saxon-xar/expath-pkg.xml !
SAXON.ver  := 0.12.0dev
SAXON.mod  := expath-http-client-saxon
SAXON.root := $(SAXON.mod)-$(SAXON.ver)
SAXON.pkg  := $(SAXON.root)/content
SAXON.prj  := ../http-client-saxon
SAXON.jar  := $(SAXON.prj)/dist/http-client-saxon.jar

SAMPLES.dir := ../samples

all: clean dist

clean: clean-java clean-saxon
dist:  dist-java  dist-saxon

dist-java:
	( cd "$(JAVA.prj)" && ant )
	mkdir "$(JAVA.root)"
	echo "Version: $(JAVA.ver)" > "$(JAVA.root)/VERSION"
	echo "Git revision:" `git describe --always` >> "$(JAVA.root)/VERSION"
	cp "$(JAVA.jar)" "$(JAVA.root)/expath-http-client-java.jar"
#	cp README.java "$(JAVA.root)/README"
	cp -pPR "$(JAVA.prj)/lib" "$(JAVA.root)"
	cp -pPR "$(JAVA.prj)/src" "$(JAVA.root)"
	find "$(JAVA.root)/src" -type d -name .~ \
	    -exec rm -rf {} \; 2>/dev/null || true
#	mkdir "$(JAVA.root)/samples"
	zip -r "$(JAVA.root).zip" "$(JAVA.root)"
	rm -rf "$(JAVA.root)"

pkg-saxon:
	( cd "$(SAXON.prj)" && ant )
	mkdir "$(SAXON.root)"
	mkdir "$(SAXON.pkg)"
	cp "saxon-xar/expath-pkg.xml" "$(SAXON.root)"
	cp "saxon-xar/saxon.xml"      "$(SAXON.root)"
	cp "saxon-xar/cxan.xml"       "$(SAXON.root)"
	mkdir "$(SAXON.pkg)/jar"
	cp "$(JAVA.jar)"              "$(SAXON.pkg)/jar/expath-http-client-java.jar"
	cp "$(SAXON.jar)"             "$(SAXON.pkg)/jar/$(SAXON.mod).jar"
	mkdir "$(SAXON.pkg)/xsl"
	cp "saxon-xar/wrapper.xsl"    "$(SAXON.pkg)/xsl/$(SAXON.mod).xsl"
	mkdir "$(SAXON.pkg)/xq"
	cp "saxon-xar/wrapper.xq"     "$(SAXON.pkg)/xq/$(SAXON.mod).xq"
	cp -pPR "$(JAVA.prj)/lib" "$(SAXON.pkg)"
	cd "$(SAXON.root)" && zip -r "../$(SAXON.root).xar" \
	    expath-pkg.xml saxon.xml cxan.xml content
	rm -rf "$(SAXON.root)"

dist-saxon: pkg-saxon
	mkdir "$(SAXON.root)"
	echo "Version: $(SAXON.ver)" > "$(SAXON.root)/VERSION"
	echo "Git revision:" `git describe --always` >> "$(SAXON.root)/VERSION"
	cp "$(SAXON.root).xar" "$(SAXON.root)"
	cp README.saxon "$(SAXON.root)/README"
	cp -pPR "$(SAXON.prj)/src" "$(SAXON.root)"
	find "$(SAXON.root)/src" -type d -name .~ \
	    -exec rm -rf {} \; 2>/dev/null || true
	mkdir "$(SAXON.root)/samples"
	cp "$(SAMPLES.dir)/simple-get.xsl" "$(SAXON.root)/samples"
	zip -r "$(SAXON.root).zip" "$(SAXON.root)"
	rm -rf "$(SAXON.root)"

clean-java:
	rm -rf "$(JAVA.root)"
	rm -rf "$(JAVA.root).zip"

clean-saxon:
	rm -rf "$(SAXON.root)"
	rm -rf "$(SAXON.root).zip"
	rm -rf "$(SAXON.root).xar"

.PHONY: dist pkg clean
