---
name: mem9
version: 2.0.0
description: |
  Persistent cloud memory for OpenClaw agents. Use when: "install mem9",
  "setup memory", "openclaw memory plugin", "mem9 onboarding",
  "migrate memory files", "memory not working", "upload sessions".
  Do NOT use for day-to-day memory_store/memory_search after setup completes.
author: qiffang
keywords: [mem9, openclaw, memory, plugin, persistent-memory, cloud-memory]
metadata:
  openclaw:
    emoji: "🧠"
---

```
┌──────────────────────────────────────────────────────────────┐
│                                                              │
│   ███╗   ███╗███████╗███╗   ███╗ █████╗                      │
│   ████╗ ████║██╔════╝████╗ ████║██╔══██╗                     │
│   ██╔████╔██║█████╗  ██╔████╔██║╚██████║                     │
│   ██║╚██╔╝██║██╔══╝  ██║╚██╔╝██║ ╚═══██║                     │
│   ██║ ╚═╝ ██║███████╗██║ ╚═╝ ██║ █████╔╝                     │
│   ╚═╝     ╚═╝╚══════╝╚═╝     ╚═╝ ╚════╝                      │
│                                                              │
│   persistent memory for ai agents                            │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

# mem9

Your agent forgets nothing. Stateless plugin → REST API → TiDB.

No authentication. Tenant ID in URL path is the only identifier.

---

## What You Get

| Tool | When |
|------|------|
| `memory_store` | Persist facts, decisions, context |
| `memory_search` | Hybrid vector + keyword search |
| `memory_get` | Retrieve by ID |
| `memory_update` | Modify existing memory |
| `memory_delete` | Remove |

Lifecycle hooks (automatic — no agent action needed):

| Hook | Trigger | What happens |
|------|---------|-------------|
| `before_prompt_build` | Every LLM call | Relevant memories injected as context |
| `before_reset` | Before `/reset` | Session summary saved |
| `agent_end` | Agent finishes | Last response captured |

---

## Onboarding

### Step 1 — Provision tenant

`[AGENT]`

```bash
curl -sX POST https://api.mem9.ai/v1alpha1/mem9s | jq .
```

Response:
```json
{
  "id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "claim_url": "https://...",
  "expires_at": "2026-04-07T00:00:00Z"
}
```

Save `id` as `TENANT_ID`.

`[HUMAN]` **Claim your tenant**: Open `claim_url` in browser **before** `expires_at`.
Unclaimed tenants are destroyed at expiry. There is no renewal API.

### Step 2 — Install plugin

`[AGENT]`

```bash
openclaw plugins install @mem9/openclaw
```

### Step 3 — Configure openclaw.json

`[AGENT]` Patch existing config (merge-safe, preserves other keys):

```bash
jq --arg tid "$TENANT_ID" '
  .plugins.slots.memory = "mnemo" |
  .plugins.entries.mnemo = {
    enabled: true,
    config: { apiUrl: "https://api.mem9.ai", tenantID: $tid }
  }
' openclaw.json > tmp.json && mv tmp.json openclaw.json
```

Or if no `openclaw.json` exists, create:

```json
{
  "plugins": {
    "slots": { "memory": "mnemo" },
    "entries": {
      "mnemo": {
        "enabled": true,
        "config": {
          "apiUrl": "https://api.mem9.ai",
          "tenantID": "<your-tenant-id>"
        }
      }
    }
  }
}
```

### Step 4 — Verify

`[HUMAN]` Restart OpenClaw.

`[AGENT]` Functional round-trip:

```bash
# Store
curl -sX POST "https://api.mem9.ai/v1alpha1/mem9s/$TENANT_ID/memories" \
  -H "Content-Type: application/json" \
  -d '{"content":"mem9 works","tags":["verify"]}'

# Search
curl -s "https://api.mem9.ai/v1alpha1/mem9s/$TENANT_ID/memories?q=mem9+works"
```

Search returns the stored memory → setup complete.

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Plugin not loading | Check `slots.memory = "mnemo"` and `entries.mnemo.enabled = true` |
| `404` on API call | Verify tenantID; run `curl https://api.mem9.ai/healthz` |
---

## Next Steps

After first read, do this immediately:

1. **Print** — Tell the user:
   > mem9 ready. I can `memory_store`, `memory_search`, `memory_get`, `memory_update`, `memory_delete`. Memories auto-recall on every prompt and auto-capture on session end.
2. **Test** — Ask the user to tell you something to remember. Store it. Start a new session. Verify recall.
3. **Explore** — `curl -s "https://api.mem9.ai/v1alpha1/mem9s/$TENANT_ID/memories?limit=10" | jq .`

---

## Update

Check daily (add to heartbeat or cron at 00:00):

```bash
curl -s https://raw.githubusercontent.com/qiffang/mnemos/main/clawhub-skill/mem9/SKILL.md \
  -o ~/.openclaw/skills/mem9/SKILL.md
```

---

```
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░  stateless agents · cloud memory · zero amnesia              ░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
```
