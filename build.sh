#!/bin/bash

VERSION="2.0.0"

docker build -t apache-php-dev . && \
docker tag php-dev huuphuc/apache-php-dev:${VERSION} && \
docker tag php-dev huuphuc/apache-php-dev:latest && \
docker push huuphuc/apache-php-dev:${VERSION} && \
docker push huuphuc/apache-php-dev:latest

