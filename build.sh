#!/bin/bash
# Usage: ./build.sh <image_tag>
IMAGE_TAG=$1

if [ -z "$IMAGE_TAG" ]; then
    echo "Error: Image tag not provided."
    exit 1
fi

echo "Building Docker image with tag: $IMAGE_TAG"
docker build -t $IMAGE_TAG .
if [ $? -ne 0 ]; then
    echo "Error: Docker build failed."
    exit 1
fi

echo "Docker build successful: $IMAGE_TAG"

