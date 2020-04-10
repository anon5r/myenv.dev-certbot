#!/bin/sh
PORT=8880
sudo docker run -it --rm \
    --privileged \
    --cap-add SYS_ADMIN --device /dev/fuse \
    --dns=8.8.8.8 \
    --name certbot \
    --env GCS_BUCKET_NAME=certs.local.myenv.dev \
    --env CERTBOT_EMAIL=local\@myenv.dev \
    --env CERTBOT_DOMAIN=local.myenv.dev \
    --env HTTP_SERVER_RUNNING_TIMEOUT=180 \
    --env PORT=80 \
    gcr.io/myenv-dev/certbot:latest \
    debug
