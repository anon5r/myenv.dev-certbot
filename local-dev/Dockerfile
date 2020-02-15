FROM certbot/dns-cloudflare:latest

ADD ../config/certbot.ini /certbot/config/certbot.ini
ADD ../config/cloudflare.ini /etc/letsencrypt/cloudflare/cloudflare.ini

CMD [ "--dns-cloudflare", "--dns-cloud-credentials", "/etc/cloudflare/cloudflare.ini", "--dns-cloudflare-propagation-seconds", "50" ]

