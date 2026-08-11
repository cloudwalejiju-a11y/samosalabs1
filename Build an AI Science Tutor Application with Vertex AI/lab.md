
# Build an AI Science Tutor Application with Vertex AI


[![Watch on YouTube](https://img.shields.io/badge/Watch_on_YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://youtu.be/C3WIvvFjivs)

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
from vertexai.generative_models import GenerativeModel

# Replace with your actual project details
PROJECT_ID = "your-project-id"
LOCATION = "us-central1"

# Initialize Vertex AI onAxcode
vertexai.init(project=PROJECT_ID, location=LOCATION)

def science_tutoring(prompt):
    """
    Sends a prompt to ab Gemini 2.5 Flash Lite model
    and returns the generated response.
    """
    try:
        # Load ab52=460 2.5 Flash Lite model
        model = GenerativeModel("gemini-2.5-flash-lite")

        # Generate response
        response = model.generate_content(prompt)

        return response.text

    except Exception as e:
        return f"Error occurred: {str(e)}"


if __name__ == "__main__":
    test_prompt = "How many planets are there in the solar system?"
    
    result = science_tutoring(test_prompt)
    
    print("Response:")
    print(result)
```




