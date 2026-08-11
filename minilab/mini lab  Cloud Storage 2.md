### mini lab : Cloud Storage : 2


### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏



```bash



cat > lifecycle.json << EOF
{
    "rule": [
      {
        "action": {
          "storageClass": "NEARLINE",
          "type": "SetStorageClass"
        },
        "condition": {
          "daysSinceNoncurrentTime": 30,
          "matchesPrefix": [
            "/projects/active/"
          ]
        }
      },
      {
        "action": {
          "storageClass": "NEARLINE",
          "type": "SetStorageClass"
        },
        "condition": {
          "daysSinceNoncurrentTime": 90,
          "matchesPrefix": [
            "/archive/"
          ]
        }
      },
      {
        "action": {
          "storageClass": "COLDLINE",
          "type": "SetStorageClass"
        },
        "condition": {
          "daysSinceNoncurrentTime": 180,
          "matchesPrefix": [
            "/archive/"
          ]
        }
      },
      {
        "action": {
          "type": "Delete"
        },
        "condition": {
          "age": 7,
          "matchesPrefix": [
            "/processing/temp_logs/"
          ]
        }
      }
    ]
  }
EOF

export PROJECT_ID=$(gcloud config get-value project)

gsutil lifecycle set lifecycle.json gs://$PROJECT_ID-bucket
```




<div align="center">

<div align="center">

<!-- Telegram Channel -->
<!-- Telegram Group -->
<!-- YouTube -->
<!-- Instagram -->
<!-- X (Twitter) -->
</div>
