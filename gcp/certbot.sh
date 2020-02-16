#!/bin/sh

docker run -it --rm \
    --device /dev/fuse --privileged \
    --dns=8.8.8.8 \
    --name certbot \
    gcr.io/myenv-dev/certbot:latest \
    #  certonly \
    #  -m "local@myenv.dev" \
    # -d 'local.myenv.dev' \
    # -d '*.local.myenv.dev' \
    # --dns-cloudflare-propagation-seconds 10
