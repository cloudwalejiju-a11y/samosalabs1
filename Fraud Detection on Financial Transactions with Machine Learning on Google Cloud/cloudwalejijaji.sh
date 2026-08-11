#!/bin/bash

# Enhanced Color Definitions
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)

BOLD=$(tput bold)
RESET=$(tput sgr0)

clear

# Display Header
echo "${CYAN}${BOLD}================================================${RESET}"
echo "${CYAN}${BOLD}   DR. ABHISHEK'S FRAUD DETECTION ANALYSIS LAB  ${RESET}"
echo "${CYAN}${BOLD}================================================${RESET}"
echo "${BLUE}YouTube Channel: https://www.youtube.com/@cloudwalejijaji${RESET}"
echo "${MAGENTA}Video Tutorials: https://www.youtube.com/@cloudwalejijaji/videos${RESET}"
echo

# Initialize Project
echo "${YELLOW}${BOLD}Step 1: Initializing Project Environment${RESET}"
export PROJECT_ID=$(gcloud config get-value project)
if [ -z "$PROJECT_ID" ]; then
  echo "${RED}✗ Failed to get project ID. Please ensure you're authenticated.${RESET}"
  exit 1
fi
echo "${GREEN}✓ Project ID: ${PROJECT_ID}${RESET}"
echo

# Download Dataset
echo "${YELLOW}${BOLD}Step 2: Downloading Fraud Detection Dataset${RESET}"
if [ -f "archive.zip" ]; then
  echo "${YELLOW}✓ Dataset already downloaded${RESET}"
else
  gsutil cp gs://spls/gsp774/archive.zip . || {
    echo "${RED}✗ Failed to download dataset${RESET}"
    exit 1
  }
  echo "${GREEN}✓ Dataset downloaded successfully${RESET}"
fi
echo

# Extract Dataset
echo "${YELLOW}${BOLD}Step 3: Extracting Dataset${RESET}"
if [ -f "PS_20174392719_1491204439457_log.csv" ]; then
  echo "${YELLOW}✓ Dataset already extracted${RESET}"
else
  unzip -o archive.zip || {
    echo "${RED}✗ Failed to extract dataset${RESET}"
    exit 1
  }
  echo "${GREEN}✓ Dataset extracted successfully${RESET}"
fi
export DATA_FILE=PS_20174392719_1491204439457_log.csv
echo

# Create BigQuery Dataset
echo "${YELLOW}${BOLD}Step 4: Creating BigQuery Dataset${RESET}"
bq show finance || bq mk --dataset $PROJECT_ID:finance
echo "${GREEN}✓ BigQuery dataset ready${RESET}"
echo

# Create Cloud Storage Bucket
echo "${YELLOW}${BOLD}Step 5: Setting Up Cloud Storage${RESET}"
BUCKET_NAME="${PROJECT_ID}-fraud-data"
if gsutil ls -b gs://$BUCKET_NAME &>/dev/null; then
  echo "${YELLOW}✓ Bucket already exists${RESET}"
else
  gsutil mb gs://$BUCKET_NAME || {
    echo "${RED}✗ Failed to create bucket${RESET}"
    exit 1
  }
  echo "${GREEN}✓ Bucket created: gs://${BUCKET_NAME}${RESET}"
fi
echo

# Upload Data to Cloud Storage
echo "${YELLOW}${BOLD}Step 6: Uploading Data to Cloud Storage${RESET}"
gsutil cp $DATA_FILE gs://$BUCKET_NAME/ || {
  echo "${RED}✗ Failed to upload data file${RESET}"
  exit 1
}
echo "${GREEN}✓ Data uploaded to Cloud Storage${RESET}"
echo

# Load Data into BigQuery
echo "${YELLOW}${BOLD}Step 7: Loading Data into BigQuery${RESET}"
bq load --autodetect --source_format=CSV --max_bad_records=100000 finance.fraud_data gs://$BUCKET_NAME/$DATA_FILE || {
  echo "${RED}✗ Failed to load data into BigQuery${RESET}"
  exit 1
}
echo "${GREEN}✓ Data loaded into BigQuery${RESET}"
echo

# Data Analysis Queries
echo "${CYAN}${BOLD}Step 8: Running Fraud Analysis Queries${RESET}"

