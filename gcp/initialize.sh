#!/bin/sh
DOMAIN_NAME=${DOMAIN_NAME:-local.myenv.dev}
mkdir -p /mnt/gcs/$GCS_BUCKET_NAME
if [ ! -e /etc/letsencrypt/archives ] ; then
    mkdir -p /etc/letsencrypt/archives
fi
if [ ! -e /etc/letsencrypt/archives/$DOMAIN_NAME ] ; then
    ln -sfn /mnt/gcs/$GCS_BUCKET_NAME /etc/letsencrypt/archives/$DOMAIN_NAME
fi

/usr/sbin/gcsfuse $GCS_BUCKET_NAME /etc/letsencrypt/archive/$DOMAIN_NAME $GOOGLE_APPLICATION_CREDENTIALS
