#!/bin/bash


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

echo "${CYAN}${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${CYAN}${BOLD}       Welcome to Cloud Wale Jija Ji Cloud Tutorials!           ${RESET}"
echo "${CYAN}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${GREEN}${BOLD}Please like, share and subscribe to the channel for more:${RESET}"
echo "${BLUE}${BOLD}https://www.youtube.com/@cloudwalejijaji/videos${RESET}"
echo

echo "${YELLOW}${BOLD}Starting Terraform Instance Creation Lab...${RESET}"

# Show current authentication
echo "${MAGENTA}${BOLD}Current gcloud authentication:${RESET}"
gcloud auth list
echo

# Get project ID and zone
echo "${BLUE}${BOLD}"
read -p "Enter your ZONE (e.g., us-central1-a): " ZONE
echo "${RESET}"

# Create Terraform configuration file
echo "${GREEN}${BOLD}Creating Terraform configuration file...${RESET}"
cat > instance.tf <<EOF_END
resource "google_compute_instance" "terraform" {
  project      = "$DEVSHELL_PROJECT_ID"
  name         = "terraform"
  machine_type = "e2-medium"
  zone         = "$ZONE"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }
}
EOF_END

# Initialize Terraform
echo "${YELLOW}${BOLD}Initializing Terraform...${RESET}"
terraform init

# Plan Terraform changes
echo "${BLUE}${BOLD}Planning Terraform changes...${RESET}"
terraform plan

# Apply Terraform changes
echo "${GREEN}${BOLD}Applying Terraform changes...${RESET}"
terraform apply --auto-approve

echo
echo "${CYAN}${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${CYAN}${BOLD}           Lab Completed Successfully!                    ${RESET}"
echo "${CYAN}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${GREEN}${BOLD}Thanks for using this lab! Don't forget to:${RESET}"
echo "${YELLOW}${BOLD}👍 Like   🔄 Share   🔔 Subscribe${RESET}"
echo "${BLUE}${BOLD}https://www.youtube.com/@cloudwalejijaji/videos${RESET}"
echo
