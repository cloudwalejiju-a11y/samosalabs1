#!/bin/bash

# Define color variables
CYAN_TEXT=$'\033[0;36m'
GREEN_TEXT=$'\033[0;32m'
YELLOW_TEXT=$'\033[0;33m'
BLUE_TEXT=$'\033[0;34m'
MAGENTA_TEXT=$'\033[0;35m'
RED_TEXT=$'\033[0;31m'
BOLD_TEXT=$'\033[1m'
RESET_FORMAT=$'\033[0m'

# Welcome message
echo
echo "${CYAN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}        Welcome to Cloud Wale Jija Ji's Cloud Tutorials         ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo

# Spinner function
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

# Fetch zone and region
echo "${YELLOW_TEXT}${BOLD_TEXT}🔍 Detecting GCP zone and region...${RESET_FORMAT}"
ZONE=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
REGION=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-region])")
PROJECT_ID=$(gcloud config get-value project)

echo "${GREEN_TEXT}🌍 Zone: $ZONE | Region: $REGION | Project: $PROJECT_ID${RESET_FORMAT}"

# Task 1: Create logging metric for 200 responses
echo
echo "${BLUE_TEXT}${BOLD_TEXT}📊 Creating logging metric for 200 OK responses...${RESET_FORMAT}"
(gcloud logging metrics create 200responses \
  --description="Counts 200 OK responses from the default App Engine service" \
  --log-filter='resource.type="gae_app" AND resource.labels.module_id="default" AND (protoPayload.status=200 OR httpRequest.status=200)') & spinner

# Task 2: Create latency metric
echo
echo "${BLUE_TEXT}${BOLD_TEXT}⏱️  Creating latency distribution metric...${RESET_FORMAT}"
cat > latency_metric.yaml <<EOF
name: projects/\$DEVSHELL_PROJECT_ID/metrics/latency_metric
description: "latency distribution"
filter: >
  resource.type="gae_app"
  resource.labels.module_id="default"
  (protoPayload.status=200 OR httpRequest.status=200)
  logName=("projects/\$DEVSHELL_PROJECT_ID/logs/cloudbuild" OR
           "projects/\$DEVSHELL_PROJECT_ID/logs/stderr" OR
           "projects/\$DEVSHELL_PROJECT_ID/logs/%2Fvar%2Flog%2Fgoogle_init.log" OR
           "projects/\$DEVSHELL_PROJECT_ID/logs/appengine.googleapis.com%2Frequest_log" OR
           "projects/\$DEVSHELL_PROJECT_ID/logs/cloudaudit.googleapis.com%2Factivity")
  severity>=DEFAULT
valueExtractor: EXTRACT(protoPayload.latency)
metricDescriptor:
  metricKind: DELTA
  valueType: DISTRIBUTION
  unit: "s"
  displayName: "Latency distribution"
bucketOptions:
  exponentialBuckets:
    numFiniteBuckets: 10
    growthFactor: 2.0
    scale: 0.01
EOF

export DEVSHELL_PROJECT_ID=$(gcloud config get-value project)
(gcloud logging metrics create latency_metric --config-from-file=latency_metric.yaml) & spinner

# Task 3: Create audit log VM
echo
echo "${BLUE_TEXT}${BOLD_TEXT}🖥️  Creating audit-log-vm instance...${RESET_FORMAT}"
(gcloud compute instances create audit-log-vm \
  --zone=$ZONE \
  --machine-type=e2-micro \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --tags=http-server \
  --metadata=startup-script='#!/bin/bash
    sudo apt update && sudo apt install -y apache2
    sudo systemctl start apache2' \
  --scopes=https://www.googleapis.com/auth/cloud-platform \
  --labels=env=lab \
  --quiet) & spinner

# Task 4: Create BigQuery sink for audit logs
echo
echo "${BLUE_TEXT}${BOLD_TEXT}📊 Creating BigQuery sink for audit logs...${RESET_FORMAT}"
SINK_NAME="AuditLogs"
BQ_DATASET="AuditLogs"
BQ_LOCATION="US"

(bq --location=$BQ_LOCATION mk --dataset $PROJECT_ID:$BQ_DATASET) & spinner
(gcloud logging sinks create $SINK_NAME \
  bigquery.googleapis.com/projects/$PROJECT_ID/datasets/$BQ_DATASET \
  --log-filter='resource.type="gce_instance"
logName="projects/'$PROJECT_ID'/logs/cloudaudit.googleapis.com%2Factivity"' \
  --description="Export GCE audit logs to BigQuery" \
  --project=$PROJECT_ID) & spinner

# Completion message
echo
echo "${GREEN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}              Now Follow The video!               ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${CYAN_TEXT}${BOLD_TEXT}🔗 Open App Engine Dashboard: ${RESET_FORMAT}${BLUE_TEXT}${BOLD_TEXT}https://console.cloud.google.com/appengine?project=$PROJECT_ID${RESET_FORMAT}"
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}💖 If you found this helpful, subscribe to my channel:${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}https://www.youtube.com/@cloudwalejijaji${RESET_FORMAT}"
echo
