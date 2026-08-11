#!/bin/bash
# Define color variables

BLACK=`tput setaf 0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`

BG_BLACK=`tput setab 0`
BG_RED=`tput setab 1`
BG_GREEN=`tput setab 2`
BG_YELLOW=`tput setab 3`
BG_BLUE=`tput setab 4`
BG_MAGENTA=`tput setab 5`
BG_CYAN=`tput setab 6`
BG_WHITE=`tput setab 7`

BOLD=`tput bold`
RESET=`tput sgr0`

#----------------------------------------------------start--------------------------------------------------#

# Welcome Banner
echo "${BLUE}${BOLD}"
echo "*****************************************************************"
echo "*                                                               *"
echo "*          Welcome to Cloud Wale Jija Ji Cloud Tutorials!             *"
echo "*                                                               *"
echo "*  Subscribe for more content:                                  *"
echo "*  https://www.youtube.com/@cloudwalejijaji/videos              *"
echo "*                                                               *"
echo "*****************************************************************"
echo "${RESET}"

# Spinner function
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

# Display current authenticated accounts
echo -n "${CYAN}${BOLD}Checking authenticated accounts...${RESET}"
(gcloud auth list > /dev/null 2>&1) &
spinner
echo " ${GREEN}✓ Done!${RESET}"
gcloud auth list

# Set up environment variables
export BUCKET_NAME=$DEVSHELL_PROJECT_ID-bucket
export PROJECT_ID=$DEVSHELL_PROJECT_ID

# Clone repository
echo -n "${YELLOW}${BOLD}Cloning repository...${RESET}"
(git clone https://github.com/quiccklabs/Redacting-Sensitive-Data-with-Cloud-Data-Loss-Prevention.git > /dev/null 2>&1) &
spinner
echo " ${GREEN}✓ Done!${RESET}"

# Install npm dependencies
echo -n "${MAGENTA}${BOLD}Installing npm dependencies...${RESET}"
(cd Redacting-Sensitive-Data-with-Cloud-Data-Loss-Prevention/quicklabgsp864/samples && npm install > /dev/null 2>&1) &
spinner
echo " ${GREEN}✓ Done!${RESET}"

# Set project
echo -n "${BLUE}${BOLD}Setting project...${RESET}"
(gcloud config set project $PROJECT_ID > /dev/null 2>&1) &
spinner
echo " ${GREEN}✓ Done!${RESET}"

# Enable services
echo -n "${GREEN}${BOLD}Enabling required services...${RESET}"
(gcloud services enable dlp.googleapis.com cloudkms.googleapis.com --project $PROJECT_ID > /dev/null 2>&1) &
spinner
echo " ${GREEN}✓ Done!${RESET}"

# Run DLP operations
echo "${CYAN}${BOLD}Running DLP inspection and redaction tasks...${RESET}"

echo -n "  - Inspecting string..."
(node inspectString.js $PROJECT_ID "My email address is jenny@somedomain.com and you can call me at 555-867-5309" > inspected-string.txt 2>&1) &
spinner
echo " ${GREEN}✓ Done!${RESET}"

echo -n "  - Inspecting file..."
(node inspectFile.js $PROJECT_ID resources/accounts.txt > inspected-file.txt 2>&1) &
spinner
echo " ${GREEN}✓ Done!${RESET}"

echo -n "  - Uploading results to bucket..."
(gsutil cp inspected-string.txt gs://$BUCKET_NAME > /dev/null 2>&1 && 
 gsutil cp inspected-file.txt gs://$BUCKET_NAME > /dev/null 2>&1) &
spinner
echo " ${GREEN}✓ Done!${RESET}"

echo -n "  - De-identifying data..."
(node deidentifyWithMask.js $PROJECT_ID "My order number is F12312399. Email me at anthony@somedomain.com" > de-identify-output.txt 2>&1) &
spinner
echo " ${GREEN}✓ Done!${RESET}"

echo -n "  - Uploading de-identified data..."
(gsutil cp de-identify-output.txt gs://$BUCKET_NAME > /dev/null 2>&1) &
spinner
echo " ${GREEN}✓ Done!${RESET}"

echo -n "  - Redacting text..."
(node redactText.js $PROJECT_ID "Please refund the purchase to my credit card 4012888888881881" CREDIT_CARD_NUMBER > redacted-string.txt 2>&1) &
spinner
echo " ${GREEN}✓ Done!${RESET}"

echo -n "  - Redacting images..."
(node redactImage.js $PROJECT_ID resources/test.png "" PHONE_NUMBER ./redacted-phone.png > /dev/null 2>&1 &&
 node redactImage.js $PROJECT_ID resources/test.png "" EMAIL_ADDRESS ./redacted-email.png > /dev/null 2>&1) &
spinner
echo " ${GREEN}✓ Done!${RESET}"

echo -n "  - Uploading redacted content..."
(gsutil cp redacted-string.txt gs://$BUCKET_NAME > /dev/null 2>&1 &&
 gsutil cp redacted-phone.png gs://$BUCKET_NAME > /dev/null 2>&1 &&
 gsutil cp redacted-email.png gs://$BUCKET_NAME > /dev/null 2>&1) &
spinner
echo " ${GREEN}✓ Done!${RESET}"

echo "${BG_RED}${BOLD}Congratulations For Completing The Lab!${RESET}"
echo "${BLUE}Don't forget to subscribe to Cloud Wale Jija Ji Cloud Tutorials for more content:"
echo "https://www.youtube.com/@cloudwalejijaji/videos${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#
