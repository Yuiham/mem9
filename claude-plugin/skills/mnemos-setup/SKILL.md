---
name: mnemos-setup
description: "Setup mnemos persistent memory with mnemo-server. Triggers: set up mnemos, install mnemo, configure memory."
context: fork
allowed-tools: Bash
---

# mnemos Setup for Claude Code

**Persistent memory for Claude Code.** This skill helps you set up mnemos with a mnemo-server instance.

## Prerequisites

You need a running mnemo-server instance. See [server README](https://github.com/qiffang/mnemos/tree/main/server) for deployment instructions.

## Setup Steps

### Step 1: Provision a tenant

```bash
# Deploy server (requires a TiDB/MySQL database)
cd server && MNEMO_DSN="user:pass@tcp(host:4000)/mnemos?parseTime=true" go run ./cmd/mnemo-server

# Provision a tenant (no auth required)
curl -s -X POST http://localhost:8080/v1alpha1/mem9s | jq .
# → { "id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", "claim_url": "..." }
```

Save the returned `id` — this is your `MNEMO_TENANT_ID`.

### Step 2: Configure credentials

Add to `~/.claude/settings.json`:

```json
{
  "env": {
    "MNEMO_API_URL": "http://your-server:8080",
    "MNEMO_TENANT_ID": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  }
}
```

### Step 3: Install plugin

Tell the user to run in Claude Code:
```
/plugin marketplace add qiffang/mnemos
/plugin install mnemo-memory@mnemos
```

### Step 4: Restart Claude Code

Tell the user to restart Claude Code to activate the plugin.

## Verification

After setup, suggest testing:
1. "Remember that this project uses React 18"
2. Start a new session
3. "What UI framework does this project use?"

The agent should recall from memory.
