## Create VPC Peering Connection between VPCs




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

gcloud auth list

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export PROJECT_ID=$(gcloud config get-value project)

gcloud config set compute/zone "$ZONE"

gcloud compute networks create workspace-vpc --subnet-mode=custom

gcloud compute networks create private-vpc --subnet-mode=custom

gcloud compute networks peerings create workspace-to-private --network=workspace-vpc --peer-network=private-vpc --auto-create-routes

gcloud compute networks peerings create private-to-workspace --network=private-vpc --peer-network=workspace-vpc --auto-create-routes

gcloud compute ssh workspace-vm --project="$PROJECT_ID" --zone="$ZONE"

```



<div align="center">

<div align="center">

<!-- X (Twitter) -->

</div>