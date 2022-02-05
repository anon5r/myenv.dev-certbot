#!/bin/sh
PROJECT="your-project-id"
CURDIR=$(pwd)
cd $(dirname $0)/../
gcloud builds submit \
    --project $PROJECT \
    --config cloudbuild.yml

cd $CURDIR
