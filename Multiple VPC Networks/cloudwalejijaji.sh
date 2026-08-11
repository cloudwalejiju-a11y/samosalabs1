#!/bin/bash
# Google Cloud Networking Lab Setup
# Expertly crafted by Cloud Wale Jija Ji Cloud


BOLD=$(tput bold)
UNDERLINE=$(tput smul)
RESET=$(tput sgr0)

# Text Colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)

# Background Colors
BG_RED=$(tput setab 1)
BG_GREEN=$(tput setab 2)
BG_YELLOW=$(tput setab 3)
BG_BLUE=$(tput setab 4)

clear
echo "${BG_BLUE}${BOLD}${WHITE}============================================${RESET}"
echo "${BG_BLUE}${BOLD}${WHITE}  WELCOME TO DR ABHISHEK CLOUD TUTORIAL      ${RESET}"
echo "${BG_BLUE}${BOLD}${WHITE}============================================${RESET}"
echo ""
echo "${CYAN}${BOLD}⚡ Expertly crafted by Cloud Wale Jija Ji Cloud${RESET}"
echo "${YELLOW}${BOLD}📺 YouTube: ${UNDERLINE}https://www.youtube.com/@cloudwalejijaji/videos${RESET}"
echo ""

# ======================
#  ENVIRONMENT SETUP
# ======================
echo "${MAGENTA}${BOLD}🌍 STEP 1: Configuring Network Environment${RESET}"

# Fetch zones and determine regions
echo "${WHITE}🔍 Detecting instance zones and regions...${RESET}"
export INSTANCE_ZONE_1=$(gcloud compute instances list --filter="name:mynet-vm-1" --format="value(zone)")
export INSTANCE_ZONE_2=$(gcloud compute instances list --filter="name:mynet-vm-2" --format="value(zone)")

export REGION_1=${INSTANCE_ZONE_1%-*}
export REGION_2=${INSTANCE_ZONE_2%-*}

echo "${GREEN}✔ Detected:${RESET}"
echo "${WHITE}Zone 1: ${YELLOW}$INSTANCE_ZONE_1${RESET} (Region: ${YELLOW}$REGION_1${RESET})"
echo "${WHITE}Zone 2: ${YELLOW}$INSTANCE_ZONE_2${RESET} (Region: ${YELLOW}$REGION_2${RESET})"
echo ""

# ======================
#  NETWORK CREATION
# ======================
echo "${MAGENTA}${BOLD}🖧 STEP 2: Creating Networks and Subnets${RESET}"

# Management Network
echo "${WHITE}🛠️ Creating management network...${RESET}"
gcloud compute networks create managementnet --subnet-mode=custom || {
    echo "${RED}${BOLD}❌ Failed to create management network${RESET}"
    exit 1
}

echo "${WHITE}🌐 Adding management subnet in ${YELLOW}$REGION_1${RESET}..."
gcloud compute networks subnets create managementsubnet-1 \
    --network=managementnet \
    --region=$REGION_1 \
    --range=10.130.0.0/20 || {
    echo "${RED}${BOLD}❌ Failed to create management subnet${RESET}"
    exit 1
}

# Private Network
echo "${WHITE}🛡️ Creating private network...${RESET}"
gcloud compute networks create privatenet --subnet-mode=custom || {
    echo "${RED}${BOLD}❌ Failed to create private network${RESET}"
    exit 1
}

echo "${WHITE}🔒 Adding private subnets..."
gcloud compute networks subnets create privatesubnet-1 \
    --network=privatenet \
    --region=$REGION_1 \
    --range=172.16.0.0/24 || {
    echo "${RED}${BOLD}❌ Failed to create privatesubnet-1${RESET}"
    exit 1
}

gcloud compute networks subnets create privatesubnet-2 \
    --network=privatenet \
    --region=$REGION_2 \
    --range=172.20.0.0/20 || {
    echo "${RED}${BOLD}❌ Failed to create privatesubnet-2${RESET}"
    exit 1
}