echo "${BLUE}Transaction Summary by Type and Fraud Status:${RESET}"
bq query --use_legacy_sql=false \
"SELECT type, isFraud, count(*) as cnt
 FROM \`finance.fraud_data\`
 GROUP BY isFraud, type
 ORDER BY type"
echo

echo "${BLUE}Fraud Count for Key Transaction Types:${RESET}"
bq query --use_legacy_sql=false \
'SELECT isFraud, count(*) as cnt
FROM `finance.fraud_data`
WHERE type in ("CASH_OUT", "TRANSFER")
GROUP BY isFraud'
echo

echo "${BLUE}Top 10 Largest Transactions:${RESET}"
bq query --use_legacy_sql=false \
"SELECT *
 FROM \`finance.fraud_data\`
 ORDER BY amount DESC
 LIMIT 10"
echo

# Feature Engineering
echo "${YELLOW}${BOLD}Step 9: Feature Engineering${RESET}"
bq query --use_legacy_sql=false \
'CREATE OR REPLACE TABLE finance.fraud_data_sample AS
SELECT
      type,
      amount,
      nameOrig,
      nameDest,
      oldbalanceOrg as oldbalanceOrig,
      newbalanceOrig,
      oldbalanceDest,
      newbalanceDest,
      if(oldbalanceOrg = 0.0, 1, 0) as origzeroFlag,
      if(newbalanceDest = 0.0, 1, 0) as destzeroFlag,
      round((newbalanceDest-oldbalanceDest-amount)) as amountError,
      generate_uuid() as id,
      isFraud
FROM finance.fraud_data
WHERE
      type in("CASH_OUT","TRANSFER") AND
      (isFraud = 1 or (RAND()< 10/100))'
echo "${GREEN}✓ Feature engineering completed${RESET}"
echo

# Data Splitting
echo "${YELLOW}${BOLD}Step 10: Splitting Data into Test and Model Sets${RESET}"
bq query --use_legacy_sql=false \
"CREATE OR REPLACE TABLE finance.fraud_data_test AS
SELECT *
FROM finance.fraud_data_sample
where RAND() < 20/100"

bq query --use_legacy_sql=false \
"CREATE OR REPLACE TABLE finance.fraud_data_model AS
SELECT *
FROM finance.fraud_data_sample  
EXCEPT distinct select * from finance.fraud_data_test"
echo "${GREEN}✓ Data splitting completed${RESET}"
echo

# Unsupervised Model Training
echo "${YELLOW}${BOLD}Step 11: Training Unsupervised K-Means Model${RESET}"
bq query --use_legacy_sql=false \
"CREATE OR REPLACE MODEL
  finance.model_unsupervised OPTIONS(model_type='kmeans', num_clusters=5) AS
SELECT
  amount, oldbalanceOrig, newbalanceOrig, oldbalanceDest, newbalanceDest, type, 
  origzeroFlag, destzeroFlag, amountError
FROM \`finance.fraud_data_model\`"
echo "${GREEN}✓ Unsupervised model trained${RESET}"
echo

# Supervised Model Training
echo "${YELLOW}${BOLD}Step 12: Training Supervised Logistic Regression Model${RESET}"
bq query --use_legacy_sql=false \
"CREATE OR REPLACE MODEL
  finance.model_supervised_initial
  OPTIONS(model_type='LOGISTIC_REG', INPUT_LABEL_COLS = ['isfraud'])
AS
SELECT
  type, amount, oldbalanceOrig, newbalanceOrig, oldbalanceDest, newbalanceDest, isFraud
FROM finance.fraud_data_model"
echo "${GREEN}✓ Supervised model trained${RESET}"
echo

# Model Evaluation
echo "${CYAN}${BOLD}Step 13: Evaluating Models${RESET}"

echo "${BLUE}Fraud Distribution Across Clusters:${RESET}"
bq query --use_legacy_sql=false \
'SELECT
  centroid_id, sum(isfraud) as fraud_cnt, count(*) total_cnt
FROM
  ML.PREDICT(MODEL `finance.model_unsupervised`,
    (SELECT * FROM `finance.fraud_data_test`))
group by centroid_id
order by centroid_id'
echo

echo "${BLUE}Supervised Model Weights:${RESET}"
bq query --use_legacy_sql=false \
'SELECT * FROM ML.WEIGHTS(MODEL `finance.model_supervised_initial`,
  STRUCT(true AS standardize))'
echo

echo "${BLUE}Fraud Predictions:${RESET}"
bq query --use_legacy_sql=false \
'SELECT id, label as predicted, isFraud as actual
FROM
  ML.PREDICT(MODEL `finance.model_supervised_initial`,
   (SELECT * FROM `finance.fraud_data_test`)
  ), unnest(predicted_isfraud_probs) as p
where p.label = 1 and p.prob > 0.5'
echo

# Cleanup
echo "${YELLOW}${BOLD}Step 14: Cleaning Up Temporary Files${RESET}"
rm -f archive.zip PS_20174392719_1491204439457_log.csv
echo "${GREEN}✓ Temporary files removed${RESET}"
echo

# Completion Message
echo "${MAGENTA}${BOLD}================================================${RESET}"
echo "${MAGENTA}${BOLD}   FRAUD DETECTION ANALYSIS COMPLETED!        ${RESET}"
echo "${MAGENTA}${BOLD}================================================${RESET}"
echo
echo "${GREEN}${BOLD}Key Insights Generated:${RESET}"
echo "1. Transaction patterns by type and fraud status"
echo "2. Feature-engineered dataset for machine learning"
echo "3. Unsupervised clustering model (K-Means)"
echo "4. Supervised classification model (Logistic Regression)"
echo "5. Model evaluation metrics and predictions"
echo
echo "${CYAN}${BOLD}Next Steps:${RESET}"
echo "1. Explore the models in BigQuery ML"
echo "2. Try different model types and parameters"
echo "3. Deploy the best model for real-time predictions"
echo
echo "${BLUE}${BOLD}For more data science tutorials:${RESET}"
echo "${WHITE}Subscribe to Cloud Wale Jija Ji's YouTube Channel:${RESET}"
echo "${CYAN}https://www.youtube.com/@cloudwalejijaji${RESET}"
echo "${WHITE}Video Tutorials:${RESET}"
echo "${CYAN}https://www.youtube.com/@cloudwalejijaji/videos${RESET}"
