#!/bin/bash

# Define text formatting variables
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

clear

# Welcome Banner
echo
echo "${CYAN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}       DR. ABHISHEK'S MICROSERVICES DEPLOYMENT LAB         ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${WHITE_TEXT}Let's deploy a monolith-to-microservices application${RESET_FORMAT}"
echo "${WHITE_TEXT}on Google Cloud Platform with load balancing and auto-scaling${RESET_FORMAT}"
echo

echo "${GREEN_TEXT}${BOLD_TEXT}=== INITIAL SETUP ===${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}🔧 Enabling Compute Engine API...${RESET_FORMAT}"
gcloud services enable compute.googleapis.com

echo "${YELLOW_TEXT}${BOLD_TEXT}📦 Creating storage bucket...${RESET_FORMAT}"
gsutil mb gs://fancy-store-$DEVSHELL_PROJECT_ID
echo "${GREEN_TEXT}✅ Bucket created: fancy-store-$DEVSHELL_PROJECT_ID${RESET_FORMAT}"

echo "${YELLOW_TEXT}${BOLD_TEXT}📥 Cloning monolith-to-microservices repository...${RESET_FORMAT}"
git clone https://github.com/googlecodelabs/monolith-to-microservices.git
cd ~/monolith-to-microservices
./setup.sh

echo "${YELLOW_TEXT}${BOLD_TEXT}📦 Installing Node.js LTS...${RESET_FORMAT}"
nvm install --lts

echo "${GREEN_TEXT}${BOLD_TEXT}=== BACKEND DEPLOYMENT ===${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}📝 Creating startup script for backend...${RESET_FORMAT}"
cd ~/monolith-to-microservices
cat > startup-script.sh <<'EOF_START'
#!/bin/bash
# Install logging monitor
curl -s "https://storage.googleapis.com/signals-agents/logging/google-fluentd-install.sh" | bash
service google-fluentd restart &

# Install dependencies
apt-get update
apt-get install -yq ca-certificates git build-essential supervisor psmisc

# Install Node.js
mkdir /opt/nodejs
curl https://nodejs.org/dist/v16.14.0/node-v16.14.0-linux-x64.tar.gz | tar xvzf - -C /opt/nodejs --strip-components=1
ln -s /opt/nodejs/bin/node /usr/bin/node
ln -s /opt/nodejs/bin/npm /usr/bin/npm

# Get application code
mkdir /fancy-store
gsutil -m cp -r gs://fancy-store-$DEVSHELL_PROJECT_ID/monolith-to-microservices/microservices/* /fancy-store/

# Install dependencies
cd /fancy-store/
npm install

# Configure application user
useradd -m -d /home/nodeapp nodeapp
chown -R nodeapp:nodeapp /opt/app

# Configure supervisor
cat >/etc/supervisor/conf.d/node-app.conf <<'EOF_END'
[program:nodeapp]
directory=/fancy-store
command=npm start
autostart=true
autorestart=true
user=nodeapp
environment=HOME="/home/nodeapp",USER="nodeapp",NODE_ENV="production"
stdout_logfile=syslog
stderr_logfile=syslog
EOF_END

supervisorctl reread
supervisorctl update
EOF_START

