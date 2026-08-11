
# 
# 
# Configure Cloud CDN for Storage using gcloud


[![Watch on YouTube](https://img.shields.io/badge/Watch_on_YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://youtu.be/C3WIvvFjivs)

> **Note:** Establish Hybrid Network Connectivity with NCC

---
### 🤝 Support
If you found this helpful, please **Subscribe** to [Cloud Wale Jiju](https://www.youtube.com/@cloudwalejijaji/videos) for more Google Cloud solutions!


### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏



```bash

BUCKET_NAME=
BACKEND_BUCKET=static-backend-bucket
URL_MAP=cdn-map
PROXY=cdn-http-proxy
FORWARDING_RULE=cdn-http-rule

gcloud compute backend-buckets create $BACKEND_BUCKET --gcs-bucket-name=$BUCKET_NAME --enable-cdn

gcloud compute url-maps create $URL_MAP --default-backend-bucket=$BACKEND_BUCKET
# karta hu copy abhishek ji ki video ki mai to hu nal;ayak
gcloud compute target-http-proxies create $PROXY --url-map=$URL_MAP

gcloud compute forwarding-rules create $FORWARDING_RULE --global --target-http-proxy=$PROXY --ports=80

gcloud compute forwarding-rules describe $FORWARDING_RULE --global --format="value(IPAddress)"

gsutil ls gs://BUCKET_NAME/images/
# jaise video banata hai sir mai ajata copy karne ko :D md file bhi na banane aati meko
curl -o nature.png http://IP_ADDRESS/images/nature.png
```




