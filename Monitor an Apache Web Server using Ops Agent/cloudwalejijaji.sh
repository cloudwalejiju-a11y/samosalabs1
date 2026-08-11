#!/bin/bash


CYAN_BOLD=$'\033[1;36m'
PURPLE_BOLD=$'\033[1;35m'
GREEN_BOLD=$'\033[1;32m'
YELLOW_BOLD=$'\033[1;33m'
RED_BOLD=$'\033[1;31m'
BLUE_BOLD=$'\033[1;34m'
ORANGE_BOLD=$'\033[1;38;5;208m'
PINK_BOLD=$'\033[1;38;5;200m'
WHITE_BOLD=$'\033[1;37m'
RESET_FORMAT=$'\033[0m'

# Clear the screen
clear


echo
echo "${BLUE_BOLD}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${BLUE_BOLD}          🚀 Welcome to Cloud Wale Jija Ji's Cloud Lab Tutorial        ${RESET_FORMAT}"
echo "${BLUE_BOLD}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo

# User input with emoji
read -p "${YELLOW_BOLD}🌍 Enter ZONE: ${RESET_FORMAT}" ZONE

# Authentication message
echo "${CYAN_BOLD}🔐 Authenticating with Google Cloud...${RESET_FORMAT}"
gcloud auth list

# Project configuration
echo "${PURPLE_BOLD}📋 Fetching the current project ID...${RESET_FORMAT}"
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_ID=$DEVSHELL_PROJECT_ID

# Zone configuration
echo "${GREEN_BOLD}📍 Setting the compute zone to ${WHITE_BOLD}$ZONE${GREEN_BOLD}...${RESET_FORMAT}"
gcloud config set compute/zone $ZONE

# VM creation
echo "${BLUE_BOLD}🖥️  Creating VM instance with firewall rules...${RESET_FORMAT}"
gcloud compute instances create quickstart-vm \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE \
  --machine-type=e2-small \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --tags=http-server,https-server
  
gcloud compute firewall-rules create default-allow-http \
  --target-tags=http-server \
  --allow tcp:80 \
  --description="Allow HTTP traffic"
  
gcloud compute firewall-rules create default-allow-https \
  --target-tags=https-server \
  --allow tcp:443 \
  --description="Allow HTTPS traffic"

# VM configuration
echo "${CYAN_BOLD}⚙️  Configuring VM with Apache and Ops Agent...${RESET_FORMAT}"
cat > cp_disk.sh <<'EOF'
#!/bin/bash
sudo apt-get update && sudo apt-get install -y apache2 php
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install

# Backup existing config
sudo cp /etc/google-cloud-ops-agent/config.yaml /etc/google-cloud-ops-agent/config.yaml.bak

# Configure Ops Agent
sudo tee /etc/google-cloud-ops-agent/config.yaml > /dev/null <<'CONFIG_EOF'
metrics:
  receivers:
    apache:
      type: apache
  service:
    pipelines:
      apache:
        receivers:
          - apache
logging:
  receivers:
    apache_access:
      type: apache_access
    apache_error:
      type: apache_error
  service:
    pipelines:
      apache:
        receivers:
          - apache_access
          - apache_error
CONFIG_EOF

sudo service google-cloud-ops-agent restart
sleep 60
EOF

# File transfer
echo "${PURPLE_BOLD}📤 Copying configuration to VM...${RESET_FORMAT}"
gcloud compute scp cp_disk.sh quickstart-vm:/tmp \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE \
  --quiet

# Remote execution
echo "${YELLOW_BOLD}⚡ Executing configuration script on VM...${RESET_FORMAT}"
gcloud compute ssh quickstart-vm \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE \
  --quiet \
  --command="chmod +x /tmp/cp_disk.sh && sudo /tmp/cp_disk.sh"

# Monitoring setup
echo "${CYAN_BOLD}🔔 Creating notification channel...${RESET_FORMAT}"
cat > monitoring-channel.json <<EOF
{
  "type": "pubsub",
  "displayName": "cloud-monitoring",
  "description": "Monitoring notifications",
  "labels": {
    "topic": "projects/$DEVSHELL_PROJECT_ID/topics/notificationTopic"
  }
}
EOF

gcloud beta monitoring channels create --channel-content-from-file=monitoring-channel.json

# Alert policy
echo "${GREEN_BOLD}🚨 Creating Apache traffic alert policy...${RESET_FORMAT}"
channel_id=$(gcloud beta monitoring channels list --format="value(name)" | head -n 1)

cat > apache-alert-policy.json <<EOF
{
  "displayName": "Apache traffic threshold exceeded",
  "conditions": [
    {
      "displayName": "High Apache traffic",
      "conditionThreshold": {
        "filter": "resource.type = \"gce_instance\" AND metric.type = \"workload.googleapis.com/apache.traffic\"",
        "aggregations": [{
          "alignmentPeriod": "60s",
          "crossSeriesReducer": "REDUCE_NONE",
          "perSeriesAligner": "ALIGN_RATE"
        }],
        "comparison": "COMPARISON_GT",
        "thresholdValue": 4000
      }
    }
  ],
  "notificationChannels": ["$channel_id"]
}
EOF

gcloud alpha monitoring policies create --policy-from-file=apache-alert-policy.json

# Completion message
echo
echo "${GREEN_BOLD}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${GREEN_BOLD}          🎉 Cloud Lab Completed Successfully!          ${RESET_FORMAT}"
echo "${GREEN_BOLD}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"

# Social media links
echo
echo -e "${YELLOW_BOLD}📺 Subscribe to my Channel:${RESET_FORMAT} ${BLUE_BOLD}https://www.youtube.com/@cloudwalejijaji${RESET_FORMAT}"
echo -e "${PURPLE_BOLD}📷 Follow on Instagram:${RESET_FORMAT} ${PINK_BOLD}https://www.instagram.com/@cloudwalejijaji/${RESET_FORMAT}"
echo
