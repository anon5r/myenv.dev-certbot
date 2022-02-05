#!/bin/sh
GCP_PROJECT_NAME=${GCP_PROJECT_NAME:-"myenv-dev"}
GCP_SERVICE_ACCOUNT=${GCP_SERVICE_ACCOUNT:-"cloud-storage-certs@${GCP_PROJECT_NAME}.iam.gserviceaccount.com"}
DOMAIN_NAME=${DOMAIN_NAME:-example.com}
GCS_BUCKET_NAME=${GCS_BUCKET_NAME:-myenvdev-certs}
LE_DIR=${LE_DIR:-/etc/letsencrypt}
export PATH=/google-cloud-sdk/bin:$PATH
echo "Start Initialize"

if [ ! -d $LE_DIR ] ; then
    mkdir -p $LE_DIR
fi

if [ ! -d $LE_DIR/google ] ; then
    mkdir -p $LE_DIR/google
fi
gcloud config set project $GCP_PROJECT_NAME

gsutil cp "gs://${GCS_BUCKET_NAME}/credentials/*.json" $LE_DIR/google/credentials.json
chmod 600 $LE_DIR/google/credentials.json

# Configure certbot

sed -i -e "s/%%%REPLACE_YOUR_EMAIL%%%/$CERTBOT_EMAIL/g" /certbot/config/certbot.ini
sed -i -e "s/%%%REPLACE_YOUR_DOMAIN%%%/$CERTBOT_DOMAIN/g" /certbot/config/certbot.ini

gsutil cp -r "gs://${GCS_BUCKET_NAME}/letsencrypt/*" $LE_DIR/

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
if [ ! -e $LE_DIR/archive/$DOMAIN_NAME ] ; then
    rm -rf $LE_DIR/live/$DOMAIN_NAME
    rmdir $LE_DIR/live
fi