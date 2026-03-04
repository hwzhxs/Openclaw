import hashlib, hmac, datetime, json, urllib.request, time, os

ak = "[REDACTED]"
sk = "[REDACTED]"
host = "visual.volcengineapi.com"
region = "cn-north-1"
service = "cv"

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
        print(f"HTTP {e.code}: {body[:300]}")
        return None

prompt = "Cyberpunk command center panorama, dark background, four holographic workstations connected by glowing data streams, neural network visualization in the sky, deep purple and blue neon lighting, futuristic city skyline silhouette, cinematic wide shot, atmospheric fog, 8k quality"
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
                p = r"C:\Users\azureuser\shared\assets\squad-images\hero-bg.png"
                with open(p, "wb") as f:
                    f.write(data)
                print(f"Saved hero: {len(data)//1024}KB")
                break
    else:
        print("timeout")
else:
    print(f"Failed: {result}")
