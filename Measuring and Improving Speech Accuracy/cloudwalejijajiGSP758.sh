#!/bin/bash


BLUE=$(tput setaf 12)
GREEN=$(tput setaf 10)
YELLOW=$(tput setaf 11)
CYAN=$(tput setaf 14)
WHITE=$(tput setaf 7)  
BOLD=$(tput bold)
UNDERLINE=$(tput smul)
NC=$(tput sgr0)  # Reset all attributes

clear

# Welcome header with better centering
header="WELCOME TO DR ABHISHEK CHANNEL"
width=50
padding=$(( ($width - ${#header}) / 2 ))

echo -e "${BLUE}${BOLD}╔════════════════════════════════════════════════╗"
printf "║%*s%s%*s║\n" $padding "" "$header" $padding ""
echo -e "╚════════════════════════════════════════════════╝${NC}\n"


while true; do
    read -p "${WHITE}${BOLD}Enter your GCP Zone (e.g. us-central1-a): ${NC}" ZONE
    if [[ -z "$ZONE" ]]; then
        echo -e "${YELLOW}Zone cannot be empty. Please try again.${NC}"
    else
        break
    fi
done
echo

# Service activation with error handling
echo -e "${YELLOW}${BOLD}⚙️  Enabling required services...${NC}"
if ! gcloud services enable notebooks.googleapis.com; then
    echo -e "${RED}Failed to enable notebooks API${NC}"
    exit 1
fi

if ! gcloud services enable aiplatform.googleapis.com; then
    echo -e "${RED}Failed to enable AI Platform API${NC}"
    exit 1
fi

sleep 5  # Reduced wait time

# Notebook creation with progress indicator
echo -e "\n${CYAN}${BOLD}🖥️  Creating new AI Notebook instance...${NC}"
echo -ne "${YELLOW}⏳ Working"

NOTEBOOK_NAME="lab-workbench"
MACHINE_TYPE="e2-standard-2"


(
    gcloud notebooks instances create "$NOTEBOOK_NAME" \
        --location="$ZONE" \
        --vm-image-project=deeplearning-platform-release \
        --vm-image-family=tf-latest-cpu > /dev/null 2>&1
) &
pid=$!

# Spinner animation
while kill -0 $pid 2>/dev/null; do
    echo -n "."
    sleep 2
done

echo -e "\n${GREEN}${BOLD}✅ Notebook instance created successfully!${NC}"


PROJECT_ID=$(gcloud config get-value project)
echo -e "\n${YELLOW}${BOLD}🔗 You can access your notebook at:${NC}"
echo -e "${BLUE}${UNDERLINE}https://console.cloud.google.com/vertex-ai/workbench/user-managed?project=${PROJECT_ID}${NC}"
echo -e "\n${WHITE}You can Ctrl+Click the link or copy/paste it into your browser.${NC}"

# Footer with better formatting
echo -e "\n${GREEN}${BOLD}╔════════════════════════════════════════════════╗"
echo -e "║         NOW FOLLOW THE VIDEO FOR NEXT TASK      ║"
echo -e "╚════════════════════════════════════════════════╝${NC}"

echo -e "\n${WHITE}For more cloud tutorials:${NC}"
echo -e "${CYAN}${BOLD}╭────────────────────────────────────────────╮"
echo -e "│    Cloud Wale Jija Ji's YouTube Channel         │"
echo -e "│    ${BLUE}${UNDERLINE}https://youtube.com/@cloudwalejijaji${NC}${CYAN}    │"
echo -e "╰────────────────────────────────────────────╯${NC}"
