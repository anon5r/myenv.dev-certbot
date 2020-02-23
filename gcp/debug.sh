#!/bin/sh

sudo docker run -it --rm \
    --privileged \
    --cap-add SYS_ADMIN --device /dev/fuse \
    --dns=8.8.8.8 \
    --name certbot \
    gcr.io/myenv-dev/certbot:latest \
    debug
