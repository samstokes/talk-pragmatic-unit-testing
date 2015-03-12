NAME = pragmatic-unit-testing
ARCHIVE_NAME = $(NAME)-$(shell date +%Y-%m-%d)
SLIDES = $(NAME)-slides.html
SLIDES_DIST = $(NAME)-slides-standalone.html
SLIDES_STYLESHEET = $(wildcard slides.css)
IMAGES = $(wildcard *.png *.jpg)
ASSETS = $(IMAGES) $(SLIDES_STYLESHEET)

all: $(SLIDES)
zip: $(ARCHIVE_NAME).zip
dist: $(SLIDES_DIST) $(ASSETS)
	mkdir -p dist
	# download external references, e.g. slidy CSS and JS
	sed -nE 's#.*(href|src)="(https?://[^"]+\.(css|js|png))".*#\2#p' $< | sort -u | xargs wget --no-check-certificate --directory-prefix dist
	#ls dist/*.gz | xargs --no-run-if-empty gunzip
	if [ -n "$(ASSETS)" ]; then cp $(ASSETS) dist; fi
	# modify external references to point to downloaded assets
	sed -E 's#(href|src)="(https?://[^"]+/([^"]+\.(css|js|png)))"#\1="\3"#; s?(href|src)="(.*)\.gz"?\1="\2"?' $< > dist/$<
	mv dist/$< dist/index.html
$(ARCHIVE_NAME).zip: dist
	cd $< && zip ../$@ *

$(SLIDES): $(NAME).otl
	OTL slidy <$< >$@
	if [ -n "$(SLIDES_STYLESHEET)" ]; then sed -i '' 's|</head>|<link href="$(SLIDES_STYLESHEET)" type="text/css" rel="stylesheet" /></head>|' $@; fi

$(SLIDES_DIST): $(SLIDES) $(SLIDES_STYLESHEET) splice.sed
	sed -f splice.sed $< >$@

clean:
	rm -rf $(SLIDES) $(SLIDES_DIST) dist $(ARCHIVE_NAME).zip
