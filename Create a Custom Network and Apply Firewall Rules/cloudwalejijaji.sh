#!/bin/bash

# Enhanced Color Definitions
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

# Function to display section headers
section_header() {
    echo
    echo "${CYAN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
    echo "${CYAN_TEXT}${BOLD_TEXT}  Welcome To Cloud Wale Jija Ji Cloud Tutorials Do like the video $1${RESET_FORMAT}"
    echo "${CYAN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
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

# Function to display completion message
task_complete() {
    echo "${GREEN_TEXT}${BOLD_TEXT}✓ $1 completed successfully${RESET_FORMAT}"
}

# Display welcome message
clear
section_header "Network Configuration Lab Setup"
echo "${MAGENTA_TEXT}${BOLD_TEXT}Network configuration  by Cloud Wale Jija Ji${RESET_FORMAT}"
echo

# Get user input for regions
echo "${YELLOW_TEXT}${BOLD_TEXT}Please enter the required regions (e.g., us-central1, europe-west1, asia-east1)${RESET_FORMAT}"
read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter REGION1: ${RESET_FORMAT}" REGION1
read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter REGION2: ${RESET_FORMAT}" REGION2
read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter REGION3: ${RESET_FORMAT}" REGION3

# Export variables
export REGION1 REGION2 REGION3

# Authentication and Configuration
section_header "Authentication and Configuration"
echo "${BLUE_TEXT}${BOLD_TEXT}Setting up project configuration...${RESET_FORMAT}"
(gcloud auth list > /dev/null 2>&1) & spinner
echo

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

(gcloud config set compute/zone "$ZONE" > /dev/null 2>&1) & spinner
(gcloud config set compute/region "$REGION" > /dev/null 2>&1) & spinner
task_complete "Project configuration"

# Network Creation
section_header "Creating Custom Network"
echo "${BLUE_TEXT}${BOLD_TEXT}Creating taw-custom-network...${RESET_FORMAT}"
(gcloud compute networks create taw-custom-network --subnet-mode custom > /dev/null 2>&1) & spinner
task_complete "Network creation"

# Subnet Creation
section_header "Creating Subnets"
echo "${BLUE_TEXT}${BOLD_TEXT}Creating subnets in specified regions...${RESET_FORMAT}"

echo "${YELLOW_TEXT}Creating subnet-$REGION1 in $REGION1...${RESET_FORMAT}"
(gcloud compute networks subnets create subnet-$REGION1 \
   --network taw-custom-network \
   --region $REGION1 \
   --range 10.0.0.0/16 > /dev/null 2>&1) & spinner
task_complete "subnet-$REGION1 creation"

echo "${YELLOW_TEXT}Creating subnet-$REGION2 in $REGION2...${RESET_FORMAT}"
(gcloud compute networks subnets create subnet-$REGION2 \
   --network taw-custom-network \
   --region $REGION2 \
   --range 10.1.0.0/16 > /dev/null 2>&1) & spinner
task_complete "subnet-$REGION2 creation"

echo "${YELLOW_TEXT}Creating subnet-$REGION3 in $REGION3...${RESET_FORMAT}"
(gcloud compute networks subnets create subnet-$REGION3 \
   --network taw-custom-network \
   --region $REGION3 \
   --range 10.2.0.0/16 > /dev/null 2>&1) & spinner
task_complete "subnet-$REGION3 creation"

# List subnets
echo "${BLUE_TEXT}${BOLD_TEXT}Listing all created subnets...${RESET_FORMAT}"
(gcloud compute networks subnets list --network taw-custom-network > /dev/null 2>&1) & spinner
gcloud compute networks subnets list --network taw-custom-network

# Firewall Rules
section_header "Configuring Firewall Rules"
echo "${BLUE_TEXT}${BOLD_TEXT}Setting up firewall rules...${RESET_FORMAT}"

echo "${YELLOW_TEXT}Creating HTTP rule...${RESET_FORMAT}"
(gcloud compute firewall-rules create nw101-allow-http \
--allow tcp:80 --network taw-custom-network --source-ranges 0.0.0.0/0 \
--target-tags http > /dev/null 2>&1) & spinner
task_complete "HTTP firewall rule"

echo "${YELLOW_TEXT}Creating ICMP rule...${RESET_FORMAT}"
(gcloud compute firewall-rules create "nw101-allow-icmp" \
--allow icmp --network "taw-custom-network" --target-tags rules > /dev/null 2>&1) & spinner
task_complete "ICMP firewall rule"

echo "${YELLOW_TEXT}Creating internal traffic rule...${RESET_FORMAT}"
(gcloud compute firewall-rules create "nw101-allow-internal" \
--allow tcp:0-65535,udp:0-65535,icmp --network "taw-custom-network" \
--source-ranges "10.0.0.0/16","10.2.0.0/16","10.1.0.0/16" > /dev/null 2>&1) & spinner
task_complete "Internal traffic firewall rule"

echo "${YELLOW_TEXT}Creating SSH rule...${RESET_FORMAT}"
(gcloud compute firewall-rules create "nw101-allow-ssh" \
--allow tcp:22 --network "taw-custom-network" --target-tags "ssh" > /dev/null 2>&1) & spinner
task_complete "SSH firewall rule"

echo "${YELLOW_TEXT}Creating RDP rule...${RESET_FORMAT}"
(gcloud compute firewall-rules create "nw101-allow-rdp" \
--allow tcp:3389 --network "taw-custom-network" > /dev/null 2>&1) & spinner
task_complete "RDP firewall rule"

# Completion Message
section_header "Lab Completed Successfully!"
echo "${GREEN_TEXT}${BOLD_TEXT}All network configurations have been successfully applied by Cloud Wale Jija Ji's Guide.${RESET_FORMAT}"
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}For more tutorials by Cloud Wale Jija Ji:${RESET_FORMAT}"
echo "${BLUE_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@cloudwalejijaji${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}Cloud Computing and DevOps Tutorials${RESET_FORMAT}"
echo
