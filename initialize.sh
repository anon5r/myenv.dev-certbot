#!/bin/sh
GCP_SERVICE_ACCOUNT=${GCP_SERVICE_ACCOUNT:-"cloud-storage-certs@myenv-dev.iam.gserviceaccount.com"}
GCP_PROJECT_NAME=${GCP_PROJECT_NAME:-"myenv-dev"}
DOMAIN_NAME=${DOMAIN_NAME:-local.myenv.dev}
GCS_BUCKET_NAME=${GCS_BUCKET_NAME:-myenvdev-certificates}
LE_DIR=/etc/letsencrypt
export PATH=/google-cloud-sdk/bin:$PATH
echo "Start Initialize"

#gcloud config set account $GCP_SERVICE_ACCOUNT
gcloud auth activate-service-account $GCP_SERVICE_ACCOUNT --key-file /app/gcs.json
gcloud config set project $GCP_PROJECT_NAME

gsutil cp -r gs://$GCS_BUCKET_NAME/letsencrypt/accounts $LE_DIR/accounts/
gsutil cp -r gs://$GCS_BUCKET_NAME/letsencrypt/csr $LE_DIR/csr/
gsutil cp -r gs://$GCS_BUCKET_NAME/letsencrypt/keys $LE_DIR/keys/
gsutil cp -r gs://$GCS_BUCKET_NAME/letsencrypt/renewal $LE_DIR/renewal/
gsutil cp -r gs://$GCS_BUCKET_NAME/letsencrypt/archive $LE_DIR/archive/

if [ ! -e $LE_DIR/live/$DOMAIN_NAME ] ; then
    mkdir -p $LE_DIR/live/$DOMAIN_NAME
fi
if [ -d $LE_DIR/archive/$DOMAIN_NAME ] ; then
    for ARC_NAME in "cert" "chain" "fullchain" "privkey"
    do
        ARCH_PATH=$(find $LE_DIR/archive/$DOMAIN_NAME/ \( -name $ARC_NAME\*.pem \) -print | tail -1)
        ln -sfn ../../archive/$DOMAIN_NAME/$(basename $ARCH_PATH) $LE_DIR/live/$DOMAIN_NAME/$ARC_NAME.pem
    done
fi
