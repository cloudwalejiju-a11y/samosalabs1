### mini lab : Cloud Storage : 1


### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏



```bash





export PROJECT=$(gcloud projects list --format="value(PROJECT_ID)")

gcloud storage buckets update gs://$PROJECT-bucket --no-uniform-bucket-level-access

gcloud storage buckets update gs://$PROJECT-bucket --web-main-page-suffix=index.html --web-error-page=error.html

gcloud storage objects update gs://$PROJECT-bucket/index.html --add-acl-grant=entity=AllUsers,role=READER

gcloud storage objects update gs://$PROJECT-bucket/error.html --add-acl-grant=entity=AllUsers,role=READER
```




<div align="center">

<div align="center">

<!-- Telegram Channel -->
<!-- Telegram Group -->
<!-- YouTube -->
<!-- Instagram -->
<!-- X (Twitter) -->
</div>
