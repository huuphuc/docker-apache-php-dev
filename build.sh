#!/bin/bash
# Build, test and push huuphuc/apache-php-dev for one PHP version.
# Usage: ./build.sh [php-version]          e.g. ./build.sh 8.3
#        NO_PUSH=1 ./build.sh 8.3          build and test only
set -euo pipefail

cd "$(dirname "$0")"

IMAGE=huuphuc/apache-php-dev
LOCAL_IMAGE=apache-php-dev
DEFAULT_PHP_VERSION=$(sed -n 's/^ARG PHP_VERSION=//p' Dockerfile)
PHP_VERSION="${1:-${DEFAULT_PHP_VERSION}}"

if [[ ! "${PHP_VERSION}" =~ ^[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid PHP version '${PHP_VERSION}'. Usage: $0 [php-version], e.g. $0 8.3 (default: ${DEFAULT_PHP_VERSION})" >&2
  exit 1
fi

TAGS=("${PHP_VERSION}" "${PHP_VERSION}-$(date +%Y%m%d)")
if [[ "${PHP_VERSION}" == "${DEFAULT_PHP_VERSION}" ]]; then
  TAGS+=(latest)
fi

echo "Building PHP ${PHP_VERSION}..."
docker build -t "${LOCAL_IMAGE}" --build-arg PHP_VERSION="${PHP_VERSION}" .

echo "Testing PHP ${PHP_VERSION}..."
./test.sh "${PHP_VERSION}"

if [[ "${NO_PUSH:-0}" == "1" ]]; then
  echo "Built and tested ${LOCAL_IMAGE} (PHP ${PHP_VERSION}). NO_PUSH=1, nothing was pushed."
  exit 0
fi

for tag in "${TAGS[@]}"; do
  echo "Pushing ${IMAGE}:${tag}..."
  docker tag "${LOCAL_IMAGE}" "${IMAGE}:${tag}"
  docker push "${IMAGE}:${tag}"
done

echo "Done. Pushed: ${TAGS[*]/#/${IMAGE}:}"
