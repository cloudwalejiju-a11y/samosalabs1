# Implement DevOps Workflows in Google Cloud

### Challenge Lab (GSP330)

---

[<img src="https://img.shields.io/badge/Open_Lab-Cloud_Skills_Boost-4285F4?style=for-the-badge&logo=google&logoColor=white&labelColor=34A853" alt="Open Lab Badge">](https://www.cloudskillsboost.google/focuses/13287?parent=catalog)
---
### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏

---

### 📋 <ins>**Prerequisites**</ins>

✅ If you do not already have a **GitHub** account, you will need to create a  
👉 [GitHub account](https://github.com/signup)

---

## 🛠️ Configuration Steps 🚀

> 💡 **Pro Tip:** *Watch the full video to ensure you achieve full scores on all "Check My Progress" steps!*

<div style="padding: 15px; margin: 10px 0;">
<p><strong>☁️ Run in Cloud Shell:</strong></p>

```bash
curl -LO https://raw.githubusercontent.com/cloudwalejiju-a11y/samosalabs1/refs/heads/main/Implement%20DevOps%20Workflows%20in%20Google%20Cloud_%20Challenge%20Lab/cloudwalejijaji.sh
sudo chmod +x cloudwalejijaji.sh
./cloudwalejijaji.sh
```

</div>

### 🛠️ **Cloud Build Trigger Configuration**  

#### **Production Deployment Trigger:** 

**Name:**
```
sample-app-prod-deploy
```

**Branch Pattern:**
```
^master$
```

**Build Configuration File:**
```
cloudbuild.yaml
```

#### **Development Deployment Trigger:** 

**Name:**
```
sample-app-dev-deploy
```

**Branch Pattern:**
```
^dev$
```

**Build Configuration File:**
```
cloudbuild-dev.yaml
```

---
### Congratulations !!!!

