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

BG_BLACK=`tput setab 0`
BG_RED=`tput setab 1`
BG_GREEN=`tput setab 2`
BG_YELLOW=`tput setab 3`
BG_BLUE=`tput setab 4`
BG_MAGENTA=`tput setab 5`
BG_CYAN=`tput setab 6`
BG_WHITE=`tput setab 7`

BOLD=`tput bold`
RESET=`tput sgr0`

#----------------------------------------------------start--------------------------------------------------#


echo "${CYAN}${BOLD}"
echo "**********************************************************************"
echo "* Welcome to Healthcare API Lab                                      *"
echo "*                                                                    *"
echo "* Brought to you by Cloud Wale Jija Ji's Cloud Tutorials                   *"
echo "* Please like, share and subscribe to:                               *"
echo "* https://www.youtube.com/@cloudwalejijaji/videos                    *"
echo "**********************************************************************"
echo "${RESET}"

echo "${YELLOW}${BOLD}Starting${RESET}" "${GREEN}${BOLD}Execution${RESET}"

# Set environment variables
echo "${BLUE}${BOLD}Setting up environment variables...${RESET}"
export PROJECT_ID=$(gcloud config list --format 'value(core.project)')
export PROJECT_NUMBER=$(gcloud projects list --filter=projectId:$PROJECT_ID \
  --format="value(projectNumber)")
export DATASET_ID=dataset1
export FHIR_STORE_ID=fhirstore1
export TOPIC=fhir-topic
export HL7_STORE_ID=hl7v2store1

# Enable Healthcare API
echo "${MAGENTA}${BOLD}Enabling Healthcare API...${RESET}"
gcloud services enable healthcare.googleapis.com
sleep 20

# Create Pub/Sub topic
echo "${GREEN}${BOLD}Creating Pub/Sub topic...${RESET}"
gcloud pubsub topics create $TOPIC

# Create BigQuery datasets
echo "${YELLOW}${BOLD}Creating BigQuery datasets...${RESET}"
bq --location=$LOCATION mk --dataset --description HCAPI-dataset $PROJECT_ID:$DATASET_ID
bq --location=$LOCATION mk --dataset --description HCAPI-dataset-de-id $PROJECT_ID:de_id

# Add IAM bindings
echo "${BLUE}${BOLD}Configuring IAM permissions...${RESET}"
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member=serviceAccount:service-$PROJECT_NUMBER@gcp-sa-healthcare.iam.gserviceaccount.com \
--role=roles/bigquery.dataEditor
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member=serviceAccount:service-$PROJECT_NUMBER@gcp-sa-healthcare.iam.gserviceaccount.com \
--role=roles/bigquery.jobUser

# Create Healthcare dataset
echo "${MAGENTA}${BOLD}Creating Healthcare dataset...${RESET}"
gcloud healthcare datasets create $DATASET_ID --location=$LOCATION

# Create FHIR stores
echo "${GREEN}${BOLD}Creating FHIR stores...${RESET}"
gcloud healthcare fhir-stores create $FHIR_STORE_ID \
  --dataset=$DATASET_ID \
  --location=$LOCATION \
  --version=R4

gcloud healthcare fhir-stores update $FHIR_STORE_ID \
  --dataset=$DATASET_ID \
  --location=$LOCATION \
  --pubsub-topic=projects/$PROJECT_ID/topics/$TOPIC

gcloud healthcare fhir-stores create de_id \
  --dataset=$DATASET_ID \
  --location=$LOCATION \
  --version=R4

# Import FHIR data
echo "${YELLOW}${BOLD}Importing FHIR data...${RESET}"
gcloud healthcare fhir-stores import gcs $FHIR_STORE_ID \
--dataset=$DATASET_ID \
--location=$LOCATION \
--gcs-uri=gs://spls/gsp457/fhir_devdays_gcp/fhir1/* \
--content-structure=BUNDLE_PRETTY

# Export to BigQuery
echo "${BLUE}${BOLD}Exporting FHIR data to BigQuery...${RESET}"
gcloud healthcare fhir-stores export bq $FHIR_STORE_ID \
--dataset=$DATASET_ID \
--location=$LOCATION \
--bq-dataset=bq://$PROJECT_ID.$DATASET_ID \
--schema-type=analytics

echo "${YELLOW}${BOLD}NOW${RESET}" "${WHITE}${BOLD}FOLLOW${RESET}" "${GREEN}${BOLD}VIDEO'S INSTRUCTIONS${RESET}"
sleep 180

# Export de-identified data
echo "${MAGENTA}${BOLD}Exporting de-identified data...${RESET}"
gcloud healthcare fhir-stores export bq de_id \
--dataset=$DATASET_ID \
--location=$LOCATION \
--bq-dataset=bq://$PROJECT_ID.de_id \
--schema-type=analytics

# Completion message
echo "${CYAN}${BOLD}"
echo "**********************************************************************"
echo "* Lab Completed Successfully!                                        *"
echo "*                                                                    *"
echo "* For more cloud tutorials, subscribe to:                            *"
echo "* Cloud Wale Jija Ji's YouTube Channel                                     *"
echo "* https://www.youtube.com/@cloudwalejijaji/videos                    *"
echo "**********************************************************************"
echo "${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#
