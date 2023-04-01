#!/usr/bin/env bash
set -euxo pipefail

# Directories
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
REPO_DIR=$SCRIPT_DIR
BUILD_DIR=build

# Build settings
#PARAMS_IMAGE_NAME="clamav-debian"
#PARAMS_NAMESPACE="inventage"
#PARAMS_FULL_VERSION="0.105.2"
PARAMS_FEATURE_VERSION="0.105"

# Settings
CLAMAV_SRC_REPOSITORY="https://github.com/Cisco-Talos/clamav.git"

trap 'cleanup' EXIT

function cleanup() {
  cd "$REPO_DIR"
  rm -f build.tar
}

pushd "$REPO_DIR"

# Checkout clamav source
rm -rf $BUILD_DIR
git clone --depth=1 $CLAMAV_SRC_REPOSITORY $BUILD_DIR

# Copy docker files
cp -r clamav-docker/clamav/$PARAMS_FEATURE_VERSION/debian/Dockerfile clamav-docker/clamav/$PARAMS_FEATURE_VERSION/debian/scripts $BUILD_DIR

pushd -0 && dirs -c
