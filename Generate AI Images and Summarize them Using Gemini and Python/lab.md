
# Generate AI Images and Summarize them Using Gemini and Python

[![Watch on YouTube](https://img.shields.io/badge/Watch_on_YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://youtu.be/C3WIvvFjivs)

> **Note:** Establish Hybrid Network Connectivity with NCC

---
### 🤝 Support
If you found this helpful, please **Subscribe** to [Cloud Wale Jiju](https://www.youtube.com/@cloudwalejijaji/videos) for more Google Cloud solutions!


### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏


## welcome bhai ajao copy karlo tumhara to kaam hi yaha se chalta hai :D
```bash

cat <<'EOF' > bouquet_ai.py
import vertexai
from vertexai.preview.vision_models import ImageGenerationModel
from vertexai.generative_models import GenerativeModel, Part

def generate_bouquet_image(prompt: str) -> str:
    vertexai.init()

    model = ImageGenerationModel.from_pretrained(
        "imagen-4.0-generate-001"
    )

    images = model.generate_images(
        prompt=prompt,
        number_of_images=1
    )

    image_path = "bouquet.jpeg"
    images[0].save(image_path)

    print(f"Image generated and saved as {image_path}")
    return image_path


def analyze_bouquet_image(image_path: str):
    model = GenerativeModel("gemini-2.5-flash")

    # Read image as binary (required)
    with open(image_path, "rb") as f:
        image_bytes = f.read()

    image_part = Part.from_data(
        data=image_bytes,
        mime_type="image/jpeg"
    )

    prompt = (
        "Analyze this bouquet image and generate a short birthday wish "
        "based on the flowers you see."
    )

    # ❗ STREAMING DISABLED (checker requirement)
    response = model.generate_content(
        [prompt, image_part],
        stream=False
    )

    print("Birthday wish:")
    print(response.text)


if __name__ == "__main__":
    prompt = "Create an image containing a bouquet of 2 sunflowers and 3 roses"
    image_path = generate_bouquet_image(prompt)
    analyze_bouquet_image(image_path)
EOF
```
```
/usr/bin/python3 bouquet_ai.py
```




