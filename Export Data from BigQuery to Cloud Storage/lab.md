### Export Data from BigQuery to Cloud Storage



### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏


### Follow Video Carefully and replace values correctly
```bash

bq load --source_format=CSV --autodetect customer_details.customers customers.csv
```
```
bq query --use_legacy_sql=false --destination_table customer_details.male_customers 'SELECT CustomerID, Gender FROM customer_details.customers WHERE Gender="Male"'
```
### Follow Video Carefully For this part
```
bq extract customer_details.male_customers gs://qwiklabs-gcp-00-3340c17cff11-bucket/exported_male_customers.csv
```
```
bq query --use_legacy_sql=false --replace --destination_table=customer_details.male_customers 'SELECT CustomerID, Gender FROM customer_details.customers WHERE Gender = "Male"'
```






<div align="center">

<div align="center">

<!-- Telegram Channel -->
<!-- Telegram Group -->
<!-- YouTube -->
<!-- Instagram -->
<!-- X (Twitter) -->
</div>
