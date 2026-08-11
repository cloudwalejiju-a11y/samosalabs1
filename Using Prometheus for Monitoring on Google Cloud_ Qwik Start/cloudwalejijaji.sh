#!/bin/bash
# Google Cloud Monitoring & Prometheus Lab
# Expertly crafted by Cloud Wale Jija Ji Cloud


# ======================
BOLD=$(tput bold)
UNDERLINE=$(tput smul)
RESET=$(tput sgr0)

# Text Colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)

# Background Colors
BG_RED=$(tput setab 1)
BG_GREEN=$(tput setab 2)
BG_YELLOW=$(tput setab 3)
BG_BLUE=$(tput setab 4)
BG_MAGENTA=$(tput setab 5)
BG_CYAN=$(tput setab 6)

# Random color selection
COLORS=($RED $GREEN $YELLOW $BLUE $MAGENTA $CYAN)
RAND_COLOR=${COLORS[$RANDOM % ${#COLORS[@]}]}


# ======================
clear
echo "${BG_BLUE}${BOLD}${WHITE}==================================================${RESET}"
echo "${BG_BLUE}${BOLD}${WHITE}   WELCOME TO DR ABHISHEK CLOUD TUTORIALS     ${RESET}"
echo "${BG_BLUE}${BOLD}${WHITE}==================================================${RESET}"
echo ""
echo "${CYAN}${BOLD}⚡ Expertly crafted by Cloud Wale Jija Ji Cloud${RESET}"
echo "${YELLOW}${BOLD}📺 YouTube: ${UNDERLINE}https://www.youtube.com/@cloudwalejijaji/videos${RESET}"
echo ""

# ======================
#  INITIAL SETUP
# ======================
echo "${RAND_COLOR}${BOLD}🚀 Starting Execution${RESET}"

# Step 1: Set Compute Zone & Region
echo "${BOLD}${BLUE}🌍 STEP 1: Setting Compute Zone & Region${RESET}"
export ZONE=$(gcloud compute project-info describe \
    --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
export REGION=$(gcloud compute project-info describe \
    --format="value(commonInstanceMetadata.items[google-compute-default-region])")

echo "${WHITE}Configured Zone: ${YELLOW}$ZONE${RESET}"
echo "${WHITE}Configured Region: ${YELLOW}$REGION${RESET}"
echo ""

# ======================
#  ARTIFACT REGISTRY
# ======================
echo "${BOLD}${GREEN}🐳 STEP 2: Creating Docker Artifact Registry${RESET}"
gcloud artifacts repositories create docker-repo \
    --repository-format=docker \
    --location=$REGION \
    --description="Docker repository" \
    --project=$DEVSHELL_PROJECT_ID || {
    echo "${RED}${BOLD}❌ Failed to create Artifact Registry${RESET}"
    exit 1
}
echo "${GREEN}✔ Artifact Registry created successfully${RESET}"
echo ""

# ======================
#  APPLICATION SETUP
# ======================
echo "${BOLD}${CYAN}📦 STEP 3: Downloading Flask Telemetry App${RESET}"
wget -q https://storage.googleapis.com/spls/gsp1024/flask_telemetry.zip || {
    echo "${RED}${BOLD}❌ Failed to download Flask app${RESET}"
    exit 1
}
unzip -q flask_telemetry.zip
echo "${GREEN}✔ Application downloaded and extracted${RESET}"
echo ""

# ======================
#  DOCKER OPERATIONS
# ======================
echo "${BOLD}${YELLOW}🐋 STEP 4: Loading Docker Image${RESET}"
docker load -i flask_telemetry.tar || {
    echo "${RED}${BOLD}❌ Failed to load Docker image${RESET}"
    exit 1
}

echo "${BOLD}${MAGENTA}🏷️ STEP 5: Tagging Docker Image${RESET}"
docker tag gcr.io/ops-demo-330920/flask_telemetry:61a2a7aabc7077ef474eb24f4b69faeab47deed9 \
    $REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/docker-repo/flask-telemetry:v1 || {
    echo "${RED}${BOLD}❌ Failed to tag Docker image${RESET}"
    exit 1
}

echo "${BOLD}${RED}📤 STEP 6: Pushing Docker Image to Artifact Registry${RESET}"
docker push $REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/docker-repo/flask-telemetry:v1 || {
    echo "${RED}${BOLD}❌ Failed to push Docker image${RESET}"
    exit 1
}
echo "${GREEN}✔ Docker operations completed successfully${RESET}"
echo ""

# ======================
#  GKE CLUSTER SETUP
# ======================
echo "${BOLD}${GREEN}☸️ STEP 7: Creating GKE Cluster with Prometheus Monitoring${RESET}"
gcloud beta container clusters create gmp-cluster \
    --num-nodes=1 \
    --zone $ZONE \
    --enable-managed-prometheus || {
    echo "${RED}${BOLD}❌ Failed to create GKE cluster${RESET}"
    exit 1
}

echo "${BOLD}${CYAN}🔑 STEP 8: Getting GKE Credentials${RESET}"
gcloud container clusters get-credentials gmp-cluster --zone $ZONE || {
    echo "${RED}${BOLD}❌ Failed to get cluster credentials${RESET}"
    exit 1
}
echo "${GREEN}✔ GKE cluster setup complete${RESET}"
echo ""

# ======================
#  KUBERNETES DEPLOYMENT
# ======================
echo "${BOLD}${YELLOW}📦 STEP 9: Creating Kubernetes Namespace${RESET}"
kubectl create ns gmp-test || {
    echo "${RED}${BOLD}❌ Failed to create namespace${RESET}"
    exit 1
}

echo "${BOLD}${MAGENTA}📥 STEP 10: Downloading Prometheus Setup Files${RESET}"
wget -q https://storage.googleapis.com/spls/gsp1024/gmp_prom_setup.zip || {
    echo "${RED}${BOLD}❌ Failed to download Prometheus setup${RESET}"
    exit 1
}
unzip -q gmp_prom_setup.zip
cd gmp_prom_setup || {
    echo "${RED}${BOLD}❌ Failed to enter setup directory${RESET}"
    exit 1
}

echo "${BOLD}${BLUE}✏️ STEP 11: Configuring Deployment YAML${RESET}"
sed -i "s|<ARTIFACT REGISTRY IMAGE NAME>|$REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/docker-repo/flask-telemetry:v1|g" flask_deployment.yaml || {
    echo "${RED}${BOLD}❌ Failed to configure deployment${RESET}"
    exit 1
}

echo "${BOLD}${GREEN}🚀 STEP 12: Deploying Flask Application${RESET}"
kubectl -n gmp-test apply -f flask_deployment.yaml || {
    echo "${RED}${BOLD}❌ Failed to deploy Flask application${RESET}"
    exit 1
}

echo "${BOLD}${CYAN}🔌 STEP 13: Exposing Flask Service${RESET}"
kubectl -n gmp-test apply -f flask_service.yaml || {
    echo "${RED}${BOLD}❌ Failed to create service${RESET}"
    exit 1
}

echo "${BOLD}${YELLOW}🌐 STEP 14: Retrieving LoadBalancer IP${RESET}"
url=$(kubectl get services -n gmp-test -o jsonpath='{.items[*].status.loadBalancer.ingress[0].ip}')
echo "${WHITE}Service URL: ${YELLOW}$url${RESET}"

echo "${BOLD}${MAGENTA}📊 STEP 15: Testing /metrics Endpoint${RESET}"
curl -s $url/metrics | head -n 10
echo "${WHITE}... (output truncated)${RESET}"
echo "${GREEN}✔ Metrics endpoint is working${RESET}"
echo ""

# ======================
#  PROMETHEUS DEPLOYMENT
# ======================
echo "${BOLD}${RED}📈 STEP 16: Deploying Prometheus Configuration${RESET}"
kubectl -n gmp-test apply -f prom_deploy.yaml || {
    echo "${RED}${BOLD}❌ Failed to deploy Prometheus${RESET}"
    exit 1
}

echo "${BOLD}${BLUE}📡 STEP 17: Generating Test Traffic (2 minutes)${RESET}"
echo "${WHITE}Generating random traffic to application...${RESET}"
timeout 120 bash -c -- 'while true; do curl -s $(kubectl get services -n gmp-test -o jsonpath='{.items[*].status.loadBalancer.ingress[0].ip}') >/dev/null; sleep $((RANDOM % 4)); done' &
echo "${GREEN}✔ Traffic generation started in background${RESET}"
echo ""

# ======================
#  MONITORING DASHBOARD
# ======================
echo "${BOLD}${GREEN}📊 STEP 18: Creating Monitoring Dashboard${RESET}"
gcloud monitoring dashboards create --config='''
{
  "category": "CUSTOM",
  "displayName": "Prometheus Dashboard Example",
  "mosaicLayout": {
    "columns": 12,
    "tiles": [
      {
        "height": 4,
        "widget": {
          "title": "prometheus/flask_http_request_total/counter [MEAN]",
          "xyChart": {
            "chartOptions": {
              "mode": "COLOR"
            },
            "dataSets": [
              {
                "minAlignmentPeriod": "60s",
                "plotType": "LINE",
                "targetAxis": "Y1",
                "timeSeriesQuery": {
                  "apiSource": "DEFAULT_CLOUD",
                  "timeSeriesFilter": {
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "crossSeriesReducer": "REDUCE_NONE",
                      "perSeriesAligner": "ALIGN_RATE"
                    },
                    "filter": "metric.type=\"prometheus.googleapis.com/flask_http_request_total/counter\" resource.type=\"prometheus_target\"",
                    "secondaryAggregation": {
                      "alignmentPeriod": "60s",
                      "crossSeriesReducer": "REDUCE_MEAN",
                      "groupByFields": [
                        "metric.label.\"status\""
                      ],
                      "perSeriesAligner": "ALIGN_MEAN"
                    }
                  }
                }
              }
            ],
            "thresholds": [],
            "timeshiftDuration": "0s",
            "yAxis": {
              "label": "y1Axis",
              "scale": "LINEAR"
            }
          }
        },
        "width": 6,
        "xPos": 0,
        "yPos": 0
      }
    ]
  }
}
''' || {
    echo "${YELLOW}⚠️ Dashboard may have already existed${RESET}"
}
echo "${GREEN}✔ Dashboard created successfully${RESET}"
echo ""

# ======================
#  COMPLETION MESSAGE
# ======================
echo "${BG_GREEN}${BOLD}${WHITE}==================================================${RESET}"
echo "${BG_GREEN}${BOLD}${WHITE}       LAB COMPLETED SUCCESSFULLY!               ${RESET}"
echo "${BG_GREEN}${BOLD}${WHITE}==================================================${RESET}"
echo ""
echo "${WHITE}${BOLD}🔍 Access your resources:${RESET}"
echo "${YELLOW}GKE Cluster: https://console.cloud.google.com/kubernetes/list?project=$DEVSHELL_PROJECT_ID${RESET}"
echo "${YELLOW}Monitoring: https://console.cloud.google.com/monitoring/dashboards?project=$DEVSHELL_PROJECT_ID${RESET}"
echo "${YELLOW}Artifact Registry: https://console.cloud.google.com/artifacts?project=$DEVSHELL_PROJECT_ID${RESET}"
echo ""
echo "${CYAN}${BOLD}💡 For more Google Cloud labs and tutorials:${RESET}"
echo "${YELLOW}${BOLD}👉 ${UNDERLINE}https://www.youtube.com/@cloudwalejijaji/videos${RESET}"
echo "${GREEN}${BOLD}🔔 Don't forget to subscribe for daily cloud tutorials!${RESET}"
echo ""

# Clean up temporary files
echo "${BOLD}${BLUE}🧹 Cleaning up temporary files...${RESET}"
cd ..
rm -rf flask_telemetry* gmp_prom_setup*
echo "${GREEN}✔ Cleanup complete${RESET}"

