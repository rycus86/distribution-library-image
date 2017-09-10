#!/bin/bash

set -e

if [ $# -eq 0 ] ; then
	echo "Usage: ./update.sh <docker/distribution tag or branch>"
	exit
fi

VERSION=$1
GOOS=$2
GOARCH=$3

echo "Fetching and building distribution $VERSION... ($GOOS/$GOARCH)"

git clone -b $VERSION https://github.com/docker/distribution.git build
docker build -t distribution-builder --build-arg GOOS=$GOOS --build-arg GOARCH=$GOARCH build

# Create a dummy distribution-build container so we can run a cp against it.
ID=$(docker create distribution-builder)

# Update the local binary and config.
docker cp $ID:/go/bin/registry registry
docker cp $ID:/go/src/github.com/docker/distribution/cmd/registry/config-example.yml registry

# Cleanup.
docker rm -f $ID
docker rmi distribution-builder

echo "Done."
