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

#----------------------------------------------------start--------------------------------------------------#

# Welcome message
echo "${BG_BLUE}${BOLD}********************************************************************************${RESET}"
echo "${BG_BLUE}${BOLD}*                                                                              *${RESET}"
echo "${BG_BLUE}${BOLD}*  ${WHITE}${BOLD}Welcome to Cloud Wale Jija Ji's Cloud Journey!                                  ${BG_BLUE}${BOLD}*${RESET}"
echo "${BG_BLUE}${BOLD}*  ${WHITE}${BOLD}Let's continue learning and growing in the world of cloud technology!     ${BG_BLUE}${BOLD}*${RESET}"
echo "${BG_BLUE}${BOLD}*                                                                              *${RESET}"
echo "${BG_BLUE}${BOLD}*  ${WHITE}${BOLD}Check out our YouTube channel for more content:                          ${BG_BLUE}${BOLD}*${RESET}"
echo "${BG_BLUE}${BOLD}*  ${YELLOW}${BOLD}https://www.youtube.com/@cloudwalejijaji                         ${BG_BLUE}${BOLD}*${RESET}"
echo "${BG_BLUE}${BOLD}*                                                                              *${RESET}"
echo "${BG_BLUE}${BOLD}********************************************************************************${RESET}"
echo ""

# Start execution message
echo "${BG_MAGENTA}${BOLD}Starting Lab Execution...${RESET}"
echo ""

# Enable API keys service
echo "${CYAN}${BOLD}Enabling apikeys.googleapis.com service...${RESET}"
gcloud services enable apikeys.googleapis.com
echo ""

# Create API key
echo "${CYAN}${BOLD}Creating API key with display name 'awesome'...${RESET}"
gcloud alpha services api-keys create --display-name="awesome" 
echo ""

# Get key name
KEY_NAME=$(gcloud alpha services api-keys list --format="value(name)" --filter "displayName=awesome")
echo "${GREEN}${BOLD}API Key Name: ${WHITE}${KEY_NAME}${RESET}"
echo ""

# Get key string
API_KEY=$(gcloud alpha services api-keys get-key-string $KEY_NAME --format="value(keyString)")
echo "${GREEN}${BOLD}API Key Value: ${WHITE}${API_KEY}${RESET}"
echo ""

# Completion message
echo "${BG_GREEN}${BLACK}${BOLD}********************************************************************************${RESET}"
echo "${BG_GREEN}${BLACK}${BOLD}*                                                                              *${RESET}"
echo "${BG_GREEN}${BLACK}${BOLD}*                    Congratulations For Completing The Lab!                    *${RESET}"
echo "${BG_GREEN}${BLACK}${BOLD}*                                                                              *${RESET}"
echo "${BG_GREEN}${BLACK}${BOLD}********************************************************************************${RESET}"
echo ""

#-----------------------------------------------------end----------------------------------------------------------#
