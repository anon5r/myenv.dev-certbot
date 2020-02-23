#!/bin/sh
DOMAIN_NAME=${DOMAIN_NAME:-local.myenv.dev}
GCS_BUCKET_NAME=${GCS_BUCKET_NAME:-myenvdev-certificates}
GCSMP=/mnt/gcs/$GCS_BUCKET_NAME
LE_DIR=/etc/letsencrypt
echo "Start Initialize"
mkdir -p $GCSMP

# if [ ! -e /etc/letsencrypt/archive ] ; then
#     mkdir -p /etc/letsencrypt/archive
# fi
# if [ ! -e /etc/letsencrypt/archive/$DOMAIN_NAME ] ; then
#     ln -sfn /mnt/gcs/$GCS_BUCKET_NAME /etc/letsencrypt/archive/$DOMAIN_NAME
# fi

GOOGLE_APPLICATION_CREDENTIALS=/opt/etc/gcs.json /usr/sbin/gcsfuse $GCS_BUCKET_NAME $GCSMP

if [ -e $GCSMP/letsencrypt/accounts ] ; then
    cp -r $GCSMP/letsencrypt/accounts $LE_DIR/
fi
if [ -e $GCSMP/letsencrypt/csr ] ; then
    cp -r $GCSMP/letsencrypt/csr $LE_DIR/
fi
if [ -e $GCSMP/letsencrypt/keys ] ; then
    cp -r $GCSMP/letsencrypt/keys $LE_DIR/
fi
if [ -e $GCSMP/letsencrypt/renewal ] ; then
    cp -r $GCSMP/letsencrypt/renewal $LE_DIR/
fi
if [ -e $GCSMP/letsencrypt/renewal ] ; then
    cp -r $GCSMP/letsencrypt/renewal $LE_DIR/
fi
if [ -e $GCSMP/letsencrypt/archive ] ; then
    cp -r $GCSMP/letsencrypt/archive $LE_DIR/
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
fi
