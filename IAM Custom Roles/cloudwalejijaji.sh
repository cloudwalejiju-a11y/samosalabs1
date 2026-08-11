#!/bin/bash

# Define color variables
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

# Welcome Banner
echo
echo "${CYAN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}          DR. ABHISHEK'S IAM ROLES MANAGEMENT LAB          ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${WHITE_TEXT}This lab demonstrates custom IAM role creation and management${RESET_FORMAT}"
echo

echo "${GREEN_TEXT}${BOLD_TEXT}=== INITIATING IAM ROLE OPERATIONS ===${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}📝 Creating a custom IAM role definition...${RESET_FORMAT}"
echo 'title: "Role Editor"
description: "Edit access for App Versions"
stage: "ALPHA"
includedPermissions:
- appengine.versions.create
- appengine.versions.delete' > role-definition.yaml

echo "${BLUE_TEXT}${BOLD_TEXT}🛠️  Creating IAM Role 'editor'...${RESET_FORMAT}"
gcloud iam roles create editor --project $DEVSHELL_PROJECT_ID \
--file role-definition.yaml

echo "${BLUE_TEXT}${BOLD_TEXT}🛠️  Creating IAM Role 'viewer' with specific permissions...${RESET_FORMAT}"
gcloud iam roles create viewer --project $DEVSHELL_PROJECT_ID \
--title "Role Viewer" --description "Custom role description." \
--permissions compute.instances.get,compute.instances.list --stage ALPHA

echo "${YELLOW_TEXT}${BOLD_TEXT}🔄 Updating IAM Role 'editor'...${RESET_FORMAT}"
echo 'description: Edit access for App Versions
etag:
includedPermissions:
- appengine.versions.create
- appengine.versions.delete
- storage.buckets.get
- storage.buckets.list
name: projects/'$DEVSHELL_PROJECT_ID'/roles/editor
stage: ALPHA
title: Role Editor' > new-role-definition.yaml

gcloud iam roles update editor --project $DEVSHELL_PROJECT_ID \
--file new-role-definition.yaml --quiet

echo "${BLUE_TEXT}${BOLD_TEXT}🔄 Updating IAM Role 'viewer' with additional permissions...${RESET_FORMAT}"
gcloud iam roles update viewer --project $DEVSHELL_PROJECT_ID \
--add-permissions storage.buckets.get,storage.buckets.list

echo "${RED_TEXT}${BOLD_TEXT}⛔ Disabling IAM Role 'viewer'...${RESET_FORMAT}"
gcloud iam roles update viewer --project $DEVSHELL_PROJECT_ID \
--stage DISABLED

echo "${RED_TEXT}${BOLD_TEXT}🗑️  Deleting IAM Role 'viewer'...${RESET_FORMAT}"
gcloud iam roles delete viewer --project $DEVSHELL_PROJECT_ID

echo "${GREEN_TEXT}${BOLD_TEXT}♻️  Restoring IAM Role 'viewer'...${RESET_FORMAT}"
gcloud iam roles undelete viewer --project $DEVSHELL_PROJECT_ID

# Completion Message
echo
echo "${GREEN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}             IAM ROLES LAB COMPLETED SUCCESSFULLY         ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}💡 For more cloud tutorials and labs:${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}Subscribe to Cloud Wale Jija Ji's YouTube Channel${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}https://www.youtube.com/@cloudwalejijaji${RESET_FORMAT}"
echo
