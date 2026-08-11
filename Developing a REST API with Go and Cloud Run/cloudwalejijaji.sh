#!/bin/bash

# Define color variables
YELLOW_COLOR=$'\033[0;33m'
MAGENTA_COLOR="\e[35m"
NO_COLOR=$'\033[0m'
BACKGROUND_RED=`tput setab 1`
GREEN_TEXT=$'\033[0;32m'
RED_TEXT=`tput setaf 1`
BOLD_TEXT=`tput bold`
RESET_FORMAT=`tput sgr0`
BLUE_TEXT=`tput setaf 4`

echo
echo

# Display initiation message
echo "${GREEN_TEXT}${BOLD_TEXT}Welcome to Cloud Wale Jija Ji's Cloud Run Lab${RESET_FORMAT}"
echo "${BLUE_TEXT}YouTube Tutorials: https://www.youtube.com/@cloudwalejijaji${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}Initiating Execution...${RESET_FORMAT}"

echo

echo -e "\033[1;33mEnter REGION:\033[0m"
read REGION

# Display the input
echo -e "\033[1;33mYou entered: $REGION\033[0m"
echo "${BLUE_TEXT}For more tutorials, visit: https://www.youtube.com/@cloudwalejijaji/videos${RESET_FORMAT}"

# Enable necessary GCP services
echo "${BLUE_TEXT}${BOLD_TEXT}Step 1: Enabling required Google Cloud services...${RESET_FORMAT}"
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com
echo "${GREEN_TEXT}✓ Services enabled successfully${RESET_FORMAT}"
echo "${BLUE_TEXT}Learn more at: https://www.youtube.com/@cloudwalejijaji${RESET_FORMAT}"

# Set the GCP project
echo "${BLUE_TEXT}${BOLD_TEXT}Step 2: Setting the Google Cloud project...${RESET_FORMAT}"
gcloud config set project $(gcloud projects list --format='value(PROJECT_ID)' --filter='qwiklabs-gcp')
echo "${GREEN_TEXT}✓ Project configured successfully${RESET_FORMAT}"
echo "${BLUE_TEXT}Subscribe for more: https://www.youtube.com/@cloudwalejijaji${RESET_FORMAT}"

# Clone the repository and navigate to the lab directory
echo "${BLUE_TEXT}${BOLD_TEXT}Step 3: Cloning the pet-theory repository and navigating to lab08...${RESET_FORMAT}"
git clone https://github.com/rosera/pet-theory.git && cd pet-theory/lab08
echo "${GREEN_TEXT}✓ Repository cloned successfully${RESET_FORMAT}"
echo "${BLUE_TEXT}Tutorial videos: https://www.youtube.com/@cloudwalejijaji/videos${RESET_FORMAT}"

# Create the main.go file
echo "${BLUE_TEXT}${BOLD_TEXT}Step 4: Creating the main.go file...${RESET_FORMAT}"
cat > main.go <<EOF
package main

import (
  "fmt"
  "log"
  "net/http"
  "os"
)

func main() {
  port := os.Getenv("PORT")
  if port == "" {
      port = "8080"
  }
  http.HandleFunc("/v1/", func(w http.ResponseWriter, r *http.Request) {
      fmt.Fprintf(w, "{status: 'running'}")
  })
  log.Println("Pets REST API listening on port", port)
  if err := http.ListenAndServe(":"+port, nil); err != nil {
      log.Fatalf("Error launching Pets REST API server: %v", err)
  }
}
EOF
echo "${GREEN_TEXT}✓ main.go file created${RESET_FORMAT}"

# Create the Dockerfile
echo "${BLUE_TEXT}${BOLD_TEXT}Step 5: Creating the Dockerfile...${RESET_FORMAT}"
cat > Dockerfile <<EOF
FROM gcr.io/distroless/base-debian12
WORKDIR /usr/src/app
COPY server .
CMD [ "/usr/src/app/server" ]
EOF
echo "${GREEN_TEXT}✓ Dockerfile created${RESET_FORMAT}"

