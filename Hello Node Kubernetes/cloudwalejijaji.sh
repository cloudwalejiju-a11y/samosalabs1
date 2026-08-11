#!/bin/bash

# Define colors and formatting
BLUE=$'\033[0;94m'
GREEN=$'\033[0;92m'
YELLOW=$'\033[0;93m'
RED=$'\033[0;91m'
NC=$'\033[0m' # No Color
BOLD=$'\033[1m'

# Header
echo
echo "${BLUE}${BOLD}╔══════════════════════════════════════════╗${NC}"
echo "${BLUE}${BOLD}║     Welcome to Cloud Wale Jija Ji Cloud Tutorials      ║${NC}"
echo "${BLUE}${BOLD}╚══════════════════════════════════════════╝${NC}"
echo

# Get project ID
export PROJECT_ID=$(gcloud config get-value project)
echo "${YELLOW}${BOLD}Project ID: ${BLUE}$PROJECT_ID${NC}"
echo

# Step 1: Create Node.js application files
echo "${YELLOW}${BOLD}Step 1: Creating application files${NC}"
cat > server.js <<EOF
var http = require('http');
var handleRequest = function(request, response) {
  response.writeHead(200);
  response.end("Hello World!");
}
var www = http.createServer(handleRequest);
www.listen(8080);
EOF

cat > Dockerfile <<EOF
FROM node:6.9.2
EXPOSE 8080
COPY server.js .
CMD node server.js
EOF

echo "${GREEN}Created server.js and Dockerfile${NC}"
echo

# Step 2: Build Docker image
echo "${YELLOW}${BOLD}Step 2: Building Docker image${NC}"
docker build -t gcr.io/$PROJECT_ID/hello-node:v1 . || {
    echo "${RED}${BOLD}Error building Docker image${NC}"
    exit 1
}
echo "${GREEN}Docker image built successfully${NC}"
echo

# Step 3: Run container locally
echo "${YELLOW}${BOLD}Step 3: Testing container locally${NC}"
docker run -d -p 8080:8080 gcr.io/$PROJECT_ID/hello-node:v1 || {
    echo "${RED}${BOLD}Error running container${NC}"
    exit 1
}

echo "${GREEN}Local test:${NC}"
curl -s http://localhost:8080
echo

ID=$(docker ps --format '{{.ID}}')
docker stop $ID
echo "${GREEN}Stopped test container${NC}"
echo

# Step 4: Push to Container Registry
echo "${YELLOW}${BOLD}Step 4: Pushing to Container Registry${NC}"
gcloud auth configure-docker --quiet
docker push gcr.io/$PROJECT_ID/hello-node:v1 || {
    echo "${RED}${BOLD}Error pushing to Container Registry${NC}"
    exit 1
}
echo "${GREEN}Image pushed to gcr.io/$PROJECT_ID/hello-node:v1${NC}"
echo

# Step 5: Create GKE cluster
echo "${YELLOW}${BOLD}Step 5: Creating GKE cluster${NC}"
export ZONE=$(gcloud config get-value compute/zone)
gcloud container clusters create hello-world \
    --zone="$ZONE" \
    --num-nodes=2 \
    --machine-type=n1-standard-1 || {
    echo "${RED}${BOLD}Error creating cluster${NC}"
    exit 1
}
echo "${GREEN}Cluster created successfully${NC}"
echo

# Step 6: Deploy to Kubernetes
echo "${YELLOW}${BOLD}Step 6: Deploying to Kubernetes${NC}"
kubectl create deployment hello-node --image=gcr.io/$PROJECT_ID/hello-node:v1 || {
    echo "${RED}${BOLD}Error creating deployment${NC}"
    exit 1
}

echo "${GREEN}Deployment status:${NC}"
sleep 5
kubectl get deployments
echo

echo "${GREEN}Pod status:${NC}"
sleep 5
kubectl get pods
echo

echo "${GREEN}Cluster info:${NC}"
kubectl cluster-info
echo

# Step 7: Expose service
echo "${YELLOW}${BOLD}Step 7: Exposing service${NC}"
kubectl expose deployment hello-node --type="LoadBalancer" --port=8080 || {
    echo "${RED}${BOLD}Error exposing service${NC}"
    exit 1
}

echo "${GREEN}Service status:${NC}"
sleep 7
kubectl get services
echo

# Step 8: Scale deployment
echo "${YELLOW}${BOLD}Step 8: Scaling deployment${NC}"
kubectl scale deployment hello-node --replicas=4 || {
    echo "${RED}${BOLD}Error scaling deployment${NC}"
    exit 1
}

echo "${GREEN}Scaled deployment status:${NC}"
sleep 5
kubectl get deployment
echo

echo "${GREEN}Pod status after scaling:${NC}"
sleep 7
kubectl get pods
echo

# Final output
SERVICE_IP=$(kubectl get service hello-node -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "${GREEN}${BOLD}Deployment successful!${NC}"
echo "${YELLOW}Access your application at: ${BLUE}http://$SERVICE_IP:8080${NC}"
echo
echo "${GREEN}Subscribe for more tutorials: ${BLUE}https://www.youtube.com/@cloudwalejijaji${NC}"
