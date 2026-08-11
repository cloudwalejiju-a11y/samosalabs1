
# Configure Cloud Buckets with gsutil for Load Balancing & Fault Tolerance

[![Watch on YouTube](https://img.shields.io/badge/Watch_on_YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://youtu.be/C3WIvvFjivs)

> **Note:** Configure Cloud Buckets with gsutil for Load Balancing & Fault Tolerance
---
### 🤝 Support
If you found this helpful, please **Subscribe** to [Cloud Wale Jiju](https://www.youtube.com/@cloudwalejijaji/videos) for more Google Cloud solutions!


### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏


### Agaye Copy karne :D 
```bash
PROJECT_ID=$(gcloud config get-value project)
OLD_BUCKET=${PROJECT_ID}-bucket
NEW_BUCKET=${PROJECT_ID}-new

gsutil mb gs://$NEW_BUCKET
gsutil web set -m index.html -e error.html gs://$NEW_BUCKET
gsutil iam ch allUsers:roles/storage.admin gs://$NEW_BUCKET
gsutil -m rsync -r gs://$OLD_BUCKET gs://$NEW_BUCKET

gcloud compute backend-buckets create backend-new --gcs-bucket-name=$NEW_BUCKET --enable-cdn

gcloud compute url-maps create website-map --default-backend-bucket=backend-new

gcloud compute target-http-proxies create website-proxy --url-map=website-map

gcloud compute forwarding-rules create website-rule --global --target-http-proxy=website-proxy --ports=80
```



