#!/bin/bash


CYAN_BOLD=$'\033[1;36m'
PURPLE_BOLD=$'\033[1;35m'
GREEN_BOLD=$'\033[1;32m'
YELLOW_BOLD=$'\033[1;33m'
RED_BOLD=$'\033[1;31m'
BLUE_BOLD=$'\033[1;34m'
ORANGE_BOLD=$'\033[1;38;5;208m'
WHITE_BOLD=$'\033[1;37m'
RESET_FORMAT=$'\033[0m'

clear


echo
echo "${BLUE_BOLD}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${BLUE_BOLD}          🚀 Welcome to Cloud Wale Jija Ji's Cloud Tutorial     ${RESET_FORMAT}"
echo "${BLUE_BOLD}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo

# User input with emoji
read -p "$(echo -e ${YELLOW_BOLD}🌍 Enter the region: ${RESET_FORMAT}) " REGION
export REGION=$REGION
echo "${GREEN_BOLD}✅ You have selected the region: ${WHITE_BOLD}$REGION${RESET_FORMAT}"
echo

# First Spanner instance
echo "${PURPLE_BOLD}🛢️  Creating first Spanner instance: banking-instance${RESET_FORMAT}"
echo "${CYAN_BOLD}This will be created in region: $REGION${RESET_FORMAT}"
echo
gcloud spanner instances create banking-instance \
  --config=regional-$REGION \
  --description="Cloud-Spanner-Lab" \
  --nodes=1

# First database
echo "${PURPLE_BOLD}💾 Creating first database: banking-db${RESET_FORMAT}"
echo "${CYAN_BOLD}This will be created in banking-instance${RESET_FORMAT}"
echo
gcloud spanner databases create banking-db --instance=banking-instance

# Second Spanner instance
echo "${PURPLE_BOLD}🛢️  Creating second Spanner instance: banking-instance-2${RESET_FORMAT}"
echo "${CYAN_BOLD}This will have 2 nodes for increased capacity${RESET_FORMAT}"
echo
gcloud spanner instances create banking-instance-2 \
  --config=regional-$REGION \
  --description="Cloud-Spanner-Lab" \
  --nodes=2

# Second database
echo "${PURPLE_BOLD}💾 Creating second database: banking-db-2${RESET_FORMAT}"
echo "${CYAN_BOLD}This will be created in banking-instance-2${RESET_FORMAT}"
echo
gcloud spanner databases create banking-db-2 --instance=banking-instance-2

# Schema update
echo "${PURPLE_BOLD}📊 Updating schema for banking-db${RESET_FORMAT}"
echo "${CYAN_BOLD}Creating Customer table with required fields${RESET_FORMAT}"
echo
gcloud spanner databases ddl update banking-db --instance=banking-instance --ddl="CREATE TABLE Customer (
  CustomerId STRING(36) NOT NULL,
  Name STRING(MAX) NOT NULL,
  Location STRING(MAX) NOT NULL,
) PRIMARY KEY (CustomerId);"


echo
echo "${GREEN_BOLD}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${GREEN_BOLD}          🎉 Spanner Lab Completed Successfully!        ${RESET_FORMAT}"
echo "${GREEN_BOLD}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo -e "${YELLOW_BOLD}📺 Subscribe to my Channel:${RESET_FORMAT} ${BLUE_BOLD}https://www.youtube.com/@cloudwalejijaji${RESET_FORMAT}"
echo -e "${ORANGE_BOLD}📷 Follow on Instagram:${RESET_FORMAT} ${PURPLE_BOLD}https://www.instagram.com/@cloudwalejijaji/${RESET_FORMAT}"
echo
