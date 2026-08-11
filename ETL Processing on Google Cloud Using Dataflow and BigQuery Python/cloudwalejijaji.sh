#!/bin/bash

# Color definitions
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

# Function to display section header
section_header() {
    echo
    echo "${BLUE_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
    echo "${BLUE_TEXT}${BOLD_TEXT}      Welcome To Cloud Wale Jija Ji Cloud Tutorials          $1${RESET_FORMAT}"
    echo "${BLUE_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
    echo
}

# Function to show progress spinner
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

clear

# Welcome message
section_header "DATAFLOW LAB SETUP"
echo "${MAGENTA_TEXT}${BOLD_TEXT}Welcome to Cloud Wale Jija Ji's Dataflow Lab Setup${RESET_FORMAT}"
echo "${CYAN_TEXT}For more cloud computing tutorials: https://www.youtube.com/@cloudwalejijaji${RESET_FORMAT}"
echo

# Get user input
read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter the REGION (e.g., us-central1): ${RESET_FORMAT}" REGION
export REGION=$REGION 

# Dataflow API configuration
section_header "CONFIGURING DATAFLOW API"
echo "${MAGENTA_TEXT}${BOLD_TEXT}Configuring Dataflow API...${RESET_FORMAT}"
(gcloud services disable dataflow.googleapis.com --quiet > /dev/null 2>&1) & spinner
echo -e "\r${GREEN_TEXT}✓ Dataflow API disabled (if previously enabled)${RESET_FORMAT}"

(gcloud services enable dataflow.googleapis.com --quiet > /dev/null 2>&1) & spinner
echo -e "\r${GREEN_TEXT}✓ Dataflow API enabled successfully${RESET_FORMAT}"

# File copy operations
section_header "SETTING UP ENVIRONMENT"
echo "${CYAN_TEXT}${BOLD_TEXT}Copying example files...${RESET_FORMAT}"
(gsutil -m cp -R gs://spls/gsp290/dataflow-python-examples . > /dev/null 2>&1) & spinner
echo -e "\r${GREEN_TEXT}✓ Example files copied to local environment${RESET_FORMAT}"

export PROJECT=$(gcloud config get-value project)
echo "${YELLOW_TEXT}${BOLD_TEXT}Current project set to: ${RESET_FORMAT}${GREEN_TEXT}${BOLD_TEXT}$PROJECT${RESET_FORMAT}"

# Bucket creation
echo "${CYAN_TEXT}${BOLD_TEXT}Creating regional bucket in ${REGION}...${RESET_FORMAT}"
(gsutil mb -p $PROJECT -l $REGION gs://$PROJECT > /dev/null 2>&1) & spinner
echo -e "\r${GREEN_TEXT}✓ Bucket gs://$PROJECT created in $REGION${RESET_FORMAT}"

# Data file copy
echo "${CYAN_TEXT}${BOLD_TEXT}Copying data files to bucket...${RESET_FORMAT}"
(gsutil cp gs://spls/gsp290/data_files/usa_names.csv gs://$PROJECT/data_files/ > /dev/null 2>&1) & spinner
(gsutil cp gs://spls/gsp290/data_files/head_usa_names.csv gs://$PROJECT/data_files/ > /dev/null 2>&1) & spinner
echo -e "\r${GREEN_TEXT}✓ Data files copied to gs://$PROJECT/data_files/${RESET_FORMAT}"

# BigQuery setup
echo "${MAGENTA_TEXT}${BOLD_TEXT}Creating BigQuery dataset...${RESET_FORMAT}"
(bq mk --location=$REGION lake > /dev/null 2>&1) & spinner
echo -e "\r${GREEN_TEXT}✓ BigQuery dataset 'lake' created in $REGION${RESET_FORMAT}"

# Docker container launch
section_header "STARTING DOCKER ENVIRONMENT"
echo "${CYAN_TEXT}${BOLD_TEXT}Launching Python 3.8 Docker container for Dataflow...${RESET_FORMAT}"
echo "${YELLOW}This will open an interactive shell inside the container${RESET_FORMAT}"
echo "${WHITE}Type 'exit' to leave the container when finished${RESET_FORMAT}"
echo

docker run -it -e PROJECT=$PROJECT -e REGION=$REGION -v $(pwd)/dataflow-python-examples:/dataflow python:3.8 /bin/bash

# Completion message
section_header "Follow The Video Now"
echo "${GREEN_TEXT}${BOLD_TEXT}Dataflow environment is now ready for your Python pipeline development!${RESET_FORMAT}"
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}For more Dataflow and cloud computing tutorials:${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}Subscribe to Cloud Wale Jija Ji's YouTube channel:${RESET_FORMAT}"
echo "${BLUE_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@cloudwalejijaji${RESET_FORMAT}"
echo
