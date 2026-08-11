
#!/bin/bash

# ----------------------------------------
# Welcome Message
# ----------------------------------------
echo "🌥️ Welcome to Cloud Wale Jija Ji Cloud Tutorials!"
echo "📺 Subscribe to the channel: https://www.youtube.com/@cloudwalejijaji/videos"
echo "----------------------------------------"

# ----------------------------------------
# Set Variables
# ----------------------------------------
ZONE=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

REGION=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-region])")

PROJECT_ID=$(gcloud config get-value project)

# ----------------------------------------
# Clone MLOps repo and enter directory
# ----------------------------------------
cd
SRC_REPO=https://github.com/GoogleCloudPlatform/mlops-on-gcp
kpt pkg get $SRC_REPO/workshops/mlep-qwiklabs/tfserving-gke-autoscaling tfserving-gke
cd tfserving-gke

# ----------------------------------------
# Set compute zone and create GKE cluster
# ----------------------------------------
gcloud config set compute/zone $ZONE

CLUSTER_NAME=cluster-1
gcloud beta container clusters create $CLUSTER_NAME \
  --cluster-version=latest \
  --machine-type=e2-standard-4 \
  --enable-autoscaling \
  --min-nodes=1 \
  --max-nodes=3 \
  --num-nodes=1 

# ----------------------------------------
# Create model bucket and copy model
# ----------------------------------------
export MODEL_BUCKET=${PROJECT_ID}-bucket
gsutil mb gs://${MODEL_BUCKET}
gsutil cp -r gs://spls/gsp777/resnet_101 gs://${MODEL_BUCKET}

echo $MODEL_BUCKET

# ----------------------------------------
# Update config and deploy to GKE
# ----------------------------------------
sed -i "s/your-bucket-name/$MODEL_BUCKET/g" tf-serving/configmap.yaml
kubectl apply -f tf-serving/configmap.yaml
kubectl apply -f tf-serving/deployment.yaml
kubectl get deployments
kubectl apply -f tf-serving/service.yaml
kubectl get svc image-classifier

# ----------------------------------------
# Enable autoscaling
# ----------------------------------------
kubectl autoscale deployment image-classifier \
  --cpu-percent=60 \
  --min=1 \
  --max=4 

kubectl get hpa
