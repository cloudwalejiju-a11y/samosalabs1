
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


## sab badhiya kaise ho
```bash

export VM_NAME=$(gcloud compute instances list --format='value(name)' --limit=1) && export ZONE=$(gcloud compute instances list --format='value(zone)' --limit=1) && export REGION=${ZONE%-*}
gcloud compute addresses create lab-static-ip --region=$REGION
export IP_ADDRESS=$(gcloud compute addresses describe lab-static-ip --region=$REGION --format='get(address)') && gcloud compute instances add-access-config $VM_NAME --zone=$ZONE --address=$IP_ADDRESS

```




