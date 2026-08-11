#!/bin/bash

# Define color variables
BLACK=`tput setaf 0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`

BOLD=`tput bold`
RESET=`tput sgr0`

# Modern spinner function
spinner() {
    local pid=$!
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

clear

# Cloud Wale Jija Ji Banner
echo "${BLUE}${BOLD}====================================================================${RESET}"
echo "${BLUE}${BOLD}                  Cloud Wale Jija Ji Cloud Tutorials                     ${RESET}"
echo "${BLUE}${BOLD}====================================================================${RESET}"
echo
echo "${GREEN}${BOLD}Starting Load Balancer and Managed Instance Group Setup${RESET}"
echo

# Get project configuration
echo "${CYAN}${BOLD}➤ Getting Project Configuration${RESET}"
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")
export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
PROJECT_ID=$(gcloud config get-value project)

echo "${GREEN}✓ Project: $PROJECT_ID | Region: $REGION | Zone: $ZONE${RESET}"

# Step 1: Create instance template
echo "${CYAN}${BOLD}➤ Creating Instance Template${RESET}"
(gcloud beta compute instance-templates create instance-template-quicklab \
  --project=$PROJECT_ID \
  --machine-type=e2-micro \
  --network-interface=network=default,network-tier=PREMIUM,stack-type=IPV4_ONLY \
  --instance-template-region=$REGION \
  --metadata=^,@^startup-script=\#\ Copyright\ 2021\ Google\ LLC$'\n'\#$'\n'\#\ Licensed\ under\ the\ Apache\ License,\ Version\ 2.0\ \(the\ \"License\"\)\;$'\n'\#\ you\ may\ not\ use\ this\ file\ except\ in\ compliance\ with\ the\ License.\#\ You\ may\ obtain\ a\ copy\ of\ the\ License\ at$'\n'\#$'\n'\#\ http://www.apache.org/licenses/LICENSE-2.0$'\n'\#$'\n'\#\ Unless\ required\ by\ applicable\ law\ or\ agreed\ to\ in\ writing,\ software$'\n'\#\ distributed\ under\ the\ License\ is\ distributed\ on\ an\ \"AS\ IS\"\ BASIS,$'\n'\#\ WITHOUT\ WARRANTIES\ OR\ CONDITIONS\ OF\ ANY\ KIND,\ either\ express\ or\ implied.$'\n'\#\ See\ the\ License\ for\ the\ specific\ language\ governing\ permissions\ and$'\n'\#\ limitations\ under\ the\ License.$'\n'$'\n'apt-get\ -y\ update$'\n'apt-get\ -y\ install\ git$'\n'apt-get\ -y\ install\ virtualenv$'\n'git\ clone\ --depth\ 1\ https://github.com/GoogleCloudPlatform/python-docs-samples$'\n'cd\ python-docs-samples/iap$'\n'virtualenv\ venv\ -p\ python3$'\n'source\ venv/bin/activate$'\n'pip\ install\ -r\ requirements.txt$'\n'cat\ example_gce_backend.py\ \|$'\n'sed\ -e\ \"s/YOUR_BACKEND_SERVICE_ID/\$\(gcloud\ compute\ backend-services\ describe\ my-backend-service\ --global--format=\"value\(id\)\"\)/g\"\ \|$'\n'\ \ \ \ sed\ -e\ \"s/YOUR_PROJECT_ID/\$\(gcloud\ config\ get-value\ project\ \|\ tr\ -cd\ \"\[0-9\]\"\)/g\"\ \>\ real_backend.py$'\n'gunicorn\ real_backend:app\ -b\ 0.0.0.0:80,@enable-oslogin=true \
  --maintenance-policy=MIGRATE \
  --provisioning-model=STANDARD \
  --scopes=https://www.googleapis.com/auth/compute.readonly,https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append \
  --tags=http-server,https-server \
  --create-disk=auto-delete=yes,boot=yes,device-name=instance-template-quicklab,image=projects/debian-cloud/global/images/debian-12-bookworm-v20250311,mode=rw,size=10,type=pd-balanced \
  --no-shielded-secure-boot \
  --shielded-vtpm \
  --shielded-integrity-monitoring \
  --reservation-affinity=any > /dev/null 2>&1) &
spinner
echo "${GREEN}✓ Created instance template: instance-template-quicklab${RESET}"

# Step 2: Create health check
echo "${CYAN}${BOLD}➤ Creating Health Check${RESET}"
(gcloud beta compute health-checks create http my-health-check \
  --project=$PROJECT_ID \
  --port=80 \
  --request-path=/ \
  --proxy-header=NONE \
  --no-enable-logging \
  --check-interval=5 \
  --timeout=5 \
  --unhealthy-threshold=2 \
  --healthy-threshold=2 > /dev/null 2>&1) &
spinner
echo "${GREEN}✓ Created health check: my-health-check${RESET}"

# Step 3: Create managed instance group
echo "${CYAN}${BOLD}➤ Creating Managed Instance Group${RESET}"
(gcloud beta compute instance-groups managed create my-managed-instance-group \
  --project=$PROJECT_ID \
  --base-instance-name=my-managed-instance-group \
  --template=projects/$PROJECT_ID/regions/$REGION/instanceTemplates/instance-template-quicklab \
  --size=1 \
  --region=$REGION \
  --target-distribution-shape=EVEN \
  --instance-redistribution-type=proactive \
  --default-action-on-vm-failure=repair \
  --health-check=projects/$PROJECT_ID/global/healthChecks/my-health-check \
  --initial-delay=300 \
  --no-force-update-on-repair \
  --standby-policy-mode=manual \
  --list-managed-instances-results=pageless > /dev/null 2>&1 && \
gcloud beta compute instance-groups managed set-autoscaling my-managed-instance-group \
  --project=$PROJECT_ID \
  --region=$REGION \
  --mode=off \
  --min-num-replicas=1 \
  --max-num-replicas=10 \
  --target-cpu-utilization=0.6 \
  --cpu-utilization-predictive-method=none \
  --cool-down-period=60 > /dev/null 2>&1) &
spinner
echo "${GREEN}✓ Created managed instance group: my-managed-instance-group${RESET}"

# Step 4: Create security policy
echo "${CYAN}${BOLD}➤ Creating Security Policy${RESET}"
(curl -X POST \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $(gcloud auth print-access-token)" \
     -d '{
       "description": "Default security policy for: my-backend-service",
       "name": "default-security-policy-for-backend-service-my-backend-service",
       "rules": [
         {
           "action": "allow",
           "match": {
             "config": {
               "srcIpRanges": [
                 "*"
               ]
             },
             "versionedExpr": "SRC_IPS_V1"
           },
           "priority": 2147483647
         },
         {
           "action": "throttle",
           "description": "Default rate limiting rule",
           "match": {
             "config": {
               "srcIpRanges": [
                 "*"
               ]
             },
             "versionedExpr": "SRC_IPS_V1"
           },
           "priority": 2147483646,
           "rateLimitOptions": {
             "conformAction": "allow",
             "enforceOnKey": "IP",
             "exceedAction": "deny(403)",
             "rateLimitThreshold": {
               "count": 500,
               "intervalSec": 60
             }
           }
         }
       ]
     }' \
     "https://compute.googleapis.com/compute/v1/projects/$PROJECT_ID/global/securityPolicies" > /dev/null 2>&1) &
spinner
echo "${GREEN}✓ Created security policy${RESET}"

sleep 30

# Step 5: Create backend service
echo "${CYAN}${BOLD}➤ Creating Backend Service${RESET}"
(curl -X POST \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $(gcloud auth print-access-token)" \
     -d '{
       "backends": [
         {
           "balancingMode": "UTILIZATION",
           "capacityScaler": 1,
           "group": "projects/'"$PROJECT_ID"'/regions/'"$REGION"'/instanceGroups/my-managed-instance-group",
           "maxUtilization": 0.8
         }
       ],
       "connectionDraining": {
         "drainingTimeoutSec": 300
       },
       "description": "",
       "enableCDN": false,
       "healthChecks": [
         "projects/'"$PROJECT_ID"'/global/healthChecks/my-health-check"
       ],
       "ipAddressSelectionPolicy": "IPV4_ONLY",
       "loadBalancingScheme": "EXTERNAL_MANAGED",
       "localityLbPolicy": "ROUND_ROBIN",
       "logConfig": {
         "enable": false
       },
       "name": "my-backend-service",
       "portName": "http",
       "protocol": "HTTP",
       "securityPolicy": "projects/'"$PROJECT_ID"'/global/securityPolicies/default-security-policy-for-backend-service-my-backend-service",
       "sessionAffinity": "NONE",
       "timeoutSec": 30
     }' \
     "https://compute.googleapis.com/compute/beta/projects/$PROJECT_ID/global/backendServices" > /dev/null 2>&1) &
spinner
echo "${GREEN}✓ Created backend service: my-backend-service${RESET}"

sleep 60

# Step 6: Set security policy
echo "${CYAN}${BOLD}➤ Setting Security Policy${RESET}"
(curl -X POST \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $(gcloud auth print-access-token)" \
     -d '{
       "securityPolicy": "projects/'"$PROJECT_ID"'/global/securityPolicies/default-security-policy-for-backend-service-my-backend-service"
     }' \
     "https://compute.googleapis.com/compute/v1/projects/$PROJECT_ID/global/backendServices/my-backend-service/setSecurityPolicy" > /dev/null 2>&1) &
spinner
echo "${GREEN}✓ Security policy set${RESET}"

sleep 60

# Step 7: Create URL map
echo "${CYAN}${BOLD}➤ Creating URL Map${RESET}"
(curl -X POST \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $(gcloud auth print-access-token)" \
     -d '{
       "defaultService": "projects/'"$PROJECT_ID"'/global/backendServices/my-backend-service",
       "name": "my-load-balancer"
     }' \
     "https://compute.googleapis.com/compute/v1/projects/$PROJECT_ID/global/urlMaps" > /dev/null 2>&1) &
spinner
echo "${GREEN}✓ Created URL map: my-load-balancer${RESET}"

sleep 30

# Step 8: Create target proxy
echo "${CYAN}${BOLD}➤ Creating Target Proxy${RESET}"
(curl -X POST \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $(gcloud auth print-access-token)" \
     -d '{
       "name": "my-load-balancer-target-proxy",
       "urlMap": "projects/'"$PROJECT_ID"'/global/urlMaps/my-load-balancer"
     }' \
     "https://compute.googleapis.com/compute/v1/projects/$PROJECT_ID/global/targetHttpProxies" > /dev/null 2>&1) &
spinner
echo "${GREEN}✓ Created target proxy: my-load-balancer-target-proxy${RESET}"

sleep 90

# Step 9: Create forwarding rule
echo "${CYAN}${BOLD}➤ Creating Forwarding Rule${RESET}"
(curl -X POST \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $(gcloud auth print-access-token)" \
     -d '{
       "IPAddress": "projects/'"$PROJECT_ID"'/global/addresses/my-cert",
       "IPProtocol": "TCP",
       "loadBalancingScheme": "EXTERNAL_MANAGED",
       "name": "my-load-balancer-forwarding-rule",
       "networkTier": "PREMIUM",
       "portRange": "80",
       "target": "projects/'"$PROJECT_ID"'/global/targetHttpProxies/my-load-balancer-target-proxy"
     }' \
     "https://compute.googleapis.com/compute/beta/projects/$PROJECT_ID/global/forwardingRules" > /dev/null 2>&1) &
spinner
echo "${GREEN}✓ Created forwarding rule: my-load-balancer-forwarding-rule${RESET}"

sleep 30

# Step 10: Set named ports
echo "${CYAN}${BOLD}➤ Setting Named Ports${RESET}"
(curl -X POST \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $(gcloud auth print-access-token)" \
     -d '{
       "namedPorts": [
         {
           "name": "http",
           "port": 80
         }
       ]
     }' \
     "https://compute.googleapis.com/compute/beta/projects/$PROJECT_ID/regions/$REGION/instanceGroups/my-managed-instance-group/setNamedPorts" > /dev/null 2>&1) &
spinner
echo "${GREEN}✓ Named ports set${RESET}"

# Completion Message
echo
echo "${BLUE}${BOLD}====================================================================${RESET}"
echo "${BLUE}${BOLD}              LAB COMPLETED SUCCESSFULLY          ${RESET}"
echo "${BLUE}${BOLD}====================================================================${RESET}"
echo
echo "${GREEN}${BOLD}Thank you for using Cloud Wale Jija Ji Cloud Tutorials!${RESET}"
echo
echo "${YELLOW}For more cloud tutorials and labs, subscribe to:${RESET}"
echo "${CYAN}https://www.youtube.com/@cloudwalejijaji/videos${RESET}"
echo
