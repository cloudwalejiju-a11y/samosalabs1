
# Automate Data Capture at Scale with Document AI: Challenge Lab 

[![Watch on YouTube](https://img.shields.io/badge/Watch_on_YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://youtu.be/oJJsa6zDU04)

> **Note:** Automate Data Capture at Scale with Document AI: Challenge Lab 
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

📌 Activate Cloud Shell & Paste Over There
```
curl -LO https://raw.githubusercontent.com/cloudwalejiju-a11y/samosalabs1/refs/heads/main/Automate%20Data%20Capture%20at%20Scale%20with%20Document%20AI%20Challenge%20Lab/cloudwalejijaji.sh
sudo chmod +x cloudwalejijaji.sh
./cloudwalejijaji.sh
````
### 🚨If you're not getting score on task 5 then run the below commands few times

```
export PROJECT_ID=$(gcloud config get-value core/project)
gsutil -m cp -r gs://cloud-training/gsp367/* \
~/document-ai-challenge/invoices gs://${PROJECT_ID}-input-invoices/
```




<div align="center">

<!-- X (Twitter) -->
</div>
