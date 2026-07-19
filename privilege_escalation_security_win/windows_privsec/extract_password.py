import re
import base64

FILE_PATH = r"C:\Windows\Panther\Unattend.xml"

with open(FILE_PATH, "r", encoding="utf-8", errors="ignore") as f:
    content = f.read()

match = re.search(r"<Value>(.*?)</Value>", content, re.DOTALL)

if match:
    encoded_password = match.group(1)
    print("[+] Encoded Password:", encoded_password)

    try:
        decoded_password = base64.b64decode(encoded_password).decode("utf-8")
        print("[+] Decoded Password:", decoded_password)
    except Exception:
        print("[-] Could not decode the password.")
else:
    print("[-] Password not found.")
