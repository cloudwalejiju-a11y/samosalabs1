
# Analyze the Text Prompt and Use it to Build an AI Image




> **Note:** Establish Hybrid Network Connectivity with NCC

---
### 🤝 Support
If you found this helpful, please **Subscribe** to [Cloud Wale Jiju](https://www.youtube.com/@cloudwalejijaji) for more Google Cloud solutions!


### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏



```bash

import google.auth
import google.auth.transport.requests
from google.auth.transport.requests import AuthorizedSession
import json

def generate_image(prompt):
    """
    Generate an image using Google Cloud's Imagen model.
    
    Args:
        prompt (str): Text description of the image to generate
        
    Returns:
        dict: Response containing image data and metadata
    """
    
    # Set your project ID here
    PROJECT_ID = "YOUR_PROJECT_ID"
    
    # Authenticate and get credentials
    credentials, _ = google.auth.default(scopes=['https://www.googleapis.com/auth/cloud-platform'])
    
    # Create an authorized session
    authed_session = AuthorizedSession(credentials)
    
    # API endpoint for Imagen 3.0
    endpoint = f"https://us-central1-aiplatform.googleapis.com/v1/projects/{PROJECT_ID}/locations/us-central1/publishers/google/models/imagen-3.0-generate-002:predict"
    
    # Request payload
    payload = {
        "instances": [
            {
                "prompt": prompt
            }
        ],
        "parameters": {
            "sampleCount": 1,
            "aspectRatio": "1:1",
            "negativePrompt": "",
            "personGeneration": "dont_allow",
            "safetyFilterLevel": "block_some",
            "addWatermark": True
        }
    }
    
    try:
        # Make the API request
        response = authed_session.post(
            endpoint,
            json=payload,
            headers={'Content-Type': 'application/json'}
        )
        
        # Check for successful response
        if response.status_code == 200:
            result = response.json()
            
            # Extract the base64 image data from the response
            if "predictions" in result and len(result["predictions"]) > 0:
                prediction = result["predictions"][0]
                
                if "mimeType" in prediction and "bytesBase64Encoded" in prediction:
                    image_data = prediction["bytesBase64Encoded"]
                    mime_type = prediction["mimeType"]
                    
                    # Save the image to a file
                    import base64
                    image_bytes = base64.b64decode(image_data)
                    
                    with open("generated_image.png", "wb") as f:
                        f.write(image_bytes)
                    
                    print(f"✅ Image generated successfully and saved as 'generated_image.png'")
                    print(f"📝 Prompt used: '{prompt}'")
                    print(f"📊 MIME Type: {mime_type}")
                    
                    return {
                        "success": True,
                        "image_path": "generated_image.png",
                        "mime_type": mime_type,
                        "prompt": prompt,
                        "full_response": result
                    }
        
        # Handle errors
        print(f"❌ Error: {response.status_code}")
        print(f"Response: {response.text}")
        return {
            "success": False,
            "error": f"API returned status {response.status_code}",
            "response": response.text
        }
        
    except Exception as e:
        print(f"❌ Exception occurred: {str(e)}")
        return {
            "success": False,
            "error": str(e)
        }

# Example usage
if __name__ == "__main__":
    # Use the specified prompt codecopy mr 
    prompt = "Create an image of a cricket ground in the heart of Los Angeles"
    
    print(f"🚀 Generating image with prompt b: '{prompt}'")
    result = generate_image(prompt)
    
    if result["success"]:
        print("🎉 Image generation completeed successfully!")
    else:
        print("❌ Image generation failed")
```




<div align="center">

<h3 style="font-family: 'Segoe UI', sans-serif; color: linear-gradient(90deg, #4F46E5, #E114E5);">🌟 Connect with Cloud Enthusiasts 🌟</h3>
<p style="font-family: 'Segoe UI', sans-serif;">Join the community, share knowledge, and grow together!</p>



<a href="https://www.whatsapp.com/channel/0029VbCB6SpLo4hdpzFoD73f" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Join_WhatsApp_Channel-25D366?style=for-the-badge&logo=whatsapp&logoColor=white&labelColor=25D366" alt="WhatsApp Channel"/>
</a>





</div>