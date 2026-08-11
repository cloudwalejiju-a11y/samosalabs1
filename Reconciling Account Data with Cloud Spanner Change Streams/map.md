## Reconciling Account Data with Cloud Spanner Change Streams


### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏


### Run the following Commands in CloudShell

```
curl -LO https://raw.githubusercontent.com/cloudwalejiju-a11y/samosalabs1/refs/heads/main/Reconciling%20Account%20Data%20with%20Cloud%20Spanner%20Change%20Streams/cloudwalejijaji.sh
sudo chmod +x cloudwalejijaji.sh
./cloudwalejijaji.sh
```
## Follow Video Carefully & Create dataflow job

### Now Paste in spanner studio 

```
INSERT INTO
 Account (AccountId,
   CreationTimestamp,
   AccountStatus,
   Balance)
VALUES
 (FROM_BASE64('ACCOUNTID11123'),
   PENDING_COMMIT_TIMESTAMP(),
   1,
   22);

 UPDATE
 Account
SET
 CreationTimestamp=PENDING_COMMIT_TIMESTAMP(),
 AccountStatus=4,
 Balance=255
WHERE
 AccountId=FROM_BASE64('ACCOUNTID11123');

 UPDATE
 Account
SET
 CreationTimestamp=PENDING_COMMIT_TIMESTAMP(),
 AccountStatus=4,
 Balance=300
WHERE
 AccountId=FROM_BASE64('ACCOUNTID11123');

 UPDATE
 Account
SET
 CreationTimestamp=PENDING_COMMIT_TIMESTAMP(),
 AccountStatus=4,
 Balance=500
WHERE
 AccountId=FROM_BASE64('ACCOUNTID11123');

 UPDATE
 Account
SET
 CreationTimestamp=PENDING_COMMIT_TIMESTAMP(),
 AccountStatus=4,
 Balance=600
WHERE
 AccountId=FROM_BASE64('ACCOUNTID11123');
```
### Congratulations !!!!

<div align="center">

<div align="center">

<!-- Telegram Channel -->
<!-- Telegram Group -->
<!-- YouTube -->
<!-- Instagram -->
<!-- X (Twitter) -->
</div>
