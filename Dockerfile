FROM certbot/dns-cloudflare:latest

LABEL "dev.myenv.vendor"="ACME"
LABEL version="1.1"
LABEL description="Auto update/re-create certification"


ENV GCS_BUCKET_NAME YOURBUCKET_NAME
ENV CERTBOT_EMAIL YOUR.EMAIL\@EXAMPLE.COM
ENV CERTBOT_DOMAIN YOUR-DOMAIN.EXAMPLE.COM
ENV HTTP_SERVER_RUNNING_TIMEOUT 180

ENV GCP_ACCOUNT=YOUR_GCP_ACCOUNT
#ENV GCP_PROJECT_NAME YOUR_PROJECT
#ENV DOMAIN_NAME www.example.com
ENV DNS_CLOUDFLARE_EMAIL YOUR.EMAIL\@.EXAMPLE.COM
ENV DNS_CLOUDFLARE_API_KEY CLOUDFLARE_API_KEY


EXPOSE 80 8080

ENV BUILD_DEPS \
    go \
    git \
    tar \
    wget \
    build-base \
    fuse-dev \
    curl-dev

ENV RUN_DEPS \
#    fuse \
    curl \
    wget \
    python3 \
    #py3-crcmod \
    libc6-compat \
    openssh-client \
    gnupg

ENV GOPATH /tmp/go
ENV GO15VENDOREXPERIMENT 1

# Build GCSFUSE
RUN set -xe && \
    apk add --no-cache $BUILD_DEPS $RUN_DEPS && \
    apk del $BUILD_DEPS && \
    rm -rf /tmp/*

COPY --from=google/cloud-sdk:alpine /google-cloud-sdk /google-cloud-sdk
RUN PATH=/google-cloud-sdk/bin:$PATH \
    && gcloud config set disable_usage_reporting true \
    && gcloud config set disable_file_logging true \
    && gcloud config set disable_color true \
    && gcloud config set disable_prompts true \
    && gcloud config set pass_credentials_to_gsutil true \
    && gcloud config set component_manager/disable_update_check true \
    && gcloud config set metrics/environment github_docker_image \
    && gcloud --version


# Startup script
RUN mkdir -p /app
COPY initialize.sh /app/initializer
#RUN touch /var/log/entrypoint.log && \
#    touch /var/log/cron.log
#RUN crond -b -l 0 -L /var/log/cron.log \
#&& set - ; { \
#    #echo 'PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin' && \
#    #echo 'SHELL=/bin/bash' && \
#    echo '@reboot /bin/bash /app/initializer' \
##; } | tee /etc/crontabs/root
#; } >> /etc/crontabs/root
RUN mkdir -p /etc/letsencrypt/cloudflare && \
set - ; { \
    echo '# Cloudflare API credentials used by Certbot' && \
    echo "dns_cloudflare_email = $DNS_CLOUDFLARE_EMAIL" \
    echo "dns_cloudflare_api_key = $DNS_CLOUDFLARE_API_KEY" \
; } | tee /etc/letsencrypt/cloudflare/cloudflare.ini


COPY ./config/certbot.ini /certbot/config/certbot.ini
RUN sed -i -e "s/%%%REPLACE_YOUR_EMAIL%%%/$CERTBOT_EMAIL/g" /certbot/config/certbot.ini && \
sed -i -e "s/%%%REPLACE_YOUR_DOMAIN%%%/$CERTBOT_DOMAIN/g" /certbot/config/certbot.ini
COPY ./gcs_tokens.json /app/gcs.json
#COPY ./httpserver.py /app/httpserver.py
COPY ./entrypoint.sh /app/entrypoint
COPY ./index.html /app/index.html
RUN chmod 600 /etc/letsencrypt/cloudflare/cloudflare.ini
RUN chmod a+x /app/entrypoint
RUN mkdir -p /var/log/letsencrypt && chmod uo+rwX /var/log/letsencrypt

WORKDIR  /app
# Change entrypoint from original image certbot/certbot
# ENTRYPOINT [ "certbot" ]
ENTRYPOINT [ "/app/entrypoint" ]
