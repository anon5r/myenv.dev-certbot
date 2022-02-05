#!/bin/sh
PROJECT_ID="your-project-id"
DOMAIN="example.com"
docker run --rm \
 --name myenvdev-certbot \
 -p 443:443/tcp \
 -p 80:80/tcp \
 -p 8080:8080/tcp \
 -e PORT=8080 \
 -e GCS_BUCKET_NAME=certs.local.${DOMAIN} \
 -e CERTBOT_EMAIL=local@${DOMAIN} \
 -e CERTBOT_DOMAIN=local.${DOMAIN} \
 -e GCP_PROJECT_NAME=${PROJECT_ID} \
 -e GCP_ACCOUNT=cloud-storage-certs@${PROJECT_ID}.iam.gserviceaccount.com \
 gcr.io/${PROJECT_ID}/certbot:latest debug
