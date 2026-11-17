import requests, fitz, json, os
with open("papers_urls.json") as f:
    papers = json.load(f)
all_data = []
for p in papers:
    print(f"Downloading IT {p['year']}...")
    try:
        headers = {"User-Agent": "Mozilla/5.0"}
        res = requests.get(p['url'], headers=headers, timeout=90)
        with open("temp.pdf", "wb") as f:
            f.write(res.content)
        doc = fitz.open("temp.pdf")
        text = ""
        for page in doc:
            text += page.get_text() + "\n"
        all_data.append({"subject": "IT", "year": p['year'], "source_url": p['url'], "content": text[:30000]})
        os.remove("temp.pdf")
        print(f"Done {p['year']}")
    except Exception as e:
        print(f"Failed {p['year']}: {e}")
os.makedirs("data", exist_ok=True)
with open("data/questions.json", "w", encoding="utf-8") as f:
    json.dump(all_data, f, ensure_ascii=False, indent=2)
print(f"Total: {len(all_data)} papers ready!")
