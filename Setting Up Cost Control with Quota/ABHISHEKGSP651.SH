#!/bin/bash

# Define color variables
BLUE=$'\033[0;94m'
RED=$'\033[0;91m'
GREEN=$'\033[0;92m'
YELLOW=$'\033[0;93m'
MAGENTA=$'\033[0;95m'
CYAN=$'\033[0;96m'
WHITE=$'\033[0;97m'
RESET=$'\033[0m'

# Text formatting
BOLD=$'\033[1m'
UNDERLINE=$'\033[4m'
BLINK=$'\033[5m'

# Clear screen
clear

# Welcome message with improved design
echo "${BLUE}${BOLD}╔══════════════════════════════════════════════════╗${RESET}"
echo "${BLUE}${BOLD}║                                                  ║${RESET}"
echo "${BLUE}${BOLD}║          Welcome to Dr abhishek Cloud Session         ║${RESET}"
echo "${BLUE}${BOLD}║                                                  ║${RESET}"
echo "${BLUE}${BOLD}╚══════════════════════════════════════════════════╝${RESET}"
echo ""
echo "${WHITE}${BOLD}Initializing environment...${RESET}"
echo ""

# Execute BigQuery SQL Query
echo "${YELLOW}${BOLD}▶ Executing BigQuery SQL Query...${RESET}"
bq query --use_legacy_sql=false \
"
SELECT
    w1mpro_ep,
    mjd,
    load_id,
    frame_id
FROM
    \`bigquery-public-data.wise_all_sky_data_release.mep_wise\`
ORDER BY
    mjd ASC
LIMIT 500
"

echo ""
echo "${CYAN}${BOLD}▶ Checking BigQuery Service Quota...${RESET}"
gcloud alpha services quota list --service=bigquery.googleapis.com --consumer=projects/${DEVSHELL_PROJECT_ID} --filter="usage"

echo ""
echo "${MAGENTA}${BOLD}▶ Updating BigQuery Quota...${RESET}"
gcloud alpha services quota update --consumer=projects/${DEVSHELL_PROJECT_ID} --service bigquery.googleapis.com --metric bigquery.googleapis.com/quota/query/usage --value 262144 --unit 1/d/{project}/{user} --force

echo ""
echo "${CYAN}${BOLD}▶ Verifying Updated Quota Settings...${RESET}"
gcloud alpha services quota list --service=bigquery.googleapis.com --consumer=projects/${DEVSHELL_PROJECT_ID} --filter="usage"

echo ""
echo "${YELLOW}${BOLD}▶ Executing Uncached Query...${RESET}"
bq query --use_legacy_sql=false --nouse_cache \
"
SELECT
    w1mpro_ep,
    mjd,
    load_id,
    frame_id
FROM
    \`bigquery-public-data.wise_all_sky_data_release.mep_wise\`
ORDER BY
    mjd ASC
LIMIT 500
"

# Completion message
echo ""
echo "${GREEN}${BOLD}╔══════════════════════════════════════════════════╗${RESET}"
echo "${GREEN}${BOLD}║                                                  ║${RESET}"
echo "${GREEN}${BOLD}║          NOW TIME TO SUBSCRIBE THE CHANNEL        ║${RESET}"
echo "${GREEN}${BOLD}║                                                  ║${RESET}"
echo "${GREEN}${BOLD}╚══════════════════════════════════════════════════╝${RESET}"
echo ""
echo "${RED}${BOLD}For more educational content:${RESET}"
echo "${BLUE}${UNDERLINE}Subscribe to Dr. Abhishek's YouTube Channel${RESET}"
echo "${WHITE}${BOLD}👉 ${BLINK}https://www.youtube.com/@drabhishek.5460/featured${RESET}"
echo ""
echo "${GREEN}${BOLD}Thank you!${RESET}"
echo ""
