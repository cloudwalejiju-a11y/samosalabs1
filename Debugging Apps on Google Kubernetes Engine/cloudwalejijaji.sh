#!/bin/bash

# Enhanced Color Definitions
BLACK=$'\033[0;90m'
RED=$'\033[0;91m'
GREEN=$'\033[0;92m'
YELLOW=$'\033[0;93m'
BLUE=$'\033[0;94m'
MAGENTA=$'\033[0;95m'
CYAN=$'\033[0;96m'
WHITE=$'\033[0;97m'

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

# Header Section
echo "${BG_MAGENTA}${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${BG_MAGENTA}${BOLD}       WELCOME TO DR ABHISHEK CLOUD  TUTORIAL              ${RESET}"
echo "${BG_MAGENTA}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${CYAN}${BOLD}          Expert Tutorial by Cloud Wale Jija Ji              ${RESET}"
echo "${YELLOW}For more GCP tutorials, visit: https://www.youtube.com/@cloudwalejijaji${RESET}"
echo
echo "${BLUE}${BOLD}⚡ Initializing Microservices Monitoring Setup...${RESET}"
echo

# Environment Setup
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ ENVIRONMENT CONFIGURATION ▬▬▬▬▬▬▬▬▬${RESET}"
echo "${YELLOW}Setting compute zone to ${WHITE}${BOLD}$ZONE${RESET}"
gcloud config set compute/zone $ZONE

export PROJECT_ID=$(gcloud info --format='value(config.project)')
echo "${YELLOW}Project ID: ${WHITE}${BOLD}$PROJECT_ID${RESET}"
echo

# Cluster Configuration
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ CLUSTER CONFIGURATION ▬▬▬▬▬▬▬▬▬${RESET}"
echo "${YELLOW}Getting cluster credentials...${RESET}"
gcloud container clusters get-credentials central --zone $ZONE
echo "${GREEN}✅ Cluster credentials configured!${RESET}"
echo

# Microservices Deployment
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ MICROSERVICES DEPLOYMENT ▬▬▬▬▬▬▬▬▬${RESET}"
echo "${YELLOW}Cloning microservices demo repository...${RESET}"
git clone https://github.com/xiangshen-dk/microservices-demo.git
cd microservices-demo

echo "${YELLOW}Deploying microservices...${RESET}"
kubectl apply -f release/kubernetes-manifests.yaml
echo "${GREEN}✅ Microservices deployed successfully!${RESET}"
echo "${YELLOW}Waiting 30 seconds for services to initialize...${RESET}"
sleep 30
echo

# Monitoring Setup
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ MONITORING CONFIGURATION ▬▬▬▬▬▬▬▬▬${RESET}"
echo "${YELLOW}Creating Error Rate SLI metric...${RESET}"
gcloud logging metrics create Error_Rate_SLI \
  --description="Error rate for recommendationservice" \
  --log-filter="resource.type=\"k8s_container\" severity=ERROR labels.\"k8s-pod/app\": \"recommendationservice\""
echo "${GREEN}✅ Error Rate SLI metric created!${RESET}"
echo "${YELLOW}Waiting 30 seconds for metric to propagate...${RESET}"
sleep 30
echo

# Alert Policy Creation
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ ALERT POLICY SETUP ▬▬▬▬▬▬▬▬▬${RESET}"
echo "${YELLOW}Creating alert policy configuration...${RESET}"
cat > awesome.json <<EOF_END
{
  "displayName": "Error Rate SLI",
  "userLabels": {},
  "conditions": [
    {
      "displayName": "Kubernetes Container - logging/user/Error_Rate_SLI",
      "conditionThreshold": {
        "filter": "resource.type = \"k8s_container\" AND metric.type = \"logging.googleapis.com/user/Error_Rate_SLI\"",
        "aggregations": [
          {
            "alignmentPeriod": "300s",
            "crossSeriesReducer": "REDUCE_NONE",
            "perSeriesAligner": "ALIGN_RATE"
          }
        ],
        "comparison": "COMPARISON_GT",
        "duration": "0s",
        "trigger": {
          "count": 1
        },
        "thresholdValue": 0.5
      }
    }
  ],
  "alertStrategy": {
    "autoClose": "604800s"
  },
  "combiner": "OR",
  "enabled": true,
  "notificationChannels": [],
  "severity": "SEVERITY_UNSPECIFIED"
}
EOF_END

echo "${YELLOW}Creating monitoring policy...${RESET}"
gcloud alpha monitoring policies create --policy-from-file="awesome.json"
echo "${GREEN}✅ Alert policy created successfully!${RESET}"
echo

# Completion Message
echo "${BG_GREEN}${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${BG_GREEN}${BOLD}          MONITORING TUTORIAL COMPLETE!    ${RESET}"
echo "${BG_GREEN}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${RED}${BOLD}🙏 Thank you for following Cloud Wale Jija Ji's tutorial!${RESET}"
echo "${YELLOW}${BOLD}📺 Subscribe for more GCP monitoring content:${RESET}"
echo "${BLUE}https://www.youtube.com/@cloudwalejijaji${RESET}"
echo
echo "${MAGENTA}${BOLD}📊 Happy monitoring your microservices on Google Cloud!${RESET}"
