import requests

url = "https://ramayana.hindbiswas.com/api/sarga/1?with_shloka=1"

response = requests.get(url)

print("Status:", response.status_code)

print(response.text[:500])