echo "${YELLOW_TEXT}${BOLD_TEXT}📤 Uploading files to storage bucket...${RESET_FORMAT}"
gsutil cp ~/monolith-to-microservices/startup-script.sh gs://fancy-store-$DEVSHELL_PROJECT_ID
cd ~
rm -rf monolith-to-microservices/*/node_modules
gsutil -m cp -r monolith-to-microservices gs://fancy-store-$DEVSHELL_PROJECT_ID/

echo "${YELLOW_TEXT}${BOLD_TEXT}🚀 Creating backend instance...${RESET_FORMAT}"
gcloud compute instances create backend \
    --zone=$ZONE \
    --machine-type=e2-standard-2 \
    --tags=backend \
    --metadata=startup-script-url=https://storage.googleapis.com/fancy-store-$DEVSHELL_PROJECT_ID/startup-script.sh

echo "${GREEN_TEXT}${BOLD_TEXT}=== FRONTEND DEPLOYMENT ===${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}🌐 Configuring frontend environment variables...${RESET_FORMAT}"
export EXTERNAL_IP_BACKEND=$(gcloud compute instances describe backend --zone=$ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

cd monolith-to-microservices/react-app
cat > .env <<EOF
REACT_APP_ORDERS_URL=http://$EXTERNAL_IP_BACKEND:8081/api/orders
REACT_APP_PRODUCTS_URL=http://$EXTERNAL_IP_BACKEND:8082/api/products
EOF

echo "${YELLOW_TEXT}${BOLD_TEXT}🔨 Building frontend application...${RESET_FORMAT}"
npm install && npm run-script build

echo "${YELLOW_TEXT}${BOLD_TEXT}📤 Uploading frontend files...${RESET_FORMAT}"
cd ~
rm -rf monolith-to-microservices/*/node_modules
gsutil -m cp -r monolith-to-microservices gs://fancy-store-$DEVSHELL_PROJECT_ID/

echo "${YELLOW_TEXT}${BOLD_TEXT}🚀 Creating frontend instance...${RESET_FORMAT}"
gcloud compute instances create frontend \
    --zone=$ZONE \
    --machine-type=e2-standard-2 \
    --tags=frontend \
    --metadata=startup-script-url=https://storage.googleapis.com/fancy-store-$DEVSHELL_PROJECT_ID/startup-script.sh

echo "${GREEN_TEXT}${BOLD_TEXT}=== NETWORK CONFIGURATION ===${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}🔒 Configuring firewall rules...${RESET_FORMAT}"
gcloud compute firewall-rules create fw-fe \
    --allow tcp:8080 \
    --target-tags=frontend

gcloud compute firewall-rules create fw-be \
    --allow tcp:8081-8082 \
    --target-tags=backend

echo "${GREEN_TEXT}${BOLD_TEXT}=== LOAD BALANCING SETUP ===${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}🛑 Stopping instances for template creation...${RESET_FORMAT}"
gcloud compute instances stop frontend --zone=$ZONE
gcloud compute instances stop backend --zone=$ZONE

echo "${YELLOW_TEXT}${BOLD_TEXT}📋 Creating instance templates...${RESET_FORMAT}"
gcloud compute instance-templates create fancy-fe \
    --source-instance-zone=$ZONE \
    --source-instance=frontend

gcloud compute instance-templates create fancy-be \
    --source-instance-zone=$ZONE \
    --source-instance=backend

echo "${YELLOW_TEXT}${BOLD_TEXT}🗑️ Removing original instances...${RESET_FORMAT}"
gcloud compute instances delete --quiet backend --zone=$ZONE

echo "${YELLOW_TEXT}${BOLD_TEXT}👥 Creating managed instance groups...${RESET_FORMAT}"
gcloud compute instance-groups managed create fancy-fe-mig \
    --zone=$ZONE \
    --base-instance-name fancy-fe \
    --size 2 \
    --template fancy-fe

gcloud compute instance-groups managed create fancy-be-mig \
    --zone=$ZONE \
    --base-instance-name fancy-be \
    --size 2 \
    --template fancy-be

echo "${YELLOW_TEXT}${BOLD_TEXT}🔧 Configuring named ports...${RESET_FORMAT}"
gcloud compute instance-groups set-named-ports fancy-fe-mig \
    --zone=$ZONE \
    --named-ports frontend:8080

gcloud compute instance-groups set-named-ports fancy-be-mig \
    --zone=$ZONE \
    --named-ports orders:8081,products:8082

echo "${GREEN_TEXT}${BOLD_TEXT}=== HEALTH CHECKS ===${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}🩺 Configuring health checks...${RESET_FORMAT}"
gcloud compute health-checks create http fancy-fe-hc \
    --port 8080 \
    --check-interval 30s \
    --healthy-threshold 1 \
    --timeout 10s \
    --unhealthy-threshold 3

