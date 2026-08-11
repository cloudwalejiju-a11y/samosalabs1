
### Cloud CDN



### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏



```bash

PROJECT_ID=$(gcloud config get-value project)
BUCKET_NAME="$PROJECT_ID"

gsutil mb -l US gs://$BUCKET_NAME


gsutil cp gs://cloud-training/gcpnet/cdn/cdn.png gs://$BUCKET_NAME


gsutil iam ch allUsers:objectViewer gs://$BUCKET_NAME


TOKEN=$(gcloud auth application-default print-access-token)

curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "bucketName": "'"$PROJECT_ID"'",
    "cdnPolicy": {
      "cacheMode": "CACHE_ALL_STATIC",
      "clientTtl": 60,
      "defaultTtl": 60,
      "maxTtl": 60,
      "negativeCaching": false,
      "serveWhileStale": 0
    },
    "compressionMode": "DISABLED",
    "description": "",
    "enableCdn": true,
    "name": "cdn-bucket"
  }' \
  "https://compute.googleapis.com/compute/v1/projects/$PROJECT_ID/global/backendBuckets"

sleep 20

curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "defaultService": "projects/'"$PROJECT_ID"'/global/backendBuckets/cdn-bucket",
    "name": "cdn-lb"
  }' \
  "https://compute.googleapis.com/compute/v1/projects/$PROJECT_ID/global/urlMaps"


sleep 20

curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "cdn-lb-target-proxy",
    "urlMap": "projects/'"$PROJECT_ID"'/global/urlMaps/cdn-lb"
  }' \
  "https://compute.googleapis.com/compute/v1/projects/$PROJECT_ID/global/targetHttpProxies"


sleep 20

curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "IPProtocol": "TCP",
    "ipVersion": "IPV4",
    "loadBalancingScheme": "EXTERNAL_MANAGED",
    "name": "cdn-lb-forwarding-rule",
    "networkTier": "PREMIUM",
    "portRange": "80",
    "target": "projects/'"$PROJECT_ID"'/global/targetHttpProxies/cdn-lb-target-proxy"
  }' \
  "https://compute.googleapis.com/compute/v1/projects/$PROJECT_ID/global/forwardingRules"
```




<div align="center">

<div align="center">

<!-- X (Twitter) -->

</div>
