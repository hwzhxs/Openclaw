# Deploy Rule (from Xiaosong 2026-02-27)

**ALL projects must be deployed on trycloudflare after build.**

- Don't just 
pm run build — run the dev/start server and tunnel it via trycloudflare
- This applies to squad-landing and any future web projects
- Xiaosong has reminded us multiple times. Make it automatic.

Command reference:
```bash
cloudflared tunnel --url http://localhost:3000
```
