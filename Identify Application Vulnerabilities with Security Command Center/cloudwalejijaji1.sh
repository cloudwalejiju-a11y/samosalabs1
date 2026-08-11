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

# Function to display progress spinner
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

# Welcome message
clear
echo "${BG_BLUE}${BOLD}${WHITE}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${BG_BLUE}${BOLD}${WHITE}   XSS Vulnerability Scanner Lab1 - Cloud Wale Jija Ji's Lab    ${RESET}"
echo "${BG_BLUE}${BOLD}${WHITE}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${GREEN}${BOLD}Let's set up a test environment for XSS scanning${RESET}"
echo "${CYAN}For more security tutorials: https://www.youtube.com/@cloudwalejijaji${RESET}"
echo

# Start execution
echo "${YELLOW}${BOLD}Starting${RESET} ${GREEN}${BOLD}Execution${RESET}"
echo

# Set region
export REGION="${ZONE%-*}"

# Enable Web Security Scanner API
echo "${BLUE}${BOLD}Enabling Web Security Scanner API...${RESET}"
(gcloud services enable websecurityscanner.googleapis.com > /dev/null 2>&1) & spinner
echo "${GREEN}✓ API enabled${RESET}"
echo

# Create IP address
echo "${BLUE}${BOLD}Creating test IP address...${RESET}"
(gcloud compute addresses create xss-test-ip-address --region=$REGION > /dev/null 2>&1) & spinner
IP_ADDRESS=$(gcloud compute addresses describe xss-test-ip-address --region=$REGION --format="value(address)")
echo "${GREEN}✓ IP address created: ${IP_ADDRESS}${RESET}"
echo

# Create test VM instance
echo "${BLUE}${BOLD}Creating test VM instance...${RESET}"
(gcloud compute instances create xss-test-vm-instance \
--address=xss-test-ip-address --no-service-account \
--no-scopes --machine-type=e2-micro --zone=$ZONE \
--metadata=startup-script='apt-get update; apt-get install -y python3-flask' > /dev/null 2>&1) & spinner
echo "${GREEN}✓ VM instance created${RESET}"
echo

# Configure firewall
echo "${BLUE}${BOLD}Configuring firewall rules...${RESET}"
(gcloud compute firewall-rules create enable-wss-scan \
--direction=INGRESS --priority=1000 \
--network=default --action=ALLOW \
--rules=tcp:8080 --source-ranges=0.0.0.0/0 > /dev/null 2>&1) & spinner
echo "${GREEN}✓ Firewall rule created${RESET}"
echo

# Wait for instance to initialize
echo "${YELLOW}Waiting for instance to initialize...${RESET}"
for i in {1..10}; do
    echo -ne "${YELLOW}⏳ $((10 - i)) seconds remaining...${RESET}\r"
    sleep 1
done
echo -ne "${GREEN}✓ Instance ready${RESET}          \n"
echo

# Get instance IP
IP=$(gcloud compute instances describe xss-test-vm-instance --zone=$ZONE --project=$DEVSHELL_PROJECT_ID --format="get(networkInterfaces[0].accessConfigs[0].natIP)")
echo "${BLUE}Instance IP address: ${IP}${RESET}"
echo

# Configure security scanner
echo "${BLUE}${BOLD}Setting up security scanner...${RESET}"
(gcloud alpha web-security-scanner scan-configs create --display-name=Awesome --starting-urls=http://$IP:8080 > /dev/null 2>&1) & spinner
SCAN_CONFIG=$(gcloud alpha web-security-scanner scan-configs list --project=$DEVSHELL_PROJECT_ID --format="value(name)")
(gcloud alpha web-security-scanner scan-runs start $SCAN_CONFIG > /dev/null 2>&1) & spinner
echo "${GREEN}✓ Security scanner configured${RESET}"
echo

# Deploy test application
echo "${BLUE}${BOLD}Deploying test application...${RESET}"
(gcloud compute ssh xss-test-vm-instance --zone $ZONE --project=$DEVSHELL_PROJECT_ID --quiet --command "gsutil cp gs://cloud-training/GCPSEC-ScannerAppEngine/flask_code.tar . && tar xvf flask_code.tar && python3 app.py" > /dev/null 2>&1) & spinner
echo "${GREEN}✓ Test application deployed${RESET}"
echo

# Completion message
echo "${BG_GREEN}${BOLD}${BLACK}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${BG_GREEN}${BOLD}${BLACK}               Now Follow The Video!                     ${RESET}"
echo "${BG_GREEN}${BOLD}${BLACK}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${MAGENTA}${BOLD}Thank you for using Cloud Wale Jija Ji's Security Lab Setup${RESET}"
echo "${CYAN}${BOLD}For more security tutorials, subscribe to:${RESET}"
echo "${BLUE}${UNDERLINE}https://www.youtube.com/@cloudwalejijaji${RESET}"
echo
