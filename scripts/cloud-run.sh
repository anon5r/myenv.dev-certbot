#!/bin/sh

GRUN_SERVICE_NAME=certbot
CONTAINER=certbot
PROJECT="your-project-id"
REGION=us-central1
DOMAIN="example.com"

CURDIR=$(pwd)
cd $(dirname $0)/../


gcloud beta run deploy $GRUN_SERVICE_NAME \
  --project $PROJECT \
  --image gcr.io/$PROJECT/$CONTAINER \
  --region $REGION \
  --platform managed \
  --set-env-vars GCS_BUCKET_NAME=certs.local.${DOMAIN} \
  --set-env-vars CERTBOT_EMAIL=local@${DOMAIN} \
  --set-env-vars CERTBOT_DOMAIN=local.${DOMAIN} \
  --set-env-vars GCP_PROJECT_NAME=$PROJECT \
  --set-env-vars GCP_SERVICE_ACCOUNT=cloud-storage-certs@${PROJECT}.iam.gserviceaccount.com \
  --set-env-vars DNS_GOOGLE_SERVICE_ACCOUNT=certbot-dns-update@${PROJECT}.iam.gserviceaccount.com
cd $CURDIR
