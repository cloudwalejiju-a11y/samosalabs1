#!/bin/bash

# Color Definitions
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

# Header
echo "${CYAN}${BOLD}"
echo "╔════════════════════════════════════════════════════════╗"
echo "║          Welcome to Dr abhishek cloud tutorial            ║"
echo "╚════════════════════════════════════════════════════════╝"
echo "${RESET}"
echo "${YELLOW}${BOLD}Starting analysis...${RESET}"
echo

# Function to run queries with formatting
run_query() {
  local description=$1
  local query=$2
  
  echo "${BLUE}${BOLD}▶ ${description}${RESET}"
  echo "${MAGENTA}Running query...${RESET}"
  bq query --use_legacy_sql=false "$query"
  echo
}

# 1. Duplicate Analysis
run_query "1. Finding duplicate rows in raw data" \
'#standardSQL
SELECT COUNT(*) as num_duplicate_rows, * FROM
`data-to-insights.ecommerce.all_sessions_raw`
GROUP BY
fullVisitorId, channelGrouping, time, country, city, totalTransactionRevenue, 
transactions, timeOnSite, pageviews, sessionQualityDim, date, visitId, type, 
productRefundAmount, productQuantity, productPrice, productRevenue, productSKU, 
v2ProductName, v2ProductCategory, productVariant, currencyCode, itemQuantity, 
itemRevenue, transactionRevenue, transactionId, pageTitle, searchKeyword, 
pagePathLevel1, eCommerceAction_type, eCommerceAction_step, eCommerceAction_option
HAVING num_duplicate_rows > 1;'

# 2. Session Analysis
run_query "2. Analyzing session duplicates" \
'#standardSQL
SELECT
fullVisitorId, visitId, date, time, v2ProductName, productSKU, type,
eCommerceAction_type, eCommerceAction_step, eCommerceAction_option,
transactionRevenue, transactionId,
COUNT(*) as row_count
FROM `data-to-insights.ecommerce.all_sessions`
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12
HAVING row_count > 1'

# 3. Traffic Analysis
run_query "3. Calculating total product views and unique visitors" \
'#standardSQL
SELECT
  COUNT(*) AS product_views,
  COUNT(DISTINCT fullVisitorId) AS unique_visitors
FROM `data-to-insights.ecommerce.all_sessions`;'

run_query "4. Unique visitors by channel" \
'#standardSQL
SELECT
  COUNT(DISTINCT fullVisitorId) AS unique_visitors,
  channelGrouping
FROM `data-to-insights.ecommerce.all_sessions`
GROUP BY channelGrouping
ORDER BY channelGrouping DESC;'

# 4. Product Analysis
run_query "5. Listing all unique product names" \
'#standardSQL
SELECT
  (v2ProductName) AS ProductName
FROM `data-to-insights.ecommerce.all_sessions`
GROUP BY ProductName
ORDER BY ProductName'

run_query "6. Top 5 most viewed products" \
'#standardSQL
SELECT
  COUNT(*) AS product_views,
  (v2ProductName) AS ProductName
FROM `data-to-insights.ecommerce.all_sessions`
WHERE type = "PAGE"
GROUP BY v2ProductName
ORDER BY product_views DESC
LIMIT 5;'

run_query "7. Top 5 products by unique viewers" \
'#standardSQL
WITH unique_product_views_by_person AS (
SELECT
 fullVisitorId,
 (v2ProductName) AS ProductName
FROM `data-to-insights.ecommerce.all_sessions`
WHERE type = "PAGE"
GROUP BY fullVisitorId, v2ProductName )
SELECT
  COUNT(*) AS unique_view_count,
  ProductName
FROM unique_product_views_by_person
GROUP BY ProductName
ORDER BY unique_view_count DESC
LIMIT 5'

# 5. Sales Analysis
run_query "8. Product views vs orders" \
'#standardSQL
SELECT
  COUNT(*) AS product_views,
  COUNT(productQuantity) AS orders,
  SUM(productQuantity) AS quantity_product_ordered,
  v2ProductName
FROM `data-to-insights.ecommerce.all_sessions`
WHERE type = "PAGE"
GROUP BY v2ProductName
ORDER BY product_views DESC
LIMIT 5;'

run_query "9. Product performance metrics" \
'#standardSQL
SELECT
  COUNT(*) AS product_views,
  COUNT(productQuantity) AS orders,
  SUM(productQuantity) AS quantity_product_ordered,
  SUM(productQuantity) / COUNT(productQuantity) AS avg_per_order,
  (v2ProductName) AS ProductName
FROM `data-to-insights.ecommerce.all_sessions`
WHERE type = "PAGE"
GROUP BY v2ProductName
ORDER BY product_views DESC
LIMIT 5;'

# Completion
echo "${GREEN}${BOLD}"
echo "╔════════════════════════════════════════════════════════╗"
echo "║         Lab completed successfully!             ║"
echo "╚════════════════════════════════════════════════════════╝"
echo "${RESET}"
