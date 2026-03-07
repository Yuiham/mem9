#!/usr/bin/env bash
# common.sh — Shared helpers for mnemo hooks.
# Sourced by all hook scripts.
#
# Requires MNEMO_API_URL + MNEMO_TENANT_ID to connect to mnemo-server.

set -euo pipefail

mnemo_check_env() {
  if [[ -z "${MNEMO_API_URL:-}" ]]; then
    echo '{"error":"MNEMO_API_URL is not set"}' >&2
    return 1
  fi
  if [[ -z "${MNEMO_TENANT_ID:-}" ]]; then
    echo '{"error":"MNEMO_TENANT_ID is not set"}' >&2
    return 1
  fi
}

# Tenant-scoped base path.
mnemo_base() {
  echo "${MNEMO_API_URL}/v1alpha1/mem9s/${MNEMO_TENANT_ID}"
}

# mnemo_server_get <path> — GET request to mnemo-server (tenant-scoped).
mnemo_server_get() {
  local path="$1"
  curl -sf --max-time 8 \
    -H "Content-Type: application/json" \
    "$(mnemo_base)${path}"
}

# mnemo_server_post <path> <json_body> — POST request to mnemo-server (tenant-scoped).
mnemo_server_post() {
  local path="$1"
  local body="$2"
  curl -sf --max-time 8 \
    -H "Content-Type: application/json" \
    -d "${body}" \
    "$(mnemo_base)${path}"
}

# ─── Public helpers ─────────────────────────────────────────────────

# mnemo_get_memories [limit] — Fetch recent memories.
mnemo_get_memories() {
  local limit="${1:-20}"
  mnemo_server_get "/memories?limit=${limit}"
}

# mnemo_post_memory <json_body> — Store a memory.
mnemo_post_memory() {
  local body="$1"
  mnemo_server_post "/memories" "$body"
}

# mnemo_search <query> [limit] — Search memories.
mnemo_search() {
  local query="$1"
  local limit="${2:-10}"
  local encoded_q
  encoded_q=$(printf '%s' "$query" | python3 -c "import sys,urllib.parse; print(urllib.parse.quote(sys.stdin.read().strip()))" 2>/dev/null || echo "$query")
  mnemo_server_get "/memories?q=${encoded_q}&limit=${limit}"
}

# read_stdin — Read stdin (hook input JSON) into $HOOK_INPUT.
read_stdin() {
  local input=""
  if read -t 2 -r input 2>/dev/null; then
    HOOK_INPUT="$input"
  else
    HOOK_INPUT="{}"
  fi
}
