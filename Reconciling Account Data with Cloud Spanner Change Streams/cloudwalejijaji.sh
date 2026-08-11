#!/bin/bash


# Color and formatting definitions
COLOR_BLACK=$'\033[0;90m'
COLOR_RED=$'\033[0;91m'
COLOR_GREEN=$'\033[0;92m'
COLOR_YELLOW=$'\033[0;93m'
COLOR_BLUE=$'\033[0;94m'
COLOR_MAGENTA=$'\033[0;95m'
COLOR_CYAN=$'\033[0;96m'
COLOR_WHITE=$'\033[0;97m'
STYLE_DIM=$'\033[2m'
STYLE_STRIKE=$'\033[9m'
STYLE_BOLD=$'\033[1m'
FORMAT_RESET=$'\033[0m'
BG_BLUE=$'\033[44m'
BG_YELLOW=$'\033[43m'
FG_BLACK=$'\033[30m'
FG_WHITE=$'\033[97m'

clear

# Function to display animated spinner
show_spinner() {
    local message="$1"
    local duration="$2"
    local spin_chars=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    
    tput civis
    for ((i=duration; i>0; i--)); do
        for char in "${spin_chars[@]}"; do
            printf "\r${COLOR_CYAN}${STYLE_BOLD}${char}${FORMAT_RESET} ${message} (${i}s remaining) "
            sleep 0.1
        done
    done
    tput cnorm
    printf "\r${COLOR_GREEN}✔ ${message} completed${FORMAT_RESET}\n"
}

# Header
echo
echo "${COLOR_BLUE}${STYLE_BOLD}╔══════════════════════════════════════════╗${FORMAT_RESET}"
echo "${COLOR_BLUE}${STYLE_BOLD}║  WELCOME TO DR ABHISHEK CLOUD TUTORIALS     ║${FORMAT_RESET}"
echo "${COLOR_BLUE}${STYLE_BOLD}╚══════════════════════════════════════════╝${FORMAT_RESET}"
echo
echo "${COLOR_MAGENTA}${STYLE_BOLD}  DO LIKE THE VIDEO & SUBSCRIBE THE CHANNEL.${FORMAT_RESET}"
echo

# Error handling
handle_error() {
    echo ""
    echo "${STYLE_BOLD}${COLOR_RED}Error: Command failed at line $1 with exit code $2.${FORMAT_RESET}"
    exit 1
}

trap 'handle_error $LINENO $?' ERR

# Step 1: Configure environment
echo "${COLOR_YELLOW}${STYLE_BOLD}🔍 Fetching project and region details${FORMAT_RESET}"
PROJECT_ID=$(gcloud config get-value project)
REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

if [[ -z "$REGION" ]]; then
    REGION="us-central1"
    echo "${COLOR_YELLOW}${STYLE_BOLD}ℹ️  Using default region: ${REGION}${FORMAT_RESET}"
fi

# Configuration variables
SPANNER_INSTANCE_ID="bitfoon-dev"
SPANNER_DATABASE="finance"
BIGQUERY_DATASET="changestream"
CHANGE_STREAM_NAME="AccountUpdateStream"
DATAFLOW_TEMPLATE="Spanner_Change_Streams_to_BigQuery"
DATAFLOW_JOB_NAME="change-stream-pipeline"

echo "${COLOR_GREEN}${STYLE_BOLD}✔ Environment configured${FORMAT_RESET}"
echo "${STYLE_BOLD}${COLOR_WHITE}┣ Project ID: ${PROJECT_ID}${FORMAT_RESET}"
echo "${STYLE_BOLD}${COLOR_WHITE}┗ Region: ${REGION}${FORMAT_RESET}"
echo

# Step 2: Create Spanner database
echo "${COLOR_CYAN}${STYLE_BOLD}🛠️  Creating Spanner database${FORMAT_RESET}"
show_spinner "Creating database '${SPANNER_DATABASE}'" 20
gcloud spanner databases create $SPANNER_DATABASE \
    --instance=$SPANNER_INSTANCE_ID \
    --ddl="CREATE TABLE Account ( AccountId BYTES(16) NOT NULL, CreationTimestamp TIMESTAMP NOT NULL OPTIONS (allow_commit_timestamp=true), AccountStatus INT64 NOT NULL, Balance NUMERIC NOT NULL ) PRIMARY KEY (AccountId);"

echo "${COLOR_GREEN}${STYLE_BOLD}✔ Database created successfully${FORMAT_RESET}"
echo

# Step 3: Insert sample data
echo "${COLOR_MAGENTA}${STYLE_BOLD}📝 Inserting sample data${FORMAT_RESET}"
ACCOUNT_IDS=("ACCOUNTID11123" "ACCOUNTID12345" "ACCOUNTID24680" "ACCOUNTID135791")

for ID in "${ACCOUNT_IDS[@]}"; do
    show_spinner "Inserting account ${ID}" 5
    gcloud spanner databases execute-sql $SPANNER_DATABASE \
        --instance=$SPANNER_INSTANCE_ID \
        --sql="INSERT INTO Account (AccountId, CreationTimestamp, AccountStatus, Balance) VALUES (FROM_BASE64('$(echo -n $ID | base64)'), PENDING_COMMIT_TIMESTAMP(), 1, 22)"
done

echo "${COLOR_GREEN}${STYLE_BOLD}✔ Sample data inserted${FORMAT_RESET}"
echo

