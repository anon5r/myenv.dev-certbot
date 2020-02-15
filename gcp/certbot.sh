#!/bin/sh

docker run -it --rm \
    --dns=8.8.8.8 \
    gcr.io/myenv-dev/certbot:latest certonly \
    -m "local@myenv.dev" \
    -d 'local.myenv.dev' \
    -d '*.local.myenv.dev' \
    --dns-cloudflare-propagation-seconds 10
