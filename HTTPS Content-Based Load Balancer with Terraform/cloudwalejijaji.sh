#!/bin/bash


# Modern Color Definitions
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

# Box Drawing Characters
BOX_TOP="${CYAN}╔════════════════════════════════════════════╗${RESET}"
BOX_MID="${CYAN}║                                            ║${RESET}"
BOX_BOT="${CYAN}╚════════════════════════════════════════════╝${RESET}"

# Header with Cloud Wale Jija Ji branding
clear
echo -e "${BOX_TOP}"
echo -e "${CYAN}║   🚀 Cloud Wale Jija Ji's HTTPS Load Balancer Lab   ║${RESET}"
echo -e "${BOX_BOT}"
echo
echo -e "${WHITE}📺 YouTube: ${BLUE}https://youtube.com/@cloudwalejijaji${RESET}"
echo -e "${WHITE}⭐ Subscribe for more Cloud & DevOps tutorials! ⭐${RESET}"
echo

# Get user input for regions
echo -e "${GREEN}${BOLD}🌍 Region Configuration${RESET}"
echo -e "${YELLOW}Please enter the regions for your backend groups:${RESET}"
read -p "Enter Group 1 Region (e.g. us-central1): " group1_region
read -p "Enter Group 2 Region (e.g. us-east1): " group2_region
read -p "Enter Group 3 Region (e.g. europe-west1): " group3_region
echo

# Clone Terraform module
echo -e "${GREEN}${BOLD}📥 Cloning Terraform HTTP Load Balancer module...${RESET}"
git clone https://github.com/terraform-google-modules/terraform-google-lb-http.git
cd ~/terraform-google-lb-http/examples/multi-backend-multi-mig-bucket-https-lb || {
    echo -e "${RED}❌ Failed to change directory${RESET}"
    exit 1
}

# Download configuration
echo -e "${GREEN}${BOLD}⚙️ Downloading Load Balancer configuration...${RESET}"
rm -rf main.tf
wget -q https://raw.githubusercontent.com/quiccklabs/Labs_solutions/master/HTTPS%20Content-Based%20Load%20Balancer%20with%20Terraform/main.tf

# Create variables file
echo -e "${GREEN}${BOLD}📝 Generating Terraform variables file...${RESET}"
cat > variables.tf <<EOF
variable "group1_region" {
  default = "$group1_region"
}

variable "group2_region" {
  default = "$group2_region"
}

variable "group3_region" {
  default = "$group3_region"
}

variable "network_name" {
  default = "ml-bk-ml-mig-bkt-s-lb"
}

variable "project" {
  type = string
}
EOF

# Terraform execution
echo -e "${GREEN}${BOLD}🛠️ Initializing Terraform...${RESET}"
terraform init

echo -e "${GREEN}${BOLD}🔎 Planning infrastructure...${RESET}"
echo $DEVSHELL_PROJECT_ID | terraform plan

echo -e "${GREEN}${BOLD}🚀 Applying configuration (may take 10-15 minutes)...${RESET}"
echo $DEVSHELL_PROJECT_ID | terraform apply -auto-approve

# Get Load Balancer IP
EXTERNAL_IP=$(terraform output | grep load-balancer-ip | cut -d = -f2 | xargs echo -n)

# Completion message
echo -e "\n${GREEN}${BOLD}╔════════════════════════════════════════════╗"
echo -e "║          🎉 Deployment Completed! 🎉          ║"
echo -e "╚════════════════════════════════════════════╝${RESET}"
echo -e "${WHITE}Your Load Balancer is now available at:${RESET}"
echo -e "${BLUE}${BOLD}http://${EXTERNAL_IP}${RESET}"
echo
echo -e "${CYAN}Thank you for using Cloud Wale Jija Ji's Cloud Lab!${RESET}"
echo -e "${CYAN}For more tutorials, subscribe: ${BLUE}https://youtube.com/@cloudwalejijaji${RESET}"
