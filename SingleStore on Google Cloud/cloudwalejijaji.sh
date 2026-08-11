#!/bin/bash
# Enhanced Color Definitions with Emoji Support
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

# Enhanced Logging Functions with Icons
log_info() {
    echo -e "${BOLD_TEXT}${BLUE_TEXT}ℹ️ [INFO]${RESET_FORMAT} $1"
}

log_success() {
    echo -e "${BOLD_TEXT}${GREEN_TEXT}✅ [SUCCESS]${RESET_FORMAT} $1"
}

log_warning() {
    echo -e "${BOLD_TEXT}${YELLOW_TEXT}⚠️ [WARNING]${RESET_FORMAT} $1"
}

log_error() {
    echo -e "${BOLD_TEXT}${RED_TEXT}❌ [ERROR]${RESET_FORMAT} $1"
}

print_header() {
    echo
    echo "${CYAN_TEXT}${BOLD_TEXT}==============================================${RESET_FORMAT}"
    echo "${MAGENTA_TEXT}${BOLD_TEXT}    🚀 Cloud Wale Jija Ji Cloud Lab Setup 🚀     ${RESET_FORMAT}"
    echo "${CYAN_TEXT}${BOLD_TEXT}       Google Cloud Storage & Dataflow       ${RESET_FORMAT}"
    echo "               ${WHITE_TEXT}${BOLD_TEXT}$(date +'%B %Y')${RESET_FORMAT}"
    echo "${CYAN_TEXT}${BOLD_TEXT}==============================================${RESET_FORMAT}"
    echo
}

execute_with_retry() {
    local cmd="$1"
    local description="$2"
    local max_attempts=3
    local attempt=1
    local delay=5

    log_info "Executing: $description"
    
    while [ $attempt -le $max_attempts ]; do
        log_info "Attempt $attempt/$max_attempts: $description"
        
        eval "$cmd"
        local status=$?
        
        if [ $status -eq 0 ]; then
            log_success "$description completed successfully."
            return 0
        else
            log_error "Attempt $attempt failed: $description (Exit code: $status)"
            if [ $attempt -lt $max_attempts ]; then
                log_warning "Retrying in $delay seconds..."
                sleep $delay
            fi
        fi
        
        attempt=$((attempt + 1))
    done
    
    log_error "Failed after $max_attempts attempts: $description"
    return 1
}

verify_resource_exists() {
    local cmd="$1"
    local resource_name="$2"
    local resource_type="$3"
    
    log_info "Verifying $resource_type '$resource_name' exists..."
    
    if eval "$cmd" > /dev/null 2>&1; then
        log_success "$resource_type '$resource_name' exists."
        return 0
    else
        log_error "$resource_type '$resource_name' does not exist."
        return 1
    fi
}

wait_for_confirmation() {
    local message="$1"
    echo -e "\n${BOLD_TEXT}${YELLOW_TEXT}🔔 $message${RESET_FORMAT}"
    echo -e "${BOLD_TEXT}Press Enter to continue when ready...${RESET_FORMAT}"
    read -r
}

task5_setup_storage() {
    echo -e "\n${BOLD_TEXT}${BLUE_TEXT}=== 🗄️ Task 5: Cloud Storage Setup ===${RESET_FORMAT}\n"
    
    PROJECT_ID=$(gcloud config get-value project)
    read -p "${YELLOW_TEXT}${BOLD_TEXT}🌍 Enter the Region (e.g., us-central1): ${RESET_FORMAT}" REGION
    export REGION
    
    gcloud config set compute/region $REGION
    
    log_info "Project ID: ${CYAN_TEXT}${BOLD_TEXT}$PROJECT_ID${RESET_FORMAT}"
    log_info "Region: ${CYAN_TEXT}${BOLD_TEXT}$REGION${RESET_FORMAT}"
    
    execute_with_retry "gcloud storage buckets create gs://$PROJECT_ID --location=$REGION" "Creating Cloud Storage bucket"
    
    execute_with_retry "gcloud storage cp -r gs://configuring-singlestore-on-gcp/drivers gs://$PROJECT_ID" "Copying drivers folder"
    execute_with_retry "gcloud storage cp -r gs://configuring-singlestore-on-gcp/trips gs://$PROJECT_ID" "Copying trips folder"
    execute_with_retry "gcloud storage cp gs://configuring-singlestore-on-gcp/neighborhoods.csv gs://$PROJECT_ID" "Copying neighborhoods.csv file"
    
    log_info "Verifying bucket contents..."
    gcloud storage ls gs://$PROJECT_ID/
    
    verify_resource_exists "gcloud storage ls gs://$PROJECT_ID/drivers/" "drivers" "folder"
    verify_resource_exists "gcloud storage ls gs://$PROJECT_ID/trips/" "trips" "folder"
    verify_resource_exists "gcloud storage ls gs://$PROJECT_ID/neighborhoods.csv" "neighborhoods.csv" "file"
}

task6_pubsub_dataflow() {
    echo -e "\n${BOLD_TEXT}${BLUE_TEXT}=== 📊 Task 6: Pub/Sub & Dataflow Setup ===${RESET_FORMAT}\n"
    
    log_info "Checking Pub/Sub topics..."
    gcloud pubsub topics list | grep "Taxi" || log_warning "Taxi topic not found"
    
    log_info "Checking Pub/Sub subscriptions..."
    gcloud pubsub subscriptions list | grep "Taxi-sub" || log_warning "Taxi-sub subscription not found"
    
    log_info "Checking Dataflow jobs..."
    gcloud dataflow jobs list | grep "GCStoPS" || log_warning "GCStoPS job not found"
    
    echo -e "\n${BOLD_TEXT}${YELLOW_TEXT}📝 Manual Steps Required:${RESET_FORMAT}"
    echo -e "${BOLD_TEXT}1. Open Dataflow console: ${UNDERLINE_TEXT}https://console.cloud.google.com/dataflow${RESET_FORMAT}"
    echo -e "${BOLD_TEXT}2. Locate the failed 'GCStoPS' job"
    echo -e "${BOLD_TEXT}3. Click 'Clone' and name it (e.g., CloudMaster)"
    echo -e "${BOLD_TEXT}4. Review settings and click 'Run Job'"
    
    wait_for_confirmation "Please complete the manual steps in the Cloud Console"
}

main() {
    print_header
    task5_setup_storage
    task6_pubsub_dataflow
    
    echo -e "\n${CYAN_TEXT}${BOLD_TEXT}=============================================="
    echo "          🎉 Lab Setup Complete!          "
    echo "==============================================${RESET_FORMAT}"
    echo -e "\n${RED_TEXT}${BOLD_TEXT}Continue your cloud journey with:${RESET_FORMAT}"
    echo -e "${BLUE_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@cloudwalejijaji/${RESET_FORMAT}"
    echo -e "\n${GREEN_TEXT}${BOLD_TEXT}👍 Like, Share, and Subscribe for more GCP tutorials!${RESET_FORMAT}\n"
}

main
