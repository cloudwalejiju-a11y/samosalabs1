#!/bin/bash

# Enhanced Color Definitions
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)

BG_BLACK=$(tput setab 0)
BG_RED=$(tput setab 1)
BG_GREEN=$(tput setab 2)
BG_YELLOW=$(tput setab 3)
BG_BLUE=$(tput setab 4)
BG_MAGENTA=$(tput setab 5)
BG_CYAN=$(tput setab 6)
BG_WHITE=$(tput setab 7)

BOLD=$(tput bold)
RESET=$(tput sgr0)

clear

# Display Header
echo "${CYAN}${BOLD}============================================${RESET}"
echo "${CYAN}${BOLD}   TERRAFORM STATE MANAGEMENT LAB           ${RESET}"
echo "${CYAN}${BOLD}============================================${RESET}"
echo "${BLUE}YouTube Channel: https://www.youtube.com/@cloudwalejijaji${RESET}"
echo "${CYAN}Video Tutorials: https://www.youtube.com/@cloudwalejijaji/videos${RESET}"
echo

# Get Region Input
echo "${YELLOW}${BOLD}Step 1: Please enter your preferred region (e.g., us-central1):${RESET}"
read REGION
export REGION
echo "${GREEN}✓ Region set to: ${REGION}${RESET}"
echo

# Start Execution
echo "${YELLOW}${BOLD}Starting${RESET} ${GREEN}${BOLD}Terraform State Management Lab${RESET}"
echo

# Create initial Terraform configuration with local backend
echo "${BLUE}${BOLD}Step 2: Creating Initial Terraform Configuration${RESET}"
cat > main.tf <<EOF
provider "google" {
  project     = "$DEVSHELL_PROJECT_ID"
  region      = "$REGION"
}

resource "google_storage_bucket" "test-bucket-for-state" {
  name        = "$DEVSHELL_PROJECT_ID"
  location    = "US"
  uniform_bucket_level_access = true
}

terraform {
  backend "local" {
    path = "terraform/state/terraform.tfstate"
  }
}
EOF

echo "${GREEN}✓ Initial configuration created${RESET}"
echo

# Initialize and apply Terraform
echo "${BLUE}${BOLD}Step 3: Initializing Terraform with Local Backend${RESET}"
terraform init
echo "${GREEN}✓ Terraform initialized${RESET}"
echo

echo "${BLUE}${BOLD}Step 4: Applying Terraform Configuration${RESET}"
terraform apply --auto-approve
echo "${GREEN}✓ Resources created with local state${RESET}"
echo

# Update configuration with GCS backend
echo "${BLUE}${BOLD}Step 5: Migrating to GCS Backend${RESET}"
cat > main.tf <<EOF
provider "google" {
  project     = "$DEVSHELL_PROJECT_ID"
  region      = "$REGION"
}

resource "google_storage_bucket" "test-bucket-for-state" {
  name        = "$DEVSHELL_PROJECT_ID"
  location    = "US"
  uniform_bucket_level_access = true
}

terraform {
  backend "gcs" {
    bucket  = "$DEVSHELL_PROJECT_ID"
    prefix  = "terraform/state"
  }
}
EOF

echo "${GREEN}✓ Configuration updated for GCS backend${RESET}"
echo

# Migrate state to GCS
echo "${BLUE}${BOLD}Step 6: Migrating State to GCS${RESET}"
yes | terraform init -migrate-state
echo "${GREEN}✓ State successfully migrated to GCS${RESET}"
echo

# Add label to bucket
echo "${BLUE}${BOLD}Step 7: Adding Label to Storage Bucket${RESET}"
gsutil label ch -l "key:value" gs://$DEVSHELL_PROJECT_ID
echo "${GREEN}✓ Label added to storage bucket${RESET}"
echo

# Completion Message
echo "${MAGENTA}${BOLD}============================================${RESET}"
echo "${MAGENTA}${BOLD}   LAB COMPLETED SUCCESSFULLY!             ${RESET}"
echo "${MAGENTA}${BOLD}============================================${RESET}"
echo
echo "${GREEN}${BOLD}Congratulations on completing the Terraform State Management Lab!${RESET}"
echo
echo "${BLUE}${BOLD}For more cloud tutorials:${RESET}"
echo "${CYAN}Subscribe to Cloud Wale Jija Ji's YouTube Channel:${RESET}"
echo "${YELLOW}https://www.youtube.com/@cloudwalejijaji${RESET}"
echo "${CYAN}Video Tutorials:${RESET}"
echo "${YELLOW}https://www.youtube.com/@cloudwalejijaji/videos${RESET}"
