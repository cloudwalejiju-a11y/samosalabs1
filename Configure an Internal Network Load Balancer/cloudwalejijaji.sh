#!/bin/bash


echo "********************************************"
echo "*       Welcome to Cloud Wale Jija Ji's Channel  *"
echo "*    Your Cloud Learning Destination! 🚀    *"
echo "********************************************"

echo "Subscribe now: https://www.youtube.com/@cloudwalejijaji"

# Prompt user for inputs
read -p "Enter Region: " REGION
read -p "Enter Zone 1 for Utility VM: " ZONE1
read -p "Enter Zone 2 for Instance Group 1: " ZONE2
read -p "Enter Zone 3 for Instance Group 2: " ZONE3

NETWORK="my-internal-app"
SUBNET_A="subnet-a"
SUBNET_B="subnet-b"
INSTANCE_GROUP_1="instance-group-1"
INSTANCE_GROUP_2="instance-group-2"
UTILITY_VM="utility-vm"

# Task 1: Configure Internal Traffic and Health Check Firewall Rules
gcloud compute firewall-rules create fw-allow-lb-access \
    --network=$NETWORK \
    --allow=all \
    --source-ranges=10.10.0.0/16 \
    --target-tags=backend-service

gcloud compute firewall-rules create fw-allow-health-checks \
    --network=$NETWORK \
    --allow=tcp:80 \
    --source-ranges=130.211.0.0/22,35.191.0.0/16 \
    --target-tags=backend-service

# Task 2: Create a NAT Configuration Using Cloud Router
gcloud compute routers create nat-router-$REGION \
    --network=$NETWORK \
    --region=$REGION

gcloud compute routers nats create nat-config \
    --router=nat-router-$REGION \
    --region=$REGION \
    --auto-allocate-nat-external-ips \
    --nat-all-subnet-ip-ranges

# Task 3: Configure Instance Templates and Create Instance Groups
for group in $INSTANCE_GROUP_1 $INSTANCE_GROUP_2; do
    gcloud compute ssh $group --zone=$(gcloud compute instances list --filter="name=$group" --format="value(zone)") --command="sudo google_metadata_script_runner startup"
done

# Create Utility VM
gcloud compute instances create $UTILITY_VM \
    --zone=$ZONE1 \
    --machine-type=e2-medium \
    --image-family=debian-12 \
    --image-project=debian-cloud \
    --network=$NETWORK \
    --subnet=$SUBNET_A \
    --private-network-ip=10.10.20.50 \
    --no-address

# Task 4: Configure the Internal Network Load Balancer
gcloud compute addresses create my-ilb-ip \
    --region=$REGION \
    --subnet=$SUBNET_B \
    --addresses=10.10.30.5

gcloud compute health-checks create tcp my-ilb-health-check \
    --port=80

gcloud compute backend-services create my-ilb-backend-service \
    --load-balancing-scheme=INTERNAL \
    --region=$REGION \
    --health-checks=my-ilb-health-check \
    --protocol=TCP

gcloud compute backend-services add-backend my-ilb-backend-service \
    --instance-group=$INSTANCE_GROUP_1 \
    --instance-group-zone=$ZONE2 \
    --region=$REGION

gcloud compute backend-services add-backend my-ilb-backend-service \
    --instance-group=$INSTANCE_GROUP_2 \
    --instance-group-zone=$ZONE3 \
    --region=$REGION

gcloud compute forwarding-rules create my-ilb \
    --load-balancing-scheme=INTERNAL \
    --region=$REGION \
    --network=$NETWORK \
    --subnet=$SUBNET_B \
    --address=my-ilb-ip \
    --ports=80 \
    --backend-service=my-ilb-backend-service

echo "********************************************"
echo "*      Thanks for using this script!       *"
echo "*  Don't forget to subscribe! 🎥🚀        *"
echo "********************************************"
