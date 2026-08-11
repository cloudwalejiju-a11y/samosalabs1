#!/bin/bash

# ==============================================
#  Static Site with Traefik on Cloud Run
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
echo "${COLOR_BLUE}║   TRAEFIK STATIC SITE ON CLOUD RUN      ║${FORMAT_RESET}"
echo "${COLOR_BLUE}║        by Cloud Wale Jija Ji Cloud           ║${FORMAT_RESET}"
echo "${COLOR_BLUE}╚══════════════════════════════════════════╝${FORMAT_RESET}"
echo

# Initialize environment
echo "${COLOR_CYAN}🔧 Initializing environment...${FORMAT_RESET}"
gcloud auth list

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")
export PROJECT_ID=$(gcloud config get-value project)

gcloud config set compute/region "$REGION" &
show_spinner "Setting compute region"
gcloud config set project "$PROJECT_ID" &
show_spinner "Setting project"

echo "${COLOR_GREEN}✓ Environment configured${FORMAT_RESET}"
echo " Project: ${PROJECT_ID}"
echo " Region:  ${REGION}"
echo

# Enable required services
echo "${COLOR_MAGENTA}🛠️ Enabling required Google Cloud services...${FORMAT_RESET}"
gcloud services enable run.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com --quiet &
show_spinner "Enabling services"

# Create Artifact Registry repository
echo "${COLOR_YELLOW}📦 Creating Docker repository...${FORMAT_RESET}"
gcloud artifacts repositories create traefik-repo --repository-format=docker --location="$REGION" --description="Docker repository for static site images" &
show_spinner "Creating Artifact Registry repository"

# Create project structure
echo "${COLOR_CYAN}🖥️ Creating project structure...${FORMAT_RESET}"
mkdir -p traefik-site/public && cd traefik-site || exit

cat > public/index.html <<EOF
<html>
<head>
  <title>My Static Website</title>
</head>
<body>
  <p>Hello from my static website on Cloud Run!</p>
</body>
</html>
EOF

echo "${COLOR_GREEN}✓ Project structure created${FORMAT_RESET}"
echo

# Configure Docker authentication
echo "${COLOR_YELLOW}🔐 Configuring Docker authentication...${FORMAT_RESET}"
gcloud auth configure-docker "$REGION"-docker.pkg.dev &
show_spinner "Configuring Docker"

# Create Traefik configuration
echo "${COLOR_MAGENTA}⚙️ Creating Traefik configuration...${FORMAT_RESET}"
cat > traefik.yml <<EOF
entryPoints:
  web:
    address: ":8080"

providers:
  file:
    filename: /etc/traefik/dynamic.yml
    watch: true

log:
  level: INFO
EOF

cat > dynamic.yml <<EOF
http:
  routers:
    static-files:
      rule: "PathPrefix(\`/\`)"
      entryPoints:
        - web
      service: static-service

  services:
    static-service:
      loadBalancer:
        servers:
          - url: "http://localhost:8000"
EOF

echo "${COLOR_GREEN}✓ Configuration files created${FORMAT_RESET}"
echo

# Build Docker image
echo "${COLOR_CYAN}🐳 Building Docker image...${FORMAT_RESET}"
cat > Dockerfile <<EOF
FROM alpine:3.20

# Install traefik and caddy
RUN apk add --no-cache traefik caddy

# Copy configs and static files
COPY traefik.yml /etc/traefik/traefik.yml
COPY dynamic.yml /etc/traefik/dynamic.yml
COPY public/ /public/

# Cloud Run uses port 8080
EXPOSE 8080

# Run static server (on 8000) and Traefik (on 8080)
ENTRYPOINT [ "caddy" ]
CMD [ "file-server", "--listen", ":8000", "--root", "/public", "&", "traefik" ]
EOF

docker build -t "$REGION"-docker.pkg.dev/"$PROJECT_ID"/traefik-repo/traefik-static-site:latest . &
show_spinner "Building Docker image"

# Push Docker image
echo "${COLOR_YELLOW}🚀 Pushing Docker image...${FORMAT_RESET}"
docker push "$REGION"-docker.pkg.dev/"$PROJECT_ID"/traefik-repo/traefik-static-site:latest &
show_spinner "Pushing to Artifact Registry"

# Deploy to Cloud Run
echo "${COLOR_MAGENTA}☁️ Deploying to Cloud Run...${FORMAT_RESET}"
gcloud run deploy traefik-static-site --region "$REGION" \
  --image "$REGION"-docker.pkg.dev/"$PROJECT_ID"/traefik-repo/traefik-static-site:latest \
  --platform managed --allow-unauthenticated --port 8000 &
show_spinner "Deploying service"

# Get service URL
SERVICE_URL=$(gcloud run services describe traefik-static-site --region "$REGION" --format='value(status.url)')

# Final output
echo
echo "${COLOR_BLUE}╔══════════════════════════════════════════╗${FORMAT_RESET}"
echo "${COLOR_BLUE}║        DEPLOYMENT COMPLETE!             ║${FORMAT_RESET}"
echo "${COLOR_BLUE}╚══════════════════════════════════════════╝${FORMAT_RESET}"
echo
echo "${COLOR_WHITE}Your static site with Traefik is now live at:${FORMAT_RESET}"
echo "${COLOR_GREEN}${SERVICE_URL}${FORMAT_RESET}"
echo
echo "${COLOR_WHITE}Next steps:${FORMAT_RESET}"
echo " • View your container in Artifact Registry:"
echo "   ${COLOR_BLUE}https://console.cloud.google.com/artifacts/docker/${PROJECT_ID}/${REGION}/traefik-repo${FORMAT_RESET}"
echo " • Manage your Cloud Run service:"
echo "   ${COLOR_BLUE}https://console.cloud.google.com/run?project=${PROJECT_ID}${FORMAT_RESET}"
echo
echo "${COLOR_MAGENTA}For more cloud tutorials, subscribe to:${FORMAT_RESET}"
echo "${COLOR_BLUE}https://www.youtube.com/@cloudwalejijaji${FORMAT_RESET}"
echo
