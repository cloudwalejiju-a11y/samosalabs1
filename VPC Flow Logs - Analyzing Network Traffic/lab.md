# VPC Flow Logs - Analyzing Network Traffic

[![Watch on YouTube](https://img.shields.io/badge/Watch_on_YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://youtu.be/V6HDAn4r9kw)

> **Note:** VPC Flow Logs - Analyzing Network TrafficC

---
### 🤝 Support
If you found this helpful, please **Subscribe** to [Cloud Wale Jiju](https://www.youtube.com/@cloudwalejijaji/videos) for more Google Cloud solutions!

### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏


### Run the following Commands in CloudShell


```
curl -LO https://raw.githubusercontent.com/cloudwalejiju-a11y/samosalabs1/refs/heads/main/VPC%20Flow%20Logs%20-%20Analyzing%20Network%20Traffic/cloudwalejijaji.sh
sudo chmod +x cloudwalejijaji.sh
./cloudwalejijaji.sh
```

- **Sink Name: vpc-flows**

---

```
CP_IP=$(gcloud compute instances describe web-server --zone=$ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

export MY_SERVER=$CP_IP

for ((i=1;i<=50;i++)); do curl $MY_SERVER; done
```
