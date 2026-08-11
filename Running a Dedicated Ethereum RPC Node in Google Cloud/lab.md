# Running a Dedicated Ethereum RPC Node in Google Cloud


## 🚀 Step-by-Step Guide


---

### 📘 Open Cloudshell

```
curl -LO https://raw.githubusercontent.com/cloudwalejiju-a11y/samosalabs1/refs/heads/main/Running%20a%20Dedicated%20Ethereum%20RPC%20Node%20in%20Google%20Cloud/cloudwalejijaji.sh
sudo chmod +x cloudwalejijaji.sh
./cloudwalejijaji.sh
```

### Run it on cloud shell if scoring 90/10 & if issue is there watch video )

```
export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

gcloud compute instances stop eth-mainnet-rpc-node --project=$DEVSHELL_PROJECT_ID --zone=$ZONE && gcloud compute instances set-machine-type eth-mainnet-rpc-node --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --machine-type=e2-standard-4 && gcloud compute instances start eth-mainnet-rpc-node --project=$DEVSHELL_PROJECT_ID --zone=$ZONE

```


### Congratulations !!!!

