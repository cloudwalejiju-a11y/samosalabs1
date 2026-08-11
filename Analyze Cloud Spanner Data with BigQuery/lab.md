
# Analyze Cloud Spanner Data with BigQuery



> **Note:** SUBSCRIBE FOR MORE

---
### 🤝 Support
If you found this helpful, please **Subscribe** to [Cloud Wale Jiju](https://www.youtube.com/@cloudwalejijaji) for more Google Cloud solutions!


### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏



```bash
export PROJECT_ID=

bq mk --connection --connection_type='CLOUD_SPANNER' --properties="{\"database\":\"projects/${PROJECT_ID}/instances/ecommerce-instance/databases/ecommerce\"}" --location=us-east4 spanner_connection

bq query --use_legacy_sql=false "CREATE OR REPLACE VIEW \`${PROJECT_ID}.ecommerce.order_history\` AS SELECT * FROM EXTERNAL_QUERY(\"${PROJECT_ID}.us-east4.spanner_connection\", \"SELECT * FROM orders;\");"
```




<div align="center">

<h3 style="font-family: 'Segoe UI', sans-serif; color: linear-gradient(90deg, #4F46E5, #E114E5);">🌟 Connect with Cloud Enthusiasts 🌟</h3>
<p style="font-family: 'Segoe UI', sans-serif;">Join the community, share knowledge, and grow together!</p>



<a href="https://www.whatsapp.com/channel/0029VbCB6SpLo4hdpzFoD73f" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Join_WhatsApp_Channel-25D366?style=for-the-badge&logo=whatsapp&logoColor=white&labelColor=25D366" alt="WhatsApp Channel"/>
</a>





</div>