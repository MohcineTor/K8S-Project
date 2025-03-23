#!/bin/bash

# Variables
DOCKER_USERNAME=""
DOCKER_PASSWORD=""
IMAGE_NAME="my-python-api"
IMAGE_TAG="1.1.0"
DOCKERHUB_REPO="$DOCKER_USERNAME/$IMAGE_NAME"


docker build -t "$IMAGE_NAME:$IMAGE_TAG" .

# Log in to Docker Hub
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

# Tag the image
docker tag "$IMAGE_NAME:$IMAGE_TAG" "$DOCKERHUB_REPO:$IMAGE_TAG"

# Push the image to Docker Hub
docker push "$DOCKERHUB_REPO:$IMAGE_TAG"

echo "Image pushed successfully to Docker Hub: $DOCKERHUB_REPO:$IMAGE_TAG"


# docker run -d -p 8080:8080 --name my-python-api my-python-api:latest