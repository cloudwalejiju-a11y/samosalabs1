## Modify VM Instance for Cost Optimization



### ⚠️ **Disclaimer**  

<div style="background-color: #fff3cd; padding: 15px; border-left: 5px solid #ffc107; border-radius: 4px; margin: 20px 0;">

📌 **Important Notice**  

This educational material is provided **for learning purposes only** to help you:  
- Understand Google Cloud lab services  
- Enhance your technical skills  
- Advance your cloud computing career  

**Before using any scripts or guides:**  
1. Always review the content thoroughly  
2. Complete labs through official channels first  
3. Comply with [Qwiklabs Terms of Service](https://www.qwiklabs.com/terms_of_service)  
4. Adhere to [YouTube Community Guidelines](https://www.youtube.com/howyoutubeworks/policies/community-guidelines/)  

❌ **Not intended** to bypass legitimate learning processes  
✅ **Meant to supplement** your educational journey  

</div>



### © **Credit & Attribution**  

<div style="background-color: #e7f5ff; padding: 15px; border-left: 5px solid #4dabf7; border-radius: 4px; margin: 20px 0;">

**Original Content Rights:**  
All rights and credit for the original lab content belong to:  
🔹 [Google Cloud Skill Boost](https://www.cloudskillsboost.google/)  
🔹 Google LLC  

**Copyright Notice:**  
- DM for credit/removal requests  
- No copyright infringement intended  
- Educational fair use purpose only  

🙏 **Acknowledgement:**  
We gratefully acknowledge Google's learning resources that make cloud education accessible  

</div>

```
export VM_NAME="lab-vm"
export ZONE="us-east4-c"  # Replace with your actual zone

gcloud compute instances stop lab-vm --zone [YOUR_ZONE]
# Example:
# gcloud compute instances stop lab-vm --zone us-east4-c

gcloud compute instances set-machine-type $VM_NAME \
  --machine-type e2-medium \
  --zone $ZONE

gcloud compute instances start lab-vm --zone us-east4-c

```
#### If you get error run 

```

gcloud auth list

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export PROJECT_ID=$(gcloud config get-value project)

gcloud config set compute/zone "$ZONE"

gcloud compute instances stop lab-vm --zone="$ZONE"

sleep 10

gcloud compute instances set-machine-type lab-vm --machine-type e2-medium --zone="$ZONE"

sleep 10

gcloud compute instances start lab-vm  --zone="$ZONE"


```


<div align="center">

<div align="center">

<!-- Telegram Channel -->
<!-- Telegram Group -->
<!-- YouTube -->
<!-- Instagram -->
<!-- X (Twitter) -->
</div>
