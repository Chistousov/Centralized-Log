#!/bin/bash

# export HTTP_PROXY="http://proxyuser:proxypass@192.168.20.4:8822/"
# export HTTPS_PROXY="http://proxyuser:proxypass@192.168.20.4:8822/"
# export NO_PROXY="localhost,127.0.0.1"

REPO_IMAGE="chistousov"
PROJECT_NAME="fluentd"
VERSION="1.0.0"

docker pull fluentd:v1.16.0-debian-1.0

if ! [ -z "HTTP_PROXY" ] || ! [ -z "HTTPS_PROXY" ]; 
then
    docker build --no-cache -t $REPO_IMAGE/$PROJECT_NAME:$VERSION --build-arg HTTP_PROXY --build-arg HTTPS_PROXY --build-arg NO_PROXY .
else
    docker build --no-cache -t $REPO_IMAGE/$PROJECT_NAME:$VERSION .
fi

# publish in docker hub 
# docker login
# docker push $REPO_IMAGE/$PROJECT_NAME:$VERSION
# docker logout
# docker rmi $REPO_IMAGE/$PROJECT_NAME:$VERSION