#!/bin/bash

# Set text styles
YELLOW=$(tput setaf 3)
BOLD=$(tput bold)
RESET=$(tput sgr0)

echo "                                                                               
  ____  _       _     _           _    _           _       _     _   
 |  _ \(_)     | |   | |         | |  | |         | |     | |   | |  
 | |_) |_  __ _| |__ | |__   ___ | | _| | ___  ___| |_ ___| |__ | |_ 
 |  _ <| |/ _\` | '_ \| '_ \/ _ \| |/ / |/ _ \/ __| __/ __| '_ \| __|
 | |_) | | (_| | | | | | | | (_) |   <| |  __/\__ \ || (__| | | | |_ 
 |____/|_|\__, |_| |_|_| |_|\___/|_|\_\_|\___||___/\__\___|_| |_|\__|
           __/ |                                                     
          |___/                                                      
"

echo "=================================================================="
echo "           WELCOME TO DR. ABHISHEK CLOUD TUTORIALS!"
echo "=================================================================="
echo " YouTube Channel: https://www.youtube.com/@cloudwalejijaji/videos"
echo "=================================================================="
echo "    SUBSCRIBE for more Kubernetes and Cloud Computing tutorials!"
echo "=================================================================="
echo ""

echo "Please set the below values correctly"
read -p "${YELLOW}${BOLD}Enter the ZONE: ${RESET}" ZONE

gcloud config set compute/zone $ZONE

export REGION="${ZONE%-*}"

gcloud config set compute/region $REGION

gsutil cp -r gs://spls/gsp480/gke-network-policy-demo .

cd gke-network-policy-demo

chmod -R 755 *

echo "y" | make setup-project

echo "yes" | make tf-apply

echo "export ZONE=$ZONE" > dr_abhishek_setup.sh

source dr_abhishek_setup.sh

cat > dr_abhishek_script.sh <<'EOF_CP'

source /tmp/dr_abhishek_setup.sh

sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin -y

echo "export USE_GKE_GCLOUD_AUTH_PLUGIN=True" >> ~/.bashrc

source ~/.bashrc

gcloud container clusters get-credentials gke-demo-cluster --zone $ZONE

kubectl apply -f ./manifests/hello-app/

kubectl apply -f ./manifests/network-policy.yaml

kubectl delete -f ./manifests/network-policy.yaml

kubectl create -f ./manifests/network-policy-namespaced.yaml

kubectl -n hello-apps apply -f ./manifests/hello-app/hello-client.yaml

echo "=================================================================="
echo "✅ GKE Network Policy Demo Setup Complete!"
echo "📺 By Cloud Wale Jija Ji Cloud Tutorials"
echo "🌐 YouTube: https://www.youtube.com/@cloudwalejijaji/videos"
echo "=================================================================="

EOF_CP


gcloud compute scp dr_abhishek_setup.sh gke-demo-bastion:/tmp --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet

gcloud compute scp dr_abhishek_script.sh gke-demo-bastion:/tmp --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet

gcloud compute ssh gke-demo-bastion --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet --command="bash /tmp/dr_abhishek_script.sh"

echo ""
echo "=============================================================================="
echo "🎉 GKE NETWORK POLICY DEMO DEPLOYMENT COMPLETE!"
echo "📺 Tutorial by Cloud Wale Jija Ji Cloud Tutorials"
echo "🌐 YouTube: https://www.youtube.com/@cloudwalejijaji/videos"
echo "=============================================================================="
echo "   Don't forget to LIKE, SHARE, and SUBSCRIBE for more tutorials!"
echo "=============================================================================="
