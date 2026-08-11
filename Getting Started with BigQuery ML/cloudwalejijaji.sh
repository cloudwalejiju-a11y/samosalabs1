#!/bin/bash

# Color Definitions
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
echo "${CYAN_TEXT}${BOLD_TEXT}==================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}🚀   WELCOME TO DR. ABHISHEK CLOUD TUTORIALS    🚀${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}==================================================${RESET_FORMAT}"
echo
echo "${WHITE_TEXT}This script demonstrates predictive modeling using"
echo "Google Analytics data with BigQuery ML${RESET_FORMAT}"
echo

echo "${GREEN_TEXT}${BOLD_TEXT}=== INITIATING EXECUTION ===${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}👉 Step 1: Creating a new BigQuery dataset named 'bqml_lab'...${RESET_FORMAT}"
echo
bq mk bqml_lab

echo
echo "${YELLOW_TEXT}${BOLD_TEXT}👉 Step 2: Training a Logistic Regression model...${RESET_FORMAT}"
echo "${WHITE_TEXT}Model name: ${BLUE_TEXT}sample_model${WHITE_TEXT} in dataset ${BLUE_TEXT}bqml_lab${RESET_FORMAT}"
echo
bq query --use_legacy_sql=false \
"
CREATE OR REPLACE MODEL \`bqml_lab.sample_model\`
OPTIONS(model_type='logistic_reg') AS
SELECT
  IF(totals.transactions IS NULL, 0, 1) AS label,
  IFNULL(device.operatingSystem, '') AS os,
  device.isMobile AS is_mobile,
  IFNULL(geoNetwork.country, '') AS country,
  IFNULL(totals.pageviews, 0) AS pageviews
FROM
  \`bigquery-public-data.google_analytics_sample.ga_sessions_*\`
WHERE
  _TABLE_SUFFIX BETWEEN '20160801' AND '20170630'
LIMIT 100000;
"

echo
echo "${YELLOW_TEXT}${BOLD_TEXT}👉 Step 3: Evaluating the trained model...${RESET_FORMAT}"
echo
bq query --use_legacy_sql=false \
"
SELECT
  *
FROM
  ml.EVALUATE(MODEL \`bqml_lab.sample_model\`, (
SELECT
  IF(totals.transactions IS NULL, 0, 1) AS label,
  IFNULL(device.operatingSystem, '') AS os,
  device.isMobile AS is_mobile,
  IFNULL(geoNetwork.country, '') AS country,
  IFNULL(totals.pageviews, 0) AS pageviews
FROM
  \`bigquery-public-data.google_analytics_sample.ga_sessions_*\`
WHERE
  _TABLE_SUFFIX BETWEEN '20170701' AND '20170801'));
"

echo
echo "${YELLOW_TEXT}${BOLD_TEXT}👉 Step 4: Predicting purchases by country...${RESET_FORMAT}"
echo
bq query --use_legacy_sql=false \
"
SELECT
  country,
  SUM(predicted_label) as total_predicted_purchases
FROM
  ml.PREDICT(MODEL \`bqml_lab.sample_model\`, (
SELECT
  IFNULL(device.operatingSystem, '') AS os,
  device.isMobile AS is_mobile,
  IFNULL(totals.pageviews, 0) AS pageviews,
  IFNULL(geoNetwork.country, '') AS country
FROM
  \`bigquery-public-data.google_analytics_sample.ga_sessions_*\`
WHERE
  _TABLE_SUFFIX BETWEEN '20170701' AND '20170801'))
GROUP BY country
ORDER BY total_predicted_purchases DESC
LIMIT 10;
"

echo
echo "${YELLOW_TEXT}${BOLD_TEXT}👉 Step 5: Identifying top potential buyers...${RESET_FORMAT}"
echo
bq query --use_legacy_sql=false \
"
SELECT
  fullVisitorId,
  SUM(predicted_label) as total_predicted_purchases
FROM
  ml.PREDICT(MODEL \`bqml_lab.sample_model\`, (
SELECT
  IFNULL(device.operatingSystem, '') AS os,
  device.isMobile AS is_mobile,
  IFNULL(totals.pageviews, 0) AS pageviews,
  IFNULL(geoNetwork.country, '') AS country,
  fullVisitorId
FROM
  \`bigquery-public-data.google_analytics_sample.ga_sessions_*\`
WHERE
  _TABLE_SUFFIX BETWEEN '20170701' AND '20170801'))
GROUP BY fullVisitorId
ORDER BY total_predicted_purchases DESC
LIMIT 10;
"

# Completion Message
echo
echo "${GREEN_TEXT}${BOLD_TEXT}=== LAB COMPLETED SUCCESSFULLY ===${RESET_FORMAT}"
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}💡 For more cloud and data science tutorials:${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}Subscribe to Cloud Wale Jija Ji's YouTube Channel${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}https://www.youtube.com/@cloudwalejijaji${RESET_FORMAT}"
echo
