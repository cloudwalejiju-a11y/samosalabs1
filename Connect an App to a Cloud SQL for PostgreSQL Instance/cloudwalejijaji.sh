#!/bin/bash

COLOR_BLACK=$'\033[0;90m'
COLOR_RED=$'\033[0;91m'
COLOR_GREEN=$'\033[0;92m'
COLOR_YELLOW=$'\033[0;93m'
COLOR_BLUE=$'\033[0;94m'
COLOR_MAGENTA=$'\033[0;95m'
COLOR_CYAN=$'\033[0;96m'
COLOR_WHITE=$'\033[0;97m'
STYLE_DIM=$'\033[2m'
STYLE_STRIKE=$'\033[9m'
STYLE_BOLD=$'\033[1m'
FORMAT_RESET=$'\033[0m'
BG_BLUE=$'\033[44m'
BG_YELLOW=$'\033[43m'
FG_BLACK=$'\033[30m'
FG_WHITE=$'\033[97m'

clear

# Function to display animated spinner
show_spinner() {
    local message="$1"
    local duration="$2"
    local spin_chars=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    
    tput civis
    for ((i=duration; i>0; i--)); do
        for char in "${spin_chars[@]}"; do
            printf "\r${COLOR_CYAN}${STYLE_BOLD}${char}${FORMAT_RESET} ${message} (${i}s remaining) "
            sleep 0.1
        done
    done
    tput cnorm
    printf "\r${COLOR_GREEN}✔ ${message} completed${FORMAT_RESET}\n"
}

# Header
echo
echo "${COLOR_BLUE}${STYLE_BOLD}╔══════════════════════════════════════════╗${FORMAT_RESET}"
echo "${COLOR_BLUE}${STYLE_BOLD}║  WELCOME TO DR ABHISHEK CLOUD TUTORIALS    ║${FORMAT_RESET}"
echo "${COLOR_BLUE}${STYLE_BOLD}╚══════════════════════════════════════════╝${FORMAT_RESET}"
echo
echo -e "${COLOR_RED}${STYLE_BOLD} >>-- Do like the video & Subscribe the channel --<< ${FORMAT_RESET}"
echo

# Step 1: Configure environment
echo -e "${COLOR_GREEN}${STYLE_BOLD} >>-- 🗺️ Configuring compute zone and region --<< ${FORMAT_RESET}"
export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

if [[ -z "$ZONE" ]]; then
    echo -en "${COLOR_YELLOW}${STYLE_BOLD}Enter your zone: ${FORMAT_RESET}"
    read ZONE
fi

export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

if [[ -z "$REGION" ]]; then
    REGION="${ZONE%-*}"
fi

# Step 2: Set up Artifact Registry
echo -e "${COLOR_CYAN}${STYLE_BOLD} >>-- 🛠️ Enabling Artifact Registry API --<< ${FORMAT_RESET}"
gcloud services enable artifactregistry.googleapis.com
show_spinner "Enabling Artifact Registry API" 5

# Step 3: Configure service account
echo -e "${COLOR_MAGENTA}${STYLE_BOLD} >>-- 🏷️ Setting up project and service account --<< ${FORMAT_RESET}"
export PROJECT_ID=$(gcloud config list --format 'value(core.project)')
export CLOUDSQL_SERVICE_ACCOUNT=cloudsql-service-account

gcloud iam service-accounts create $CLOUDSQL_SERVICE_ACCOUNT --project=$PROJECT_ID
show_spinner "Creating service account" 3

echo -e "${COLOR_BLUE}${STYLE_BOLD} >>-- 🔑 Assigning Cloud SQL Admin role --<< ${FORMAT_RESET}"
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="serviceAccount:$CLOUDSQL_SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com" \
--role="roles/cloudsql.admin" > /dev/null 2>&1

gcloud iam service-accounts keys create $CLOUDSQL_SERVICE_ACCOUNT.json \
    --iam-account=$CLOUDSQL_SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
    --project=$PROJECT_ID
show_spinner "Generating service account key" 4

# Step 4: Create GKE cluster
echo -e "${COLOR_CYAN}${STYLE_BOLD} >>-- ☁️ Creating GKE cluster --<< ${FORMAT_RESET}"
gcloud container clusters create postgres-cluster \
--zone=$ZONE --num-nodes=2
show_spinner "Provisioning GKE cluster" 120

# Step 5: Configure Kubernetes secrets
echo -e "${COLOR_MAGENTA}${STYLE_BOLD} >>-- 🔒 Setting up Kubernetes secrets --<< ${FORMAT_RESET}"
kubectl create secret generic cloudsql-instance-credentials \
--from-file=credentials.json=$CLOUDSQL_SERVICE_ACCOUNT.json
    
