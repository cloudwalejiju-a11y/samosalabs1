
# Establish Hybrid Network Connectivity with NCC

[![Watch on YouTube](https://img.shields.io/badge/Watch_on_YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://youtu.be/C3WIvvFjivs)

> **Note:** Establish Hybrid Network Connectivity with NCC

---
### 🤝 Support
If you found this helpful, please **Subscribe** to [Cloud Wale Jiju](https://www.youtube.com/@cloudwalejijaji/videos) for more Google Cloud solutions!


### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏

### Agaye copy karne :D 

```bash

gcloud compute firewall-rules list --filter="network=default" --format="value(name)" | xargs -r -I {} gcloud compute firewall-rules delete {} --quiet && \
gcloud compute networks delete default --quiet && \
gcloud compute networks create custom-vpc --subnet-mode=custom && \
gcloud compute networks subnets create custom-subnet-us --network=custom-vpc --region=us-central1 --range=10.0.1.0/24 && \
gcloud compute networks subnets create custom-subnet-asia --network=custom-vpc --region=asia-southeast1 --range=10.0.2.0/24

```




