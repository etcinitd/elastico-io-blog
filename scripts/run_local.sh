#!/bin/bash
set -e

SERVER_ADDR=${1:-localhost}

exec hugo --theme allegiant server --bind "0.0.0.0" -v --baseURL http://${SERVER_ADDR}:1313/
