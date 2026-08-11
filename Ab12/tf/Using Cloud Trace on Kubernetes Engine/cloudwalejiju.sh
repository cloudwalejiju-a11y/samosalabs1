#!/bin/bash

# ==============================================
# GKE Tracing Demo Complete Setup
# Welcome to Cloud Wale Jiju Cloud Tutorials!
# YouTube: https://www.youtube.com/@cloudwalejijaji
# ==============================================

# Set text styles
YELLOW=$(tput setaf 3)
BOLD=$(tput bold)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

# ASCII Art Banner
echo "                                                                               
  ____  _       _     _           _    _           _       _     _   
 |  _ \(_)     | |   | |         | |  | |         | |     | |   | |  
 | |_) |_  __ _| |__ | |__   ___ | | _| | ___  ___| |_ ___| |__ | |_ 
 |  _ <| |/ _\` | '_ \| '_ \/ _ \| |/ / |/ _ \/ __| __/ __| '_ \| __|
 | |_) | | (_| | | | | | | | (_) |   <| |  __/\__ \ || (__| | | | |_ 
 |____/|_|\__, |_| |_|_| |_|\___/|_|\_\_|\___||___/\__\___|_| |_|\__|
           __/ |                                                     
          |___/                                                      
"

echo "=================================================================="
echo "           WELCOME TO CLOUD WALE JIJU CLOUD TUTORIALS!"
echo "=================================================================="
echo " YouTube Channel: https://www.youtube.com/@cloudwalejijaji"
echo "=================================================================="
echo "    SUBSCRIBE for more GKE and Observability tutorials!"
echo "=================================================================="
echo ""

# Function to display progress
progress() {
    echo "${GREEN}✅${RESET} ${BOLD}$1${RESET}"
    sleep 2
}

# Function to handle errors
handle_error() {
    echo "${RED}❌ Error: $1${RESET}"
    sleep 2
}

# Function to check command success
check_success() {
    if [ $? -eq 0 ]; then
        echo "${GREEN}✅ Success${RESET}"
    else
        handle_error "$2"
    fi
}

# Get zone input and export it properly
echo "${BOLD}Please set the below values correctly${RESET}"
read -p "${YELLOW}${BOLD}Enter the ZONE (e.g., us-central1-a): ${RESET}" ZONE

if [ -z "$ZONE" ]; then
    handle_error "Zone cannot be empty. Exiting."
    exit 1
fi

# Export zone and derive region
export ZONE="$ZONE"
export REGION="${ZONE%-*}"

progress "Setting compute region and zone..."
gcloud config set compute/region "$REGION"
gcloud config set compute/zone "$ZONE"

check_success "Region set to $REGION and Zone set to $ZONE" "Failed to set region/zone"

# Display exported values
echo "${BOLD}Exported values:${RESET}"
echo "  ZONE: $ZONE"
echo "  REGION: $REGION"

# Task 1: Clone demo
progress "Task 1: Cloning GKE Tracing Demo repository..."
git clone https://github.com/GoogleCloudPlatform/gke-tracing-demo
check_success "Repository cloned" "Failed to clone repository"

progress "Changing to gke-tracing-demo directory..."
cd gke-tracing-demo
check_success "Changed directory" "Failed to change directory"

# Task 3: Terraform Initialization
progress "Task 3: Changing to terraform directory..."
cd terraform

# Update provider.tf file
progress "Updating provider.tf configuration..."
if [ -f "provider.tf" ]; then
    # Remove the version constraint line
    sed -i '/version =/d' provider.tf
    # Also ensure the provider block is correct
    cat > provider.tf << EOF
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}
provider "google" {
  project = var.project
}
EOF
    check_success "Provider configuration updated" "Failed to update provider.tf"
else
    handle_error "provider.tf not found"
    exit 1
fi

# Terraform initialization
progress "Initializing Terraform..."
terraform init
check_success "Terraform initialized" "Terraform init failed"

# Generate Terraform variables using exported values
progress "Generating Terraform variables using exported ZONE: $ZONE..."
if [ -f "../scripts/generate-tfvars.sh" ]; then
    # Set the zone for the generate script
    export ZONE="$ZONE"
    ../scripts/generate-tfvars.sh
    check_success "Terraform variables generated" "Failed to generate tfvars"
else
    handle_error "generate-tfvars.sh not found - creating manually using exported values..."
    # Create terraform.tfvars manually using exported values
    PROJECT_ID=$(gcloud config get-value project)
    cat > terraform.tfvars << EOF
project = "$PROJECT_ID"
zone    = "$ZONE"
EOF
    check_success "terraform.tfvars created manually with zone: $ZONE" "Failed to create tfvars"
fi

# Verify the generated terraform.tfvars
progress "Checking generated terraform.tfvars:"
cat terraform.tfvars

# Task 4: Terraform Deployment
progress "Task 4: Creating Terraform execution plan..."
terraform plan
check_success "Terraform plan created" "Terraform plan failed"

progress "Applying Terraform configuration (this may take 10-15 minutes)..."
terraform apply -auto-approve
check_success "Terraform apply completed" "Terraform apply failed"

# Return to main directory
cd ..

# Task 5: Setup Cloud Monitoring workspace
progress "Task 5: Setting up Cloud Monitoring workspace..."
echo "Please manually set up Cloud Monitoring Metrics Scope:"
echo "1. Go to Cloud Console → Navigation menu → Observability → Monitoring"
echo "2. Wait for Monitoring Overview page to load (your metrics scope will be ready)"
echo "This step requires manual intervention in the Cloud Console."
sleep 5

# Task 6: Deploy demo application
progress "Task 6: Deploying tracing demo application..."
if [ -f "tracing-demo-deployment.yaml" ]; then
    kubectl apply -f tracing-demo-deployment.yaml
    check_success "Tracing demo deployed" "Failed to deploy tracing demo"
else
    handle_error "tracing-demo-deployment.yaml not found"
    exit 1
fi

# Wait for deployment to be ready
progress "Waiting for deployment to be ready (this may take a few minutes)..."
for i in {1..12}; do
    echo "Waiting... $((i*30)) seconds passed"
    sleep 30
    STATUS=$(kubectl get deployment tracing-demo -n default -o jsonpath='{.status.availableReplicas}')
    if [ "$STATUS" = "1" ]; then
        break
    fi
done

progress "Checking deployment status..."
kubectl get deployments -n default
kubectl get pods -n default

# Task 7: Validation and generating telemetry data
progress "Task 7: Retrieving application endpoint..."
EXTERNAL_IP=$(kubectl get svc tracing-demo -n default -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)

if [ -n "$EXTERNAL_IP" ] && [ "$EXTERNAL_IP" != "null" ]; then
    APPLICATION_URL="http://${EXTERNAL_IP}"
    CUSTOM_URL="http://${EXTERNAL_IP}?string=CustomMessage"
    
    echo ""
    echo "${GREEN}==================================================================${RESET}"
    echo "${BOLD}🎉 GKE TRACING DEMO DEPLOYMENT COMPLETED!${RESET}"
    echo "${GREEN}==================================================================${RESET}"
    echo ""
    echo "${BOLD}🌐 Application URLs:${RESET}"
    echo "   Default: ${BLUE}${APPLICATION_URL}${RESET}"
    echo "   Custom:  ${BLUE}${CUSTOM_URL}${RESET}"
    echo ""
    echo "${BOLD}📊 To generate telemetry data:${RESET}"
    echo "   Visit the URLs above in your browser"
    echo "   Or use curl:"
    echo "   curl \"${APPLICATION_URL}\""
    echo "   curl \"${CUSTOM_URL}\""
    echo ""
    echo "${BOLD}🔧 To view traces:${RESET}"
    echo "   Visit Google Cloud Console → Trace Explorer"
    echo ""
    
    # Test the endpoints
    progress "Testing application endpoints..."
    echo "Testing default endpoint:"
    curl -s "${APPLICATION_URL}" || echo "Endpoint not ready yet"
    echo ""
    echo "Testing custom endpoint:"
    curl -s "${CUSTOM_URL}" || echo "Endpoint not ready yet"
    
else
    echo "${YELLOW}⚠️  External IP not yet assigned. Checking status...${RESET}"
    kubectl describe svc tracing-demo -n default
    echo ""
    echo "${BOLD}The LoadBalancer may take a few minutes to provision.${RESET}"
    echo "${BOLD}Run this command later to get the URL:${RESET}"
    echo 'echo http://$(kubectl get svc tracing-demo -n default -o jsonpath='"'"'{.status.loadBalancer.ingress[0].ip}'"'"')'
fi

# Display current resources
echo ""
echo "${GREEN}==================================================================${RESET}"
echo "${BOLD}📋 CURRENT DEPLOYMENT STATUS:${RESET}"
echo "${GREEN}==================================================================${RESET}"

progress "Listing all resources:"
kubectl get all -n default

echo ""
echo "${BOLD}📺 To complete the lab:${RESET}"
echo "1. Visit Cloud Console → Kubernetes Engine → Clusters to see your cluster"
echo "2. Visit Pub/Sub → Topics to see the created topic"
echo "3. Visit Trace Explorer to view generated traces"
echo "4. Generate more traffic by visiting your application URLs"

echo ""
echo "${BLUE}==================================================================${RESET}"
echo "${BOLD}📺 LIKE THIS TUTORIAL? SUBSCRIBE TO CLOUD WALE JIJU CLOUD TUTORIALS!${RESET}"
echo "${BLUE}🌐 YouTube: https://www.youtube.com/@cloudwalejijaji${RESET}"
echo "${BLUE}==================================================================${RESET}"
echo "${BOLD}   Don't forget to LIKE, SHARE, and COMMENT on the tutorials!${RESET}"
echo "${BLUE}==================================================================${RESET}"

# Create verification script that uses exported values
cat > verify_deployment.sh << EOF
#!/bin/bash
echo "Verifying GKE Tracing Demo Deployment..."
echo ""
echo "Using exported values:"
echo "ZONE: $ZONE"
echo "REGION: $REGION"
echo ""
echo "1. Checking cluster:"
gcloud container clusters list --filter="name:gke-tracing-demo" --zone="$ZONE"
echo ""
echo "2. Checking Kubernetes resources:"
kubectl get all -n default
echo ""
echo "3. Checking external IP:"
EXTERNAL_IP=\$(kubectl get svc tracing-demo -n default -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
if [ -n "\$EXTERNAL_IP" ]; then
    echo "   Application URL: http://\${EXTERNAL_IP}"
    echo "   Test: curl http://\${EXTERNAL_IP}"
else
    echo "   External IP not yet assigned"
fi
EOF

chmod +x verify_deployment.sh

echo ""
echo "${GREEN}Verification script created: ./verify_deployment.sh${RESET}"
echo "${GREEN}Run it to check your deployment status at any time.${RESET}"

# Final export confirmation
echo ""
echo "${GREEN}==================================================================${RESET}"
echo "${BOLD}📋 EXPORTED VARIABLES:${RESET}"
echo "${GREEN}==================================================================${RESET}"
echo "ZONE: $ZONE"
echo "REGION: $REGION"
echo "These variables are now available for use in other scripts/sessions"
echo "${GREEN}==================================================================${RESET}"