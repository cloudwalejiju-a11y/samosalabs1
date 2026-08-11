#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Spinner function
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [${CYAN}%c${NC}]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Cloud Wale Jija Ji Banner
echo -e "${PURPLE}"
echo "  ____  _____     _     _       _      _    "
echo " |  _ \|  __ \   | |   | |     | |    | |   "
echo " | | | | |__) |__| |__ | |__  _| |__ _| | __"
echo " | |_| |  _  // _\` |_ \| '_ \| | / _\` | |/ /"
echo " |____/|_| \_\ \__,_|___/|_.__/|_|\__,_|_|___\\"
echo -e "${NC}"
echo -e "${YELLOW}🚀 Kubernetes Masterclass with Cloud Wale Jija Ji${NC}"
echo -e "${BLUE}------------------------------------------------${NC}"
echo -e "${CYAN}💡 Pro Tip: Follow along at https://youtube.com/@cloudwalejijaji${NC}"
echo -e "${GREEN}🔔 Don't forget to LIKE, SHARE, and SUBSCRIBE!${NC}"
echo ""

# Concept Explanation Function
explain() {
    echo -e "\n${PURPLE}🧠 Cloud Wale Jija Ji Explains:${NC} $1${NC}"
}

# Function to validate zone input
validate_zone() {
    local zone=$1
    if [[ -z "$zone" ]]; then
        echo -e "${RED}Zone cannot be empty!${NC}"
        return 1
    elif ! gcloud compute zones list --filter="name=$zone" --format="value(name)" | grep -q "^$zone$"; then
        echo -e "${RED}Invalid zone! Please check available zones with 'gcloud compute zones list'${NC}"
        return 1
    fi
    return 0
}

# Step 0: Zone Selection
echo -e "${YELLOW}[0/10] ${BLUE}📍 Zone Selection${NC}"
DEFAULT_ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

while true; do
    echo -e "${CYAN}Available zones in your region:${NC}"
    gcloud compute zones list --format="value(name)" | sort | pr -3 -t
    
    echo -e "\n${YELLOW}Please enter your preferred zone (e.g., us-central1-a):${NC}"
    echo -e "${GREEN}Press Enter to use default zone (${DEFAULT_ZONE})${NC}"
    read -p "Zone: " ZONE
    
    # Use default if empty
    [[ -z "$ZONE" ]] && ZONE=$DEFAULT_ZONE
    
    if validate_zone "$ZONE"; then
        break
    fi
done

export ZONE
export REGION=${ZONE%-*}
export PROJECT_ID=$(gcloud config get-value project)

echo -e "\n${GREEN}✓ Selected zone: ${CYAN}${ZONE}${NC}"
echo -e "${GREEN}✓ Derived region: ${CYAN}${REGION}${NC}"
echo -e "${GREEN}✓ Project ID: ${CYAN}${PROJECT_ID}${NC}"

explain "The zone determines where your resources will be physically located. Choose wisely based on your latency needs and compliance requirements."
echo ""

# Step 1: Authentication
echo -e "${YELLOW}[1/10] ${BLUE}🔐 Authentication Check${NC}"
gcloud auth list
explain "We first verify your GCP authentication to ensure proper authorization for all operations."
echo ""

# Step 2: Environment Configuration
echo -e "${YELLOW}[2/10] ${BLUE}⚙️ Environment Configuration${NC}"
gcloud config set compute/zone "$ZONE" & spinner
echo -e "\n${GREEN}✓ Compute zone configured${NC}"
echo ""

# Step 3: Cluster Creation
echo -e "${YELLOW}[3/10] ${BLUE}⚙️ Creating GKE Cluster${NC}"
explain "A GKE cluster is the foundation of your Kubernetes environment. It manages your worker nodes where containers will run."
gcloud container clusters create io --zone $ZONE & spinner
echo -e "\n${GREEN}✓ Cluster 'io' created successfully${NC}"
echo ""

# Step 4: Resource Download
echo -e "${YELLOW}[4/10] ${BLUE}📥 Downloading Kubernetes Resources${NC}"
explain "We're downloading pre-configured Kubernetes manifests to accelerate your learning process."
gsutil cp -r gs://spls/gsp021/* . & spinner
echo -e "\n${GREEN}✓ Kubernetes resources downloaded${NC}"
echo ""

# Step 5: Basic Deployment
cd orchestrate-with-kubernetes/kubernetes
echo -e "${YELLOW}[5/10] ${BLUE}🐳 Basic Nginx Deployment${NC}"
explain "This creates a simple nginx deployment - the 'Hello World' of Kubernetes!"
kubectl create deployment nginx --image=nginx:1.10.0 & spinner
echo -e "\n${GREEN}✓ Nginx deployment created${NC}"

echo -e "\n${BLUE}📦 Current pods:${NC}"
kubectl get pods

