#!/bin/bash

# Enhanced Color Definitions
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BOLD=$(tput bold)
RESET=$(tput sgr0)

# Display Header
clear
echo "${YELLOW}${BOLD}================================================${RESET}"
echo "${YELLOW}${BOLD}   DR. ABHISHEK'S GKE AUTOSCALING DEMO LAB     ${RESET}"
echo "${YELLOW}${BOLD}================================================${RESET}"
echo "${BLUE}YouTube Channel: https://www.youtube.com/@cloudwalejijaji${RESET}"
echo "${CYAN}Video Tutorials: https://www.youtube.com/@cloudwalejijaji/videos${RESET}"
echo

# Get Zone Input
echo "${CYAN}${BOLD}Step 1: Please enter your preferred zone (e.g., us-central1-a):${RESET}"
read ZONE
export ZONE
REGION=${ZONE%-*}
echo "${GREEN}✓ Zone set to: ${ZONE}${RESET}"
echo "${GREEN}✓ Region automatically set to: ${REGION}${RESET}"
echo

# Initialize Project
echo "${CYAN}${BOLD}Step 2: Initializing Google Cloud Project...${RESET}"
gcloud auth list
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_ID=$DEVSHELL_PROJECT_ID
gcloud config set compute/zone $ZONE
gcloud config set compute/region $REGION
echo "${GREEN}✓ Project initialized: ${PROJECT_ID}${RESET}"
echo

# Create GKE Cluster with VPA
echo "${CYAN}${BOLD}Step 3: Creating GKE Cluster with Vertical Pod Autoscaling...${RESET}"
gcloud container clusters create scaling-demo --num-nodes=3 --enable-vertical-pod-autoscaling
echo "${GREEN}✓ Cluster 'scaling-demo' created with VPA enabled${RESET}"
echo

# Deploy PHP Apache Application
echo "${CYAN}${BOLD}Step 4: Deploying PHP Apache Application...${RESET}"
cat << EOF > php-apache.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-apache
spec:
  selector:
    matchLabels:
      run: php-apache
  replicas: 3
  template:
    metadata:
      labels:
        run: php-apache
    spec:
      containers:
      - name: php-apache
        image: k8s.gcr.io/hpa-example
        ports:
        - containerPort: 80
        resources:
          limits:
            cpu: 500m
          requests:
            cpu: 200m
---
apiVersion: v1
kind: Service
metadata:
  name: php-apache
  labels:
    run: php-apache
spec:
  ports:
  - port: 80
  selector:
    run: php-apache
EOF

kubectl apply -f php-apache.yaml
kubectl get deployment
echo "${GREEN}✓ PHP Apache application deployed${RESET}"
echo

# Configure Horizontal Pod Autoscaler
echo "${CYAN}${BOLD}Step 5: Configuring Horizontal Pod Autoscaler (HPA)...${RESET}"
kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10
kubectl get hpa
echo "${GREEN}✓ HPA configured for php-apache deployment${RESET}"
echo

# Verify VPA Configuration
echo "${CYAN}${BOLD}Step 6: Verifying Vertical Pod Autoscaling Configuration...${RESET}"
gcloud container clusters describe scaling-demo | grep ^verticalPodAutoscaling -A 1
echo "${GREEN}✓ Vertical Pod Autoscaling verified${RESET}"
echo

# Deploy Hello-Server Application
echo "${CYAN}${BOLD}Step 7: Deploying Hello-Server Application...${RESET}"
kubectl create deployment hello-server --image=gcr.io/google-samples/hello-app:1.0
kubectl get deployment hello-server
kubectl set resources deployment hello-server --requests=cpu=450m
kubectl describe pod hello-server | sed -n "/Containers:$/,/Conditions:/p"
echo "${GREEN}✓ Hello-server application deployed${RESET}"
echo

# Configure Vertical Pod Autoscaler
echo "${CYAN}${BOLD}Step 8: Configuring Vertical Pod Autoscaler (VPA)...${RESET}"
cat << EOF > hello-vpa.yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: hello-server-vpa
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind:       Deployment
    name:       hello-server
  updatePolicy:
    updateMode: "Off"
EOF

kubectl apply -f hello-vpa.yaml
kubectl describe vpa hello-server-vpa
echo "${GREEN}✓ VPA configured in Off mode${RESET}"
echo

