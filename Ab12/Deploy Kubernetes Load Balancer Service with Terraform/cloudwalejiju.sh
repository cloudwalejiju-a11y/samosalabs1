#!/bin/bash

# ==============================================
# GKE Kubernetes Service Load Balancer Setup
# Welcome to Cloud Wale Jiju Cloud Tutorials!
# YouTube: https://www.youtube.com/@cloudwalejijaji
# ==============================================

# Color definitions
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Function to display banner
display_banner() {
    echo -e "${YELLOW}${BOLD}**********************************************************${NC}"
    echo -e "${YELLOW}${BOLD}**                 S U B S C R I B E  TO                **${NC}"
    echo -e "${YELLOW}${BOLD}**           CLOUD WALE JIJU CLOUD TUTORIALS               **${NC}"
    echo -e "${YELLOW}${BOLD}**                                                      **${NC}"
    echo -e "${YELLOW}${BOLD}**       YouTube: https://www.youtube.com/@drcloudwalejiju   **${NC}"
    echo -e "${YELLOW}${BOLD}**********************************************************${NC}"
    echo ""
}

# Function to display progress
progress() {
    echo -e "${GREEN}✅${NC} ${BOLD}$1${NC}"
    sleep 2
}

# Function to handle errors
handle_error() {
    echo -e "${RED}❌ Error: $1${NC}"
    sleep 2
}

# Function to check command success
check_success() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Success${NC}"
    else
        handle_error "$2"
    fi
}

# Display initial banner
display_banner

# Check if gcloud is authenticated
progress "Checking Google Cloud authentication..."
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q "@"; then
    handle_error "No active Google Cloud account found. Please run 'gcloud auth login' first."
    exit 1
fi

# Set Google Cloud configuration
progress "Setting Google Cloud configuration..."
export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

# Validate zone and region
if [[ -z "$ZONE" || -z "$REGION" ]]; then
    handle_error "Could not determine default zone or region. Please set them manually."
    echo "Available zones:"
    gcloud compute zones list --format="value(name)" | head -5
    echo ""
    echo "Available regions:"
    gcloud compute regions list --format="value(name)" | head -5
    exit 1
fi

gcloud config set compute/zone "$ZONE"
gcloud config set compute/region "$REGION"

echo -e "${BOLD}Configured zone: ${BLUE}$ZONE${NC}"
echo -e "${BOLD}Configured region: ${BLUE}$REGION${NC}"

# Copy files from GCS
progress "Copying files from GCS bucket..."
if ! gsutil -m cp -r gs://spls/gsp233/* . 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Warning: Failed to copy some files from GCS bucket. Continuing...${NC}"
fi

# Check if files were copied successfully
if [ ! -d "tf-gke-k8s-service-lb" ]; then
    handle_error "Target directory tf-gke-k8s-service-lb not found after copy operation"
    echo "Available files:"
    ls -la
    exit 1
fi

# Change to Terraform directory
progress "Changing to Terraform directory..."
cd tf-gke-k8s-service-lb || { 
    handle_error "Directory tf-gke-k8s-service-lb not found"; 
    echo "Available directories:"
    ls -d */
    exit 1; 
}

# Initialize Terraform
progress "Initializing Terraform..."
terraform init
check_success "Terraform initialized" "Terraform init failed"

# Apply Terraform configuration
progress "Applying Terraform configuration (this may take 10-15 minutes)..."
terraform apply -var="region=$REGION" -var="location=$ZONE" --auto-approve
check_success "Terraform apply completed" "Terraform apply failed"

# Display deployment information
progress "Gathering deployment information..."
echo -e "${BOLD}${GREEN}🎉 Deployment Completed Successfully!${NC}"
echo ""
echo -e "${BOLD}📋 Deployment Details:${NC}"
echo -e "   Region: ${BLUE}$REGION${NC}"
echo -e "   Zone: ${BLUE}$ZONE${NC}"
echo ""

# Check Kubernetes resources if available
progress "Checking Kubernetes resources..."
if command -v kubectl &> /dev/null; then
    echo -e "${BOLD}Kubernetes Services:${NC}"
    kubectl get services 2>/dev/null || echo "Kubernetes services not available yet"
    
    echo -e "${BOLD}Kubernetes Pods:${NC}"
    kubectl get pods 2>/dev/null || echo "Kubernetes pods not available yet"
else
    echo "kubectl not available for resource checking"
fi

# Display next steps
echo ""
echo -e "${BOLD}📝 Next Steps:${NC}"
echo "1. Check Google Cloud Console → Kubernetes Engine → Services"
echo "2. Verify load balancer configuration"
echo "3. Test the application endpoints"
echo "4. Monitor traffic and performance"

# Display final banner with completion message
echo ""
display_banner
echo -e "${GREEN}${BOLD}**********************************************************${NC}"
echo -e "${GREEN}${BOLD}**        GKE LOAD BALANCER SETUP COMPLETE!            **${NC}"
echo -e "${GREEN}${BOLD}**                                                      **${NC}"
echo -e "${GREEN}${BOLD}**    Don't forget to check the YouTube channel for     **${NC}"
echo -e "${GREEN}${BOLD}**        more Google Cloud and Kubernetes tutorials!   **${NC}"
echo -e "${GREEN}${BOLD}**********************************************************${NC}"

# Create verification script
cat > verify_deployment.sh << 'EOF'
#!/bin/bash
echo "Verifying GKE Load Balancer Deployment..."
echo ""
echo "Current configuration:"
echo "ZONE: $ZONE"
echo "REGION: $REGION"
echo ""
echo "1. Checking Google Cloud resources:"
gcloud container clusters list --zone="$ZONE"
echo ""
echo "2. Checking Kubernetes resources (if available):"
if command -v kubectl &> /dev/null; then
    kubectl get all
else
    echo "kubectl not available"
fi
EOF

chmod +x verify_deployment.sh

echo ""
echo -e "${GREEN}Verification script created: ./verify_deployment.sh${NC}"
echo -e "${GREEN}Run it to check your deployment status.${NC}"

# Export variables for future use
echo ""
echo -e "${BOLD}Exported variables for future use:${NC}"
echo "export ZONE=\"$ZONE\""
echo "export REGION=\"$REGION\""