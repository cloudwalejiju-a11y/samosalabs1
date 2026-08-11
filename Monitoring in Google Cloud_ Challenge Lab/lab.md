## Monitoring in Google Cloud: Challenge Lab



### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏


### Run the following Commands in CloudShell

```
curl -LO https://raw.githubusercontent.com/cloudwalejiju-a11y/samosalabs1/refs/heads/main/Monitoring%20in%20Google%20Cloud_%20Challenge%20Lab/cloudwalejijaji.sh
sudo chmod +x cloudwalejijaji.sh
./cloudwalejijaji.sh
```
* Go to `Create log-based metric` from [here](https://console.cloud.google.com/logs/metrics/edit?)

1. For Log-based metric name: enter `drabhi`

2. Paste The Following in `Build filter` & Replace PROJECT_ID
```
resource.type="gce_instance"
logName="projects/PROJECT_ID/logs/apache-access"
textPayload:"200"
```

3. Paste The Following in `Regular Expression` field:
```
execution took (\d+)

```
### Congratulations !!!!
