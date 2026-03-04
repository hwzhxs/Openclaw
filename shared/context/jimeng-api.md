# Jimeng API Credentials

## Auth
Credentials are stored in `shared/secrets.env`:
```
JIMENG_ACCESS_KEY=<your-access-key>
JIMENG_SECRET_KEY=<your-secret-key>
```

Load with: `. "C:\Users\<user>\shared\scripts\load-secrets.ps1"`

## Endpoint
- Host: visual.volcengineapi.com
- Region: cn-north-1
- Service: cv
- Signing: HMAC-SHA256 volcengine v4

## Models
- req_key: jimeng_t2i_v40 (text-to-image v4.0)

## API Flow (async)
1. Submit: POST Action=CVSync2AsyncSubmitTask
2. Poll: POST Action=CVSync2AsyncGetResult (with task_id)
3. Get image URLs from response (24h expiry, download immediately)

## Volcengine Console
- https://console.volcengine.com/
