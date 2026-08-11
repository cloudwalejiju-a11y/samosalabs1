#!/bin/bash

# Color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Welcome message
echo -e "${YELLOW}============================================${NC}"
echo -e "${GREEN} Welcome to ${RED}Cloud Wale Jija Ji Cloud Tutorial${NC}"
echo -e "${YELLOW}============================================${NC}"
echo -e "${BLUE}Don't forget to subscribe to Cloud Wale Jija Ji's YouTube channel:${NC}"
echo -e "${GREEN}https://www.youtube.com/@cloudwalejijaji/videos${NC}"
echo -e "${YELLOW}============================================${NC}"
echo -e "\n"

# Create dataset
echo -e "${BLUE}Creating ecommerce dataset...${NC}"
bq mk ecommerce

# First model creation
echo -e "\n${BLUE}Creating classification_model...${NC}"
bq query --use_legacy_sql=false "
CREATE OR REPLACE MODEL \`ecommerce.classification_model\`
OPTIONS
(
model_type='logistic_reg',
input_label_cols = ['will_buy_on_return_visit']
)
AS

#standardSQL
SELECT
  * EXCEPT(fullVisitorId)
FROM

  # features
  (SELECT
    fullVisitorId,
    IFNULL(totals.bounces, 0) AS bounces,
    IFNULL(totals.timeOnSite, 0) AS time_on_site
  FROM
    \`data-to-insights.ecommerce.web_analytics\`
  WHERE
    totals.newVisits = 1
    AND date BETWEEN '20160801' AND '20170430') # train on first 9 months
  JOIN
  (SELECT
    fullvisitorid,
    IF(COUNTIF(totals.transactions > 0 AND totals.newVisits IS NULL) > 0, 1, 0) AS will_buy_on_return_visit
  FROM
      \`data-to-insights.ecommerce.web_analytics\`
  GROUP BY fullvisitorid)
  USING (fullVisitorId)
;
"

# Evaluate first model
echo -e "\n${BLUE}Evaluating classification_model...${NC}"
bq query --use_legacy_sql=false "
SELECT
  roc_auc,
  CASE
    WHEN roc_auc > .9 THEN 'good'
    WHEN roc_auc > .8 THEN 'fair'
    WHEN roc_auc > .7 THEN 'decent'
    WHEN roc_auc > .6 THEN 'not great'
  ELSE 'poor' END AS model_quality
FROM
  ML.EVALUATE(MODEL ecommerce.classification_model,  (

SELECT
  * EXCEPT(fullVisitorId)
FROM

  # features
  (SELECT
    fullVisitorId,
    IFNULL(totals.bounces, 0) AS bounces,
    IFNULL(totals.timeOnSite, 0) AS time_on_site
  FROM
    \`data-to-insights.ecommerce.web_analytics\`
  WHERE
    totals.newVisits = 1
    AND date BETWEEN '20170501' AND '20170630') # eval on 2 months
  JOIN
  (SELECT
    fullvisitorid,
    IF(COUNTIF(totals.transactions > 0 AND totals.newVisits IS NULL) > 0, 1, 0) AS will_buy_on_return_visit
  FROM
      \`data-to-insights.ecommerce.web_analytics\`
  GROUP BY fullvisitorid)
  USING (fullVisitorId)

));
"

# Second model creation
echo -e "\n${BLUE}Creating improved classification_model_2...${NC}"
bq query --use_legacy_sql=false "
CREATE OR REPLACE MODEL \`ecommerce.classification_model_2\`
OPTIONS
  (model_type='logistic_reg', input_label_cols = ['will_buy_on_return_visit']) AS

WITH all_visitor_stats AS (
  SELECT
    fullvisitorid,
    IF(COUNTIF(totals.transactions > 0 AND totals.newVisits IS NULL) > 0, 1, 0) AS will_buy_on_return_visit
  FROM \`data-to-insights.ecommerce.web_analytics\`
  GROUP BY fullvisitorid
)

SELECT * EXCEPT(unique_session_id) FROM (
  SELECT
    CONCAT(fullvisitorid, CAST(visitId AS STRING)) AS unique_session_id,
    will_buy_on_return_visit,
    MAX(CAST(h.eCommerceAction.action_type AS INT64)) AS latest_ecommerce_progress,
    IFNULL(totals.bounces, 0) AS bounces,
    IFNULL(totals.timeOnSite, 0) AS time_on_site,
    IFNULL(totals.pageviews, 0) AS pageviews,
    trafficSource.source,
    trafficSource.medium,
    channelGrouping,
    device.deviceCategory,
    IFNULL(geoNetwork.country, '') AS country
  FROM \`data-to-insights.ecommerce.web_analytics\`,
       UNNEST(hits) AS h
  JOIN all_visitor_stats USING(fullvisitorid)
  WHERE totals.newVisits = 1
    AND date BETWEEN '20160801' AND '20170430' # train on 9 months
  GROUP BY
    unique_session_id,
    will_buy_on_return_visit,
    bounces,
    time_on_site,
    totals.pageviews,
    trafficSource.source,
    trafficSource.medium,
    channelGrouping,
    device.deviceCategory,
    country
);
"

# Evaluate second model
echo -e "\n${BLUE}Evaluating classification_model_2...${NC}"
bq query --use_legacy_sql=false "
#standardSQL
SELECT
  roc_auc,
  CASE
    WHEN roc_auc > 0.9 THEN 'good'
    WHEN roc_auc > 0.8 THEN 'fair'
    WHEN roc_auc > 0.7 THEN 'decent'
    WHEN roc_auc > 0.6 THEN 'not great'
    ELSE 'poor'
  END AS model_quality
FROM
  ML.EVALUATE(MODEL \`ecommerce.classification_model_2\`,  (
    WITH all_visitor_stats AS (
      SELECT
        fullvisitorid,
        IF(COUNTIF(totals.transactions > 0 AND totals.newVisits IS NULL) > 0, 1, 0) AS will_buy_on_return_visit
      FROM \`data-to-insights.ecommerce.web_analytics\`
      GROUP BY fullvisitorid
    )
    SELECT * EXCEPT(unique_session_id) FROM (
      SELECT
        CONCAT(fullvisitorid, CAST(visitId AS STRING)) AS unique_session_id,
        will_buy_on_return_visit,
        MAX(CAST(h.eCommerceAction.action_type AS INT64)) AS latest_ecommerce_progress,
        IFNULL(totals.bounces, 0) AS bounces,
        IFNULL(totals.timeOnSite, 0) AS time_on_site,
        totals.pageviews,
        trafficSource.source,
        trafficSource.medium,
        channelGrouping,
        device.deviceCategory,
        IFNULL(geoNetwork.country, '') AS country
      FROM \`data-to-insights.ecommerce.web_analytics\`,
           UNNEST(hits) AS h
      JOIN all_visitor_stats USING(fullvisitorid)
      WHERE totals.newVisits = 1
        AND date BETWEEN '20170501' AND '20170630' # eval on 2 months
      GROUP BY
        unique_session_id,
        will_buy_on_return_visit,
        bounces,
        time_on_site,
        totals.pageviews,
        trafficSource.source,
        trafficSource.medium,
        channelGrouping,
        device.deviceCategory,
        country
    )
  ));
"

# Make predictions
echo -e "\n${BLUE}Making predictions with classification_model_2...${NC}"
bq query --nouse_legacy_sql '
SELECT
*
FROM
  ml.PREDICT(MODEL `ecommerce.classification_model_2`,
   (
WITH all_visitor_stats AS (
SELECT
  fullvisitorid,
  IF(COUNTIF(totals.transactions > 0 AND totals.newVisits IS NULL) > 0, 1, 0) AS will_buy_on_return_visit
  FROM `data-to-insights.ecommerce.web_analytics`
  GROUP BY fullvisitorid
)
  SELECT
      CONCAT(fullvisitorid, "-",CAST(visitId AS STRING)) AS unique_session_id,
      # labels
      will_buy_on_return_visit,
      MAX(CAST(h.eCommerceAction.action_type AS INT64)) AS latest_ecommerce_progress,
      # behavior on the site
      IFNULL(totals.bounces, 0) AS bounces,
      IFNULL(totals.timeOnSite, 0) AS time_on_site,
      totals.pageviews,
      # where the visitor came from
      trafficSource.source,
      trafficSource.medium,
      channelGrouping,
      # mobile or desktop
      device.deviceCategory,
      # geographic
      IFNULL(geoNetwork.country, "") AS country
  FROM `data-to-insights.ecommerce.web_analytics`,
     UNNEST(hits) AS h
    JOIN all_visitor_stats USING(fullvisitorid)
  WHERE
    # only predict for new visits
    totals.newVisits = 1
    AND date BETWEEN "20170701" AND "20170801" # test 1 month
  GROUP BY
  unique_session_id,
  will_buy_on_return_visit,
  bounces,
  time_on_site,
  totals.pageviews,
  trafficSource.source,
  trafficSource.medium,
  channelGrouping,
  device.deviceCategory,
  country
)
)
ORDER BY
  predicted_will_buy_on_return_visit DESC;'

# Final message
echo -e "\n${YELLOW}============================================${NC}"
echo -e "${GREEN}Lab completed!${NC}"
echo -e "${BLUE}Thanks for using Cloud Wale Jija Ji's Cloud Tutorial${NC}"
echo -e "${GREEN}Subscribe for more content: https://www.youtube.com/@cloudwalejijaji/videos${NC}"
echo -e "${YELLOW}============================================${NC}"