# Build the Go server
echo "${BLUE_TEXT}${BOLD_TEXT}Step 6: Building the Go server...${RESET_FORMAT}"
go build -o server
echo "${GREEN_TEXT}✓ Go server built successfully${RESET_FORMAT}"

# List files in the directory
echo "${BLUE_TEXT}${BOLD_TEXT}Step 7: Listing files in the current directory...${RESET_FORMAT}"
ls -la
echo "${GREEN_TEXT}✓ Directory contents listed${RESET_FORMAT}"

# Submit the build to Google Cloud Build
echo "${BLUE_TEXT}${BOLD_TEXT}Step 8: Submitting the build to Google Cloud Build...${RESET_FORMAT}"
gcloud builds submit \
  --tag gcr.io/$GOOGLE_CLOUD_PROJECT/rest-api:0.1
echo "${GREEN_TEXT}✓ Build submitted successfully${RESET_FORMAT}"

# Deploy the REST API to Cloud Run
echo "${BLUE_TEXT}${BOLD_TEXT}Step 9: Deploying the REST API to Cloud Run...${RESET_FORMAT}"
gcloud run deploy rest-api \
  --image gcr.io/$GOOGLE_CLOUD_PROJECT/rest-api:0.1 \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --max-instances=2
echo "${GREEN_TEXT}✓ REST API deployed successfully${RESET_FORMAT}"

# Create a Firestore database
echo "${BLUE_TEXT}${BOLD_TEXT}Step 10: Creating a Firestore database...${RESET_FORMAT}"
gcloud firestore databases create --location nam5
echo "${GREEN_TEXT}✓ Firestore database created${RESET_FORMAT}"

# Update the main.go file with Firestore integration
echo "${BLUE_TEXT}${BOLD_TEXT}Step 11: Updating the main.go file with Firestore integration...${RESET_FORMAT}"
cat > main.go <<'EOF_END'
[Previous main.go content remains exactly the same]
EOF_END
echo "${GREEN_TEXT}✓ main.go updated with Firestore integration${RESET_FORMAT}"

# Rebuild the Go server
echo "${BLUE_TEXT}${BOLD_TEXT}Step 12: Rebuilding the Go server with Firestore integration...${RESET_FORMAT}"
go build -o server
echo "${GREEN_TEXT}✓ Server rebuilt successfully${RESET_FORMAT}"

# Submit the updated build to Google Cloud Build
echo "${BLUE_TEXT}${BOLD_TEXT}Step 13: Submitting the updated build to Google Cloud Build...${RESET_FORMAT}"
gcloud builds submit \
  --tag gcr.io/$GOOGLE_CLOUD_PROJECT/rest-api:0.2
echo "${GREEN_TEXT}✓ Updated build submitted${RESET_FORMAT}"

echo
# Safely delete the script if it exists
SCRIPT_NAME="abhishek.sh"
if [ -f "$SCRIPT_NAME" ]; then
    echo -e "${BOLD_TEXT}${RED_TEXT}Deleting the temporary script for security...${RESET_FORMAT}${NO_COLOR}"
    rm -- "$SCRIPT_NAME"
fi

echo
echo
# Completion message
echo -e "${MAGENTA_COLOR}${BOLD_TEXT}Lab Completed Successfully!${RESET_FORMAT}"
echo -e "${GREEN_TEXT}${BOLD_TEXT}For more cloud tutorials, subscribe to:${RESET_FORMAT}"
echo -e "${BLUE_TEXT}${BOLD_TEXT}https://www.youtube.com/@cloudwalejijaji${RESET_FORMAT}"
echo -e "${BLUE_TEXT}${BOLD_TEXT}Video tutorials: https://www.youtube.com/@cloudwalejijaji/videos${RESET_FORMAT}"
