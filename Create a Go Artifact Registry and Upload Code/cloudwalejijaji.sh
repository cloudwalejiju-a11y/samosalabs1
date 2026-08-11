#!/bin/bash

# ==============================================
#  Google Cloud Artifact Registry Go Demo
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
echo "${COLOR_BLUE}║   ARTIFACT REGISTRY GO MODULE DEMO       ║${FORMAT_RESET}"
echo "${COLOR_BLUE}║        by Cloud Wale Jija Ji Cloud            ║${FORMAT_RESET}"
echo "${COLOR_BLUE}╚══════════════════════════════════════════╝${FORMAT_RESET}"
echo

# Initialize environment
echo "${COLOR_CYAN}🔧 Initializing environment...${FORMAT_RESET}"
gcloud auth list

echo "${COLOR_YELLOW}Enabling Artifact Registry API...${FORMAT_RESET}"
gcloud services enable artifactregistry.googleapis.com --quiet &
show_spinner "Enabling API"

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")
export PROJECT_ID=$(gcloud config get-value project)

gcloud config set compute/region $REGION
gcloud config set project $PROJECT_ID

echo "${COLOR_GREEN}✓ Environment configured${FORMAT_RESET}"
echo " Project: ${PROJECT_ID}"
echo " Region:  ${REGION}"
echo

# Create Artifact Registry repository
echo "${COLOR_MAGENTA}🛠️ Creating Go repository in Artifact Registry...${FORMAT_RESET}"
gcloud artifacts repositories create my-go-repo \
    --repository-format=go \
    --location="$REGION" \
    --description="Go repository" &
show_spinner "Creating repository"

echo "${COLOR_YELLOW}Repository details:${FORMAT_RESET}"
gcloud artifacts repositories describe my-go-repo \
    --location="$REGION"

# Configure Go environment
echo "${COLOR_CYAN}⚙️ Configuring Go environment...${FORMAT_RESET}"
go env -w GOPRIVATE=cloud.google.com/"$PROJECT_ID" &
show_spinner "Setting GOPRIVATE"

export GONOPROXY=github.com/GoogleCloudPlatform/artifact-registry-go-tools
GOPROXY=proxy.golang.org go run github.com/GoogleCloudPlatform/artifact-registry-go-tools/cmd/auth@latest add-locations --locations="$REGION" &
show_spinner "Configuring Go auth"

# Create Go module
echo "${COLOR_MAGENTA}📦 Creating Go module...${FORMAT_RESET}"
mkdir -p hello
cd hello || exit

go mod init labdemo.app/hello &
show_spinner "Initializing module"

cat > hello.go <<EOF
package main

import "fmt"

func main() {
    fmt.Println("Hello, Go module from Artifact Registry!")
}
EOF

echo "${COLOR_YELLOW}Building Go module...${FORMAT_RESET}"
go build &
show_spinner "Building module"

# Configure Git
echo "${COLOR_CYAN}🔧 Configuring Git...${FORMAT_RESET}"
git config --global user.email "$EMAIL" &
git config --global user.name "cls" &
git config --global init.defaultBranch main &
show_spinner "Setting Git config"

git init &
git add . &
git commit -m "Initial commit" &
git tag v1.0.0 &
show_spinner "Initializing Git repo"

# Upload to Artifact Registry
echo "${COLOR_MAGENTA}🚀 Uploading module to Artifact Registry...${FORMAT_RESET}"
gcloud artifacts go upload \
  --repository=my-go-repo \
  --location="$REGION" \
  --module-path=labdemo.app/hello \
  --version=v1.0.0 \
  --source=. &
show_spinner "Uploading module"

# List packages
echo "${COLOR_YELLOW}📦 Listing packages in repository:${FORMAT_RESET}"
gcloud artifacts packages list --repository=my-go-repo --location="$REGION"

# Final output
echo
echo "${COLOR_BLUE}╔══════════════════════════════════════════╗${FORMAT_RESET}"
echo "${COLOR_BLUE}║         DEMO COMPLETED SUCCESSFULLY      ║${FORMAT_RESET}"
echo "${COLOR_BLUE}╚══════════════════════════════════════════╝${FORMAT_RESET}"
echo
echo "${COLOR_WHITE}Next steps:${FORMAT_RESET}"
echo " • View your Go module in Artifact Registry:"
echo "   ${COLOR_BLUE}https://console.cloud.google.com/artifacts?project=${PROJECT_ID}${FORMAT_RESET}"
echo
echo "${COLOR_MAGENTA}For more cloud tutorials, subscribe to:${FORMAT_RESET}"
echo "${COLOR_BLUE}https://www.youtube.com/@cloudwalejijaji${FORMAT_RESET}"
echo
