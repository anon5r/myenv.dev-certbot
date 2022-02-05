#!/bin/sh
PROJECT_ID="your-project-id"
DOMAIN="example.com"
PORT=8880
sudo docker run -it --rm \
    --privileged \
    --cap-add SYS_ADMIN --device /dev/fuse \
    --dns=8.8.8.8 \
    --name certbot \
    --env GCS_BUCKET_NAME=certs.local.${DOMAIN} \
    --env CERTBOT_EMAIL=local\@${DOMAIN} \
    --env CERTBOT_DOMAIN=local.${DOMAIN} \
    --env HTTP_SERVER_RUNNING_TIMEOUT=180 \
    --env PORT=80 \
    gcr.io/$PROJECT_ID/certbot:latest \
    debug
