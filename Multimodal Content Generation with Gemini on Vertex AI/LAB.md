
# Multimodal Content Generation with Gemini on Vertex AI


[![Watch on YouTube](https://img.shields.io/badge/Watch_on_YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://youtu.be/i86rdVw_ri4)

> **Note:** Establish Hybrid Network Connectivity with NCC

---
### 🤝 Support
If you found this helpful, please **Subscribe** to [Cloud Wale Jiju](https://www.youtube.com/@cloudwalejijaji/videos) for more Google Cloud solutions!


### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏



```bash

import vertexai
import urllib.request
from vertexai.generative_models import GenerativeModel, Part

PROJECT_ID = "your-project-id"
LOCATION = "your-location"

vertexai.init(project=PROJECT_ID, location=LOCATION)

def load_image_from_url(prompt):
    print(f"Processing prompt: {prompt}")
    image_url = "https://storage.googleapis.com/cloud-samples-data/generative-ai/image/scones.jpg"
    
    try:
        with urllib.request.urlopen(image_url) as response:
            image_bytes = response.read()
            
        image_part = Part.from_data(
            data=image_bytes,
            mime_type="image/jpeg"
        )
        model = GenerativeModel("gemini-2.5-flash")

        response = model.generate_content(
            [image_part, prompt],
            generation_config={
                "temperature": 0.4,
                "max_output_tokens": 2048
            }
        )
        
        print("\n--- Model Response ---")
        print(response.text)
        return response.text

    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    text_prompt = "Write a descriptive caption for this image and suggest a flavor profile."
    load_image_from_url(text_prompt)
```




