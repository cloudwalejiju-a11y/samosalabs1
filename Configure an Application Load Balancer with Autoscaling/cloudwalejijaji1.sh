#!/bin/bash

# Enable error reporting and logging
set -e
exec > >(tee -i dynamic_lab_setup.log)
exec 2>&1

echo "Welcome to Cloud Wale Jija Ji GCP tutorials.."

# Get project details
PROJECT_ID=$(gcloud config get-value project)
DEFAULT_REGION=$(gcloud compute project-info describe --format="value(defaultComputeRegion)")

# Function to check if resource exists
resource_exists() {
    local resource_type=$1
    local resource_name=$2
    local extra_flags=${3:-}
    
    if gcloud compute $resource_type describe $resource_name $extra_flags --format="value(name)" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to get random zone from a region
get_random_zone() {
    local region=$1
    gcloud compute zones list --filter="region=$region AND status=UP" --format="value(name)" | shuf -n 1
}

# Dynamically select two distinct regions
echo "Selecting optimal regions..."
REGIONS=($(gcloud compute regions list --filter="name~'us-.*|europe-.*|asia-.*'" --format="value(name)" | shuf -n 2))
REGION1=${REGIONS[0]}
REGION2=${REGIONS[1]}
ZONE1=$(get_random_zone $REGION1)
ZONE2=$(get_random_zone $REGION2)

echo "Selected regions: $REGION1 (zone: $ZONE1) and $REGION2 (zone: $ZONE2)"

# Task 1: Configure Health Check Firewall Rule
if ! resource_exists firewall-rules fw-allow-health-checks; then
    echo "Creating health check firewall rule..."
    gcloud compute firewall-rules create fw-allow-health-checks \
        --network=default \
        --action=allow \
        --direction=INGRESS \
        --rules=tcp:80 \
        --source-ranges=130.211.0.0/22,35.191.0.0/16 \
        --target-tags=allow-health-checks
else
    echo "Firewall rule 'fw-allow-health-checks' already exists, skipping..."
fi

# Task 2: Create NAT Configuration in first region
if ! resource_exists routers nat-router-dynamic --region=$REGION1; then
    echo "Setting up Cloud NAT in $REGION1..."
    gcloud compute routers create nat-router-dynamic \
        --region=${REGION1} \
        --network=default

    gcloud compute routers nats create nat-config-dynamic \
        --router=nat-router-dynamic \
        --router-region=${REGION1} \
        --auto-allocate-nat-external-ips \
        --nat-all-subnet-ip-ranges
else
    echo "NAT configuration already exists in $REGION1, skipping..."
fi

# Task 3: Create Custom Web Server Image
if ! resource_exists images mywebserver-dynamic; then
    echo "Creating web server VM in $ZONE1..."
    gcloud compute instances create webserver-dynamic \
        --zone=${ZONE1} \
        --machine-type=e2-micro \
        --tags=allow-health-checks \
        --no-address \
        --image-family=debian-10 \
        --image-project=debian-cloud \
        --boot-disk-size=10GB \
        --metadata=startup-script='#! /bin/bash
        sudo apt-get update
        sudo apt-get install -y apache2
        sudo service apache2 start
        sudo update-rc.d apache2 enable'

    echo "Waiting 2 minutes for VM to initialize..."
    sleep 120

    echo "Creating custom image..."
    gcloud compute images create mywebserver-dynamic \
        --source-disk=webserver-dynamic \
        --source-disk-zone=${ZONE1}

    echo "Cleaning up web server VM..."
    gcloud compute instances delete webserver-dynamic \
        --zone=${ZONE1} \
        --keep-disks=boot \
        --quiet
else
    echo "Custom image 'mywebserver-dynamic' already exists, skipping..."
fi

# Task 4: Configure Instance Template and Groups
if ! resource_exists instance-templates mywebserver-template-dynamic; then
    echo "Creating instance template..."
    gcloud compute instance-templates create mywebserver-template-dynamic \
        --machine-type=e2-micro \
        --tags=allow-health-checks \
        --no-address \
        --image=mywebserver-dynamic \
        --network=default
else
    echo "Instance template 'mywebserver-template-dynamic' already exists, skipping..."
fi

if ! resource_exists health-checks http-health-check-dynamic; then
    echo "Creating health check..."
    gcloud compute health-checks create tcp http-health-check-dynamic \
        --port=80
else
    echo "Health check 'http-health-check-dynamic' already exists, skipping..."
fi

# Create managed instance groups in both regions
if ! resource_exists instance-groups mig-dynamic-1 --zone=$ZONE1; then
    echo "Creating MIG in $REGION1 ($ZONE1)..."
    gcloud compute instance-groups managed create mig-dynamic-1 \
        --template=mywebserver-template-dynamic \
        --size=1 \
        --zone=${ZONE1} \
        --health-check=http-health-check-dynamic \
        --initial-delay=60

    gcloud compute instance-groups managed set-autoscaling mig-dynamic-1 \
        --zone=${ZONE1} \
        --max-num-replicas=2 \
        --target-load-balancing-utilization=0.8 \
        --cool-down-period=60
else
    echo "MIG 'mig-dynamic-1' already exists in $ZONE1, skipping..."
fi

if ! resource_exists instance-groups mig-dynamic-2 --zone=$ZONE2; then
    echo "Creating MIG in $REGION2 ($ZONE2)..."
    gcloud compute instance-groups managed create mig-dynamic-2 \
        --template=mywebserver-template-dynamic \
        --size=1 \
        --zone=${ZONE2} \
        --health-check=http-health-check-dynamic \
        --initial-delay=60

    gcloud compute instance-groups managed set-autoscaling mig-dynamic-2 \
        --zone=${ZONE2} \
        --max-num-replicas=2 \
        --target-load-balancing-utilization=0.8 \
        --cool-down-period=60
else
    echo "MIG 'mig-dynamic-2' already exists in $ZONE2, skipping..."
fi

# Task 5: Configure HTTP Load Balancer
if ! resource_exists backend-services http-backend-dynamic --global; then
    echo "Creating load balancer..."
    gcloud compute backend-services create http-backend-dynamic \
        --protocol=HTTP \
        --health-checks=http-health-check-dynamic \
        --global

    # Add backends
    gcloud compute backend-services add-backend http-backend-dynamic \
        --instance-group=mig-dynamic-1 \
        --instance-group-zone=${ZONE1} \
        --balancing-mode=RATE \
        --max-rate-per-instance=50 \
        --global

    gcloud compute backend-services add-backend http-backend-dynamic \
        --instance-group=mig-dynamic-2 \
        --instance-group-zone=${ZONE2} \
        --balancing-mode=UTILIZATION \
        --max-utilization=0.8 \
        --global

    # Create URL map and proxy
    gcloud compute url-maps create http-lb-dynamic \
        --default-service=http-backend-dynamic

    gcloud compute target-http-proxies create http-lb-proxy-dynamic \
        --url-map=http-lb-dynamic

    # Create forwarding rules
    gcloud compute forwarding-rules create http-lb-forwarding-rule-dynamic \
        --target-http-proxy=http-lb-proxy-dynamic \
        --ports=80 \
        --global

    gcloud compute forwarding-rules create http-lb-forwarding-rule-ipv6-dynamic \
        --target-http-proxy=http-lb-proxy-dynamic \
        --ports=80 \
        --ip-version=IPV6 \
        --global
else
    echo "Load balancer components already exist, skipping..."
fi

# Get LB IP
LB_IP=$(gcloud compute forwarding-rules describe http-lb-forwarding-rule-dynamic --global --format="value(IPAddress)")
echo "Load Balancer IP: $LB_IP"

# Task 6: Automated Stress Test
STRESS_ZONE=$(gcloud compute zones list --filter="region=$REGION1" --format="value(name)" | grep -v "$ZONE1" | shuf -n 1)

if ! resource_exists instances stress-test-dynamic --zone=$STRESS_ZONE; then
    echo "Creating stress-test VM in $STRESS_ZONE..."
    gcloud compute instances create stress-test-dynamic \
        --zone=${STRESS_ZONE} \
        --machine-type=e2-standard-2 \
        --image-family=debian-10 \
        --image-project=debian-cloud \
        --metadata=startup-script='#! /bin/bash
        sudo apt-get update
        sudo apt-get install -y apache2-utils'
    
    echo "Waiting 2 minutes for stress-test VM to initialize..."
    sleep 120
else
    echo "Stress-test VM already exists, skipping creation..."
fi

echo "Starting fully automated stress test..."
echo "This will run 500,000 requests (may take 5-10 minutes)..."
echo "--------------------------------------------------------"

# Run stress test via SSH (fully automated)
gcloud compute ssh stress-test-dynamic --zone=$STRESS_ZONE --quiet --command="\
    echo '=== Stress Test Started at \$(date) ==='; \
    echo 'Target: http://$LB_IP/'; \
    echo 'Running 500,000 requests with 1000 concurrent connections...'; \
    ab -n 500000 -c 1000 http://$LB_IP/; \
    echo '=== Stress Test Completed at \$(date) ==='"

echo "--------------------------------------------------------"
echo "Stress test completed successfully!"

# Monitoring commands
echo -e "\nMonitoring commands:"
echo "1. Check load balancer backends:"
echo "   gcloud compute backend-services get-health http-backend-dynamic --global"
echo ""
echo "2. Check instance groups:"
echo "   gcloud compute instance-groups list-instances mig-dynamic-1 --zone=$ZONE1"
echo "   gcloud compute instance-groups list-instances mig-dynamic-2 --zone=$ZONE2"
echo ""
echo "3. Check Cloud Monitoring:"
echo "   https://console.cloud.google.com/monitoring"
echo ""
echo "4. To delete all resources when done:"
echo "   gcloud compute instances delete stress-test-dynamic --zone=$STRESS_ZONE"
echo "   gcloud compute instance-groups managed delete mig-dynamic-1 --zone=$ZONE1"
echo "   gcloud compute instance-groups managed delete mig-dynamic-2 --zone=$ZONE2"
echo "   gcloud compute forwarding-rules delete http-lb-forwarding-rule-dynamic --global"
echo "   gcloud compute target-http-proxies delete http-lb-proxy-dynamic"
echo "   gcloud compute url-maps delete http-lb-dynamic"
echo "   gcloud compute backend-services delete http-backend-dynamic --global"
echo "   gcloud compute health-checks delete http-health-check-dynamic"
echo "   gcloud compute instance-templates delete mywebserver-template-dynamic"
echo "   gcloud compute images delete mywebserver-dynamic"
echo "   gcloud compute routers nats delete nat-config-dynamic --router=nat-router-dynamic --router-region=$REGION1"
echo "   gcloud compute routers delete nat-router-dynamic --region=$REGION1"
echo "   gcloud compute firewall-rules delete fw-allow-health-checks"
