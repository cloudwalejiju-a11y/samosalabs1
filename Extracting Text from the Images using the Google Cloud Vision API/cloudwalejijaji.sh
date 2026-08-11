#!/bin/bash

# ==============================================
#  Cloud OCR Translation Pipeline Setup
#  Created by Cloud Wale Jija Ji Cloud Tutorials
#  YouTube: https://www.youtube.com/@cloudwalejijaji
# ==============================================

# Text styles and colors
YELLOW=$(tput setaf 3)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
BOLD=$(tput bold)
RESET=$(tput sgr0)

# Header
echo
echo "${BLUE}${BOLD}╔══════════════════════════════════════════╗${RESET}"
echo "${BLUE}${BOLD}║   CLOUD OCR TRANSLATION PIPELINE SETUP   ║${RESET}"
echo "${BLUE}${BOLD}║        by Cloud Wale Jija Ji Cloud            ║${RESET}"
echo "${BLUE}${BOLD}╚══════════════════════════════════════════╝${RESET}"
echo

# Enable required services
echo "${YELLOW}${BOLD}🔧 Enabling required services...${RESET}"
gcloud services enable \
  artifactregistry.googleapis.com \
  cloudfunctions.googleapis.com \
  cloudbuild.googleapis.com \
  eventarc.googleapis.com \
  run.googleapis.com \
  logging.googleapis.com \
  pubsub.googleapis.com

# Set region and project variables
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects list --filter="project_id:$PROJECT_ID" --format='value(project_number)')

echo "${GREEN}✓ Project: $PROJECT_ID${RESET}"
echo "${GREEN}✓ Region: $REGION${RESET}"
echo

# Create storage buckets
echo "${YELLOW}${BOLD}📦 Creating storage buckets...${RESET}"
gcloud storage buckets create gs://$PROJECT_ID-image --location=$REGION
gcloud storage buckets create gs://$PROJECT_ID-result --location=$REGION

# Create Pub/Sub topics
echo "${YELLOW}${BOLD}📨 Creating Pub/Sub topics...${RESET}"
gcloud pubsub topics create ocr-translate
gcloud pubsub topics create ocr-result

# Configure IAM permissions
echo "${YELLOW}${BOLD}🔐 Configuring IAM permissions...${RESET}"
SERVICE_ACCOUNT=$(gcloud storage service-agent --project=$PROJECT_ID)
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$SERVICE_ACCOUNT \
  --role roles/pubsub.publisher

# Clone sample code
echo "${YELLOW}${BOLD}💻 Cloning sample code...${RESET}"
git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git
cd python-docs-samples/functions/ocr/app/

# Deploy OCR functions with retry logic
deploy_function() {
  local function_name=$1
  local entry_point=$2
  local trigger=$3
  local env_vars=$4
  local attempts=0
  local max_attempts=3

  while [ $attempts -lt $max_attempts ]; do
    echo "${YELLOW}Deploying $function_name (Attempt $((attempts+1)) of $max_attempts)...${RESET}"
    
    if gcloud functions deploy $function_name \
      --gen2 \
      --runtime python312 \
      --region=$REGION \
      --source=. \
      --entry-point $entry_point \
      $trigger \
      --service-account $PROJECT_NUMBER-compute@developer.gserviceaccount.com \
      --allow-unauthenticated \
      --set-env-vars "$env_vars"; then
      
      echo "${GREEN}✓ $function_name deployed successfully${RESET}"
      return 0
    else
      attempts=$((attempts+1))
      echo "${RED}✗ $function_name deployment failed${RESET}"
      if [ $attempts -lt $max_attempts ]; then
        echo "${YELLOW}Retrying in 10 seconds...${RESET}"
        sleep 10
      fi
    fi
  done
  
  echo "${RED}✗ Failed to deploy $function_name after $max_attempts attempts${RESET}"
  return 1
}

# Deploy all functions
echo "${YELLOW}${BOLD}🚀 Deploying Cloud Functions...${RESET}"

deploy_function "ocr-extract" "process_image" "--trigger-bucket gs://$PROJECT_ID-image" "GCP_PROJECT=$PROJECT_ID,TRANSLATE_TOPIC=ocr-translate,RESULT_TOPIC=ocr-result,TO_LANG=es,en,fr,ja"

deploy_function "ocr-translate" "translate_text" "--trigger-topic ocr-translate" "GCP_PROJECT=$PROJECT_ID,RESULT_TOPIC=ocr-result"

deploy_function "ocr-save" "save_result" "--trigger-topic ocr-result" "GCP_PROJECT=$PROJECT_ID,RESULT_BUCKET=$PROJECT_ID-result"

# Upload test image
echo "${YELLOW}${BOLD}🖼️ Uploading test image...${RESET}"
gsutil cp gs://cloud-training/OCBL307/menu.jpg .
gsutil cp menu.jpg gs://$PROJECT_ID-image/

# View logs
echo "${YELLOW}${BOLD}📝 Displaying function logs...${RESET}"
gcloud functions logs read --limit 100

# Final output
echo
echo "${BLUE}${BOLD}╔══════════════════════════════════════════╗${RESET}"
echo "${BLUE}${BOLD}║        SETUP COMPLETED SUCCESSFULLY     ║${RESET}"
echo "${BLUE}${BOLD}╚══════════════════════════════════════════╝${RESET}"
echo
echo "${BOLD}Next steps:${RESET}"
echo " • Check your Cloud Functions in the console:"
echo "   ${BLUE}https://console.cloud.google.com/functions?project=$PROJECT_ID${RESET}"
echo " • View your storage buckets:"
echo "   ${BLUE}https://console.cloud.google.com/storage/browser?project=$PROJECT_ID${RESET}"
echo
echo "${YELLOW}${BOLD}For more cloud tutorials, subscribe to:${RESET}"
echo "${BLUE}https://www.youtube.com/@cloudwalejijaji${RESET}"
echo
