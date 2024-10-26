#!/usr/bin/env bash

IMAGE_NAME="osrf/space-ros"
TAG="nav2"

VCS_REF=$(git rev-parse --short HEAD)

# Exit script with failure if build fails
set -eo pipefail

function usage {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h, --help"
    echo "  --base"
    echo "  --dev"
    echo ""
    echo "Example:"
    echo "  $0 -b osrf/space-ros:latest"
}

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    usage
    exit 0
fi

BASE_IMAGE="osrf/space-ros:latest"
# If dev variant is specified, update the base image to use the dev variant
if [ "$1" == "--dev" ]; then
    BASE_IMAGE="osrf/space-ros:dev"
    TAG="nav2-dev"
fi

echo ""
echo "##### Building Navigation2/Space ROS Docker Image #####"
echo ""

docker build -t $IMAGE_NAME:$TAG \
    --build-arg VCS_REF="$VCS_REF" \
    --build-arg BASE_IMAGE="$BASE_IMAGE" \
    .

echo ""
echo "##### Done! #####"
