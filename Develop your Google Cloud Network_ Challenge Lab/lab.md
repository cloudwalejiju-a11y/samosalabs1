### Develop your Google Cloud Network: Challenge Lab



### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏

### Run the following Commands in CloudShell

```
export ZONE=
```
```bash

curl -LO https://raw.githubusercontent.com/cloudwalejiju-a11y/samosalabs1/refs/heads/main/Develop%20your%20Google%20Cloud%20Network_%20Challenge%20Lab/cloudwalejijaji.sh
sudo chmod +x cloudwalejijaji.sh
./cloudwalejijaji.sh
```

### Task 8. Enable monitoring

1. Go to [Services and Ingress](https://console.cloud.google.com/kubernetes/discovery)
2. Copy `endpoint's`(wordpress) `IP address`.
3. Then go to -> [Uptime Checks](https://console.cloud.google.com/monitoring/uptime) -> `+ CREATE UPTIME CHECK`. 
4. Fill in the details as provided below : 

* Hostname : `endpoint's IP address` (without http and port number)

* Path : `/`

* Title: `Wordpress Uptime`

5. Leave everything as default. Click `Next` -> `Next` -> `Create`



<div align="center">

<div align="center">

<!-- Telegram Channel -->
<!-- Telegram Group -->
<!-- YouTube -->
<!-- Instagram -->
<!-- X (Twitter) -->
</div>