gcloud compute health-checks create http fancy-be-hc \
    --port 8081 \
    --request-path=/api/orders \
    --check-interval 30s \
    --healthy-threshold 1 \
    --timeout 10s \
    --unhealthy-threshold 3

echo "${YELLOW_TEXT}${BOLD_TEXT}🔒 Configuring health check firewall rules...${RESET_FORMAT}"
gcloud compute firewall-rules create allow-health-check \
    --allow tcp:8080-8081 \
    --source-ranges 130.211.0.0/22,35.191.0.0/16 \
    --network default

echo "${YELLOW_TEXT}${BOLD_TEXT}⚙️ Updating instance groups with health checks...${RESET_FORMAT}"
gcloud compute instance-groups managed update fancy-fe-mig \
    --zone=$ZONE \
    --health-check fancy-fe-hc \
    --initial-delay 300

gcloud compute instance-groups managed update fancy-be-mig \
    --zone=$ZONE \
    --health-check fancy-be-hc \
    --initial-delay 300

echo "${GREEN_TEXT}${BOLD_TEXT}=== LOAD BALANCER CONFIGURATION ===${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}🩺 Creating backend health checks...${RESET_FORMAT}"
gcloud compute http-health-checks create fancy-fe-frontend-hc \
  --request-path / \
  --port 8080

gcloud compute http-health-checks create fancy-be-orders-hc \
  --request-path /api/orders \
  --port 8081

gcloud compute http-health-checks create fancy-be-products-hc \
  --request-path /api/products \
  --port 8082

echo "${YELLOW_TEXT}${BOLD_TEXT}🛠️ Creating backend services...${RESET_FORMAT}"
gcloud compute backend-services create fancy-fe-frontend \
  --http-health-checks fancy-fe-frontend-hc \
  --port-name frontend \
  --global

gcloud compute backend-services create fancy-be-orders \
  --http-health-checks fancy-be-orders-hc \
  --port-name orders \
  --global

gcloud compute backend-services create fancy-be-products \
  --http-health-checks fancy-be-products-hc \
  --port-name products \
  --global

echo "${YELLOW_TEXT}${BOLD_TEXT}➕ Adding backends to services...${RESET_FORMAT}"
gcloud compute backend-services add-backend fancy-fe-frontend \
  --instance-group-zone=$ZONE \
  --instance-group fancy-fe-mig \
  --global

gcloud compute backend-services add-backend fancy-be-orders \
  --instance-group-zone=$ZONE \
  --instance-group fancy-be-mig \
  --global

gcloud compute backend-services add-backend fancy-be-products \
  --instance-group-zone=$ZONE \
  --instance-group fancy-be-mig \
  --global

echo "${YELLOW_TEXT}${BOLD_TEXT}🗺️ Creating URL map and path matcher...${RESET_FORMAT}"
gcloud compute url-maps create fancy-map \
  --default-service fancy-fe-frontend

gcloud compute url-maps add-path-matcher fancy-map \
   --default-service fancy-fe-frontend \
   --path-matcher-name orders \
   --path-rules "/api/orders=fancy-be-orders,/api/products=fancy-be-products"

echo "${YELLOW_TEXT}${BOLD_TEXT}🔌 Creating target proxy and forwarding rule...${RESET_FORMAT}"
gcloud compute target-http-proxies create fancy-proxy \
  --url-map fancy-map

gcloud compute forwarding-rules create fancy-http-rule \
  --global \
  --target-http-proxy fancy-proxy \
  --ports 80

# Completion Message
echo
echo "${GREEN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}       MICROSERVICES DEPLOYMENT PART 1 COMPLETED SUCCESSFULLY    ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}💡Note: HIT Check my progress till task 5 once you got score then only proceed further:${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}Subscribe to Cloud Wale Jija Ji's YouTube Channel${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}https://www.youtube.com/@cloudwalejijaji${RESET_FORMAT}"
echo
