#!/bin/sh

GRUN_SERVICE_NAME=certbot
CONTAINER=certbot
PROJECT=myenv-dev
REGION=us-central1

CURDIR=$(pwd)
cd $(dirname $0)/../


# gcloud beta run deploy $GRUN_SERVICE_NAME \
#   --project $PROJECT \
#   --image gcr.io/$PROJECT/$CONTAINER \
#   --region $REGION \
#   --platform managed \
#   --set-env-vars GCS_BUCKET_NAME=certs.local.myenv.dev \
#   --set-env-vars CERTBOT_EMAIL=local@myenv.dev \
#   --set-env-vars CERTBOT_DOMAIN=local.myenv.dev \
#   --set-env-vars GCP_PROJECT_NAME=myenv-dev \
#   --set-env-vars GCP_SERVICE_ACCOUNT=cloud-storage-certs@myenv-dev.iam.gserviceaccount.com \
#   --set-env-vars DNS_CLOUDFLARE_EMAIL=anon@anoncom.net \
#   --set-env-vars DNS_CLOUDFLARE_API_KEY=52115b0a719affc34505d7977c82e4ed5f501
gcloud beta run deploy $GRUN_SERVICE_NAME \
  --project $PROJECT \
  --image gcr.io/$PROJECT/$CONTAINER \
  --region $REGION \
  --platform managed \
  --set-env-vars GCS_BUCKET_NAME=certs.local.myenv.dev \
  --set-env-vars CERTBOT_EMAIL=local@myenv.dev \
  --set-env-vars CERTBOT_DOMAIN=local.myenv.dev \
  --set-env-vars GCP_PROJECT_NAME=myenv-dev \
  --set-env-vars GCP_SERVICE_ACCOUNT=cloud-storage-certs@myenv-dev.iam.gserviceaccount.com \
  --set-env-vars DNS_GOOGLE_SERVICE_ACCOUNT=certbot-dns-update@myenv-dev.iam.gserviceaccount.com
cd $CURDIR
