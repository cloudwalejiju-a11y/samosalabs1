

### Speech-to-Text API: Qwik Start


## What You'll Do  

In this hands-on lab, you will learn how to use the *Speech-to-Text** to:  

- ✅ *Create an API key
  
- ✅ *Create a Speech-to-Text API request & Call the Speech-to-Text API.**
---


### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏

---


# Connect to your VM by running the following commands in Cloud Shell:

```bash
export ZONE=$(gcloud compute instances list linux-instance --format 'csv[no-heading](zone)')
gcloud compute ssh linux-instance --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet
```

Once connected to the VM, download and run the setup script:
```
curl -LO https://raw.githubusercontent.com/cloudwalejiju-a11y/samosalabs1/refs/heads/main/Speech-to-Text%20API_%20Qwik%20Start/abhishekGSP119.sh
sudo chmod +x abhishekGSP119.sh
./abhishekGSP119.sh
```




## Join the Community

- 