# Step 4: Create change stream
echo "${COLOR_BLUE}${STYLE_BOLD}🌊 Creating change stream${FORMAT_RESET}"
show_spinner "Setting up change stream" 15
gcloud spanner databases ddl update $SPANNER_DATABASE \
    --instance=$SPANNER_INSTANCE_ID \
    --ddl="CREATE CHANGE STREAM ${CHANGE_STREAM_NAME} FOR Account(AccountStatus, Balance);"

echo "${COLOR_GREEN}${STYLE_BOLD}✔ Change stream configured${FORMAT_RESET}"
echo

# Step 5: Create BigQuery dataset
echo "${COLOR_CYAN}${STYLE_BOLD}📊 Preparing BigQuery dataset${FORMAT_RESET}"
show_spinner "Creating dataset '${BIGQUERY_DATASET}'" 10
bq --location=$REGION mk --dataset \
    --description "Dataset for Spanner change stream" \
    $PROJECT_ID:$BIGQUERY_DATASET

echo "${COLOR_GREEN}${STYLE_BOLD}✔ BigQuery dataset ready${FORMAT_RESET}"
echo

# Step 6: Dataflow setup instructions
echo "${BG_BLUE}${STYLE_BOLD}${FG_WHITE}════════════════════════════════════════════${FORMAT_RESET}"
echo "${BG_BLUE}${STYLE_BOLD}${FG_WHITE}  NEXT STEP: SET UP DATAFLOW PIPELINE        ${FORMAT_RESET}"
echo "${BG_BLUE}${STYLE_BOLD}${FG_WHITE}════════════════════════════════════════════${FORMAT_RESET}"
echo
echo "${COLOR_WHITE}${STYLE_BOLD}1. Open the Dataflow console:${FORMAT_RESET}"
echo "${COLOR_BLUE}https://console.cloud.google.com/dataflow/createjob?project=${PROJECT_ID}${FORMAT_RESET}"
echo
echo "${COLOR_WHITE}${STYLE_BOLD}2. Use these parameters:${FORMAT_RESET}"
echo "┣ Template: ${COLOR_CYAN}${DATAFLOW_TEMPLATE}${FORMAT_RESET}"
echo "┣ Region: ${COLOR_CYAN}${REGION}${FORMAT_RESET}"
echo "┗ Job Name: ${COLOR_CYAN}${DATAFLOW_JOB_NAME}${FORMAT_RESET}"
echo
read -p "${COLOR_YELLOW}${STYLE_BOLD}Press Enter after starting the Dataflow job...${FORMAT_RESET}"

# Step 7: Monitor Dataflow job
echo "${COLOR_MAGENTA}${STYLE_BOLD}🔍 Monitoring Dataflow job status${FORMAT_RESET}"
while true; do
    JOB_STATE=$(gcloud dataflow jobs list --region=$REGION --filter="name=${DATAFLOW_JOB_NAME}" --format="value(state)")
    
    if [[ "$JOB_STATE" == "Running" ]]; then
        echo "${COLOR_GREEN}${STYLE_BOLD}✔ Dataflow job is running${FORMAT_RESET}"
        break
    else
        show_spinner "Waiting for job to start" 10
    fi
done

# Step 8: Trigger changes
echo "${COLOR_CYAN}${STYLE_BOLD}🔄 Triggering database changes${FORMAT_RESET}"
show_spinner "Inserting test record" 5
gcloud spanner databases execute-sql $SPANNER_DATABASE \
    --instance=$SPANNER_INSTANCE_ID \
    --sql="INSERT INTO Account (AccountId, CreationTimestamp, AccountStatus, Balance) VALUES (FROM_BASE64('$(echo -n ACCOUNTID98765 | base64)'), PENDING_COMMIT_TIMESTAMP(), 1, 22)"

BALANCES=(255 300 500 600)
for BALANCE in "${BALANCES[@]}"; do
    show_spinner "Updating balance to $BALANCE" 3
    gcloud spanner databases execute-sql $SPANNER_DATABASE \
        --instance=$SPANNER_INSTANCE_ID \
        --sql="UPDATE Account SET CreationTimestamp=PENDING_COMMIT_TIMESTAMP(), AccountStatus=4, Balance=${BALANCE} WHERE AccountId=FROM_BASE64('$(echo -n ACCOUNTID11123 | base64)');"
done

echo "${COLOR_GREEN}${STYLE_BOLD}✔ Changes triggered successfully${FORMAT_RESET}"
echo

# Final output
echo "${BG_BLUE}${STYLE_BOLD}${FG_WHITE}════════════════════════════════════════════${FORMAT_RESET}"
echo "${BG_BLUE}${STYLE_BOLD}${FG_WHITE}  DEPLOYMENT COMPLETE!                      ${FORMAT_RESET}"
echo "${BG_BLUE}${STYLE_BOLD}${FG_WHITE}════════════════════════════════════════════${FORMAT_RESET}"
echo
echo "${COLOR_WHITE}${STYLE_BOLD}Next steps:${FORMAT_RESET}"
echo "┣ Check Dataflow job: ${COLOR_BLUE}https://console.cloud.google.com/dataflow/jobs?project=${PROJECT_ID}${FORMAT_RESET}"
echo "┣ View BigQuery data: ${COLOR_BLUE}https://console.cloud.google.com/bigquery?project=${PROJECT_ID}${FORMAT_RESET}"
echo "┗ Monitor Spanner: ${COLOR_BLUE}https://console.cloud.google.com/spanner/instances?project=${PROJECT_ID}${FORMAT_RESET}"
echo
echo "${COLOR_MAGENTA}${STYLE_BOLD}For more cloud tutorials, subscribe to:${FORMAT_RESET}"
echo "${COLOR_BLUE}https://www.youtube.com/@cloudwalejijaji${FORMAT_RESET}"
echo

trap - ERR
