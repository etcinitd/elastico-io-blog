#!/bin/bash
set -e

BUCKET_NAME=elastico.io

hugo -v --theme=allegiant

# Copy over pages - not static js/img/css/downloads
aws s3 sync --profile elastico --acl "public-read" --sse "AES256" public/ s3://$BUCKET_NAME/ --exclude 'img' --exclude 'js' --exclude 'fonts' --exclude 'css' --exclude 'page'

# Ensure static files are set to cache forever - cache for a month --cache-control "max-age=2592000"
aws s3 sync --profile elastico --cache-control "max-age=2592000" --acl "public-read" --sse "AES256" public/img/ s3://$BUCKET_NAME/img/
aws s3 sync --profile elastico --cache-control "max-age=2592000" --acl "public-read" --sse "AES256" public/css/ s3://$BUCKET_NAME/css/
aws s3 sync --profile elastico --cache-control "max-age=2592000" --acl "public-read" --sse "AES256" public/js/ s3://$BUCKET_NAME/js/
aws s3 sync --profile elastico --cache-control "max-age=2592000" --acl "public-read" --sse "AES256" public/js/ s3://$BUCKET_NAME/fonts/

# Downloads binaries, not part of repo - cache at edge for a year --cache-control "max-age=31536000"
# aws s3 sync --profile elastico --cache-control "max-age=31536000" --acl "public-read" --sse "AES256"  static/downloads/ s3://$BUCKET_NAME/downloads/
