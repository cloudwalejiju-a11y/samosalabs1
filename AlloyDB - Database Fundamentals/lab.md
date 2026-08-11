
# AlloyDB - Database Fundamentals




> **Note:** 

---
### 🤝 Support
If you found this helpful, please **Subscribe** to [Cloud Wale Jiju](https://www.youtube.com/@cloudwalejijaji) for more Google Cloud solutions!


### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏



---


 **Launch Cloud Shell:**  
   Start your Google CloudShell session by [``clicking here``](https://console.cloud.google.com/home/dashboard?project=&pli=1&cloudshell=true).


```bash
export REGION=
```

```bash
gcloud beta alloydb clusters create lab-cluster \
    --password=Change3Me \
    --network=peering-network \
    --region=$REGION \
    --project=$DEVSHELL_PROJECT_ID

gcloud beta alloydb instances create lab-instance \
    --instance-type=PRIMARY \
    --cpu-count=2 \
    --region=$REGION  \
    --cluster=lab-cluster \
    --project=$DEVSHELL_PROJECT_ID
```
---

 **Launch Another Cloud Shell +**  

```bash
export REGION=
```

```bash
gcloud beta alloydb clusters create gcloud-lab-cluster \
    --password=Change3Me \
    --network=peering-network \
    --region=$REGION \
    --project=$DEVSHELL_PROJECT_ID

gcloud beta alloydb instances create gcloud-lab-instance\
    --instance-type=PRIMARY \
    --cpu-count=2 \
    --region=$REGION  \
    --cluster=gcloud-lab-cluster \
    --project=$DEVSHELL_PROJECT_ID
```

----

### 🔗 [``VM Instance``](https://console.cloud.google.com/compute/instances?referrer=search&project=)

### 🔗 [``AlloyDB``](https://console.cloud.google.com/alloydb/clusters?referrer=search&project=)



Set the following environment variable, replacing ALLOYDB_ADDRESS with the Private IP address of the AlloyDB instance.
```bash
export ALLOYDB=
```
Run the following command to store the Private IP address of the AlloyDB instance on the AlloyDB client VM so that it will persist throughout the lab.
```bash
echo $ALLOYDB  > alloydbip.txt 
```
Use the following command to launch the PostgreSQL (psql) client. You will be prompted to provide the postgres user's password (``Change3Me``) which you entered when you created the cluster.
```bash
psql -h $ALLOYDB -U postgres
```

Input and run the following SQL commands separately to enable the extension.
```bash
\c postgres
```
```bash
CREATE TABLE regions (
    region_id bigint NOT NULL,
    region_name varchar(25)
) ;

ALTER TABLE regions ADD PRIMARY KEY (region_id);
```
```bash
INSERT INTO regions VALUES ( 1, 'Europe' );

INSERT INTO regions VALUES ( 2, 'Americas' );

INSERT INTO regions VALUES ( 3, 'Asia' );

INSERT INTO regions VALUES ( 4, 'Middle East and Africa' );
```

Run the following system query to see details on the pgaudit extension.
```bash
SELECT region_id, region_name from regions;
```

---

<div align="center">

<h3 style="font-family: 'Segoe UI', sans-serif; color: linear-gradient(90deg, #4F46E5, #E114E5);">🌟 Connect with Cloud Enthusiasts 🌟</h3>
<p style="font-family: 'Segoe UI', sans-serif;">Join the community, share knowledge, and grow together!</p>



<a href="https://www.whatsapp.com/channel/0029VbCB6SpLo4hdpzFoD73f" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Join_WhatsApp_Channel-25D366?style=for-the-badge&logo=whatsapp&logoColor=white&labelColor=25D366" alt="WhatsApp Channel"/>
</a>





</div>

---