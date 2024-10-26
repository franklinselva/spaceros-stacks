#!/usr/bin/env bash

IMAGE_NAME="osrf/space-ros"
TAG="nav2"

VCS_REF=$(git rev-parse --short HEAD)

# Exit script with failure if build fails
set -eo pipefail

echo ""
echo "##### Building Navigation2/Space ROS Docker Image #####"
echo ""

docker build -t $IMAGE_NAME:$TAG \
    --build-arg VCS_REF="$VCS_REF" \
    .

echo ""
echo "##### Done! #####"
