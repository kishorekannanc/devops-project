#!/bin/bash
# Usage: ./deploy.sh <image_tag> <docker_username> <docker_password>
IMAGE_TAG=$1
DOCKER_USERNAME=$2
DOCKER_PASSWORD=$3

if [ -z "$IMAGE_TAG" ] || [ -z "$DOCKER_USERNAME" ] || [ -z "$DOCKER_PASSWORD" ]; then
    echo "Error: Missing arguments."
    exit 1
fi

echo "Logging into Docker Hub..."
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
if [ $? -ne 0 ]; then
    echo "Error: Docker login failed."
    exit 1
fi

echo "Pushing Docker image: $IMAGE_TAG"
docker push $IMAGE_TAG
if [ $? -ne 0 ]; then
    echo "Error: Docker push failed."
    exit 1
fi

echo "Docker image pushed successfully: $IMAGE_TAG"

