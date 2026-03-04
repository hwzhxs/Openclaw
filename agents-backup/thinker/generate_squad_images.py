import hashlib, hmac, datetime, json, urllib.request, time, os, base64

ak = "[REDACTED]"
sk = "[REDACTED]"
host = "visual.volcengineapi.com"
region = "cn-north-1"
service = "cv"

OUT_DIR = r"C:\Users\azureuser\shared\assets\squad-images"
os.makedirs(OUT_DIR, exist_ok=True)

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

def generate_image(prompt, filename, width=1024, height=1024):
    print(f"\n=== Generating: {filename} ===")
    print(f"Prompt: {prompt[:80]}...")
    
    result = make_request("CVSync2AsyncSubmitTask", {
        "req_key": "jimeng_t2i_v40",
        "prompt": prompt,
        "width": width,
        "height": height,
        "force_single": True
    })
    
    if not result or result.get("code") != 10000:
        print(f"Submit failed: {result}")
        return None
    
    task_id = result["data"]["task_id"]
    print(f"Task ID: {task_id}")
    
    for i in range(30):
        time.sleep(3)
        poll = make_request("CVSync2AsyncGetResult", {
            "req_key": "jimeng_t2i_v40",
            "task_id": task_id,
            "req_json": json.dumps({"return_url": True, "logo_info": {"add_logo": False}})
        })
        if poll and poll.get("data", {}).get("status") == "done" and poll.get("code") == 10000:
            urls = poll["data"].get("image_urls", [])
            if urls:
                print(f"Done! Downloading...")
                img_data = urllib.request.urlopen(urls[0]).read()
                path = os.path.join(OUT_DIR, filename)
                with open(path, "wb") as f:
                    f.write(img_data)
                print(f"Saved: {path} ({len(img_data)//1024}KB)")
                return path
        elif poll and poll.get("data", {}).get("status") in ("not_found", "expired"):
            print("Task failed")
            return None
    print("Timed out")
    return None

# Style prefix for consistency
STYLE = "Cyberpunk robot portrait, dark background #0a0a0a, cinematic lighting, high detail, metallic surface with glowing accents, digital art, 8k quality"

prompts = [
    ("admin-popo.png", f"{STYLE}, a commanding robot leader with bronze and gold armor plating, police-style tactical visor glowing amber, confident stance, shoulder-mounted communication array with holographic displays, warm bronze LED accents throughout the body, military commander aesthetic", 1024, 1024),
    ("thinker-kanye.png", f"{STYLE}, an intellectual robot analyst with translucent cranium revealing glowing blue neural circuits and data streams, contemplative pose with hand near chin, slate blue and silver color scheme, multiple holographic data screens floating around head, researcher aesthetic", 1024, 1024),
    ("gatekeeper-rocky.png", f"{STYLE}, a guardian robot sentinel with heavy sage green armor plating, amber energy shield projected from forearm, stern vigilant expression, scanning visor with amber HUD overlay, defensive posture, quality inspector aesthetic with checkmark symbols etched into armor", 1024, 1024),
    ("creator-tyler.png", f"{STYLE}, a creative builder robot with sleek mauve and purple chassis, multiple articulated tool-arms with welding torch and precision instruments, artistic paint splatters of neon colors on armor, workshop goggles pushed up on forehead, maker aesthetic", 1024, 1024),
    ("hero-bg.png", f"Cyberpunk command center panorama, dark background, four holographic workstations connected by glowing data streams, neural network visualization in the sky, deep purple and blue neon lighting, futuristic city skyline silhouette, cinematic wide shot, atmospheric fog, 8k quality", 1920, 1080),
]

results = {}
for filename, prompt, w, h in prompts:
    path = generate_image(prompt, filename, w, h)
    results[filename] = path

print("\n=== RESULTS ===")
for name, path in results.items():
    status = "✅" if path else "❌"
    print(f"{status} {name}: {path or 'FAILED'}")
