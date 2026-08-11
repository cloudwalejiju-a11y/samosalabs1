### Prepare Data for Looker Dashboards and Reports: Challenge Lab


[![Watch on YouTube](https://img.shields.io/badge/Watch_on_YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://youtu.be/AiUi-q6A-bc)



---
### 🤝 Support
If you found this helpful, please **Subscribe** to [Cloud Wale Jiju](https://www.youtube.com/@cloudwalejijaji/videos) for more Google Cloud solutions!


### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏

---
# Looks for Each Task

Look 1:-

```
explore: +airports {
     query: start_from_here{
      dimensions: [city, state]
      measures: [count]
      filters: [airports.facility_type: "HELIPORT^ ^ ^ ^ ^ ^ ^ "]
    } 
}

```

Look 2:-

```
explore: +airports {
    query: start_from_here{
      dimensions: [facility_type, state]
      measures: [count]
    }
  }


```

Look 3:-

```
explore: +flights {
    query: start_from_here{
      dimensions: [aircraft_origin.city, aircraft_origin.state]
      measures: [cancelled_count, count]
    }
}

```


