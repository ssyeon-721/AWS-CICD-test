#!/bin/bash
set -e

AWS_REGION=ap-northeast-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
IMAGE_REPO=cicd-test-ecr

echo ">>> Fetching latest image tag..."
IMG_TAG=$(aws ecr describe-images \
  --repository-name $IMAGE_REPO \
  --region $AWS_REGION \
  --query 'sort_by(imageDetails,& imagePushedAt)[-1].imageTags[0]' \
  --output text)

echo ">>> Pulling latest image from ECR: $IMG_TAG"
docker pull $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_REPO:$IMG_TAG

echo ">>> Stopping old container (if exists)"
docker stop cicd-test-ecr || true

echo ">>> Running new container"
docker run -d --rm --name cicd-test-ecr -p 80:80 $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_REPO:$IMG_TAG
