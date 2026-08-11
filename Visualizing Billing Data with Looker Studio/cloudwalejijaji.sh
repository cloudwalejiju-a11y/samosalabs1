#!/bin/bash

# Enhanced Color Definitions
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

clear

# Display Header
echo "${CYAN}${BOLD}============================================${RESET}"
echo "${CYAN}${BOLD}   DR. ABHISHEK'S BIGQUERY BILLING ANALYSIS ${RESET}"
echo "${CYAN}${BOLD}============================================${RESET}"
echo "${BLUE}YouTube Channel: https://www.youtube.com/@cloudwalejijaji${RESET}"
echo "${MAGENTA}Video Tutorials: https://www.youtube.com/@cloudwalejijaji/videos${RESET}"
echo

# Set the billing export table path
BILLING_TABLE="ctg-storage.bigquery_billing_export.gcp_billing_export_v1_01150A_B8F62B_47D999"

# Query 1: Show all billing data
echo "${YELLOW}${BOLD}Step 1: Displaying Billing Data Overview${RESET}"
bq query --use_legacy_sql=false \
"SELECT * FROM \`${BILLING_TABLE}\` LIMIT 10"
echo "${GREEN}✓ Basic billing data retrieved${RESET}"
echo

# Query 2: List unique services
echo "${YELLOW}${BOLD}Step 2: Analyzing Services Used${RESET}"
bq query --use_legacy_sql=false \
"SELECT service.description as service_name 
FROM \`${BILLING_TABLE}\` 
GROUP BY service_name
ORDER BY service_name"
echo "${GREEN}✓ Service inventory completed${RESET}"
echo

# Query 3: Count usage by service
echo "${YELLOW}${BOLD}Step 3: Calculating Service Usage Frequency${RESET}"
bq query --use_legacy_sql=false \
"SELECT 
  service.description as service_name, 
  COUNT(*) as usage_count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM \`${BILLING_TABLE}\` 
GROUP BY service_name
ORDER BY usage_count DESC"
echo "${GREEN}✓ Service usage analysis completed${RESET}"
echo

# Query 4: List unique regions
echo "${YELLOW}${BOLD}Step 4: Identifying Resource Locations${RESET}"
bq query --use_legacy_sql=false \
"SELECT 
  location.region as region,
  COUNT(*) as record_count
FROM \`${BILLING_TABLE}\` 
WHERE location.region IS NOT NULL
GROUP BY region
ORDER BY record_count DESC"
echo "${GREEN}✓ Regional distribution analyzed${RESET}"
echo

# Query 5: Cost analysis by region
echo "${YELLOW}${BOLD}Step 5: Calculating Costs by Region${RESET}"
bq query --use_legacy_sql=false \
"SELECT
  location.region as region,
  COUNT(*) as usage_count,
  SUM(cost) as total_cost,
  AVG(cost) as average_cost,
  MIN(cost) as min_cost,
  MAX(cost) as max_cost
FROM \`${BILLING_TABLE}\`
WHERE location.region IS NOT NULL
GROUP BY region
ORDER BY total_cost DESC"
echo "${GREEN}✓ Regional cost analysis completed${RESET}"
echo

# Completion Message
echo "${MAGENTA}${BOLD}============================================${RESET}"
echo "${MAGENTA}${BOLD}   BILLING ANALYSIS COMPLETED SUCCESSFULLY!${RESET}"
echo "${MAGENTA}${BOLD}============================================${RESET}"
echo
echo "${GREEN}${BOLD}Key Insights:${RESET}"
echo "1. Services used in your GCP environment"
echo "2. Most frequently used services"
echo "3. Regional distribution of resources"
echo "4. Cost breakdown by region"
echo
echo "${CYAN}${BOLD}For more cloud cost optimization tutorials:${RESET}"
echo "${BLUE}Subscribe to Cloud Wale Jija Ji's YouTube Channel:${RESET}"
echo "${WHITE}https://www.youtube.com/@cloudwalejijaji${RESET}"
echo "${BLUE}Video Tutorials:${RESET}"
echo "${WHITE}https://www.youtube.com/@cloudwalejijaji/videos${RESET}"
