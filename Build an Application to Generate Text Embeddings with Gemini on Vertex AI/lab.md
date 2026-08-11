
# Build an Application to Generate Text Embeddings with Gemini on Vertex AI


[![Watch on YouTube](https://img.shields.io/badge/Watch_on_YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://youtu.be/C3WIvvFjivs)

> **Note:** Establish Hybrid Network Connectivity with NCC

---
### 🤝 Support
If you found this helpful, please **Subscribe** to [Cloud Wale Jiju](https://www.youtube.com/@cloudwalejijaji/videos) for more Google Cloud solutions!


### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏


### Update region too
```bash
import vertexai
from vertexai.language_models import TextEmbeddingModel

def text_embedding(prompt):
    vertexai.init(project="YOUR_PROJECT_ID", location="us-central1")
    model = TextEmbeddingModel.from_pretrained("text-embedding-005")
    embeddings = model.get_embeddings([prompt])
    vector = embeddings[0].values
    print(f"Length of embedding vector: {len(vector)}")
    return vector

if __name__ == "__main__":
    sample_text = "Natural language processing enables computers to understand human language."
    print(f"Processing text: '{sample_text}'")
    text_embedding(sample_text)
```




