## Streaming Analytics into BigQuery: Challenge Lab





### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏


### Run the following Commands in CloudShell

```
curl -LO https://raw.githubusercontent.com/cloudwalejiju-a11y/samosalabs1/refs/heads/main/Streaming%20Analytics%20into%20BigQuery_%20Challenge%20Lab/cloudwalejijaji.sh
sudo chmod +x cloudwalejijaji.sh
./cloudwalejijaji.sh
```


```
gcloud dataflow jobs run $JOB_NAME-1 --gcs-location gs://dataflow-templates-$REGION/latest/PubSub_to_BigQuery --region $REGION --staging-location gs://$DEVSHELL_PROJECT_ID/temp --parameters inputTopic=projects/$DEVSHELL_PROJECT_ID/topics/$TOPIC_NAME,outputTableSpec=$DEVSHELL_PROJECT_ID:$DATASET_NAME.$TABLE_NAME
```
### Congratulations !!!!

<div style="text-align: center; display: flex; flex-direction: column; align-items: center; gap: 20px;">
  <p></p>  

  </div>
