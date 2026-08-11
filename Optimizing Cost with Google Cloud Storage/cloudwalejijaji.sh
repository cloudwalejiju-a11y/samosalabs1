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

# Define text formatting variables
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

clear

# Welcome Banner for Cloud Wale Jija Ji Cloud Tutorials
echo
echo "${BLUE_TEXT}${BOLD_TEXT}╔══════════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}║                                                              ║${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}║    🎯 WELCOME TO DR. ABHISHEK CLOUD TUTORIALS 🎯           ║${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}║                                                              ║${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}║         Google Cloud Functions - Let's Rock Together         ║${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}║                                                              ║${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}╚══════════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${CYAN_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}                Like the video                                    ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo

# Step 1: Set compute region, project ID & project number
echo "${BOLD}${YELLOW}Step 1: Setting region, project ID & project number${RESET}"
export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)

export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")

echo "${GREEN_TEXT}✓ Region: $REGION, Project ID: $PROJECT_ID, Project Number: $PROJECT_NUMBER${RESET_FORMAT}"
echo

# Step 2: Enable required services
echo "${BOLD}${CYAN}Step 2: Enabling required Google Cloud APIs${RESET}"
gcloud services enable cloudscheduler.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable cloudfunctions.googleapis.com
echo "${GREEN_TEXT}✓ All required APIs enabled successfully${RESET_FORMAT}"
echo

# Step 3: Add IAM policy binding for Artifact Registry
echo "${BOLD}${RED}Step 3: Configuring IAM permissions for Artifact Registry${RESET}"
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
--role="roles/artifactregistry.reader"
echo "${GREEN_TEXT}✓ Artifact Registry reader role granted${RESET_FORMAT}"
echo

# Step 4: Copy training files and move into directory
echo "${BOLD}${GREEN}Step 4: Downloading lab resources${RESET}"
gcloud storage cp -r gs://spls/gsp649/* . && cd gcf-automated-resource-cleanup/
WORKDIR=$(pwd)
echo "${GREEN_TEXT}✓ Lab resources downloaded to: $WORKDIR${RESET_FORMAT}"
echo

# Step 5: Install apache2-utils
echo "${BOLD}${BLUE}Step 5: Installing required packages${RESET}"
sudo apt-get update
sudo apt-get install apache2-utils -y
echo "${GREEN_TEXT}✓ apache2-utils installed successfully${RESET_FORMAT}"
echo

# Step 6: Move to migrate-storage directory
echo "${BOLD}${MAGENTA}Step 6: Configuring storage migration${RESET}"
cd $WORKDIR/migrate-storage
echo "${GREEN_TEXT}✓ Working directory: $(pwd)${RESET_FORMAT}"
echo

# Step 7: Create public serving bucket
echo "${BOLD}${CYAN}Step 7: Creating public serving bucket${RESET}"
gcloud storage buckets create  gs://${PROJECT_ID}-serving-bucket -l $REGION
echo "${GREEN_TEXT}✓ Serving bucket created: gs://${PROJECT_ID}-serving-bucket${RESET_FORMAT}"
echo

# Step 8: Make entire bucket publicly readable
echo "${BOLD}${RED}Step 8: Configuring bucket permissions${RESET}"
gsutil acl ch -u allUsers:R gs://${PROJECT_ID}-serving-bucket
echo "${GREEN_TEXT}✓ Bucket set to publicly readable${RESET_FORMAT}"
echo

# Step 9: Upload test file to serving bucket
echo "${BOLD}${GREEN}Step 9: Uploading test file${RESET}"
gcloud storage cp $WORKDIR/migrate-storage/testfile.txt  gs://${PROJECT_ID}-serving-bucket
echo "${GREEN_TEXT}✓ Test file uploaded successfully${RESET_FORMAT}"
echo

# Step 10: Make test file publicly accessible
echo "${BOLD}${YELLOW}Step 10: Setting file permissions${RESET}"
gsutil acl ch -u allUsers:R gs://${PROJECT_ID}-serving-bucket/testfile.txt
echo "${GREEN_TEXT}✓ Test file set to publicly accessible${RESET_FORMAT}"
echo

# Step 11: Test file availability via curl
echo "${BOLD}${BLUE}Step 11: Testing public access${RESET}"
curl http://storage.googleapis.com/${PROJECT_ID}-serving-bucket/testfile.txt
echo "${GREEN_TEXT}✓ Public access test completed${RESET_FORMAT}"
echo

# Step 12: Create idle bucket
echo "${BOLD}${MAGENTA}Step 12: Creating idle storage bucket${RESET}"
gcloud storage buckets create gs://${PROJECT_ID}-idle-bucket -l $REGION
export IDLE_BUCKET_NAME=$PROJECT_ID-idle-bucket
echo "${GREEN_TEXT}✓ Idle bucket created: gs://${PROJECT_ID}-idle-bucket${RESET_FORMAT}"
echo

