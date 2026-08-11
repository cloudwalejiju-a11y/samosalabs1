## Create and Test a Document AI Processor



### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏


### Run the following Commands in CloudShell
```bash
gcloud services enable documentai.googleapis.com
export ZONE=$(gcloud compute instances list document-ai-dev --format 'csv[no-heading](zone)')
gcloud compute ssh document-ai-dev --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet
```

* Open **`Document AI`** from [HERE](https://console.cloud.google.com/ai/document-ai?)
* Processor Name: **`form-parser`**
* Download [form.pdf](https://storage.googleapis.com/cloud-training/document-ai/generic/form.pdf)



```
curl -LO https://raw.githubusercontent.com/cloudwalejiju-a11y/samosalabs1/refs/heads/main/Create%20and%20Test%20a%20Document%20AI%20Processor/cloudwalejijaji.sh
sudo chmod +x cloudwalejijaji.sh
./cloudwalejijaji.sh
```
### Congratulations !!!!

