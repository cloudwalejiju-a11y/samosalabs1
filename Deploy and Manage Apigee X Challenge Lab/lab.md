### Deploy and Manage Apigee X: Challenge Lab


### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏


## Task 3:
### Search `organizations.instances.natAddresses`
```bash
organizations/{YOUR PROJECTID}/instances/eval-instance
```
### Activate NAT address:-
```bash
organizations/{YOUR PROJECTID}/instances/eval-instance/natAddresses/apigee-nat-ip
```

## Task 4: 
###  Create the Cloud Armor policy:-
```bash
evaluatePreconfiguredExpr('rce-stable')
```

## ☁️Run the following commands in Cloud Shell:
```bash
echo ${GOOGLE_CLOUD_PROJECT}
```
```bash
export INSTANCE_NAME=eval-instance; curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application/json" -X POST "https://apigee.googleapis.com/v1/organizations/${GOOGLE_CLOUD_PROJECT}/instances/${INSTANCE_NAME}/attachments" -d '{ "environment": "staging" }' | jq
```
```bash
export ATTACHING_ENV=staging; export INSTANCE_NAME=eval-instance; echo "waiting for ${ATTACHING_ENV} attachment"; while : ; do export ATTACHMENT_DONE=$(curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)" -X GET "https://apigee.googleapis.com/v1/organizations/${GOOGLE_CLOUD_PROJECT}/instances/${INSTANCE_NAME}/attachments" | jq "select(.attachments != null) | .attachments[] | select(.environment == \"${ATTACHING_ENV}\") | .environment" --join-output); [[ "${ATTACHMENT_DONE}" != "${ATTACHING_ENV}" ]] || break; echo -n "."; sleep 5; done; echo; echo "***${ATTACHING_ENV} ENVIRONMENT ATTACHED***";
```

</div>

---



<div align="center">

<div align="center">

<!-- Telegram Channel -->
<!-- Telegram Group -->
<!-- YouTube -->
<!-- Instagram -->
<!-- X (Twitter) -->
</div>
