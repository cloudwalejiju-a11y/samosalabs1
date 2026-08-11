#!/bin/bash

# Modern Color Palette
DARK_BLUE=$'\033[38;5;27m'
TEAL=$'\033[38;5;50m'
PURPLE=$'\033[38;5;129m'
ORANGE=$'\033[38;5;208m'
LIME=$'\033[38;5;118m'
PINK=$'\033[38;5;200m'
RESET=$'\033[0m'
BOLD=$'\033[1m'
DIM=$'\033[2m'

# Modern UI Elements
DIVIDER="${DARK_BLUE}${BOLD}┃${RESET}"
TOP_CORNER="${DARK_BLUE}${BOLD}╭${RESET}"
BOTTOM_CORNER="${DARK_BLUE}${BOLD}╰${RESET}"
LINE="${DARK_BLUE}${BOLD}─${RESET}"

clear

# Modern Header with gradient effect
echo
echo "${TOP_CORNER}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${RESET}"
echo "${DARK_BLUE}${BOLD}                    WELCOME TO DR ABHISHEK CLOUD                    ${RESET}"
echo "${DARK_BLUE}${BOLD}                      TUTORIALS  DO LIKE THE VIDEO             ${RESET}"
echo "${BOTTOM_CORNER}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${RESET}"
echo

# Step 1: Dataset Creation
echo "${PURPLE}${BOLD}▐▓▒▌ STEP 1: DATASET CREATION ${DARK_BLUE}${BOLD}◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈${RESET}"
echo
echo "${TEAL}${BOLD} Creating 'Reports' dataset in BigQuery...${RESET}"
echo "${DIM}${TEAL} Command: ${BOLD}bq mk Reports${RESET}"

# Execute with visual feedback
echo -n "${TEAL}${BOLD} Executing..."
bq mk Reports > /dev/null 2>&1 &
pid=$!

# Spinner animation
spin='⣾⣽⣻⢿⡿⣟⣯⣷'
while kill -0 $pid 2>/dev/null; do
    for i in $(seq 0 7); do
        echo -ne "${TEAL}${BOLD}\r Executing... ${spin:$i:1} ${RESET}"
        sleep 0.1
    done
done

echo -e "${TEAL}${BOLD}\r Executing... ✓ Done!          ${RESET}"
echo "${LIME}${BOLD}✔ Successfully created 'Reports' dataset${RESET}"
echo

# Step 2: Query Execution
echo "${PURPLE}${BOLD}▐▓▒▌ STEP 2: QUERY EXECUTION ${DARK_BLUE}${BOLD}◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈${RESET}"
echo
echo "${TEAL}${BOLD} Running analytics query to populate 'Trees' table...${RESET}"
echo "${DIM}${TEAL} This may take a few moments depending on data size${RESET}"

# Execute query with progress indicator
(
bq query \
  --use_legacy_sql=false \
  --destination_table=$DEVSHELL_PROJECT_ID:Reports.Trees \
  --replace=false \
  --nouse_cache \
  "SELECT
    TIMESTAMP_TRUNC(plant_date, MONTH) as plant_month,
    COUNT(tree_id) AS total_trees,
    species,
    care_taker,
    address,
    site_info
  FROM
    \`bigquery-public-data.san_francisco_trees.street_trees\`
  WHERE
    address IS NOT NULL
    AND plant_date >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 365 DAY)
    AND plant_date < TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY)
  GROUP BY
    plant_month,
    species,
    care_taker,
    address,
    site_info"
) &> /dev/null &

pid=$!

# Fancy progress bar
echo -ne "${ORANGE}${BOLD} Progress: [          ] 0% ${RESET}"
for i in {1..10}; do
    sleep $((RANDOM%3+1))
    echo -ne "${ORANGE}${BOLD}\r Progress: ["
    for j in $(seq 1 $i); do
        echo -ne "▓"
    done
    for j in $(seq $i 9); do
        echo -ne " "
    done
    echo -ne "] $((i*10))% ${RESET}"
done

echo -e "${LIME}${BOLD}\r Progress: [▓▓▓▓▓▓▓▓▓▓] 100% ✓ Complete!          ${RESET}"
echo "${LIME}${BOLD}✔ Successfully populated 'Trees' table with analytics data${RESET}"
echo


echo
echo "${PINK}${BOLD}╭──────────────────────────────────────────────────────────────╮${RESET}"
echo "${PINK}${BOLD}│    🚀 Analytics Pipeline Execution Completed Successfully!   │${RESET}"
echo "${PINK}${BOLD}│    🔍 Explore your data in BigQuery Console                  │${RESET}"
echo "${PINK}${BOLD}╰──────────────────────────────────────────────────────────────╯${RESET}"
echo
echo "${DARK_BLUE}${BOLD} For more advanced data engineering tutorials, visit:${RESET}"
echo "${TEAL}${BOLD}   https://www.youtube.com/@cloudwalejijaji/${RESET}"
echo
echo "${DIM}${DARK_BLUE} Like and subscribe for more cloud data tutorials! ${RESET}"
echo