echo -e "\n${YELLOW}🌐 Exposing nginx service...${NC}"
explain "A LoadBalancer service exposes your deployment to the internet with a public IP."
kubectl expose deployment nginx --port 80 --type LoadBalancer & spinner
echo -e "\n${GREEN}✓ Service exposed${NC}"

echo -e "\n${BLUE}🔌 Current services:${NC}"
kubectl get services
echo ""

# Step 6: Monolith Deployment
echo -e "${YELLOW}[6/10] ${BLUE}🏢 Monolith Application Setup${NC}"
explain "A monolith packages all components together, which we'll later break into microservices."
kubectl create -f pods/monolith.yaml & spinner
echo -e "\n${GREEN}✓ Monolith pod created${NC}"

echo -e "\n${BLUE}📦 Current pods:${NC}"
kubectl get pods
echo ""

# Step 7: Secure Monolith
echo -e "${YELLOW}[7/10] ${BLUE}🔒 Securing the Monolith${NC}"
explain "We're now adding TLS certificates and security configurations to protect our application."
kubectl create secret generic tls-certs --from-file tls/ & spinner
kubectl create configmap nginx-proxy-conf --from-file nginx/proxy.conf & spinner
kubectl create -f pods/secure-monolith.yaml & spinner
echo -e "\n${GREEN}✓ Secure monolith configured${NC}"

kubectl create -f services/monolith.yaml & spinner
echo -e "\n${GREEN}✓ Monolith service created${NC}"

gcloud compute firewall-rules create allow-monolith-nodeport --allow=tcp:31000 & spinner
echo -e "\n${GREEN}✓ Firewall rule added${NC}"

echo -e "\n${BLUE}🏷️ Labeling secure monolith...${NC}"
explain "Labels help organize and select subsets of objects in Kubernetes."
kubectl label pods secure-monolith 'secure=enabled' & spinner
kubectl get pods secure-monolith --show-labels
echo ""

# Step 8: Microservices Deployment
echo -e "${YELLOW}[8/10] ${BLUE}🧩 Microservices Deployment${NC}"
explain "Now we're breaking the monolith into microservices - the modern cloud architecture approach!"
kubectl create -f deployments/auth.yaml & spinner
kubectl create -f services/auth.yaml & spinner
kubectl create -f deployments/hello.yaml & spinner
kubectl create -f services/hello.yaml & spinner
echo -e "\n${GREEN}✓ Auth and hello services deployed${NC}"

kubectl create configmap nginx-frontend-conf --from-file=nginx/frontend.conf & spinner
kubectl create -f deployments/frontend.yaml & spinner
kubectl create -f services/frontend.yaml & spinner
echo -e "\n${GREEN}✓ Frontend deployed${NC}"
echo ""

# Final Output
echo -e "${YELLOW}[9/10] ${BLUE}✅ Verification${NC}"
echo -e "\n${BLUE}🌍 Frontend service details:${NC}"
kubectl get services frontend

echo -e "\n${YELLOW}[10/10] ${BLUE}🧹 Cleanup Reminder${NC}"
echo -e "${RED}⚠️ Remember to clean up resources when done to avoid unnecessary charges:${NC}"
echo -e "1. Delete the cluster: ${CYAN}gcloud container clusters delete io --zone $ZONE${NC}"
echo -e "2. Delete firewall rule: ${CYAN}gcloud compute firewall-rules delete allow-monolith-nodeport${NC}"

echo -e "\n${PURPLE}"
echo "  _____                    _    _           _   _             "
echo " |  __ \                  | |  | |         | | (_)            "
echo " | |__) |___  ___ ___  ___| | _| |__   __ _| |_ _  ___  _ __  "
echo " |  _  // _ \/ __/ __|/ _ \ |/ / '_ \ / _\` | __| |/ _ \| '_ \ "
echo " | | \ \  __/\__ \__ \  __/   <| | | | (_| | |_| | (_) | | | |"
echo " |_|  \_\___||___/___/\___|_|\_\_| |_|\__,_|\__|_|\___/|_| |_|"
echo -e "${NC}"
echo -e "${GREEN}🎉 Congratulations! You've completed Cloud Wale Jija Ji's Kubernetes Lab!${NC}"
echo -e "${YELLOW}👉 Access your application at the EXTERNAL-IP shown above${NC}"
echo -e "\n${CYAN}💡 Want to learn more? Check out these resources:${NC}"
echo -e "${BLUE}📺 YouTube: https://youtube.com/@cloudwalejijaji${NC}"
echo -e "${BLUE}📚 Blog: https://medium.com/@drabhishek${NC}"
echo -e "\n${GREEN}🔔 Don't forget to LIKE, SHARE, and SUBSCRIBE for more tutorials!${NC}"
