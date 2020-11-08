# What is this

Automated update SSL certificates with Certbot for Let's Encrypt

Use Cloud Run and Cloud Schedular, which run on Google Cloud Platform, to periodically run certbot to renew your domain's certificate.

# How to use

## What to prepare

- [Google Cloud Platform](https://cloud.google.com)
- [Cloud Run](https://cloud.google.com/run)
- [Cloud Storage](https://cloud.google.com/storage)
- [Cloud DNS](https://cloud.google.com/dns)
  - (or, [Cloudflare](https://cloudflare.com) DNS)
- [Cloud Scheduler](https://cloud.google.com/scheduler)
- [Container Registry](https://cloud.google.com/container-registry)
- [Cloud Build](https://cloud.google.com/cloud-build)

## How to build

Build container image using with Cloud Build.

Then push image to Container Registry.

```
sh ./cloud-build.sh
```

## How to deploy

Deploy image to Cloud Run

```
sh ./cloud-run.sh
```
