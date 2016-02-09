.PHONY: all generate upload-s3

TAG = v1

all: generate

generate:
	markdown install-docker-windows.md | sed 's/<code/<code class="prettyprint"/g' > /tmp/install-docker-windows.html
	cat header.html /tmp/install-docker-windows.html footer.html > install-docker-windows.html

upload-s3:
	echo "Not supported yet!"