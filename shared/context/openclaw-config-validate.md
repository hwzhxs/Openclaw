# openclaw config validate (2026-03-03)

**Rule: Always validate before restart.**

After editing any `openclaw.json`, run:
```
openclaw config validate
```

For non-default agent instances, set config path first:
```
set OPENCLAW_CONFIG_PATH=C:\Users\azureuser\.openclaw-agent2\openclaw.json
openclaw config validate
```

Checks for typos, invalid fields, bad formats BEFORE gateway restart. No more silent config errors.

Available since v2026.3.2.
