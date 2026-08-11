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

clear


echo "${BLUE}${BOLD}====================================================================${RESET}"
echo "${BLUE}${BOLD}                  Cloud Wale Jija Ji Cloud Tutorials                     ${RESET}"
echo "${BLUE}${BOLD}====================================================================${RESET}"
echo
echo "${GREEN}${BOLD}Starting IAP Configuration Lab${RESET}"
echo

# Step 1: Export Project ID and Project Number
echo "${CYAN}${BOLD}➤ Retrieving Project Information${RESET}"
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format="value(projectNumber)")
export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

echo "${GREEN}✓ Project ID: $PROJECT_ID${RESET}"
echo "${GREEN}✓ Project Number: $PROJECT_NUMBER${RESET}"
echo "${GREEN}✓ Zone: $ZONE${RESET}"
echo

# Step 2: Enable IAP API
echo "${CYAN}${BOLD}➤ Enabling IAP API${RESET}"
gcloud services enable iap.googleapis.com
echo "${GREEN}✓ IAP API enabled${RESET}"
echo

# Step 3: Create Linux VM
echo "${CYAN}${BOLD}➤ Creating Linux IAP Instance${RESET}"
gcloud compute instances create linux-iap \
    --project=$PROJECT_ID \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --network-interface=stack-type=IPV4_ONLY,subnet=default,no-address
echo "${GREEN}✓ Linux IAP instance created${RESET}"
echo

# Step 4: Create Windows VM
echo "${CYAN}${BOLD}➤ Creating Windows IAP Instance${RESET}"
gcloud compute instances create windows-iap \
    --project=$PROJECT_ID \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --network-interface=stack-type=IPV4_ONLY,subnet=default,no-address \
    --create-disk=auto-delete=yes,boot=yes,device-name=windows-iap,image=projects/windows-cloud/global/images/windows-server-2016-dc-v20240313,mode=rw,size=50,type=projects/$PROJECT_ID/zones/$ZONE/diskTypes/pd-standard \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --reservation-affinity=any
echo "${GREEN}✓ Windows IAP instance created${RESET}"
echo

# Step 5: Create Windows Connectivity VM
echo "${CYAN}${BOLD}➤ Creating Windows Connectivity Instance${RESET}"
gcloud compute instances create windows-connectivity \
    --project=$PROJECT_ID \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
    --metadata=enable-oslogin=true \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --create-disk=auto-delete=yes,boot=yes,device-name=windows-connectivity,image=projects/qwiklabs-resources/global/images/iap-desktop-v001,mode=rw,size=50,type=projects/$PROJECT_ID/zones/$ZONE/diskTypes/pd-standard \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --reservation-affinity=any
echo "${GREEN}✓ Windows Connectivity instance created${RESET}"
echo

# Step 6: Create Firewall Rule
echo "${CYAN}${BOLD}➤ Creating Firewall Rule for IAP${RESET}"
gcloud compute firewall-rules create allow-ingress-from-iap \
  --network default \
  --allow tcp:22,tcp:3389 \
  --source-ranges 35.235.240.0/20
echo "${GREEN}✓ Firewall rule created${RESET}"
echo

# Step 7: Display Console Links
echo "${CYAN}${BOLD}➤ Console Links for Verification${RESET}"
echo "${YELLOW}Firewall Rule:${RESET}"
echo "${BLUE}https://console.cloud.google.com/net-security/firewall-manager/firewall-policies/details/allow-ingress-from-iap?project=$PROJECT_ID${RESET}"
echo
echo "${YELLOW}IAP Settings:${RESET}"
echo "${BLUE}https://console.cloud.google.com/security/iap?tab=ssh-tcp-resources&project=$PROJECT_ID${RESET}"
echo

# Step 8: Display Service Account
echo "${CYAN}${BOLD}➤ Service Account Information${RESET}"
echo "${GREEN}Service Account: $PROJECT_NUMBER-compute@developer.gserviceaccount.com${RESET}"
echo

# Completion Message
echo "${BLUE}${BOLD}====================================================================${RESET}"
echo "${BLUE}${BOLD}               LAB COMPLETED SUCCESSFULLY                          ${RESET}"
echo "${BLUE}${BOLD}====================================================================${RESET}"
echo
echo "${GREEN}${BOLD}Thank you for using Cloud Wale Jija Ji Cloud Tutorials!${RESET}"
echo
echo "${YELLOW}For more cloud tutorials and labs, visit:${RESET}"
echo "${CYAN}https://www.youtube.com/@cloudwalejijaji${RESET}"
echo

# Cleanup
cd
rm -f gsp* arc* shell* 2>/dev/null
