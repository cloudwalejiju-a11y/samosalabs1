
# Configure Cloud Storage Bucket for Website Hosting using gsutil

[![Watch on YouTube](https://img.shields.io/badge/Watch_on_YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://youtu.be/C3WIvvFjivs)

> **Note:** Configure Cloud Storage Bucket for Website Hosting using gsutil


---
### 🤝 Support
If you found this helpful, please **Subscribe** to [Cloud Wale Jiju](https://www.youtube.com/@cloudwalejijaji/videos) for more Google Cloud solutions!


### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏





```bash
export BUCKET=
```
```bash
gsutil web set -m index.html -e error.html gs://$BUCKET
gsutil uniformbucketlevelaccess set off gs://$BUCKET
gsutil defacl set public-read gs://$BUCKET
gsutil acl set -a public-read gs://$BUCKET/index.html
gsutil acl set -a public-read gs://$BUCKET/error.html
gsutil acl set -a public-read gs://$BUCKET/style.css
gsutil acl set -a public-read gs://$BUCKET/logo.jpg
```

```

```


