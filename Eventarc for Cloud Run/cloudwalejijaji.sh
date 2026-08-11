#!/bin/bash

# Bright Foreground Colors
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'

NO_COLOR=$'\033[0m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

# Welcome Message
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}       Welcome to Cloud Wale Jija Ji's Cloud Tutorial!         ${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${CYAN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}                  Starting the process...                ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo

# Region Selection
echo
echo "${YELLOW_TEXT}${BOLD_TEXT} Enter REGION:  ${RESET_FORMAT}"
read REGION
echo

if [ -z "$REGION" ]; then
    echo "${CYAN_TEXT}${BOLD_TEXT}Using Default region: us-central1 ${RESET_FORMAT}"
   export REGION=us-central1
else
  echo "${CYAN_TEXT}${BOLD_TEXT}Using region: $REGION ${RESET_FORMAT}"
    export REGION=$REGION
fi

# Initial Configuration
gcloud config set project $DEVSHELL_PROJECT_ID
gcloud config set run/region $REGION
gcloud config set run/platform managed
gcloud config set eventarc/location $REGION

# Project Number
echo
echo "${GREEN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬ Getting Project Number ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
echo
export PROJECT_NUMBER="$(gcloud projects list \
  --filter=$(gcloud config get-value project) \
  --format='value(PROJECT_NUMBER)')"

# IAM Policy Binding
echo
echo "${GREEN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬ Adding IAM Policy Binding ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
echo
gcloud projects add-iam-policy-binding $(gcloud config get-value project) \
  --member=serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com \
  --role='roles/eventarc.admin'

# Eventarc Providers
echo
echo "${GREEN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬ Listing Eventarc Providers ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
echo
gcloud eventarc providers list

echo
echo "${GREEN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬ Describing PubSub Provider ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
echo
gcloud eventarc providers describe pubsub.googleapis.com

# Cloud Run Deployment
export SERVICE_NAME=event-display
export IMAGE_NAME="gcr.io/cloudrun/hello"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬ Deploying Cloud Run Service ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
echo
gcloud run deploy ${SERVICE_NAME} \
  --image ${IMAGE_NAME} \
  --allow-unauthenticated \
  --max-instances=3

# PubSub Trigger Setup
echo
echo "${GREEN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬ Creating PubSub Trigger ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
echo
gcloud eventarc triggers create trigger-pubsub \
  --destination-run-service=${SERVICE_NAME} \
  --event-filters="type=google.cloud.pubsub.topic.v1.messagePublished"

export TOPIC_ID=$(gcloud eventarc triggers describe trigger-pubsub \
  --format='value(transport.pubsub.topic)')

echo "${CYAN_TEXT}Publishing Topic ID: ${TOPIC_ID}${RESET_FORMAT}"

# List Triggers
echo
echo "${GREEN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬ Listing Eventarc Triggers ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
echo
gcloud eventarc triggers list

# Publish Test Message
echo
echo "${GREEN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬ Publishing Test Message ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
echo
gcloud pubsub topics publish ${TOPIC_ID} --message="Hello there"

# Storage Bucket Setup
export BUCKET_NAME=$(gcloud config get-value project)-cr-bucket
echo
echo "${GREEN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬ Creating Storage Bucket ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
echo
gsutil mb -p $(gcloud config get-value project) \
  -l $(gcloud config get-value run/region) \
  gs://${BUCKET_NAME}/

# IAM Policy Update
echo
echo "${GREEN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬ Updating IAM Policy ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
echo
gcloud projects get-iam-policy $DEVSHELL_PROJECT_ID > policy.yaml

cat <<EOF >> policy.yaml
auditConfigs:
- auditLogConfigs:
  - logType: ADMIN_READ
  - logType: DATA_READ
  - logType: DATA_WRITE
  service: storage.googleapis.com
EOF

gcloud projects set-iam-policy $DEVSHELL_PROJECT_ID policy.yaml

# Test File Creation
echo
echo "${GREEN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬ Creating Test File ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
echo
echo "Hello World" > random.txt

echo
echo "${GREEN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬ Uploading Test File ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
echo
gsutil cp random.txt gs://${BUCKET_NAME}/random.txt

sleep 30

# Audit Log Setup
echo
echo "${GREEN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬ Setting Up Audit Log Trigger ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
echo
gcloud eventarc triggers create trigger-auditlog \
  --destination-run-service=${SERVICE_NAME} \
  --event-filters="type=google.cloud.audit.log.v1.written" \
  --event-filters="serviceName=storage.googleapis.com" \
  --event-filters="methodName=storage.objects.create" \
  --service-account=${PROJECT_NUMBER}-compute@developer.gserviceaccount.com

# Final Verification
echo
echo "${GREEN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬ Verifying Triggers ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
echo
gcloud eventarc triggers list

echo
echo "${GREEN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬ Triggering Final Test ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
echo
gsutil cp random.txt gs://${BUCKET_NAME}/random.txt

# Completion Message
echo
echo "${GREEN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}            Tutorial Completed Successfully!             ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${RED_TEXT}${BOLD_TEXT}🙏 Thank you for following Cloud Wale Jija Ji's Cloud Tutorial!${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}👍 Like, Share, and Subscribe for more GCP content:${RESET_FORMAT}"
echo "${BLUE_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@cloudwalejijaji${RESET_FORMAT}"
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}🚀 Happy Cloud Computing!${RESET_FORMAT}"
