#!/bin/bash

# Set your project
export PROJECT_ID=$(gcloud config get-value project)

# Set default region
DEFAULT_REGION="us-central1"

# Prompt user to enter region with default value
echo "Enter your preferred region (default: $DEFAULT_REGION):"
read REGION

# Use default if no input provided
REGION=${REGION:-$DEFAULT_REGION}

echo "Using region: $REGION"

# Set the region in gcloud config
gcloud config set functions/region $REGION
gcloud config set compute/region $REGION

# Clone the repository and navigate to the function
git clone https://github.com/GoogleCloudPlatform/nodejs-docs-samples.git
cd nodejs-docs-samples/functions/v2/helloPubSub/

# Deploy the function
gcloud functions deploy cf-demo \
--gen2 \
--runtime=nodejs20 \
--region=$REGION \
--source=. \
--entry-point=helloPubSub \
--trigger-topic=cf_topic \
--quiet
