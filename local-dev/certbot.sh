#!/bin/sh

docker run -it --rm \
    -v "/Users/anon/Workspace/repos/myenv.dev-certbot/artifacts:/etc/letsencrypt" \
    -v "/Users/anon/Workspace/repos/myenv.dev-certbot/config/cloudflare:/etc/cloudflare" \
    --dns=8.8.8.8 \
    certbot/dns-cloudflare:latest certonly \
    --agree-tos \
    -m "local@myenv.dev" \
    -d 'local.myenv.dev' \
    -d '*.local.myenv.dev' \
    --dns-cloudflare \
    --dns-cloudflare-credentials /etc/cloudflare/cloudflare.ini \
    --dns-cloudflare-propagation-seconds 10
