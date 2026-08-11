#!/bin/bash

# Define color variables
BLUE=$'\033[0;34m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
RED=$'\033[0;31m'
NC=$'\033[0m' # No Color
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

clear

# Welcome Banner
echo "${BLUE}${BOLD}"
echo "╔════════════════════════════════════════════════╗"
echo "║          Welcome to Dr abhishek Cloud          ║"
echo "╚════════════════════════════════════════════════╝"
echo "${NC}"

# Get Zone Input
echo "${YELLOW}${BOLD}Please enter your  zone (e.g., us-central1-a):${NC}${NORMAL}"
read ZONE
export ZONE

echo
echo "${GREEN}${BOLD}****** Lab Started  *****${NC}"
echo

echo "${YELLOW}Setting compute zone to ${ZONE}...${NC}"
gcloud config set compute/zone $ZONE

echo "${YELLOW}Creating GKE cluster 'io'...${NC}"
gcloud container clusters create io

echo "${YELLOW}Cloning training repository...${NC}"
git clone https://github.com/GoogleCloudPlatform/training-data-analyst

echo "${YELLOW}Creating symbolic link...${NC}"
ln -s ~/training-data-analyst/courses/ak8s/CloudBridge ~/ak8s

cd ~/ak8s/

echo "${YELLOW}Creating nginx deployment...${NC}"
kubectl create deployment nginx --image=nginx:1.10.0

echo "${YELLOW}Listing pods...${NC}"
kubectl get pods

echo "${YELLOW}Exposing nginx service...${NC}"
kubectl expose deployment nginx --port 80 --type LoadBalancer

echo "${YELLOW}Listing services...${NC}"
kubectl get services

cd ~/ak8s

echo "${YELLOW}Creating monolith pod...${NC}"
kubectl create -f pods/monolith.yaml

echo "${YELLOW}Listing pods...${NC}"
kubectl get pods

cd ~/ak8s

echo "${YELLOW}Creating TLS secrets and config maps...${NC}"
kubectl create secret generic tls-certs --from-file tls/
kubectl create configmap nginx-proxy-conf --from-file nginx/proxy.conf
kubectl create -f pods/secure-monolith.yaml

echo "${YELLOW}Creating monolith service...${NC}"
kubectl create -f services/monolith.yaml

echo "${YELLOW}Creating firewall rule...${NC}"
gcloud compute firewall-rules create allow-monolith-nodeport \
  --allow=tcp:31000

echo "${YELLOW}Listing monolith pods...${NC}"
kubectl get pods -l "app=monolith"

echo "${YELLOW}Listing secure monolith pods...${NC}"
kubectl get pods -l "app=monolith,secure=enabled"

echo "${YELLOW}Labeling secure-monolith pod...${NC}"
kubectl label pods secure-monolith 'secure=enabled'
kubectl get pods secure-monolith --show-labels

echo "${YELLOW}Describing monolith service endpoints...${NC}"
kubectl describe services monolith | grep Endpoints

echo "${YELLOW}Creating auth deployment and service...${NC}"
kubectl create -f deployments/auth.yaml
kubectl create -f services/auth.yaml

echo "${YELLOW}Creating hello deployment and service...${NC}"
kubectl create -f deployments/hello.yaml
kubectl create -f services/hello.yaml

echo "${YELLOW}Creating frontend config and deployment...${NC}"
kubectl create configmap nginx-frontend-conf --from-file=nginx/frontend.conf
kubectl create -f deployments/frontend.yaml
kubectl create -f services/frontend.yaml

echo "${YELLOW}Getting frontend service details...${NC}"
kubectl get services frontend

echo
echo "${GREEN}${BOLD}****** Congratulations! Lab Completed  *****${NC}"
echo
echo "${BLUE}${BOLD}For more cloud tutorials:${NC}"
echo "${BLUE}Subscribe to Cloud Wale Jija Ji's YouTube Channel:"
echo "https://www.youtube.com/@cloudwalejijaji${NC}"
echo
