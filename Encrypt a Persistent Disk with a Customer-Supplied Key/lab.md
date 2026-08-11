
# Encrypt a Persistent Disk with a Customer-Supplied Key


[![Watch on YouTube](https://img.shields.io/badge/Watch_on_YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://youtu.be/C3WIvvFjivs)

> **Note:** Establish Hybrid Network Connectivity with NCC

---
### 🤝 Support
If you found this helpful, please **Subscribe** to [Cloud Wale Jiju](https://www.youtube.com/@cloudwalejijaji/videos) for more Google Cloud solutions!


### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏

## fir agye na copy karne

```bash

export PROJECT_ID=$(gcloud config get-value project) ZONE=$(gcloud compute instances list --limit=1 --format="value(zone)") VM_NAME=$(gcloud compute instances list --limit=1 --format="value(name)") BASE64_KEY=$(head -c 32 /dev/urandom | base64)
gcloud compute disks create csek-encrypted-disk --size=200GB --zone=$ZONE --csek-key-file=<(echo "[{\"uri\": \"https://www.googleapis.com/compute/v1/projects/$PROJECT_ID/zones/$ZONE/disks/csek-encrypted-disk\", \"key\": \"$BASE64_KEY\", \"key-type\": \"raw\"}]")
gcloud compute instances attach-disk $VM_NAME --disk=csek-encrypted-disk --zone=$ZONE --csek-key-file=<(echo "[{\"uri\": \"https://www.googleapis.com/compute/v1/projects/$PROJECT_ID/zones/$ZONE/disks/csek-encrypted-disk\", \"key\": \"$BASE64_KEY\", \"key-type\": \"raw\"}]")

```




