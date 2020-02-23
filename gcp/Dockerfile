FROM certbot/dns-cloudflare:latest

LABEL "dev.myenv.vendor"="ACME"
LABEL version="1.1"
LABEL description="Auto update/re-create certification"


ENV GCS_BUCKET_NAME myenvdev-certificates
ENV CERTBOT_EMAIL local@myenv.dev
ENV CERTBOT_DOMAIN local.myenv.dev
ENV HTTP_SERVER_PORT 8080
ENV HTTP_SERVER_RUNNING_TIMEOUT 30


ENV BUILD_DEPS \
    go \
    git \
    tar \
    wget \
    build-base \
    fuse-dev \
    curl-dev

ENV RUN_DEPS \
    fuse \
    curl

ENV GOPATH /tmp/go
ENV GO15VENDOREXPERIMENT 1

# Build GCSFUSE
RUN set -xe && \
    apk add --no-cache $BUILD_DEPS $RUN_DEPS && \
    go get -u github.com/googlecloudplatform/gcsfuse && \
    mv $GOPATH/bin/gcsfuse /usr/sbin && \
    apk del $BUILD_DEPS && \
    rm -rf /tmp/*

# Mount GCS with GCSFUSE
COPY ./gcs.json /opt/etc/gcs.json
ENV GOOGLE_APPLICATION_CREDENTIALS /opt/etc/gcs.json
#RUN gcsfuse myenvdev-certificates /mnt/gcs/${GCS_BUCKET_NAME}


# Write fstab
RUN set - ; { \
  echo "$GCS_BUCKET_NAME /mnt/gcs/${GCS_BUCKET_NAME} gcsfuse rw,noauto,user,key_file=/opt/etc/gcs.json" \
; } | tee /etc/fstab


# Startup script
COPY initialize.sh /opt/var/initializer
RUN touch /var/log/entrypoint.log && \
    touch /var/log/cron.log
RUN crond -b -l 0 -L /var/log/cron.log \
&& set - ; { \
    #echo 'PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin' && \
    #echo 'SHELL=/bin/bash' && \
    echo '@reboot /bin/bash /opt/var/initializer' \
#; } | tee /etc/crontabs/root
; } >> /etc/crontabs/root

COPY ./config/certbot.ini /certbot/config/certbot.ini
COPY ./config/cloudflare.ini /etc/letsencrypt/cloudflare/cloudflare.ini
COPY ./entrypoint /usr/bin/entrypoint
RUN chmod 604 /etc/letsencrypt/cloudflare/cloudflare.ini
RUN chmod a+x /usr/bin/entrypoint

# Change entrypoint from original image certbot/certbot
# ENTRYPOINT [ "certbot" ]
ENTRYPOINT [ "entrypoint" ]
