FROM certbot/dns-cloudflare:latest

LABEL "dev.myenv.vendor"="ACME"
LABEL version="1.0"
LABEL description="Auto update/re-create certification"


ENV GCS_BUCKET_NAME myenvdev-certificates

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
#RUN gcsfuse myenvdev-certificates /opt/certs


# Write fstab
RUN set - ; { \
  echo "$GCS_BUCKET_NAME /etc/letsencrypt/archives/local.myenv.dev gcsfuse rw,noauto,user,key_file=/opt/etc/gcs.json" \
; } | tee /etc/fstab


# Startup script
COPY initialize.sh /opt/var/initializer
RUN set - ; { \
    echo 'PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin' \
    echo 'SHELL=/bin/bash' \
    echo '@reboot /bin/sh /opt/var/initializer' >> /etc/crontab \
; } | tee /etc/crontab
RUN touch /var/log/entrypoint.log && \
    touch /var/log/monitor.log && \
    touch /var/log/cron.log && \
    touch /var/log/awslogs.log && \
    chown -R robuser /var/log

COPY ./config/certbot.ini /certbot/config/certbot.ini
COPY ./config/cloudflare.ini /etc/letsencrypt/cloudflare/cloudflare.ini
COPY ./entrypoint /opt/certbot/entrypoint
RUN [ "chmod" "a+x" "/opt/certbot/entrypoint" ]

ENTRYPOINT [ "entrypoint" ]
CMD [ "--agree-tos" "-n" "--dns-cloudflare", "--dns-cloudflare-credentials", "/etc/letsencrypt/cloudflare/cloudflare.ini", "--dns-cloudflare-propagation-seconds", "20" ]

