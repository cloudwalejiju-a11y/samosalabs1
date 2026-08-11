
# Query Datasets and Save Results in Views with BigQuery


[![Watch on YouTube](https://img.shields.io/badge/Watch_on_YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)]()



---
### 🤝 Support
If you found this helpful, please **Subscribe** to [Cloud Wale Jiju](https://www.youtube.com/@cloudwalejijaji/videos) for more Google Cloud solutions!


### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏



```bash
bq query --use_legacy_sql=false "CREATE OR REPLACE VIEW \`Inventory.Product_View\` AS SELECT DISTINCT p.product_name, p.price FROM \`Inventory.products\` AS p INNER JOIN \`Inventory.category\` AS c ON p.category_id = c.category_id WHERE p.category_id = 1;"


```




