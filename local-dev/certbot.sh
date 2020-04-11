#!/bin/sh
docker run -it --rm \
 --name myenvdev-certbot \
 -p 443:443/tcp \
 -p 80:80/tcp \
 -p 8080:8080/tcp \
 -e PORT=8080 \
 -e GCS_BUCKET_NAME=certs.local.myenv.dev \
 -e CERTBOT_EMAIL=local@myenv.dev \
 -e CERTBOT_DOMAIN=local.myenv.dev \
 -e GCP_PROJECT_NAME=myenv-dev \
 -e GCP_ACCOUNT=cloud-storage-certs@myenv-dev.iam.gserviceaccount.com \
 gcr.io/myenv-dev/certbot:latest debug
