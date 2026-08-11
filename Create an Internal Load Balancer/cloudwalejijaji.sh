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

# Modern UI Elements
DIVIDER="${BLUE}${BOLD}┃${RESET}"
TOP_CORNER="${BLUE}${BOLD}╭${RESET}"
BOTTOM_CORNER="${BLUE}${BOLD}╰${RESET}"
LINE="${BLUE}${BOLD}─${RESET}"

clear

# Modern Header
echo
echo "${TOP_CORNER}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${RESET}"
echo "${BLUE}${BOLD}       WELCOME TO DR ABHISHEK CLOUD      ${RESET}"
echo "${BLUE}${BOLD}         TUTORIAL DO LIKE THE VIDEO        ${RESET}"
echo "${BOTTOM_CORNER}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${RESET}"
echo

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

# Function to change zone automatically
change_zone_automatically() {
    echo -n "${CYAN}${BOLD}🔍 Determining secondary zone..."
    ZONE_1=$(gcloud compute project-info describe \
        --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
    
    if [[ -z "$ZONE_1" ]]; then
        echo -e "\r${RED}${BOLD}✘ Could not retrieve current zone!          ${RESET}"
        return 1
    fi

    zone_prefix=${ZONE_1::-1}
    last_char=${ZONE_1: -1}
    valid_chars=("b" "c" "d")
    
    for char in "${valid_chars[@]}"; do
        if [[ $char != "$last_char" ]]; then
            ZONE_2="${zone_prefix}${char}"
            break
        fi
    done

    export ZONE_2
    echo -e "\r${GREEN}${BOLD}✔ Secondary zone set to: ${BLUE}$ZONE_2          ${RESET}"
}

# Step 1: Retrieve default zone and region
echo "${MAGENTA}${BOLD}▐▓▒▌ STEP 1: PROJECT CONFIGURATION ${BLUE}${BOLD}◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈${RESET}"
echo
echo -n "${CYAN}${BOLD}🌍 Retrieving default zone and region..."
ZONE_1=$(gcloud compute project-info describe \
    --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
REGION=$(gcloud compute project-info describe \
    --format="value(commonInstanceMetadata.items[google-compute-default-region])")
echo -e "\r${GREEN}${BOLD}✔ Zone: ${BLUE}$ZONE_1 ${GREEN}Region: ${BLUE}$REGION          ${RESET}"
echo

# Step 2: Firewall Rules
echo "${MAGENTA}${BOLD}▐▓▒▌ STEP 2: FIREWALL CONFIGURATION ${BLUE}${BOLD}◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈${RESET}"
echo
echo -n "${CYAN}${BOLD}🛡️ Creating HTTP firewall rule..."
(gcloud compute firewall-rules create app-allow-http \
    --direction=INGRESS \
    --priority=1000 \
    --network=my-internal-app \
    --action=ALLOW \
    --rules=tcp:80 \
    --source-ranges=10.10.0.0/16 \
    --target-tags=lb-backend > /dev/null 2>&1) &
spinner
echo -e "\r${GREEN}${BOLD}✔ HTTP firewall rule created!          ${RESET}"

echo -n "${CYAN}${BOLD}🛡️ Creating health check firewall rule..."
(gcloud compute firewall-rules create app-allow-health-check \
    --direction=INGRESS \
    --priority=1000 \
    --network=my-internal-app \
    --action=ALLOW \
    --rules=tcp:80 \
    --source-ranges=130.211.0.0/22,35.191.0.0/16 \
    --target-tags=lb-backend > /dev/null 2>&1) &
spinner
echo -e "\r${GREEN}${BOLD}✔ Health check firewall rule created!          ${RESET}"
echo

# Step 3: Instance Templates
echo "${MAGENTA}${BOLD}▐▓▒▌ STEP 3: INSTANCE TEMPLATES ${BLUE}${BOLD}◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈${RESET}"
echo
echo -n "${CYAN}${BOLD}🖥️ Creating template for subnet-a..."
(gcloud compute instance-templates create instance-template-1 \
    --machine-type e2-micro \
    --network my-internal-app \
    --subnet subnet-a \
    --tags lb-backend \
    --metadata startup-script-url=gs://cloud-training/gcpnet/ilb/startup.sh \
    --region=$REGION > /dev/null 2>&1) &
spinner
echo -e "\r${GREEN}${BOLD}✔ Template for subnet-a created!          ${RESET}"

echo -n "${CYAN}${BOLD}🖥️ Creating template for subnet-b..."
(gcloud compute instance-templates create instance-template-2 \
    --machine-type e2-micro \
    --network my-internal-app \
    --subnet subnet-b \
    --tags lb-backend \
    --metadata startup-script-url=gs://cloud-training/gcpnet/ilb/startup.sh \
    --region=$REGION > /dev/null 2>&1) &
spinner
echo -e "\r${GREEN}${BOLD}✔ Template for subnet-b created!          ${RESET}"
echo

# Step 4: Instance Groups
echo "${MAGENTA}${BOLD}▐▓▒▌ STEP 4: INSTANCE GROUPS ${BLUE}${BOLD}◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈${RESET}"
echo
change_zone_automatically

echo -n "${CYAN}${BOLD}🔄 Creating instance group 1..."
(gcloud beta compute instance-groups managed create instance-group-1 \
    --project=$DEVSHELL_PROJECT_ID \
    --base-instance-name=instance-group-1 \
    --size=1 \
    --template=instance-template-1 \
    --zone=$ZONE_1 \
    --list-managed-instances-results=PAGELESS \
    --no-force-update-on-repair > /dev/null 2>&1) &
spinner
echo -e "\r${GREEN}${BOLD}✔ Instance group 1 created!          ${RESET}"

echo -n "${CYAN}${BOLD}📈 Setting autoscaling for group 1..."
(gcloud beta compute instance-groups managed set-autoscaling instance-group-1 \
    --project=$DEVSHELL_PROJECT_ID \
    --zone=$ZONE_1 \
    --cool-down-period=45 \
    --max-num-replicas=5 \
    --min-num-replicas=1 \
    --mode=on \
    --target-cpu-utilization=0.8 > /dev/null 2>&1) &
spinner
echo -e "\r${GREEN}${BOLD}✔ Autoscaling configured for group 1!          ${RESET}"

echo -n "${CYAN}${BOLD}🔄 Creating instance group 2..."
(gcloud beta compute instance-groups managed create instance-group-2 \
    --project=$DEVSHELL_PROJECT_ID \
    --base-instance-name=instance-group-2 \
    --size=1 \
    --template=instance-template-2 \
    --zone=$ZONE_2 \
    --list-managed-instances-results=PAGELESS \
    --no-force-update-on-repair > /dev/null 2>&1) &
spinner
echo -e "\r${GREEN}${BOLD}✔ Instance group 2 created!          ${RESET}"

echo -n "${CYAN}${BOLD}📈 Setting autoscaling for group 2..."
(gcloud beta compute instance-groups managed set-autoscaling instance-group-2 \
    --project=$DEVSHELL_PROJECT_ID \
    --zone=$ZONE_2 \
    --cool-down-period=45 \
    --max-num-replicas=5 \
    --min-num-replicas=1 \
    --mode=on \
    --target-cpu-utilization=0.8 > /dev/null 2>&1) &
spinner
echo -e "\r${GREEN}${BOLD}✔ Autoscaling configured for group 2!          ${RESET}"
echo

# Step 5: Utility VM
echo "${MAGENTA}${BOLD}▐▓▒▌ STEP 5: UTILITY VM ${BLUE}${BOLD}◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈${RESET}"
echo
echo -n "${CYAN}${BOLD}🖥️ Creating utility VM..."
(gcloud compute instances create utility-vm \
    --zone $ZONE_1 \
    --machine-type e2-micro \
    --network my-internal-app \
    --subnet subnet-a \
    --private-network-ip 10.10.20.50 > /dev/null 2>&1) &
spinner
echo -e "\r${GREEN}${BOLD}✔ Utility VM created!          ${RESET}"
echo

# Step 6: Load Balancer Components
echo "${MAGENTA}${BOLD}▐▓▒▌ STEP 6: LOAD BALANCER SETUP ${BLUE}${BOLD}◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈${RESET}"
echo
echo -n "${CYAN}${BOLD}🩺 Creating health check..."
(curl -s -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  -d '{
    "checkIntervalSec": 5,
    "description": "",
    "healthyThreshold": 2,
    "name": "my-ilb-health-check",
    "region": "projects/'"$DEVSHELL_PROJECT_ID"'/regions/'"$REGION"'",
    "tcpHealthCheck": {
      "port": 80,
      "proxyHeader": "NONE"
    },
    "timeoutSec": 5,
    "type": "TCP",
    "unhealthyThreshold": 2
  }' \
  "https://compute.googleapis.com/compute/beta/projects/$DEVSHELL_PROJECT_ID/regions/$REGION/healthChecks" > /dev/null 2>&1) &
spinner
echo -e "\r${GREEN}${BOLD}✔ Health check created!          ${RESET}"

sleep 10  # Allow health check to propagate

echo -n "${CYAN}${BOLD}⚖️ Creating backend service..."
(curl -s -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  -d '{
    "backends": [
      {
        "balancingMode": "CONNECTION",
        "failover": false,
        "group": "projects/'"$DEVSHELL_PROJECT_ID"'/zones/'"$ZONE_1"'/instanceGroups/instance-group-1"
      },
      {
        "balancingMode": "CONNECTION",
        "failover": false,
        "group": "projects/'"$DEVSHELL_PROJECT_ID"'/zones/'"$ZONE_2"'/instanceGroups/instance-group-2"
      }
    ],
    "connectionDraining": {
      "drainingTimeoutSec": 300
    },
    "description": "",
    "failoverPolicy": {},
    "healthChecks": [
      "projects/'"$DEVSHELL_PROJECT_ID"'/regions/'"$REGION"'/healthChecks/my-ilb-health-check"
    ],
    "loadBalancingScheme": "INTERNAL",
    "logConfig": {
      "enable": false
    },
    "name": "my-ilb",
    "network": "projects/'"$DEVSHELL_PROJECT_ID"'/global/networks/my-internal-app",
    "protocol": "TCP",
    "region": "projects/'"$DEVSHELL_PROJECT_ID"'/regions/'"$REGION"'",
    "sessionAffinity": "NONE"
  }' \
  "https://compute.googleapis.com/compute/v1/projects/$DEVSHELL_PROJECT_ID/regions/$REGION/backendServices" > /dev/null 2>&1) &
spinner
echo -e "\r${GREEN}${BOLD}✔ Backend service created!          ${RESET}"

sleep 15  # Allow backend service to propagate

echo -n "${CYAN}${BOLD}🚦 Creating forwarding rule..."
(curl -s -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  -d '{
    "IPAddress": "10.10.30.5",
    "IPProtocol": "TCP",
    "allowGlobalAccess": false,
    "backendService": "projects/'"$DEVSHELL_PROJECT_ID"'/regions/'"$REGION"'/backendServices/my-ilb",
    "description": "",
    "ipVersion": "IPV4",
    "loadBalancingScheme": "INTERNAL",
    "name": "my-ilb-forwarding-rule",
    "networkTier": "PREMIUM",
    "ports": ["80"],
    "region": "projects/'"$DEVSHELL_PROJECT_ID"'/regions/'"$REGION"'",
    "subnetwork": "projects/'"$DEVSHELL_PROJECT_ID"'/regions/'"$REGION"'/subnetworks/subnet-b"
  }' \
  "https://compute.googleapis.com/compute/v1/projects/$DEVSHELL_PROJECT_ID/regions/$REGION/forwardingRules" > /dev/null 2>&1) &
spinner
echo -e "\r${GREEN}${BOLD}✔ Forwarding rule created!          ${RESET}"
echo

# Completion Message
echo
echo "${BG_BLUE}${WHITE}${BOLD}╔════════════════════════════════════════════════════╗${RESET}"
echo "${BG_BLUE}${WHITE}${BOLD}  🎉 LAB COMPLETE! 🎉       ${RESET}"
echo "${BG_BLUE}${WHITE}${BOLD}╚════════════════════════════════════════════════════╝${RESET}"
echo
echo "${GREEN}${BOLD}✔ All resources have been successfully deployed${RESET}"
echo
echo "${CYAN}${BOLD}🔹 Primary Zone: ${BLUE}$ZONE_1${RESET}"
echo "${CYAN}${BOLD}🔹 Secondary Zone: ${BLUE}$ZONE_2${RESET}"
echo "${CYAN}${BOLD}🔹 Region: ${BLUE}$REGION${RESET}"
echo
echo "${MAGENTA}${BOLD}For more cloud engineering tutorials, visit:${RESET}"
echo "${BLUE}${BOLD}👉 https://www.youtube.com/@cloudwalejijaji/${RESET}"
echo
echo "${YELLOW}${BOLD}💡 Tip: Use 'gcloud compute instances list' to view your VMs${RESET}"
echo

# Cleanup function
remove_files() {
    echo -n "${CYAN}${BOLD}🧹 Cleaning up temporary files..."
    for file in *; do
        if [[ "$file" == gsp* || "$file" == arc* || "$file" == shell* ]]; then
            if [[ -f "$file" ]]; then
                rm "$file" > /dev/null 2>&1
            fi
        fi
    done
    echo -e "\r${GREEN}${BOLD}✔ Temporary files cleaned up!          ${RESET}"
}

remove_files