# Step 13: View function call in main.py
echo "${BOLD}${CYAN}Step 13: Reviewing Cloud Function code${RESET}"
cat $WORKDIR/migrate-storage/main.py | grep "migrate_storage(" -A 15
echo "${GREEN_TEXT}✓ Function code reviewed${RESET_FORMAT}"
echo

# Step 14: Replace placeholder with actual project ID
echo "${BOLD}${RED}Step 14: Configuring function parameters${RESET}"
sed -i "s/<project-id>/$PROJECT_ID/" $WORKDIR/migrate-storage/main.py
echo "${GREEN_TEXT}✓ Project ID configured in main.py${RESET_FORMAT}"
echo

# Step 15: Disable Cloud Functions temporarily
echo "${BOLD}${GREEN}Step 15: Preparing for deployment${RESET}"
gcloud services disable cloudfunctions.googleapis.com
echo "${YELLOW_TEXT}⚠ Cloud Functions API disabled temporarily${RESET_FORMAT}"
echo

# Step 16: Wait 10 seconds
echo "${BOLD}${YELLOW}Step 16: Waiting for service propagation${RESET}"
sleep 10
echo "${GREEN_TEXT}✓ Wait completed${RESET_FORMAT}"
echo

# Step 17: Re-enable Cloud Functions
echo "${BOLD}${BLUE}Step 17: Re-enabling Cloud Functions API${RESET}"
gcloud services enable cloudfunctions.googleapis.com
echo "${GREEN_TEXT}✓ Cloud Functions API re-enabled${RESET_FORMAT}"
echo

# Step 18: Deploy the function using Cloud Functions Gen2
echo "${BOLD}${MAGENTA}Step 18: Deploying Cloud Function (Gen2)${RESET}"
gcloud functions deploy migrate_storage --gen2 --trigger-http --runtime=python39 --region $REGION --allow-unauthenticated
echo "${GREEN_TEXT}✓ Cloud Function deployed successfully${RESET_FORMAT}"
echo

# Step 19: Fetch the function URL
echo "${BOLD}${CYAN}Step 19: Retrieving function endpoint${RESET}"
export FUNCTION_URL=$(gcloud functions describe migrate_storage --format=json --region $REGION | jq -r '.url')
echo "${GREEN_TEXT}✓ Function URL: $FUNCTION_URL${RESET_FORMAT}"
echo

# Step 20: Replace IDLE_BUCKET_NAME placeholder in incident.json
echo "${BOLD}${RED}Step 20: Configuring incident payload${RESET}"
export IDLE_BUCKET_NAME=$PROJECT_ID-idle-bucket
sed -i "s/\\\$IDLE_BUCKET_NAME/$IDLE_BUCKET_NAME/" $WORKDIR/migrate-storage/incident.json
echo "${GREEN_TEXT}✓ Incident payload configured${RESET_FORMAT}"
echo

# Step 21: Trigger the function using curl
echo "${BOLD}${GREEN}Step 21: Executing storage migration${RESET}"
envsubst < $WORKDIR/migrate-storage/incident.json | curl -X POST -H "Content-Type: application/json" $FUNCTION_URL -d @-
echo "${GREEN_TEXT}✓ Storage migration triggered${RESET_FORMAT}"
echo

# Step 22: Verify default storage class
echo "${BOLD}${YELLOW}Step 22: Verifying storage configuration${RESET}"
gsutil defstorageclass get gs://$PROJECT_ID-idle-bucket
echo "${GREEN_TEXT}✓ Storage class verification completed${RESET_FORMAT}"
echo

# Cleanup temporary files
cd
remove_files() {
    echo "${BOLD}${MAGENTA}Cleaning up temporary files...${RESET}"
    # Loop through all files in the current directory
    for file in *; do
        # Check if the file name starts with "gsp", "arc", or "shell"
        if [[ "$file" == gsp* || "$file" == arc* || "$file" == shell* ]]; then
            # Check if it's a regular file (not a directory)
            if [[ -f "$file" ]]; then
                # Remove the file and echo the file name
                rm "$file"
                echo "File removed: $file"
            fi
        fi
    done
}

remove_files

# Final Completion Message
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}╔══════════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}║                                                              ║${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}║         🎉 LAB COMPLETED SUCCESSFULLY! 🎉                   ║${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}║                                                              ║${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}║    Google Cloud Functions - Resource Cleanup Complete!       ║${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}║                                                              ║${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}╚══════════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${CYAN_TEXT}${BOLD_TEXT}For more cloud engineering tutorials and courses:${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}   📚 Visit: https://www.youtube.com/@cloudwalejijaji/${RESET_FORMAT}"
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}Like, Share, and Subscribe for more cloud architecture content! 🚀${RESET_FORMAT}"
echo
echo "${BLUE_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}              EXECUTION COMPLETED!                    ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo
