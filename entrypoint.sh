#!/bin/sh
GCP_ACCOUNT=${GCP_ACCOUNT:-"cloud-storage-certs@myenv-dev.iam.gserviceaccount.com"}
GCP_PROJECT_NAME=${GCP_PROJECT_NAME:-"myenv-dev"}
GCS_BUCKET_NAME=${GCS_BUCKET_NAME:-"BUCKET_NAME"}
CERTBOT_EMAIL=${CERTBOT_EMAIL:-"user@example.com"}
CERTBOT_DOMAIN=${CERTBOT_DOMAIN:-"www.example.com"}
HTTP_SERVER_PORT=${PORT:-8080}
#HTTP_SERVER_RUNNING_TIMEOUT=${HTTP_SERVER_RUNNING_TIMEOUT:-20}
export PATH=/google-cloud-sdk/bin:$PATH

export LE_DIR=/etc/letsencrypt
export LE_BACKUP_DIRS="accounts csr keys renewal renrewal-hooks archive"
# CF_CREDENTIAL=$LE_DIR/cloudflare/cloudflare.ini
GOOG_CREDENTIAL=$LE_DIR/google/credentials.json

#PLUGIN_OPT="--dns-cloudflare --dns-cloudflare-credentials $CF_CREDENTIAL --dns-cloudflare-propagation-seconds 5"
PLUGIN_OPT="--dns-google --dns-google-credentials $GOOG_CREDENTIAL --dns-google-propagation-seconds 5"

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
            --max-log-backups 0 \
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
            --max-log-backups 0 \
            -d $CERTBOT_DOMAIN \
            -d "*.${CERTBOT_DOMAIN}" \
            $PLUGIN_OPT
    fi
fi

CERTBOT_PROC=$?

echo -n "Certbot has been "
if [ $CERTBOT_PROC -eq 0 ] ; then
    echo "successfully completed."
else
    echo "error occurred."
fi

if [ $CERTBOT_PROC -eq 0 ] ; then
    # Copy certificates
    #if [ $(ls $LE_DIR/live/$CERTBOT_DOMAIN/ | wc -) -en 0 ] ; then
        echo "Saving certificates..."
        GS_TARGET="gs://${GCS_BUCKET_NAME}/certs/"
        cd $LE_DIR/live/$CERTBOT_DOMAIN/
        gsutil -m cp -e -a public-read -r ./ gs://$GCS_BUCKET_NAME/certs/
        
        gsutil setmeta -h "Content-Type:application/x-pem-file" $GS_TARGET/$CERTBOT_DOMAIN/privkey.pem
        gsutil setmeta -h "Content-Type:application/x-pem-file" $GS_TARGET/$CERTBOT_DOMAIN/cert.pem
        gsutil setmeta -h "Content-Type:application/x-pem-file" $GS_TARGET/$CERTBOT_DOMAIN/chain.pem
        gsutil setmeta -h "Content-Type:application/x-pem-file" $GS_TARGET/$CERTBOT_DOMAIN/fullchain.pem
    #fi

    echo "Saving Let's Encrypt configurations..."
    cd $LE_DIR/
    gsutil -m cp -r ./ gs://$GCS_BUCKET_NAME/  
fi


if [ $DEBUG -eq 1 ] ; then
    # debug
    echo -n "[DEBUG] If you want to finish, type \"end\": "
    while read READ_DEBUG
    do
        case $READ_DEBUG in
            "end" )
                break
                ;;
            * )
                echo -n "[DEBUG] If you want to finish, type \"end\": "
        esac
    done
fi

#if [ $CERTBOT_PROC -eq 0 ]; then
    echo "Start HTTP server HTTP_SERVER_PORT=$HTTP_SERVER_PORT"
    #python /app/httpserver.py $PORT
    python -m http.server $PORT
#fi

