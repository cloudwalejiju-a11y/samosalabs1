#!/bin/bash

# Color codes for formatting
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
MAGENTA='\e[1;35m'
CYAN='\e[1;36m'
WHITE='\e[1;37m'
NC='\e[0m' # No Color

# Function to display spinner
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Function to print section header
print_header() {
    echo -e "\n${MAGENTA}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║${NC} ${CYAN}$1${NC} ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════════╝${NC}"
}

# Function to print success message
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Function to print error message
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to print info message
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Welcome message with animation
echo -e "${CYAN}"
cat << "EOF"
  _    _ _   _ _ _ _          _   _           _     
 | |  | | | | | | | |        | | | |         | |    
 | |  | | | | | | | | ___  __| | | |__   __ _| |__  
 | |  | | | | | | | |/ _ \/ _` | | '_ \ / _` | '_ \ 
 | |__| | |_| | | | |  __/ (_| | | | | | (_| | | | |
  \____/ \___/|_|_|_|\___|\__,_| |_| |_|\__,_|_| |_|
EOF
echo -e "${NC}"

# Cloud Wale Jija Ji YouTube promotion
echo -e "${YELLOW}📺 Welcome to Advanced Kubernetes Lab!${NC}"
echo -e "${MAGENTA}🌟 Don't forget to subscribe to:${NC}"
echo -e "${CYAN}   Cloud Wale Jija Ji YouTube Channel:${NC} ${WHITE}https://www.youtube.com/@cloudwalejijaji/videos${NC}"
echo -ne "${GREEN}   Loading awesome content:${NC} "
(sleep 2) & spinner $!
echo -e "${GREEN}✅ Ready to learn!${NC}"

# Fetch zone and region
print_header "Fetching Google Cloud Configuration"
print_info "Getting zone, region, and project details..."
ZONE=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-zone])" 2>/dev/null)
REGION=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-region])" 2>/dev/null)
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)

if [ -z "$ZONE" ] || [ -z "$REGION" ] || [ -z "$PROJECT_ID" ]; then
    print_error "Failed to get Google Cloud configuration. Please check your gcloud setup."
    exit 1
fi

print_success "Zone: $ZONE"
print_success "Region: $REGION"
print_success "Project ID: $PROJECT_ID"

# Set up Google Cloud configuration
print_info "Setting up Google Cloud configuration..."
gcloud auth list &
spinner $!

gcloud config set project $DEVSHELL_PROJECT_ID &
spinner $!

gcloud config set compute/zone "$ZONE" &
spinner $!

gcloud config set compute/region "$REGION" &
spinner $!

# Create GKE cluster
print_header "Creating GKE Cluster"
print_info "Creating test-cluster with 3 nodes and IP alias..."
gcloud container clusters create test-cluster --num-nodes=3 --enable-ip-alias &
spinner $!
print_success "GKE cluster created successfully!"

# Create frontend pod
print_header "Creating Frontend Pod"
print_info "Creating gb-frontend pod configuration..."
cat << EOF > gb_frontend_pod.yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: gb-frontend
  name: gb-frontend
spec:
    containers:
    - name: gb-frontend
      image: gcr.io/google-samples/gb-frontend-amd64:v5
      resources:
        requests:
          cpu: 100m
          memory: 256Mi
      ports:
      - containerPort: 80
EOF

kubectl apply -f gb_frontend_pod.yaml &
spinner $!
print_success "Frontend pod created successfully!"

# Create ClusterIP service
print_header "Creating ClusterIP Service"
print_info "Creating gb-frontend service..."
cat << EOF > gb_frontend_cluster_ip.yaml
apiVersion: v1
kind: Service
metadata:
  name: gb-frontend-svc
  annotations:
    cloud.google.com/neg: '{"ingress": true}'
spec:
  type: ClusterIP
  selector:
    app: gb-frontend
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
EOF

kubectl apply -f gb_frontend_cluster_ip.yaml &
spinner $!
print_success "ClusterIP service created successfully!"

# Create Ingress
print_header "Creating Ingress"
print_info "Setting up ingress for the application..."
cat << EOF > gb_frontend_ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: gb-frontend-ingress
spec:
  defaultBackend:
    service:
      name: gb-frontend-svc
      port:
        number: 80
EOF

kubectl apply -f gb_frontend_ingress.yaml &
spinner $!
print_success "Ingress created successfully!"

# Wait for backend services
print_info "Waiting for backend services to be ready..."
sleep 600 &
spinner $!

# Check backend service health
print_header "Checking Backend Service Health"
BACKEND_SERVICE=$(gcloud compute backend-services list | grep NAME | cut -d ' ' -f2)
print_info "Checking health of backend service: $BACKEND_SERVICE"
gcloud compute backend-services get-health $BACKEND_SERVICE --global

# Get ingress details
print_info "Getting ingress details..."
kubectl get ingress gb-frontend-ingress

# Part 2 - Confirmation
print_header "PART 2: Advanced Kubernetes Features"
while true; do
    echo -ne "${YELLOW}🎯 Do you want to proceed with Part 2? ${NC}[${GREEN}Y${NC}/${RED}N${NC}]: "
    read confirm
    case "$confirm" in
        [Yy]) 
            echo -e "${GREEN}🚀 Continuing with Part 2...${NC}"
            break
            ;;
        [Nn]|"") 
            echo -e "${YELLOW}⏸️  Operation canceled.${NC}"
            exit 0
            ;;
        *) 
            echo -e "${RED}❌ Invalid input. Please enter Y or N.${NC}" 
            ;;
    esac