echo "${GREEN}✔ All networks and subnets created successfully${RESET}"
echo ""

# ======================
#  FIREWALL RULES
# ======================
echo "${MAGENTA}${BOLD}🔥 STEP 3: Configuring Firewall Rules${RESET}"

echo "${WHITE}🛡️ Setting up managementnet firewall rules..."
gcloud compute firewall-rules create managementnet-allow-icmp-ssh-rdp \
    --direction=INGRESS \
    --priority=1000 \
    --network=managementnet \
    --action=ALLOW \
    --rules=icmp,tcp:22,tcp:3389 \
    --source-ranges=0.0.0.0/0 || {
    echo "${RED}${BOLD}❌ Failed to create managementnet firewall rules${RESET}"
    exit 1
}

echo "${WHITE}🛡️ Setting up privatenet firewall rules..."
gcloud compute firewall-rules create privatenet-allow-icmp-ssh-rdp \
    --direction=INGRESS \
    --priority=1000 \
    --network=privatenet \
    --action=ALLOW \
    --rules=icmp,tcp:22,tcp:3389 \
    --source-ranges=0.0.0.0/0 || {
    echo "${RED}${BOLD}❌ Failed to create privatenet firewall rules${RESET}"
    exit 1
}

echo "${GREEN}✔ Firewall rules configured successfully${RESET}"
echo ""

# ======================
#  INSTANCE DEPLOYMENT
# ======================
echo "${MAGENTA}${BOLD}🖥️ STEP 4: Deploying Compute Instances${RESET}"

echo "${WHITE}🚀 Launching managementnet-vm-1 in ${YELLOW}$INSTANCE_ZONE_1${RESET}..."
gcloud compute instances create managementnet-vm-1 \
    --zone=$INSTANCE_ZONE_1 \
    --machine-type=e2-micro \
    --subnet=managementsubnet-1 || {
    echo "${RED}${BOLD}❌ Failed to create managementnet-vm-1${RESET}"
    exit 1
}

echo "${WHITE}🚀 Launching privatenet-vm-1 in ${YELLOW}$INSTANCE_ZONE_1${RESET}..."
gcloud compute instances create privatenet-vm-1 \
    --zone=$INSTANCE_ZONE_1 \
    --machine-type=e2-micro \
    --subnet=privatesubnet-1 || {
    echo "${RED}${BOLD}❌ Failed to create privatenet-vm-1${RESET}"
    exit 1
}

echo "${WHITE}🚀 Deploying vm-appliance with multiple network interfaces..."
gcloud compute instances create vm-appliance \
    --zone=$INSTANCE_ZONE_1 \
    --machine-type=e2-standard-4 \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=privatesubnet-1 \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=managementsubnet-1 \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=mynetwork || {
    echo "${RED}${BOLD}❌ Failed to create vm-appliance${RESET}"
    exit 1
}

echo "${GREEN}✔ All instances deployed successfully${RESET}"
echo ""

# ======================
#  COMPLETION MESSAGE
# ======================
echo "${BG_GREEN}${BOLD}${WHITE}============================================${RESET}"
echo "${BG_GREEN}${BOLD}${WHITE}    LAB COMPLETE!          ${RESET}"
echo "${BG_GREEN}${BOLD}${WHITE}============================================${RESET}"
echo ""
echo "${WHITE}${BOLD}🔍 Access your resources:${RESET}"
echo "${YELLOW}https://console.cloud.google.com/networking/${RESET}"
echo ""
echo "${CYAN}${BOLD}💡 For more Google Cloud labs and tutorials:${RESET}"
echo "${YELLOW}${BOLD}👉 ${UNDERLINE}https://www.youtube.com/@cloudwalejijaji/videos${RESET}"
echo "${GREEN}${BOLD}🔔 Don't forget to subscribe for daily cloud tutorials!${RESET}"
