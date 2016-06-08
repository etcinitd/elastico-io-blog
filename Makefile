.PHONY: all generate upload-s3

TAG = v1
SOURCES=install-docker-windows.md jboss-docker-tutorial.md why-you-need-docker.md useful-docker-commands.md docker-basic-concepts.md install-docker-centos7.md how-to-write-dockerfile.md what-is-registry-repository.md
HTMLS=$(SOURCES:.md=.html)

all: $(SOURCES) generate

generate: $(HTMLS)
	echo "Done!"

$(HTMLS): %.html: %.md
	markdown $< | sed 's/<code/<code class="prettyprint"/g' > /tmp/$@
	TITLE=`head -n 1 $<` && cat header.html | sed "s/{{title}}/$${TITLE}/g" > /tmp/temp-header.html
	cat /tmp/temp-header.html /tmp/$@ footer.html > $@

upload-s3:
	echo "Not supported yet!"
