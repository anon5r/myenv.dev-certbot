#!/bin/sh
GCP_SERVICE_ACCOUNT=${GCP_SERVICE_ACCOUNT:-"cloud-storage-certs@myenv-dev.iam.gserviceaccount.com"}
GCP_PROJECT_NAME=${GCP_PROJECT_NAME:-"myenv-dev"}
DOMAIN_NAME=${DOMAIN_NAME:-local.myenv.dev}
GCS_BUCKET_NAME=${GCS_BUCKET_NAME:-myenvdev-certificates}
LE_DIR=/etc/letsencrypt
export PATH=/google-cloud-sdk/bin:$PATH
echo "Start Initialize"

# Configure certbot
if [ ! -d /etc/letsencrypt/cloudflare ] ; then
    mkdir -p /etc/letsencrypt/cloudflare &&
fi
set - ; { \
    echo '# Cloudflare API credentials used by Certbot' && \
    echo "dns_cloudflare_email = $DNS_CLOUDFLARE_EMAIL" \ &&
    echo "dns_cloudflare_api_key = $DNS_CLOUDFLARE_API_KEY" \
; } | tee /etc/letsencrypt/cloudflare/cloudflare.ini
chmod 600 /etc/letsencrypt/cloudflare/cloudflare.ini

sed -i -e "s/%%%REPLACE_YOUR_EMAIL%%%/$CERTBOT_EMAIL/g" /certbot/config/certbot.ini
sed -i -e "s/%%%REPLACE_YOUR_DOMAIN%%%/$CERTBOT_DOMAIN/g" /certbot/config/certbot.ini



#gcloud config set account $GCP_SERVICE_ACCOUNT
#gcloud auth activate-service-account $GCP_SERVICE_ACCOUNT --key-file /app/gcs.json
gcloud config set project $GCP_PROJECT_NAME


if [ ! -d $LE_DIR ] ; then
    mkdir -p $LE_DIR
fi
gsutil cp -r gs://$GCS_BUCKET_NAME/letsencrypt/ $LE_DIR/

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