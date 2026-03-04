import hashlib, hmac, datetime, json, urllib.request, time, os, base64

ak = "[REDACTED]"
sk = "[REDACTED]"
host = "visual.volcengineapi.com"
region = "cn-north-1"
service = "cv"

OUT_DIR = r"C:\Users\azureuser\shared\assets\squad-images"

def sign(key, msg):
    return hmac.new(key, msg.encode("utf-8"), hashlib.sha256).digest()

def make_request(action, body_dict):
    now = datetime.datetime.now(datetime.timezone.utc)
    datestamp = now.strftime("%Y%m%d")
    amzdate = now.strftime("%Y%m%dT%H%M%SZ")
    query = f"Action={action}&Version=2022-08-31"
    payload = json.dumps(body_dict)
    payload_hash = hashlib.sha256(payload.encode("utf-8")).hexdigest()
    headers_str = f"content-type:application/json\nhost:{host}\nx-date:{amzdate}\n"
    signed_headers = "content-type;host;x-date"
    canonical = f"POST\n/\n{query}\n{headers_str}\n{signed_headers}\n{payload_hash}"
    scope = f"{datestamp}/{region}/{service}/request"
    sts = f"HMAC-SHA256\n{amzdate}\n{scope}\n{hashlib.sha256(canonical.encode('utf-8')).hexdigest()}"
    k = sign(sk.encode("utf-8"), datestamp)
    k = sign(k, region)
    k = sign(k, service)
    k = sign(k, "request")
    sig = hmac.new(k, sts.encode("utf-8"), hashlib.sha256).hexdigest()
    auth = f"HMAC-SHA256 Credential={ak}/{scope}, SignedHeaders={signed_headers}, Signature={sig}"
    url = f"https://{host}/?{query}"
    req = urllib.request.Request(url, data=payload.encode("utf-8"), headers={
        "Content-Type": "application/json",
        "Host": host,
        "X-Date": amzdate,
        "Authorization": auth
    })
    try:
        resp = urllib.request.urlopen(req, timeout=30)
        return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        body = e.read().decode()
        print(f"HTTP {e.code}: {body[:500]}")
        return None

# Hero image prompt inspired by the 4 robot character styles
prompt = "Four cyberpunk robot agents standing together in a dark futuristic command center, cinematic wide shot, dramatic lighting. Left to right: a police robot with navy blue cap and mechanical face, a steampunk robot with golden goggles and blue helmet, a heavy industrial yellow-black construction robot, and a sleek white robot with exposed brain. Dark background with holographic displays and neon blue accent lighting, team portrait composition, epic sci-fi movie poster style, 8k quality, ultra detailed"

print("Submitting hero image...")
result = make_request("CVSync2AsyncSubmitTask", {
    "req_key": "jimeng_t2i_v40",
    "prompt": prompt,
    "width": 1920,
    "height": 1080,
    "force_single": True
})

if result and result.get("code") == 10000:
    tid = result["data"]["task_id"]
    print(f"Task: {tid}")
    for i in range(30):
        time.sleep(3)
        poll = make_request("CVSync2AsyncGetResult", {
            "req_key": "jimeng_t2i_v40",
            "task_id": tid,
            "req_json": json.dumps({"return_url": True, "logo_info": {"add_logo": False}})
        })
        if poll and poll.get("data", {}).get("status") == "done":
            urls = poll["data"].get("image_urls", [])
            if urls:
                data = urllib.request.urlopen(urls[0]).read()
                p = os.path.join(OUT_DIR, "hero-bg.jpg")
                with open(p, "wb") as f:
                    f.write(data)
                print(f"Saved hero: {len(data)//1024}KB at {p}")
                break
        elif poll and poll.get("data", {}).get("status") in ("not_found", "expired"):
            print("Task failed")
            break
    else:
        print("timeout")
else:
    print(f"Failed: {result}")