kubectl create secret generic cloudsql-db-credentials \
--from-literal=username=postgres \
--from-literal=password=supersecret! \
--from-literal=dbname=gmemegen_db
show_spinner "Configuring Kubernetes secrets" 5

# Step 6: Download application files
echo -e "${COLOR_GREEN}${STYLE_BOLD} >>-- 📦 Downloading application files --<< ${FORMAT_RESET}"
gsutil -m cp -r gs://spls/gsp919/gmemegen .
cd gmemegen || exit
show_spinner "Downloading application files" 10

# Step 7: Configure Docker repository
echo -e "${COLOR_CYAN}${STYLE_BOLD} >>-- 🐳 Configuring Docker repository --<< ${FORMAT_RESET}"
export REGION=${ZONE%-*}
export PROJECT_ID=$(gcloud config list --format 'value(core.project)')
export REPO=gmemegen

gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet
gcloud artifacts repositories create $REPO \
    --repository-format=docker --location=$REGION
show_spinner "Setting up Docker repository" 15

# Step 8: Build and push Docker image
echo -e "${COLOR_GREEN}${STYLE_BOLD} >>-- 🏗️ Building and pushing Docker image --<< ${FORMAT_RESET}"
docker build -t ${REGION}-docker.pkg.dev/${PROJECT_ID}/gmemegen/gmemegen-app:v1 .
show_spinner "Building Docker image" 45

docker push ${REGION}-docker.pkg.dev/${PROJECT_ID}/gmemegen/gmemegen-app:v1
show_spinner "Pushing Docker image" 30

# Step 9: Update deployment configuration
echo -e "${COLOR_YELLOW}${STYLE_BOLD} >>-- 📝 Updating deployment configuration --<< ${FORMAT_RESET}"
sed -i "33c\          image: $REGION-docker.pkg.dev/$PROJECT_ID/gmemegen/gmemegen-app:v1" gmemegen_deployment.yaml
sed -i "60c\                    \"-instances=$PROJECT_ID:$REGION:postgres-gmemegen=tcp:5432\"," gmemegen_deployment.yaml
show_spinner "Updating configuration" 5

# Step 10: Deploy application
echo -e "${COLOR_MAGENTA}${STYLE_BOLD} >>-- 🚀 Deploying application to Kubernetes --<< ${FORMAT_RESET}"
kubectl create -f gmemegen_deployment.yaml
show_spinner "Deploying application" 30

# Step 11: Expose service
echo -e "${COLOR_CYAN}${STYLE_BOLD} >>-- 🌐 Creating LoadBalancer service --<< ${FORMAT_RESET}"
kubectl expose deployment gmemegen \
    --type "LoadBalancer" \
    --port 80 --target-port 8080
show_spinner "Creating service" 20

# Step 12: Get service information
echo -e "${COLOR_YELLOW}${STYLE_BOLD} >>-- 🔍 Retrieving service information --<< ${FORMAT_RESET}"
export LOAD_BALANCER_IP=$(kubectl get svc gmemegen \
-o=jsonpath='{.status.loadBalancer.ingress[0].ip}' -n default)
echo -e "${COLOR_GREEN}Application URL: http://$LOAD_BALANCER_IP${FORMAT_RESET}"

POD_NAME=$(kubectl get pods --output=json | jq -r ".items[0].metadata.name")
kubectl logs $POD_NAME gmemegen | grep "INFO"

# Final output
echo
echo "${BG_BLUE}${STYLE_BOLD}${FG_WHITE}                                                      ${FORMAT_RESET}"
echo "${BG_BLUE}${STYLE_BOLD}${FG_WHITE}   DEPLOYMENT SUCCESSFUL! APPLICATION IS NOW RUNNING   ${FORMAT_RESET}"
echo "${BG_BLUE}${STYLE_BOLD}${FG_WHITE}                                                      ${FORMAT_RESET}"
echo
echo -e "${COLOR_GREEN}${STYLE_BOLD}Next steps:"
echo -e "1. Access your application at: ${COLOR_CYAN}http://$LOAD_BALANCER_IP${FORMAT_RESET}"
echo -e "2. Monitor your deployment with: ${COLOR_CYAN}kubectl get all${FORMAT_RESET}"
echo
echo -e "${COLOR_MAGENTA}${STYLE_BOLD}For more tutorials, subscribe to:${FORMAT_RESET}"
echo -e "${COLOR_BLUE}${STYLE_BOLD}https://www.youtube.com/@cloudwalejijaji${FORMAT_RESET}"
echo
