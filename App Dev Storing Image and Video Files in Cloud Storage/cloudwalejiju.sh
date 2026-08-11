#!/bin/bash

# Define color variables
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Cloud Wale Jiju banner
pattern=(
"**********************************************************"
"**          WELCOME TO CLOUD WALE JIJU CLOUD TUTORIALS     **"
"**               CLOUD STORAGE LAB EXECUTION            **"
"**                                                      **"
"**********************************************************"
)
for line in "${pattern[@]}"
do
    echo -e "${YELLOW}${line}${NC}"
done

echo
echo -e "${CYAN}Setting up Google Cloud Storage Lab...${NC}"
echo

# Get user input for region
echo -e "${YELLOW}Please enter your preferred region:${NC}"
echo -e "${BLUE}Examples: us-central1, us-east1, europe-west1, asia-southeast1${NC}"
read -p "Enter region: " USER_REGION

# Validate region input
if [ -z "$USER_REGION" ]; then
    echo -e "${RED}Error: Region cannot be empty. Using default region.${NC}"
    USER_REGION="us-central1"
fi

echo -e "${GREEN}Using region: $USER_REGION${NC}"
echo

# Set project
echo -e "${CYAN}Configuring Google Cloud project...${NC}"
gcloud config set project $DEVSHELL_PROJECT_ID
echo -e "${GREEN}Project set to: $DEVSHELL_PROJECT_ID${NC}"

# Clone repository
echo -e "${CYAN}Cloning training repository...${NC}"
git clone https://github.com/GoogleCloudPlatform/training-data-analyst

# Navigate to directory
cd ~/training-data-analyst/courses/developingapps/python/cloudstorage/start

# Update region in configuration
echo -e "${CYAN}Configuring environment for region: $USER_REGION${NC}"
sed -i s/us-central/$USER_REGION/g prepare_environment.sh

# Prepare environment
echo -e "${CYAN}Preparing application environment...${NC}"
. prepare_environment.sh

# Create Cloud Storage bucket
echo -e "${CYAN}Creating Cloud Storage bucket...${NC}"
gsutil mb -l $USER_REGION gs://$DEVSHELL_PROJECT_ID-media

# Download and upload sample image
echo -e "${CYAN}Downloading and uploading sample image...${NC}"
wget https://storage.googleapis.com/cloud-training/quests/Google_Cloud_Storage_logo.png
gsutil cp Google_Cloud_Storage_logo.png gs://$DEVSHELL_PROJECT_ID-media

# Set environment variable
export GCLOUD_BUCKET=$DEVSHELL_PROJECT_ID-media
echo -e "${GREEN}Cloud Storage bucket set to: $GCLOUD_BUCKET${NC}"
echo -e "${GREEN}Bucket location: $USER_REGION${NC}"

# Navigate to GCP directory
cd quiz/gcp

# Create storage.py with Cloud Storage integration
echo -e "${CYAN}Configuring Cloud Storage integration...${NC}"
cat > storage.py <<EOF_END
# TODO: Get the Bucket name from the
# GCLOUD_BUCKET environment variable
bucket_name = os.getenv('GCLOUD_BUCKET')
# END TODO
# TODO: Import the storage module
from google.cloud import storage
# END TODO
# TODO: Create a client for Cloud Storage
storage_client = storage.Client()
# END TODO
# TODO: Use the client to get the Cloud Storage bucket
bucket = storage_client.get_bucket(bucket_name)
# END TODO

"""
Uploads a file to a given Cloud Storage bucket and returns the public url
to the new object.
"""
def upload_file(image_file, public):
    # TODO: Use the bucket to get a blob object
    blob = bucket.blob(image_file.filename)
    # END TODO
    # TODO: Use the blob to upload the file
    blob.upload_from_string(
        image_file.read(),
        content_type=image_file.content_type)
    # END TODO
    # TODO: Make the object public
    if public:
        blob.make_public()
    # END TODO
    # TODO: Modify to return the blob's Public URL
    return blob.public_url
    # END TODO
EOF_END

# Navigate to webapp directory
cd ../webapp/

# Create questions.py with file upload functionality
echo -e "${CYAN}Configuring file upload functionality...${NC}"
cat > questions.py <<EOF_END
# TODO: Import the storage module
from quiz.gcp import storage, datastore
# END TODO
"""
uploads file into google cloud storage
- upload file
- return public_url
"""
def upload_file(image_file, public):
    if not image_file:
        return None
    # TODO: Use the storage client to Upload the file
    # The second argument is a boolean
    public_url = storage.upload_file(
       image_file,
       public
    )
    # END TODO
    # TODO: Return the public URL
    # for the object
    return public_url
    # END TODO
"""
uploads file into google cloud storage
- call method to upload file (public=true)
- call datastore helper method to save question
"""
def save_question(data, image_file):
    # TODO: If there is an image file, then upload it
    # And assign the result to a new Datastore
    # property imageUrl
    # If there isn't, assign an empty string
    if image_file:
        data['imageUrl'] = str(
                  upload_file(image_file, True))
    else:
        data['imageUrl'] = u''
    # END TODO
    data['correctAnswer'] = int(data['correctAnswer'])
    datastore.save_question(data)
    return

EOF_END

# Navigate back to start directory
cd ~/training-data-analyst/courses/developingapps/python/cloudstorage/start

# Display configuration summary
echo
echo -e "${CYAN}${BLUE}=== Configuration Summary ===${NC}"
echo -e "${GREEN}Project ID: $DEVSHELL_PROJECT_ID${NC}"
echo -e "${GREEN}Region: $USER_REGION${NC}"
echo -e "${GREEN}Cloud Storage Bucket: $GCLOUD_BUCKET${NC}"
echo -e "${BLUE}=================================${NC}"
echo

# Start the application server
echo -e "${CYAN}Starting the application server...${NC}"
echo -e "${GREEN}Application is now running with Cloud Storage integration!${NC}"
echo -e "${YELLOW}The server will start now. Press Ctrl+C to stop the server.${NC}"
echo
python run_server.py

# Final Cloud Wale Jiju banner
echo
pattern=(
"**********************************************************"
"**        CLOUD STORAGE LAB COMPLETED SUCCESSFULLY!     **"
"**                                                      **"
"**           THANK YOU FOR FOLLOWING CLOUD WALE JIJU       **"
"**               CLOUD TUTORIALS                        **"
"**                                                      **"
"**    Subscribe for more cloud computing tutorials:     **"
"**    https://www.youtube.com/@cloudwalejijaji   **"
"**                                                      **"
"**         Don't forget to Like, Share & Subscribe!     **"
"**********************************************************"
)
for line in "${pattern[@]}"
do
    echo -e "${YELLOW}${line}${NC}"
done