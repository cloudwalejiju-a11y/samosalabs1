#!/bin/bash

# Color Definitions
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

# Clear screen and display banner
clear

echo "${CYAN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}║    🚀 WELCOME TO DR. ABHISHEK'S CLOUD LAB 🚀  ║${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${WHITE_TEXT}📺 YouTube: ${BLUE_TEXT}https://www.youtube.com/@cloudwalejijaji${RESET_FORMAT}"
echo "${WHITE_TEXT}⭐ Subscribe for more Cloud & DevOps Tutorials! ⭐${RESET_FORMAT}"
echo

# Get user input
read -p "${CYAN_TEXT}${BOLD_TEXT}🌍 Enter The Region (e.g., us-central1): ${RESET_FORMAT}" LOCATION
export LOCATION
export MSG_BODY='Hello from Cloud Wale Jija Ji Tutorials!'

# Step 1: Create Pub/Sub Topic
echo
echo "${BLUE_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}  🎯 STEP 1: Creating Pub/Sub Topic ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
gcloud pubsub topics create cloud-pubsub-topic

# Step 2: Create Subscription
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}  📩 STEP 2: Creating Subscription ${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
gcloud pubsub subscriptions create cloud-pubsub-subscription --topic=cloud-pubsub-topic

# Step 3: Enable Cloud Scheduler
echo
echo "${GREEN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}  ⏱️  STEP 3: Enabling Cloud Scheduler ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
gcloud services enable cloudscheduler.googleapis.com

# Step 4: Create Scheduler Job
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}  🔄 STEP 4: Creating Scheduled Job (Every Minute) ${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
gcloud scheduler jobs create pubsub cron-scheduler-job \
  --location=$LOCATION \
  --schedule="* * * * *" \
  --topic=cloud-pubsub-topic \
  --message-body="$MSG_BODY"

# Step 5: Verify Messages
echo
echo "${CYAN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}  ✅ STEP 5: Verifying Message Delivery ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
echo "${WHITE_TEXT}Waiting 10 seconds for first message to arrive...${RESET_FORMAT}"
sleep 10
gcloud pubsub subscriptions pull cloud-pubsub-subscription --limit 5

# Completion Message
echo
echo "${GREEN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}║          🎉 LAB COMPLETED SUCCESSFULLY! 🎉  ║${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${WHITE_TEXT}${BOLD_TEXT}Thank you for using Cloud Wale Jija Ji's Cloud Tutorial!${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}Don't forget to subscribe: ${BLUE_TEXT}https://www.youtube.com/@cloudwalejijaji${RESET_FORMAT}"
echo