done

# Copy Locust files
print_header "Setting Up Load Testing with Locust"
print_info "Copying Locust image files..."
gsutil -m cp -r gs://spls/gsp769/locust-image . &
spinner $!

# Build and deploy Locust
print_info "Building Locust container image..."
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/locust-tasks:latest locust-image &
spinner $!

print_info "Deploying Locust to Kubernetes..."
gsutil cp gs://spls/gsp769/locust_deploy_v2.yaml . &
spinner $!

sed 's/${GOOGLE_CLOUD_PROJECT}/'$GOOGLE_CLOUD_PROJECT'/g' locust_deploy_v2.yaml | kubectl apply -f - &
spinner $!
print_success "Locust deployed successfully!"

# Check Locust service
print_info "Getting Locust service details..."
kubectl get service locust-main

# Liveness probe demo
print_header "Liveness Probe Demo"
print_info "Creating liveness probe demonstration..."
cat > liveness-demo.yaml <<EOF_END
apiVersion: v1
kind: Pod
metadata:
  labels:
    demo: liveness-probe
  name: liveness-demo-pod
spec:
  containers:
  - name: liveness-demo-pod
    image: centos
    args:
    - /bin/sh
    - -c
    - touch /tmp/alive; sleep infinity
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/alive
      initialDelaySeconds: 5
      periodSeconds: 10
EOF_END

kubectl apply -f liveness-demo.yaml &
spinner $!

print_info "Describing liveness demo pod..."
kubectl describe pod liveness-demo-pod

print_info "Testing liveness probe by removing health file..."
kubectl exec liveness-demo-pod -- rm /tmp/alive &
spinner $!

print_info "Checking pod status after liveness failure..."
kubectl describe pod liveness-demo-pod

# Readiness probe demo
print_header "Readiness Probe Demo"
print_info "Creating readiness probe demonstration..."
cat << EOF > readiness-demo.yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    demo: readiness-probe
  name: readiness-demo-pod
spec:
  containers:
  - name: readiness-demo-pod
    image: nginx
    ports:
    - containerPort: 80
    readinessProbe:
      exec:
        command:
        - cat
        - /tmp/healthz
      initialDelaySeconds: 5
      periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: readiness-demo-svc
  labels:
    demo: readiness-probe
spec:
  type: LoadBalancer
  ports:
    - port: 80
      targetPort: 80
      protocol: TCP
  selector:
    demo: readiness-probe
EOF

kubectl apply -f readiness-demo.yaml &
spinner $!

print_info "Getting readiness service details..."
kubectl get service readiness-demo-svc

print_info "Describing readiness demo pod..."
kubectl describe pod readiness-demo-pod

print_info "Waiting for pod to stabilize..."
sleep 45 &
spinner $!

print_info "Making pod ready by creating health file..."
kubectl exec readiness-demo-pod -- touch /tmp/healthz &
spinner $!

print_info "Checking pod conditions..."
kubectl describe pod readiness-demo-pod | grep ^Conditions -A 5

# Frontend deployment
print_header "Creating Frontend Deployment"
print_info "Deleting standalone pod..."
kubectl delete pod gb-frontend &
spinner $!

print_info "Creating deployment with 5 replicas..."
cat << EOF > gb_frontend_deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gb-frontend
  labels:
    run: gb-frontend
spec:
  replicas: 5
  selector:
    matchLabels:
      run: gb-frontend
  template:
    metadata:
      labels:
        run: gb-frontend
    spec:
      containers:
        - name: gb-frontend
          image: gcr.io/google-samples/gb-frontend-amd64:v5
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
          ports:
            - containerPort: 80
              protocol: TCP
EOF

kubectl apply -f gb_frontend_deployment.yaml &
spinner $!
print_success "Frontend deployment created with 5 replicas!"

# Final Locust setup
print_header "Finalizing Load Testing Setup"
print_info "Rebuilding Locust image..."
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/locust-tasks:latest locust-image &
spinner $!

print_info "Getting Locust UI IP address..."
export LOCUST_IP=$(kubectl get svc locust-main -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)

if [ -n "$LOCUST_IP" ]; then
    print_success "Locust UI IP: $LOCUST_IP"
    echo -e "\n${CYAN}=================================================${NC}"
    echo -e "${GREEN}🎉 Lab Setup Completed Successfully!${NC}"
    echo -e "${YELLOW}🌐 Your Locust UI is available at:${NC}"
    echo -e "${WHITE}   http://$LOCUST_IP:8089 ${NC}🚀"
    echo -e "${CYAN}=================================================${NC}"
else
    print_warning "Locust service IP not available yet. Please check later with:"
    echo -e "${BLUE}kubectl get svc locust-main${NC}"
fi

# Final message
echo -e "\n${MAGENTA}🙏 Thank you for completing the Advanced Kubernetes Lab!${NC}"
echo -e "${CYAN}📚 Learn more from Cloud Wale Jija Ji's YouTube channel:${NC}"
echo -e "${WHITE}   https://www.youtube.com/@cloudwalejijaji/videos${NC}"
echo -e "${YELLOW}⭐ Don't forget to like and subscribe!${NC}"
