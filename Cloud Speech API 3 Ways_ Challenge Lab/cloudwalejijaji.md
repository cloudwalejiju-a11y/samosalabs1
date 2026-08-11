## Cloud Speech API 3 Ways: Challenge Lab

### In a challenge lab you’re given a scenario and a set of tasks. Instead of following step-by-step instructions, you will use the skills learned from the labs in the course to figure out how to complete the tasks on your own! An automated scoring system (shown on this page) will provide feedback on whether you have completed your tasks correctly.

### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏

***To start the VM session on Cloud Shell*** 
```
# Get the zone of your lab VM
export ZONE=$(gcloud compute instances list lab-vm --format 'csv[no-heading](zone)')

# SSH into the lab VM
gcloud compute ssh lab-vm --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet
```

***Export the Value from lab page as showed in the video*** 


```bash

curl -LO https://raw.githubusercontent.com/cloudwalejiju-a11y/samosalabs1/refs/heads/main/Cloud%20Speech%20API%203%20Ways_%20Challenge%20Lab/abhishekARC132.sh
sudo chmod +x abhishekARC132.sh
./abhishekARC132.sh
```




<div align="center">

<div align="center">

<!-- Telegram Channel -->
<!-- Telegram Group -->
<!-- YouTube -->
<!-- Instagram -->
<!-- X (Twitter) -->
</div>
