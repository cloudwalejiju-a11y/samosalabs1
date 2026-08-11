#!/bin/bash

# Enhanced Color Definitions
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'

NO_COLOR=$'\033[0m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

clear

echo
echo "${BLUE_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}          Welcome to   Cloud Wale Jija Ji Cloud Tutorials                 ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}Starting Dataplex Configuration Lab${RESET_FORMAT}"
echo

# Get Region Input
echo "${CYAN_TEXT}${BOLD_TEXT}➤ Region Configuration${RESET_FORMAT}"
read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter REGION: ${RESET_FORMAT}" REGION
export REGION=$REGION
echo "${GREEN_TEXT}✓ Region set to: $REGION${RESET_FORMAT}"
echo

# Enable Services
echo "${CYAN_TEXT}${BOLD_TEXT}➤ Enabling Required Services${RESET_FORMAT}"
(gcloud services enable dataplex.googleapis.com datacatalog.googleapis.com > /dev/null 2>&1) &
echo "${GREEN_TEXT}✓ Dataplex and Data Catalog services enabled${RESET_FORMAT}"
echo

# Create Dataplex Lake
echo "${CYAN_TEXT}${BOLD_TEXT}➤ Creating Dataplex Lake${RESET_FORMAT}"
(gcloud dataplex lakes create orders-lake \
  --location=$REGION \
  --display-name="Orders Lake" > /dev/null 2>&1) &
echo "${GREEN_TEXT}✓ Created 'orders-lake' in region: $REGION${RESET_FORMAT}"
echo

# Create Zone
echo "${CYAN_TEXT}${BOLD_TEXT}➤ Creating Curated Zone${RESET_FORMAT}"
(gcloud dataplex zones create customer-curated-zone \
    --location=$REGION \
    --lake=orders-lake \
    --display-name="Customer Curated Zone" \
    --resource-location-type=SINGLE_REGION \
    --type=CURATED \
    --discovery-enabled \
    --discovery-schedule="0 * * * *" > /dev/null 2>&1) &
echo "${GREEN_TEXT}✓ Created 'customer-curated-zone'${RESET_FORMAT}"
echo

# Create Asset
echo "${CYAN_TEXT}${BOLD_TEXT}➤ Creating Dataset Asset${RESET_FORMAT}"
(gcloud dataplex assets create customer-details-dataset \
    --location=$REGION \
    --lake=orders-lake \
    --zone=customer-curated-zone \
    --display-name="Customer Details Dataset" \
    --resource-type=BIGQUERY_DATASET \
    --resource-name=projects/$DEVSHELL_PROJECT_ID/datasets/customers \
    --discovery-enabled > /dev/null 2>&1) &
echo "${GREEN_TEXT}✓ Created 'customer-details-dataset' asset${RESET_FORMAT}"
echo

# Create Tag Template
echo "${CYAN_TEXT}${BOLD_TEXT}➤ Creating Tag Template${RESET_FORMAT}"
(gcloud data-catalog tag-templates create protected_data_template \
    --location=$REGION \
    --field=id=protected_data_flag,display-name="Protected Data Flag",type='enum(YES|NO)' \
    --display-name="Protected Data Template" > /dev/null 2>&1) &
echo "${GREEN_TEXT}✓ Created 'protected_data_template'${RESET_FORMAT}"
echo

# Completion Message
echo "${BLUE_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}             FOLLOW THE VIDEO NOW                 ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${CYAN_TEXT}${BOLD_TEXT}To view your Dataplex resources:${RESET_FORMAT}"
echo "${WHITE_TEXT}${BOLD_TEXT}https://console.cloud.google.com/dataplex/search?project=$DEVSHELL_PROJECT_ID${RESET_FORMAT}"
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}For more cloud tutorials, visit:${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}https://www.youtube.com/@cloudwalejijaji${RESET_FORMAT}"
echo
