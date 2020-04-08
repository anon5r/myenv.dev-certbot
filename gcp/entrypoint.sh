#!/bin/sh
GCP_ACCOUNT=${GCP_ACCOUNT:-"cloud-storage-certs@myenv-dev.iam.gserviceaccount.com"}
GCP_PROJECT_NAME=${GCP_PROJECT_NAME:-"myenv-dev"}
GCS_BUCKET_NAME=${GCS_BUCKET_NAME:-"BUCKET_NAME"}
CERTBOT_EMAIL=${CERTBOT_EMAIL:-"user@example.com"}
CERTBOT_DOMAIN=${CERTBOT_DOMAIN:-"www.example.com"}
HTTP_SERVER_PORT=${PORT:-8080}
#HTTP_SERVER_RUNNING_TIMEOUT=${HTTP_SERVER_RUNNING_TIMEOUT:-20}
export PATH=/google-cloud-sdk/bin:$PATH

LE_DIR=/etc/letsencrypt
CF_CREDENTIAL=/etc/letsencrypt/cloudflare/cloudflare.ini

PLUGIN_OPT="--dns-cloudflare --dns-cloudflare-credentials $CF_CREDENTIAL --dns-cloudflare-propagation-seconds 5"

DEBUG=0

if [ $# -ne 0 ] && [ $1 = "debug" ] ; then
    DEBUG=1
fi



#crond -b -l 0 -L /var/log/cron.log
/bin/sh /app/initializer

# if [ $DEBUG -eq 1 ] ; then
#     echo -n "[DEBUG] If you want continue, type \"go\": "
#     while read READ_DEBUG
#     do
#         case $READ_DEBUG in
#             "go" )
#                 break
#                 ;;
#             * )
#                 echo -n "[DEBUG] If you want tcontinue, type \"go\": "
#         esac
#     done
# fi


if [ $DEBUG -eq 1 ] ; then
    if [ -e $LE_DIR/archives/$CERTBOT_DOMAIN ] ; then
        certbot \
            renew \
            --dry-run \
            $PLUGIN_OPT
    else
        certbot \
            certonly \
            --staging \
            --agree-tos \
            --register-unsafely-without-email \
            --email ${CERTBOT_EMAIL} \
            --preferred-challenges dns-01 \
            --noninteractive \
            -d $CERTBOT_DOMAIN \
            -d "*.${CERTBOT_DOMAIN}" \
            $PLUGIN_OPT
    fi
else
    if [ $# -ne 0 ]; then
        certbot $@

    elif [ -e $LE_DIR/archives/$CERTBOT_DOMAIN ] ; then
        certbot \
            renew \
            $PLUGIN_OPT
    else 
        certbot \
            certonly \
            --agree-tos \
            --register-unsafely-without-email \
            --email ${CERTBOT_EMAIL} \
            --preferred-challenges dns-01 \
            --noninteractive \
            -d $CERTBOT_DOMAIN \
            -d "*.${CERTBOT_DOMAIN}" \
            $PLUGIN_OPT
    fi
fi

if [ $? -eq 0 ] ; then
    # Copy certificates
    echo "Saving certificates..."

    #cp -rfL $LE_DIR/live/$CERTBOT_DOMAIN $GCSMP/certs/
    gsutil cp -r $LE_DIR/certs gs://$GCS_BUCKET_NAME/letsencrypt/

    echo "Saving Let's Encrypt configurations..."
    if [ -e $LE_DIR/accounts ] ; then
        gsutil cp -r $LE_DIR/accounts gs://$GCS_BUCKET_NAME/letsencrypt/
    fi
    if [ -e $LE_DIR/csr ] ; then
        gsutil cp -r $LE_DIR/csr gs://$GCS_BUCKET_NAME/letsencrypt/
    fi
    if [ -e $LE_DIR/keys ] ; then
        gsutil cp -r $LE_DIR/keys gs://$GCS_BUCKET_NAME/letsencrypt/
    fi
    if [ -e $LE_DIR/renewal ] ; then
        cp -rfL $LE_DIR/renewal $GCSMP/letsencrypt/
        gsutil cp -r $LE_DIR/renewal gs://$GCS_BUCKET_NAME/letsencrypt/
    fi
    if [ -e $LE_DIR/renewal-hooks ] ; then
        cp -rfL $LE_DIR/renewal-hooks $GCSMP/letsencrypt/
        gsutil cp -r $LE_DIR/renewa;-hooks gs://$GCS_BUCKET_NAME/letsencrypt/
    fi
    if [ -e $LE_DIR/archive ] ; then
        gsutil cp -r $LE_DIR/archive gs://$GCS_BUCKET_NAME/letsencrypt/
    fi
fi


# if [ $DEBUG -eq 1 ] ; then
#     # debug
#     echo -n "[DEBUG] If you want to finish, type \"end\": "
#     while read READ_DEBUG
#     do
#         case $READ_DEBUG in
#             "end" )
#                 break
#                 ;;
#             * )
#                 echo -n "[DEBUG] If you want to finish, type \"end\": "
#         esac
#     done
# fi

#echo "Start HTTP server HTTP_SERVER_PORT=$HTTP_SERVER_PORT, will terminate later $HTTP_SERVER_RUNNING_TIMEOUT sec."
#timeout $HTTP_SERVER_RUNNING_TIMEOUT python -m http.server $HTTP_SERVER_PORT &
#python -m http.server $HTTP_SERVER_PORT &
echo "Start HTTP server HTTP_SERVER_PORT=$HTTP_SERVER_PORT"
python /app/httpserver.py $PORT

