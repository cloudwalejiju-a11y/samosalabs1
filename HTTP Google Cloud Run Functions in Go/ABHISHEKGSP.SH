#!/bin/bash

# Define color variables
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

# Clear the screen
clear

# Print the welcome message with improved design
echo "${BLUE_TEXT}${BOLD_TEXT}╔══════════════════════════════════════════╗${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}║          WELCOME TO DR ABHISHEK CLOUD TUTORIAL...         ║${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}╚══════════════════════════════════════════╝${RESET_FORMAT}"
echo

display_step() {
    echo "${CYAN_TEXT}${BOLD_TEXT}╔═▶ STEP $1: $2${RESET_FORMAT}"
    echo "${WHITE_TEXT}$3${RESET_FORMAT}"
    echo
}

# Step 1: Authentication
display_step 1 "Authentication" "Verifying Google Cloud credentials..."
gcloud auth list

# Step 2: Enable Services
display_step 2 "Service Enablement" "Activating required Google Cloud APIs..."
echo "${YELLOW_TEXT}Enabling Cloud Run and Cloud Functions APIs...${RESET_FORMAT}"
gcloud services enable run.googleapis.com cloudfunctions.googleapis.com

# Step 3: Set Zone
display_step 3 "Zone Configuration" "Setting default compute zone..."
export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
gcloud config set compute/zone "$ZONE"
echo "${GREEN_TEXT}✓ Default zone set to: $ZONE${RESET_FORMAT}"

# Step 4: Set Region
display_step 4 "Region Configuration" "Setting default compute region..."
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")
gcloud config set compute/region "$REGION"
echo "${GREEN_TEXT}✓ Default region set to: $REGION${RESET_FORMAT}"

# Step 5: Download Code
display_step 5 "Code Download" "Fetching sample code from GitHub..."
echo "${YELLOW_TEXT}Downloading and extracting Go sample functions...${RESET_FORMAT}"
curl -LO https://github.com/GoogleCloudPlatform/golang-samples/archive/main.zip
unzip -q main.zip
cd golang-samples-main/functions/codelabs/gopher || exit

# Function for deployment with retry logic
deploy_with_retry() {
    local function_name=$1
    local attempts=0
    local max_attempts=3
    
    while [[ $attempts -lt $max_attempts ]]; do
        echo "${MAGENTA_TEXT}Deploying $function_name (Attempt $((attempts+1))/$max_attempts)...${RESET_FORMAT}"
        
        if gcloud functions deploy $function_name --gen2 --runtime go121 --trigger-http --region $REGION --quiet; then
            echo "${GREEN_TEXT}✓ $function_name deployed successfully${RESET_FORMAT}"
            return 0
        else
            attempts=$((attempts+1))
            echo "${RED_TEXT}✗ Deployment failed${RESET_FORMAT}"
            [[ $attempts -lt $max_attempts ]] && sleep 10
        fi
    done
    
    echo "${RED_TEXT}${BOLD_TEXT}Failed to deploy $function_name after $max_attempts attempts${RESET_FORMAT}"
    return 1
}

# Step 6: Deploy HelloWorld
display_step 6 "Function Deployment" "Deploying HelloWorld function..."
deploy_with_retry HelloWorld

# Step 7: Deploy Gopher
display_step 7 "Function Deployment" "Deploying Gopher function..."
deploy_with_retry Gopher

echo
echo "${GREEN_TEXT}${BOLD_TEXT}╔══════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}║         LIKE THE VIDEO AND SUBSCRIBE THE CHANNEL                ║${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}╚══════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${WHITE_TEXT}For more cloud tutorials and guides, visit:${RESET_FORMAT}"
echo "${BLUE_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@drabhishek.5460/videos${RESET_FORMAT}"
echo
