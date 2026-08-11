#!/bin/bash

# =====================
BOLD=$(tput bold)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BG_RED=$(tput setab 1)
BG_GREEN=$(tput setab 2)
RESET=$(tput sgr0)
UNDERLINE=$(tput smul)

# Header with channel branding
clear
echo "${BG_RED}${BOLD}${WHITE} GOOGLE CLOUD VISION API LAB ${RESET}"
echo "${CYAN}${BOLD}Expertly crafted by Cloud Wale Jija Ji Cloud${RESET}"
echo "${YELLOW}${BOLD}📺 YouTube: ${UNDERLINE}https://www.youtube.com/@DrCloud Wale Jija JiCloud${RESET}"
echo ""

# =====================
#  LAB IMPLEMENTATION
# =====================

# API Key Creation
echo "${BLUE}${BOLD}🔑 STEP 1: Creating API Key...${RESET}"
gcloud alpha services api-keys create --display-name="vision-api-key" || {
    echo "${RED}${BOLD}❌ Error: Failed to create API key${RESET}"
    exit 1
}

KEY_NAME=$(gcloud alpha services api-keys list --format="value(name)" --filter "displayName=vision-api-key")
export API_KEY=$(gcloud alpha services api-keys get-key-string $KEY_NAME --format="value(keyString)")
export PROJECT_ID=$(gcloud config get-value project)

echo "${GREEN}${BOLD}✔ Success: ${YELLOW}API Key created${RESET}"
echo "${WHITE}Key: ${CYAN}$API_KEY${RESET}"
echo ""

# Storage Setup
echo "${BLUE}${BOLD}🪣 STEP 2: Creating Cloud Storage Bucket...${RESET}"
gsutil mb gs://$PROJECT_ID-vision-lab || {
    echo "${RED}${BOLD}❌ Error: Bucket creation failed${RESET}"
    exit 1
}
echo "${GREEN}${BOLD}✔ Success: ${YELLOW}Bucket gs://$PROJECT_ID-vision-lab ready${RESET}"
echo ""

# Image Processing
echo "${BLUE}${BOLD}🖼️ STEP 3: Downloading Sample Images...${RESET}"
declare -a IMAGE_FILES=(
    "city.png"
    "donuts.png" 
    "selfie.png"
)

for IMAGE in "${IMAGE_FILES[@]}"; do
    echo "${WHITE}Downloading $IMAGE...${RESET}"
    curl -LO "https://raw.githubusercontent.com/GoogleCloudPlatform/cloud-vision/main/samples/$IMAGE" || {
        echo "${RED}${BOLD}❌ Download failed for $IMAGE${RESET}"
        continue
    }
    gsutil cp $IMAGE gs://$PROJECT_ID-vision-lab/
    gsutil acl ch -u AllUsers:R gs://$PROJECT_ID-vision-lab/$IMAGE
    echo "${GREEN}✔ Uploaded: ${CYAN}$IMAGE${RESET}"
done
echo ""

# =====================
#  COMPLETION MESSAGE
# =====================
echo "${BG_GREEN}${BOLD}${WHITE}✅ LAB SETUP COMPLETE ${RESET}"
echo ""
echo "${BOLD}${UNDERLINE}Access Your Resources:${RESET}"
echo "🔑 API Key: ${YELLOW}$API_KEY${RESET}"
echo "🌐 Storage URL: ${CYAN}https://console.cloud.google.com/storage/browser/$PROJECT_ID-vision-lab${RESET}"
echo ""
echo "${MAGENTA}${BOLD}For more expert Google Cloud content:${RESET}"
echo "${YELLOW}${BOLD}👉 ${UNDERLINE}https://www.youtube.com/@DrCloud Wale Jija JiCloud${RESET}"
echo "${GREEN}${BOLD}🔔 Subscribe for daily cloud engineering tutorials!${RESET}"
