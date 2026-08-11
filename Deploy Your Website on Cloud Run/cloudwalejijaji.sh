#!/bin/bash

# Color Definitions
BOLD=$(tput bold)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
RESET=$(tput sgr0)

# Header
echo "${CYAN}${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${CYAN}${BOLD}      Welcome to my channel        ${RESET}"
echo "${CYAN}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${BLUE}${BOLD}          Tutorial by Cloud Wale Jija Ji                        ${RESET}"
echo "${YELLOW}For more GCP tutorials, visit: https://www.youtube.com/@cloudwalejijaji${RESET}"
echo
echo "${GREEN}${BOLD}Starting deployment...${RESET}"
echo

# Section 1: Initial Setup
echo "${BOLD}${RED}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${BOLD}${RED}                    Initial Setup                        ${RESET}"
echo "${BOLD}${RED}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${GREEN}Checking authentication and region...${RESET}"
gcloud auth list
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")
echo "${GREEN}Region set to: ${REGION}${RESET}"

# Section 2: Clone Repository
echo
echo "${BOLD}${RED}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${BOLD}${RED}                    Cloning Repository                   ${RESET}"
echo "${BOLD}${RED}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${GREEN}Cloning monolith-to-microservices repository...${RESET}"
git clone https://github.com/googlecodelabs/monolith-to-microservices.git
cd ~/monolith-to-microservices
./setup.sh

# Section 3: Artifact Registry Setup
echo
echo "${BOLD}${RED}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${BOLD}${RED}                Artifact Registry Setup                  ${RESET}"
echo "${BOLD}${RED}╚════════════════════════════════════════════════════════╝${RESET}"
echo
cd ~/monolith-to-microservices/monolith
echo "${GREEN}Creating Artifact Registry repository...${RESET}"
gcloud artifacts repositories create monolith-demo --location=$REGION --repository-format=docker --description="Docker repository for monolith demo"

echo "${GREEN}Configuring Docker authentication...${RESET}"
gcloud auth configure-docker $REGION-docker.pkg.dev

# Section 4: Enable Services
echo
echo "${BOLD}${RED}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${BOLD}${RED}                  Enabling GCP Services                  ${RESET}"
echo "${BOLD}${RED}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${GREEN}Enabling required GCP services...${RESET}"
gcloud services enable artifactregistry.googleapis.com \
    cloudbuild.googleapis.com \
    run.googleapis.com

# Section 5: Initial Build and Deploy
echo
echo "${BOLD}${RED}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${BOLD}${RED}                Initial Build and Deploy                 ${RESET}"
echo "${BOLD}${RED}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${GREEN}Building and submitting monolith image (v1.0.0)...${RESET}"
gcloud builds submit --tag $REGION-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/monolith-demo/monolith:1.0.0

echo "${GREEN}Deploying monolith to Cloud Run...${RESET}"
gcloud run deploy monolith --image $REGION-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/monolith-demo/monolith:1.0.0 --allow-unauthenticated --region $REGION

# Section 6: Concurrency Testing
echo
echo "${BOLD}${RED}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${BOLD}${RED}                Concurrency Testing                     ${RESET}"
echo "${BOLD}${RED}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${GREEN}Testing with concurrency=1...${RESET}"
gcloud run deploy monolith --image $REGION-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/monolith-demo/monolith:1.0.0 --allow-unauthenticated --region $REGION --concurrency 1

echo "${GREEN}Testing with concurrency=80...${RESET}"
gcloud run deploy monolith --image $REGION-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/monolith-demo/monolith:1.0.0 --allow-unauthenticated --region $REGION --concurrency 80

# Section 7: Frontend Update
echo
echo "${BOLD}${RED}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${BOLD}${RED}                  Frontend Update                       ${RESET}"
echo "${BOLD}${RED}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${GREEN}Updating frontend code...${RESET}"
cd ~/monolith-to-microservices/react-app/src/pages/Home
mv index.js.new index.js
cat ~/monolith-to-microservices/react-app/src/pages/Home/index.js

# Section 8: Rebuild and Redeploy
echo
echo "${BOLD}${RED}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${BOLD}${RED}                  Rebuild and Redeploy                   ${RESET}"
echo "${BOLD}${RED}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${GREEN}Building monolith with updated frontend...${RESET}"
cd ~/monolith-to-microservices/react-app
npm run build:monolith

echo "${GREEN}Building and submitting monolith image (v2.0.0)...${RESET}"
cd ~/monolith-to-microservices/monolith
gcloud builds submit --tag $REGION-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/monolith-demo/monolith:2.0.0

echo "${GREEN}Deploying updated monolith to Cloud Run...${RESET}"
gcloud run deploy monolith --image $REGION-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/monolith-demo/monolith:2.0.0 --allow-unauthenticated --region $REGION

# Completion Message
echo
echo "${GREEN}${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${GREEN}${BOLD}             Lab Completed Successfully!          ${RESET}"
echo "${GREEN}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${RED}${BOLD}🙏 Thank you for following Cloud Wale Jija Ji's tutorial!${RESET}"
echo "${YELLOW}${BOLD}📺 Subscribe for more GCP content:${RESET}"
echo "${BLUE}https://www.youtube.com/@cloudwalejijaji${RESET}"
echo
