#!/bin/bash

# Color Definitions
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

# Welcome Message
echo "${BG_BLUE}${WHITE}${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${BG_BLUE}${WHITE}${BOLD}             WELCOME TO DR ABHISHEK CLOUD TUTORIAL             ${RESET}"
echo "${BG_BLUE}${WHITE}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${CYAN}${BOLD}          Tutorial by Cloud Wale Jija Ji                       ${RESET}"
echo "${YELLOW}For more security tutorials, visit: https://www.youtube.com/@cloudwalejijaji${RESET}"
echo
echo "${BLUE}${BOLD}⚡ Initializing XSS Test Setup...${RESET}"
echo

# Zone Input
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ ZONE SELECTION ▬▬▬▬▬▬▬▬▬${RESET}"
echo "${YELLOW}Please enter your preferred zone (e.g., us-central1-a):${RESET}"
echo "${CYAN}Common options:${RESET}"
echo "  - us-central1-a"
echo "  - us-east1-b" 
echo "  - europe-west1-b"
echo "  - asia-southeast1-a"
echo
read -p "Enter your zone: " ZONE

# Validate zone format
if [[ ! $ZONE =~ ^[a-z]+-[a-z]+[0-9]-[a-z]$ ]]; then
    echo "${RED}Invalid zone format. Please use format like 'us-central1-a'${RESET}"
    exit 1
fi

export ZONE
export REGION="${ZONE%-*}"
echo "${GREEN}Selected Zone: ${ZONE}${RESET}"
echo "${GREEN}Derived Region: ${REGION}${RESET}"
echo

# Main Execution
echo "${YELLOW}${BOLD}Starting${RESET}" "${GREEN}${BOLD}Execution${RESET}"

echo "${CYAN}Enabling Web Security Scanner API...${RESET}"
gcloud services enable websecurityscanner.googleapis.com

echo "${CYAN}Creating IP address...${RESET}"
gcloud compute addresses create xss-test-ip-address --region=$REGION

echo "${CYAN}Creating VM instance...${RESET}"
gcloud compute instances create xss-test-vm-instance \
--address=xss-test-ip-address --no-service-account \
--no-scopes --machine-type=e2-micro --zone=$ZONE \
--metadata=startup-script='apt-get update; apt-get install -y python3-flask'

echo "${CYAN}Creating firewall rule...${RESET}"
gcloud compute firewall-rules create enable-wss-scan \
--direction=INGRESS --priority=1000 \
--network=default --action=ALLOW \
--rules=tcp:8080 --source-ranges=0.0.0.0/0

echo "${YELLOW}Waiting 10 seconds for resources to initialize...${RESET}"
sleep 10

IP=$(gcloud compute instances describe xss-test-vm-instance --zone=$ZONE --project=$DEVSHELL_PROJECT_ID --format="get(networkInterfaces[0].accessConfigs[0].natIP)")

echo "${CYAN}Creating security scan configuration...${RESET}"
gcloud alpha web-security-scanner scan-configs create --display-name=Awesome --starting-urls=http://$IP:8080

SCAN_CONFIG=$(gcloud alpha web-security-scanner scan-configs list --project=$DEVSHELL_PROJECT_ID --format="value(name)")

echo "${CYAN}Starting security scan...${RESET}"
gcloud alpha web-security-scanner scan-runs start $SCAN_CONFIG

echo "${YELLOW}Waiting 10 seconds for scan to initialize...${RESET}"
sleep 10

# Pause for manual verification
echo "${BG_MAGENTA}${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${BG_MAGENTA}${BOLD}    PLEASE VERIFY SCAN RESULTS IN WEB SECURITY SCANNER     ${RESET}"
echo "${BG_MAGENTA}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${YELLOW}Go to Cloud Web Security Scanner:${RESET}"
echo "${BLUE}https://console.cloud.google.com/security/web-scanner/scanConfigs${RESET}"
echo
read -p "Have you verified the scan results? Enter 'y' to continue: " confirm
if [ "$confirm" != "y" ]; then
    echo "${RED}Script paused. Run again after verification.${RESET}"
    exit 0
fi

# Part 2 Execution
echo "${CYAN}Setting up Flask application...${RESET}"
gcloud compute ssh xss-test-vm-instance --zone $ZONE --project=$DEVSHELL_PROJECT_ID --quiet --command "gsutil cp gs://cloud-training/GCPSEC-ScannerAppEngine/flask_code.tar . && tar xvf flask_code.tar && python3 app.py"

# Completion Message
echo "${BG_GREEN}${BLACK}${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${BG_GREEN}${BLACK}${BOLD}          CONGRATULATIONS - LAB COMPLETED!               ${RESET}"
echo "${BG_GREEN}${BLACK}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${RED}${BOLD}🙏 Thank you for following Cloud Wale Jija Ji's tutorial!${RESET}"
echo "${YELLOW}${BOLD}📺 Subscribe for more security content:${RESET}"
echo "${BLUE}https://www.youtube.com/@cloudwalejijaji${RESET}"
echo
echo "${MAGENTA}${BOLD}🚀 Happy learning about web security!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#
