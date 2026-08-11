
# Text-to-Image Generation with Gemini on Vertex AI


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

PROJECT_ID = "your-project-id"
LOCATION = "us-central1"

vertexai.init(project=PROJECT_ID, location=LOCATION)

def get_chat_response(prompt):
    model = GenerativeModel("gemini-2.5-flash")
    response = model.generate_content(prompt)
    return response.text

if __name__ == "__main__":
    prompts = [
        "Hello! What are all the colors in a rainbow?",
        "What is Prism?"
    ]

    for question in prompts:
        print(f"User: {question}")
        try:
            answer = get_chat_response(question)
            print(f"Model: {answer}\n")
        except Exception as e:
            print(f"Error: {e}")
```




