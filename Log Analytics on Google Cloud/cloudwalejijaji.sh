#!/bin/bash

# Define text colors and formatting
BLUE=$'\033[0;94m'
YELLOW=$'\033[0;93m'
GREEN=$'\033[0;92m'
RED=$'\033[0;91m'
NC=$'\033[0m' # No Color
BOLD=$'\033[1m'

# Display header
echo
echo "${BLUE}${BOLD}╔══════════════════════════════════════════╗${NC}"
echo "${BLUE}${BOLD}║    WELCOME TO DR ABHISHEK CLOUD TUTORIALS      ║${NC}"
echo "${BLUE}${BOLD}╚══════════════════════════════════════════╝${NC}"
echo

# Step 1: Authenticate and set up environment
echo "${YELLOW}${BOLD}Step 1: Setting up GCP environment${NC}"
gcloud auth list

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")
export PROJECT_ID=$(gcloud config get-value project)

gcloud config set compute/zone "$ZONE"
gcloud config set compute/region "$REGION"

# Step 2: Configure Kubernetes cluster
echo
echo "${YELLOW}${BOLD}Step 2: Configuring Kubernetes cluster${NC}"
gcloud container clusters get-credentials day2-ops --region $REGION

# Step 3: Deploy microservices
echo
echo "${YELLOW}${BOLD}Step 3: Deploying microservices${NC}"
git clone https://github.com/GoogleCloudPlatform/microservices-demo.git
cd microservices-demo || exit

kubectl apply -f release/kubernetes-manifests.yaml

echo "${GREEN}Waiting for pods to initialize...${NC}"
sleep 45
kubectl get pods

# Step 4: Get external IP
echo
echo "${YELLOW}${BOLD}Step 4: Getting external IP${NC}"
export EXTERNAL_IP=$(kubectl get service frontend-external -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
echo "Frontend External IP: ${BLUE}${BOLD}$EXTERNAL_IP${NC}"

# Step 5: Test the deployment
echo
echo "${YELLOW}${BOLD}Step 5: Testing deployment${NC}"
HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}\n" "http://${EXTERNAL_IP}")
echo "HTTP Status Code: ${BLUE}${BOLD}$HTTP_STATUS${NC}"

# Step 6: Configure logging
echo
echo "${YELLOW}${BOLD}Step 6: Configuring logging${NC}"
gcloud logging buckets update _Default --project=$PROJECT_ID --location=global --enable-analytics

gcloud logging sinks create day2ops-sink \
    logging.googleapis.com/projects/$PROJECT_ID/locations/global/buckets/day2ops-log \
    --log-filter='resource.type="k8s_container"' \
    --include-children --format='json'

# Final output
echo
echo "${GREEN}${BOLD}Deployment completed successfully!${NC}"
echo
echo "${YELLOW}${BOLD}Next steps:${NC}"
echo "1. Access the application at: ${BLUE}http://${EXTERNAL_IP}${NC}"
echo "2. View logs in the console: ${BLUE}https://console.cloud.google.com/logs/storage/bucket?project=${PROJECT_ID}${NC}"
echo
echo "${GREEN}Subscribe for more tutorials: ${BLUE}https://www.youtube.com/@cloudwalejijaji${NC}"
