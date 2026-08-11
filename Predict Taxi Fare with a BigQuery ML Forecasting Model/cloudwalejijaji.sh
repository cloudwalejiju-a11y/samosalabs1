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
echo "${CYAN_TEXT}${BOLD_TEXT}🚀   WELCOME TO DR. ABHISHEK'S BIGQUERY LAB     🚀${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}==================================================${RESET_FORMAT}"
echo
echo "${WHITE_TEXT}This script demonstrates taxi fare prediction using"
echo "New York City taxi data with BigQuery ML${RESET_FORMAT}"
echo

echo "${GREEN_TEXT}${BOLD_TEXT}=== INITIATING EXECUTION ===${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}🛠️  Creating a new BigQuery dataset named 'taxi' in the US location...${RESET_FORMAT}"
bq mk --location=us taxi

echo
echo "${GREEN_TEXT}${BOLD_TEXT}📊  Querying monthly trip counts from the 2015 NYC TLC Yellow Trips public dataset...${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT
  TIMESTAMP_TRUNC(pickup_datetime,
    MONTH) month,
  COUNT(*) trips
FROM
  \`bigquery-public-data.new_york.tlc_yellow_trips_2015\`
GROUP BY
  1
ORDER BY
  1
"

echo
echo "${GREEN_TEXT}${BOLD_TEXT}⏱️  Calculating the average trip speed per hour from the 2015 dataset...${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT
  EXTRACT(HOUR
  FROM
    pickup_datetime) hour,
  ROUND(AVG(trip_distance / TIMESTAMP_DIFF(dropoff_datetime,
        pickup_datetime,
        SECOND))*3600, 1) speed
FROM
  \`bigquery-public-data.new_york.tlc_yellow_trips_2015\`
WHERE
  trip_distance > 0
  AND fare_amount/trip_distance BETWEEN 2
  AND 10
  AND dropoff_datetime > pickup_datetime
GROUP BY
  1
ORDER BY
  1
"

echo
echo "${BLUE_TEXT}${BOLD_TEXT}🔍  Selecting a sample of taxi trip data for training purposes...${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
WITH params AS (
    SELECT
    1 AS TRAIN,
    2 AS EVAL
    ),

  daynames AS
    (SELECT ['Sun', 'Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat'] AS daysofweek),

  taxitrips AS (
  SELECT
    (tolls_amount + fare_amount) AS total_fare,
    daysofweek[ORDINAL(EXTRACT(DAYOFWEEK FROM pickup_datetime))] AS dayofweek,
    EXTRACT(HOUR FROM pickup_datetime) AS hourofday,
    pickup_longitude AS pickuplon,
    pickup_latitude AS pickuplat,
    dropoff_longitude AS dropofflon,
    dropoff_latitude AS dropofflat,
    passenger_count AS passengers
  FROM
    \`nyc-tlc.yellow.trips\`, daynames, params
  WHERE
    trip_distance > 0 AND fare_amount > 0
    AND MOD(ABS(FARM_FINGERPRINT(CAST(pickup_datetime AS STRING))),1000) = params.TRAIN
  )

  SELECT *
  FROM taxitrips
"

echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}🧠  Creating or replacing a BigQuery ML linear regression model named 'taxifare_model' to predict total fare...${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
CREATE or REPLACE MODEL taxi.taxifare_model
OPTIONS
  (model_type='linear_reg', labels=['total_fare']) AS

WITH params AS (
    SELECT
    1 AS TRAIN,
    2 AS EVAL
    ),

  daynames AS
    (SELECT ['Sun', 'Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat'] AS daysofweek),

  taxitrips AS (
  SELECT
    (tolls_amount + fare_amount) AS total_fare,
    daysofweek[ORDINAL(EXTRACT(DAYOFWEEK FROM pickup_datetime))] AS dayofweek,
    EXTRACT(HOUR FROM pickup_datetime) AS hourofday,
    pickup_longitude AS pickuplon,
    pickup_latitude AS pickuplat,
    dropoff_longitude AS dropofflon,
    dropoff_latitude AS dropofflat,
    passenger_count AS passengers
  FROM
    \`nyc-tlc.yellow.trips\`, daynames, params
  WHERE
    trip_distance > 0 AND fare_amount > 0
    AND MOD(ABS(FARM_FINGERPRINT(CAST(pickup_datetime AS STRING))),1000) = params.TRAIN
  )

  SELECT *
  FROM taxitrips
"

echo
echo "${YELLOW_TEXT}${BOLD_TEXT}📈  Evaluating the trained model 'taxifare_model' using the evaluation dataset and calculating RMSE...${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT
  SQRT(mean_squared_error) AS rmse
FROM
  ML.EVALUATE(MODEL taxi.taxifare_model,
  (

  WITH params AS (
    SELECT
    1 AS TRAIN,
    2 AS EVAL
    ),

  daynames AS
    (SELECT ['Sun', 'Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat'] AS daysofweek),

  taxitrips AS (
  SELECT
    (tolls_amount + fare_amount) AS total_fare,
    daysofweek[ORDINAL(EXTRACT(DAYOFWEEK FROM pickup_datetime))] AS dayofweek,
    EXTRACT(HOUR FROM pickup_datetime) AS hourofday,
    pickup_longitude AS pickuplon,
    pickup_latitude AS pickuplat,
    dropoff_longitude AS dropofflon,
    dropoff_latitude AS dropofflat,
    passenger_count AS passengers
  FROM
    \`nyc-tlc.yellow.trips\`, daynames, params
  WHERE
    trip_distance > 0 AND fare_amount > 0
    AND MOD(ABS(FARM_FINGERPRINT(CAST(pickup_datetime AS STRING))),1000) = params.EVAL
  )

  SELECT *
  FROM taxitrips

  ))
"

echo
echo "${CYAN_TEXT}${BOLD_TEXT}🔮  Making predictions using the 'taxifare_model' on the evaluation dataset...${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT
*
FROM
  ml.PREDICT(MODEL \`taxi.taxifare_model\`,
   (

 WITH params AS (
    SELECT
    1 AS TRAIN,
    2 AS EVAL
    ),

  daynames AS
    (SELECT ['Sun', 'Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat'] AS daysofweek),

  taxitrips AS (
  SELECT
    (tolls_amount + fare_amount) AS total_fare,
    daysofweek[ORDINAL(EXTRACT(DAYOFWEEK FROM pickup_datetime))] AS dayofweek,
    EXTRACT(HOUR FROM pickup_datetime) AS hourofday,
    pickup_longitude AS pickuplon,
    pickup_latitude AS pickuplat,
    dropoff_longitude AS dropofflon,
    dropoff_latitude AS dropofflat,
    passenger_count AS passengers
  FROM
    \`nyc-tlc.yellow.trips\`, daynames, params
  WHERE
    trip_distance > 0 AND fare_amount > 0
    AND MOD(ABS(FARM_FINGERPRINT(CAST(pickup_datetime AS STRING))),1000) = params.EVAL
  )

  SELECT *
  FROM taxitrips

));
"

# Completion Message
echo
echo "${GREEN_TEXT}${BOLD_TEXT}=== LAB COMPLETED SUCCESSFULLY ===${RESET_FORMAT}"
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}💡 For more cloud and data science tutorials:${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}Subscribe to Cloud Wale Jija Ji's YouTube Channel${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}https://www.youtube.com/@cloudwalejijaji${RESET_FORMAT}"
echo
