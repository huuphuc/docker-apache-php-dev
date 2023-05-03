#!/bin/bash

PHP_VERSION=$1
if [ "${PHP_VERSION}" == "" ]; then
  PHP_VERSION=8.2
fi
VERSION="${PHP_VERSION}-v1.0"

echo "Building PHP-${PHP_VERSION}..."

docker build -t apache-php-dev . --build-arg PHP_VERSION=${PHP_VERSION} && \
docker tag apache-php-dev huuphuc/apache-php-dev:${VERSION} && \
docker tag apache-php-dev huuphuc/apache-php-dev:latest && \
docker push huuphuc/apache-php-dev:${VERSION} && \
docker push huuphuc/apache-php-dev:latest