# Update VPA to Auto Mode
echo "${CYAN}${BOLD}Step 9: Updating VPA to Auto Mode...${RESET}"
sed -i 's/Off/Auto/g' hello-vpa.yaml
kubectl apply -f hello-vpa.yaml
kubectl scale deployment hello-server --replicas=2
kubectl get pods
kubectl describe pod hello-server | sed -n "/Containers:$/,/Conditions:/p"
echo "${GREEN}✓ VPA updated to Auto mode${RESET}"
echo

# Configure Cluster Autoscaler
echo "${CYAN}${BOLD}Step 10: Configuring Cluster Autoscaler...${RESET}"
gcloud beta container clusters update scaling-demo --enable-autoscaling --min-nodes 1 --max-nodes 5
gcloud beta container clusters update scaling-demo --autoscaling-profile optimize-utilization
echo "${GREEN}✓ Cluster autoscaler configured${RESET}"
echo

# Create Pod Disruption Budgets
echo "${CYAN}${BOLD}Step 11: Creating Pod Disruption Budgets...${RESET}"
kubectl create poddisruptionbudget kube-dns-pdb --namespace=kube-system --selector k8s-app=kube-dns --max-unavailable 1
kubectl create poddisruptionbudget prometheus-pdb --namespace=kube-system --selector k8s-app=prometheus-to-sd --max-unavailable 1
kubectl create poddisruptionbudget kube-proxy-pdb --namespace=kube-system --selector component=kube-proxy --max-unavailable 1
kubectl create poddisruptionbudget metrics-agent-pdb --namespace=kube-system --selector k8s-app=gke-metrics-agent --max-unavailable 1
kubectl create poddisruptionbudget metrics-server-pdb --namespace=kube-system --selector k8s-app=metrics-server --max-unavailable 1
kubectl create poddisruptionbudget fluentd-pdb --namespace=kube-system --selector k8s-app=fluentd-gke --max-unavailable 1
kubectl create poddisruptionbudget backend-pdb --namespace=kube-system --selector k8s-app=glbc --max-unavailable 1
kubectl create poddisruptionbudget kube-dns-autoscaler-pdb --namespace=kube-system --selector k8s-app=kube-dns-autoscaler --max-unavailable 1
kubectl create poddisruptionbudget stackdriver-pdb --namespace=kube-system --selector app=stackdriver-metadata-agent --max-unavailable 1
kubectl create poddisruptionbudget event-pdb --namespace=kube-system --selector k8s-app=event-exporter --max-unavailable 1
echo "${GREEN}✓ Pod Disruption Budgets created${RESET}"
echo

# Enable Autoprovisioning
echo "${CYAN}${BOLD}Step 12: Enabling Cluster Autoprovisioning...${RESET}"
gcloud container clusters update scaling-demo \
    --enable-autoprovisioning \
    --min-cpu 1 \
    --min-memory 2 \
    --max-cpu 45 \
    --max-memory 160
echo "${GREEN}✓ Cluster autoprovisioning enabled${RESET}"
echo

# Configure Overprovisioning
echo "${CYAN}${BOLD}Step 13: Configuring Overprovisioning...${RESET}"
cat << EOF > pause-pod.yaml
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: overprovisioning
value: -1
globalDefault: false
description: "Priority class used by overprovisioning."
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: overprovisioning
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      run: overprovisioning
  template:
    metadata:
      labels:
        run: overprovisioning
    spec:
      priorityClassName: overprovisioning
      containers:
      - name: reserve-resources
        image: k8s.gcr.io/pause
        resources:
          requests:
            cpu: 1
            memory: 4Gi
EOF

kubectl apply -f pause-pod.yaml
echo "${GREEN}✓ Overprovisioning configured${RESET}"
echo

# Final Status Check
echo "${CYAN}${BOLD}Step 14: Final Status Check...${RESET}"
kubectl get nodes
kubectl get hpa
kubectl get vpa
echo "${GREEN}✓ All components verified${RESET}"
echo

# Completion Message
echo "${MAGENTA}${BOLD}============================================${RESET}"
echo "${MAGENTA}${BOLD}   GKE AUTOSCALING DEMO LAB COMPLETED!      ${RESET}"
echo "${MAGENTA}${BOLD}============================================${RESET}"
echo
echo "${GREEN}${BOLD}Congratulations on completing the lab!${RESET}"
echo
echo "${BLUE}${BOLD}For more cloud tutorials:${RESET}"
echo "${CYAN}Subscribe to Cloud Wale Jija Ji's YouTube Channel:${RESET}"
echo "${YELLOW}https://www.youtube.com/@cloudwalejijaji${RESET}"
echo "${CYAN}Video Tutorials:${RESET}"
echo "${YELLOW}https://www.youtube.com/@cloudwalejijaji/videos${RESET}"
