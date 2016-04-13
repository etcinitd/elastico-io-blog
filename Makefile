.PHONY: all generate upload-s3

TAG = v1
SOURCES=install-docker-windows.md jboss-docker-tutorial.md why-you-need-docker.md
HTMLS=$(SOURCES:.md=.html)

all: $(SOURCES) generate

generate: $(HTMLS)
	echo "Done!"

$(HTMLS): %.html: %.md
	markdown $< | sed 's/<code/<code class="prettyprint"/g' > /tmp/$@
	cat header.html /tmp/$@ footer.html > $@

upload-s3:
	echo "Not supported yet!"
