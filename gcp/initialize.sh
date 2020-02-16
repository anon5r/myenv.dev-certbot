#!/bin/sh
DOMAIN_NAME=${DOMAIN_NAME:-local.myenv.dev}
GCS_BUCKET_NAME=${GCS_BUCKET_NAME:-myenvdev-certificates}
mkdir -p /mnt/gcs/$GCS_BUCKET_NAME

# if [ ! -e /etc/letsencrypt/archive ] ; then
#     mkdir -p /etc/letsencrypt/archive
# fi
# if [ ! -e /etc/letsencrypt/archives/$DOMAIN_NAME ] ; then
#     ln -sfn /mnt/gcs/$GCS_BUCKET_NAME /etc/letsencrypt/archive/$DOMAIN_NAME
# fi

#GOOGLE_APPLICATION_CREDENTIALS=/opt/etc/gcs.json /usr/sbin/gcsfuse $GCS_BUCKET_NAME /mnt/gcs/$GCS_BUCKET_NAME
