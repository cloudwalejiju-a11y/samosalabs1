#!/bin/bash

# ==============================================
#  Caddy on Cloud Run Deployment
#  Created by Cloud Wale Jija Ji Cloud Tutorials
#  YouTube: https://www.youtube.com/@cloudwalejijaji
# ==============================================

# Color definitions
COLOR_RED=$'\033[1;31m'
COLOR_GREEN=$'\033[1;32m'
COLOR_YELLOW=$'\033[1;33m'
COLOR_BLUE=$'\033[1;34m'
COLOR_MAGENTA=$'\033[1;35m'
COLOR_CYAN=$'\033[1;36m'
COLOR_WHITE=$'\033[1;37m'
FORMAT_RESET=$'\033[0m'

# Spinner function
show_spinner() {
    local pid=$!
    local delay=0.1
    local spin_chars=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    
    tput civis
    while kill -0 $pid 2>/dev/null; do
        for char in "${spin_chars[@]}"; do
            printf "\r${COLOR_CYAN}${char}${FORMAT_RESET} $1 "
            sleep $delay
        done
    done
    tput cnorm
    printf "\r${COLOR_GREEN}✓ $1 completed${FORMAT_RESET}\n"
}

# Header
clear
echo
echo "${COLOR_BLUE}╔══════════════════════════════════════════╗${FORMAT_RESET}"
echo "${COLOR_BLUE}║   CADDY ON CLOUD RUN DEPLOYMENT         ║${FORMAT_RESET}"
echo "${COLOR_BLUE}║        by Cloud Wale Jija Ji Cloud           ║${FORMAT_RESET}"
echo "${COLOR_BLUE}╚══════════════════════════════════════════╝${FORMAT_RESET}"
echo

# Initialize environment
echo "${COLOR_CYAN}🔧 Initializing environment...${FORMAT_RESET}"
gcloud auth list

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")
export PROJECT_ID=$(gcloud config get-value project)

gcloud config set compute/region "$REGION"
gcloud config set project "$PROJECT_ID"

echo "${COLOR_GREEN}✓ Environment configured${FORMAT_RESET}"
echo " Project: ${PROJECT_ID}"
echo " Region:  ${REGION}"
echo

# Enable required services
echo "${COLOR_MAGENTA}🛠️ Enabling required Google Cloud services...${FORMAT_RESET}"
gcloud services enable run.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com --quiet &
show_spinner "Enabling services"

# Create Artifact Registry repository
echo "${COLOR_YELLOW}📦 Creating Docker repository in Artifact Registry...${FORMAT_RESET}"
gcloud artifacts repositories create caddy-repo --repository-format=docker --location="$REGION" --description="Docker repository for Caddy images" &
show_spinner "Creating repository"

# Create website files
echo "${COLOR_CYAN}🖥️ Creating static website files...${FORMAT_RESET}"
cat > index.html <<EOF
<html>
<head>
  <title>My Static Website</title>
</head>
<body>
  <div>Hello from Caddy on Cloud Run!</div>
  <p>This website is served by Caddy running in a Docker container on Google Cloud Run.</p>
</body>
</html>
EOF

cat > Caddyfile <<EOF
:8080
root * /usr/share/caddy
file_server
EOF

cat > Dockerfile <<EOF
FROM caddy:2-alpine

WORKDIR /usr/share/caddy

COPY index.html .
COPY Caddyfile /etc/caddy/Caddyfile
EOF

echo "${COLOR_GREEN}✓ Website files created${FORMAT_RESET}"
echo

# Build and push Docker image
echo "${COLOR_MAGENTA}🐳 Building and pushing Docker image...${FORMAT_RESET}"
docker build -t "$REGION"-docker.pkg.dev/"$PROJECT_ID"/caddy-repo/caddy-static:latest . &
show_spinner "Building Docker image"

docker push "$REGION"-docker.pkg.dev/"$PROJECT_ID"/caddy-repo/caddy-static:latest &
show_spinner "Pushing Docker image"

# Deploy to Cloud Run
echo "${COLOR_YELLOW}🚀 Deploying to Cloud Run...${FORMAT_RESET}"
gcloud run deploy caddy-static --region=$REGION --image "$REGION"-docker.pkg.dev/"$PROJECT_ID"/caddy-repo/caddy-static:latest --platform managed --allow-unauthenticated &
show_spinner "Deploying service"

# Get service URL
SERVICE_URL=$(gcloud run services describe caddy-static --region=$REGION --format='value(status.url)')

# Final output
echo
echo "${COLOR_BLUE}╔══════════════════════════════════════════╗${FORMAT_RESET}"
echo "${COLOR_BLUE}║        DEPLOYMENT COMPLETE!             ║${FORMAT_RESET}"
echo "${COLOR_BLUE}╚══════════════════════════════════════════╝${FORMAT_RESET}"
echo
echo "${COLOR_WHITE}Your static website is now live at:${FORMAT_RESET}"
echo "${COLOR_GREEN}${SERVICE_URL}${FORMAT_RESET}"
echo
echo "${COLOR_WHITE}Next steps:${FORMAT_RESET}"
echo " • View your container in Artifact Registry:"
echo "   ${COLOR_BLUE}https://console.cloud.google.com/artifacts/docker/${PROJECT_ID}/${REGION}/caddy-repo${FORMAT_RESET}"
echo " • Manage your Cloud Run service:"
echo "   ${COLOR_BLUE}https://console.cloud.google.com/run?project=${PROJECT_ID}${FORMAT_RESET}"
echo
echo "${COLOR_MAGENTA}For more cloud tutorials, subscribe to:${FORMAT_RESET}"
echo "${COLOR_BLUE}https://www.youtube.com/@cloudwalejijaji${FORMAT_RESET}"
echo
