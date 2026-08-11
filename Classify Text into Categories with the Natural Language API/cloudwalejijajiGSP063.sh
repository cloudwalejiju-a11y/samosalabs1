#!/bin/bash

# Define color variables
BLACK='\033[0;90m'
RED='\033[0;91m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
BLUE='\033[0;94m'
MAGENTA='\033[0;95m'
CYAN='\033[0;96m'
WHITE='\033[0;97m'

NC='\033[0m' # No Color
BOLD='\033[1m'
UNDERLINE='\033[4m'

# Box drawing characters
BOX_TOP="${BLUE}╔══════════════════════════════════════════════════╗${NC}"
BOX_MID="${BLUE}║      Welcome to Dr abhishek Channel                                            ║${NC}"
BOX_BOT="${BLUE}╚══════════════════════════════════════════════════╝${NC}"

clear

# Welcome message with box design
echo -e "\n${BOX_TOP}"
echo -e "${BLUE}${BOLD}          INITIATING LAB EXECUTION...          ${NC}"
echo -e "${BOX_BOT}\n"

# Section header function
section() {
    echo -e "\n${YELLOW}${BOLD}▐▓▒░ ${1} ░▒▓▌${NC}"
}

# Get API key
section "Configuration Setup"
echo -e "${WHITE}Please enter your API key to continue:${NC}"
read -p "$(echo -e "${YELLOW}${BOLD}➤ API Key: ${NC}")" KEY
export KEY

# Enable API
section "Enabling Natural Language API"
echo -e "${CYAN}› Enabling the Natural Language API...${NC}"
gcloud services enable language.googleapis.com

# Zone information
section "Fetching Instance Information"
echo -e "${MAGENTA}› Retrieving your compute instance zone...${NC}"
ZONE="$(gcloud compute instances list --project=$DEVSHELL_PROJECT_ID --format='value(ZONE)')"

# Add metadata
section "Configuring Instance Metadata"
echo -e "${GREEN}› Adding API key to instance metadata...${NC}"
gcloud compute instances add-metadata linux-instance \
    --metadata API_KEY="$KEY" \
    --project=$DEVSHELL_PROJECT_ID \
    --zone=$ZONE

# Create script
section "Creating Analysis Script"
echo -e "${BLUE}› Generating prepare_disk.sh script...${NC}"
cat > prepare_disk.sh <<'EOF'
#!/bin/bash

# Get API key from metadata
API_KEY=$(curl -H "Metadata-Flavor: Google" \
    http://metadata.google.internal/computeMetadata/v1/instance/attributes/API_KEY)

export API_KEY="$API_KEY"

# Create request JSON
cat > request.json <<'REQUEST_EOF'
{
    "document":{
        "type":"PLAIN_TEXT",
        "content":"A Smoky Lobster Salad With a Tapa Twist. This spin on the Spanish pulpo a la gallega skips the octopus, but keeps the sea salt, olive oil, pimentón and boiled potatoes."
    }
}
REQUEST_EOF

# Make API call
echo "Analyzing text content..."
curl "https://language.googleapis.com/v1/documents:classifyText?key=${API_KEY}" \
    -s -X POST -H "Content-Type: application/json" --data-binary @request.json

# Save results
curl "https://language.googleapis.com/v1/documents:classifyText?key=${API_KEY}" \
    -s -X POST -H "Content-Type: application/json" --data-binary @request.json > result.json

echo "Analysis complete. Results saved to result.json"
EOF

# Transfer script
section "Transferring Script to Instance"
echo -e "${MAGENTA}› Copying script to compute instance...${NC}"
gcloud compute scp prepare_disk.sh linux-instance:/tmp \
    --project=$DEVSHELL_PROJECT_ID \
    --zone=$ZONE \
    --quiet

# Execute script
section "Executing Text Analysis"
echo -e "${CYAN}› Running analysis on compute instance...${NC}"
gcloud compute ssh linux-instance \
    --project=$DEVSHELL_PROJECT_ID \
    --zone=$ZONE \
    --quiet \
    --command="export API_KEY=$KEY && bash /tmp/prepare_disk.sh"

# BigQuery setup
section "Configuring BigQuery"
echo -e "${GREEN}› Creating dataset for classification results...${NC}"
bq --location=US mk --dataset $DEVSHELL_PROJECT_ID:news_classification_dataset

echo -e "${GREEN}› Creating table structure...${NC}"
bq mk --table $DEVSHELL_PROJECT_ID:news_classification_dataset.article_data \
    article_text:STRING,category:STRING,confidence:FLOAT

# Completion message
echo -e "\n${GREEN}${BOLD}╔══════════════════════════════════════════════════╗"
echo -e "║          LAB  COMPLETED SUCCESSFULLY!      ║"
echo -e "╚══════════════════════════════════════════════════╝${NC}"

# Footer with channel information
echo -e "\n${WHITE}${BOLD}For more cloud related  content:${NC}"
echo -e "${RED}${BOLD}► Subscribe to Cloud Wale Jija Ji's YouTube Channel:${NC}"
echo -e "${BLUE}${UNDERLINE}https://www.youtube.com/@cloudwalejijaji/playlists${NC}\n"
