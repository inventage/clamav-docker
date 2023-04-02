#!/usr/bin/env bash
set -euxo pipefail

# Directories
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
REPO_DIR=$SCRIPT_DIR
BUILD_DIR=build

# Build settings
PARAM_IMAGE_NAME="clamav-debian"
PARAM_NAMESPACE="inventage"
PARAM_FULL_VERSION="0.105.2"
PARAM_FEATURE_VERSION="0.105"
PARAM_DOCKER_REGISTRY=""
PARAM_DOCKER_BUILDX_BUILDER="clamav"
PARAM_CLAMAV_SRC_REPOSITORY="https://github.com/Cisco-Talos/clamav.git"

trap 'cleanup' EXIT

function cleanup() {
  cd "$REPO_DIR"
  rm -f build.tar
  docker buildx uninstall
}

pushd "$REPO_DIR"

# Checkout clamav source
rm -rf $BUILD_DIR
git clone --depth=1 $PARAM_CLAMAV_SRC_REPOSITORY $BUILD_DIR

# Copy docker files
cp -r clamav/$PARAM_FEATURE_VERSION/debian/Dockerfile clamav/$PARAM_FEATURE_VERSION/debian/scripts $BUILD_DIR

# Configure docker buildx
docker buildx install
if ! docker buildx inspect $PARAM_DOCKER_BUILDX_BUILDER; then
  docker buildx create --name $PARAM_DOCKER_BUILDX_BUILDER --use --bootstrap
else
  docker buildx use $PARAM_DOCKER_BUILDX_BUILDER
fi

# Make sure we have the latest base image.
docker pull debian:11-slim

# Build docker images
pushd $BUILD_DIR
docker buildx build --platform linux/amd64,linux/arm64 --tag "${PARAM_IMAGE_NAME}:${PARAM_FULL_VERSION}_base" .
docker image tag "${PARAM_IMAGE_NAME}:${PARAM_FULL_VERSION}-${PARAM_REVISION}_base" "${PARAM_DOCKER_REGISTRY}/${PARAM_NAMESPACE}/${PARAM_IMAGE_NAME}:${PARAM_FULL_VERSION}-${PARAM_REVISION}_base"
docker image push "${PARAM_DOCKER_REGISTRY}/${PARAM_NAMESPACE}/${PARAM_IMAGE_NAME}:${PARAM_FULL_VERSION}-${PARAM_REVISION}_base"

pushd -0 && dirs -c
