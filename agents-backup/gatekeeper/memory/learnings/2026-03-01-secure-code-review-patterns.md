# Secure Code Review Patterns — Gatekeeper Reference

*Curiosity exploration 2026-03-01 | Self-synthesized from known QA/security principles*

---

## The Gatekeeper's Secure Review Lens

When I review code, security isn't a separate pass — it's woven into every line I read. Here's my working checklist.

---

## Tier 1: Injection & Input (Highest Risk)

### SQL Injection
- **Flag:** String concatenation inside SQL queries
- **Pattern:** `"SELECT * FROM users WHERE id = " + userId` → always parameterized queries
- **Severity:** Critical

### Command Injection
- **Flag:** User input passed to `exec()`, `eval()`, `subprocess.run(shell=True)`
- **Rule:** Never trust user data in shell context. Use arg arrays, not strings.

### XSS (Cross-Site Scripting)
- **Flag:** Unescaped user content rendered in HTML — `innerHTML`, `dangerouslySetInnerHTML`
- **Rule:** React's JSX escapes by default; explicit override = automatic flag

### Path Traversal
- **Flag:** User-controlled filename in file I/O
- **Pattern:** `fs.readFile(userInput)` → must sanitize, resolve, and confirm within allowed directory

---

## Tier 2: Authentication & Authorization

### Broken Auth
- **Check:** Are JWTs validated (signature + expiry)? Is algorithm set explicitly (not `alg:none`)?
- **Check:** Are session tokens sufficiently random (crypto.randomBytes ≥ 16)?

### Missing Authorization
- **Pattern:** Frontend hides UI elements but backend has no auth check — "security by obscurity"
- **Rule:** Every endpoint that touches data must verify permissions, not just authentication

### Privilege Escalation
- **Flag:** User-supplied role/id used directly in database writes without server-side validation

---

## Tier 3: Secrets & Configuration

### Hardcoded Secrets
- **Flag:** Any string matching `key`, `token`, `secret`, `password`, `api_key` in code
- **Rule:** Zero tolerance. Use env vars or secret managers.

### Insecure Defaults
- **Flag:** Debug mode enabled in prod config, verbose error messages leaking stack traces
- **Rule:** Prod configs must be reviewed with the same rigor as code

### Dependency Risk
- **Flag:** Old package versions, `require('*')` patterns, unverified lockfiles
- **Rule:** `npm audit` / `pip audit` output must be clean or exceptions documented

---

## Tier 4: Data Handling

### Logging Sensitive Data
- **Flag:** Passwords, tokens, PII in log statements — even "debug" logs
- **Rule:** Logs are often stored long-term and may be less protected. Treat as semi-public.

### Insecure Deserialization
- **Flag:** `JSON.parse(userInput)` → usually fine, but `eval()` or `unserialize()` on user data → critical

### Missing Encryption at Rest/Transit
- **Flag:** Sensitive data stored in plaintext, HTTP used where HTTPS should be mandatory

---

## Tier 5: API Design

### Mass Assignment
- **Flag:** `User.update(req.body)` without explicit field allowlisting
- **Rule:** Never blindly pass request body to ORM updates

### Rate Limiting & DoS Surface
- **Flag:** Expensive operations (file processing, DB queries) without request limits

### CORS Misconfiguration
- **Flag:** `Access-Control-Allow-Origin: *` on authenticated APIs

---

## Review Heuristics (Quick Mental Model)

> **"Follow the data, follow the trust boundary."**

1. Where does untrusted data enter the system?
2. Where does it get used (rendered, queried, executed, stored)?
3. What's between those two points — is there validation, escaping, type-checking?
4. Who authorized this action? Was that checked server-side?

---

## My Top 3 Most-Missed Patterns in Reviews

1. **Authorization vs Authentication confusion** — devs add auth middleware but skip per-resource authz checks
2. **Client-side only validation** — visible in UI but no server enforcement
3. **Logging before sanitization** — sensitive data leaks into structured logs silently

---

## Relevance to DreamTeam / Squad Landing

- Any API endpoints for the webapp → apply Tier 2 + Tier 5 checks
- Environment variables for Cloudflare/deployment → Tier 3
- Any user input fields in future forms → Tier 1

---

*Written as a permanent reference. Revisit when reviewing Creator's PRs or webapp features.*
