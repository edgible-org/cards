#!/bin/sh
# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# A note can be written and found by search, and the MCP endpoint answers. Both hostnames are
# gated by Edgible, which would stop a script, so this talks to the port on this machine.
set -eu
B="http://127.0.0.1:${NOTEDISCOVERY_PORT:-8000}"; H='Content-Type: application/json'
curl -fsS -X POST "$B/api/notes/card-test.md" -H "$H" -d '{"content":"# Onboarding\nzebrafinch handbook"}' | grep -q '"success"'
curl -fsS "$B/api/search?q=zebrafinch" | grep -q card-test
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$B/mcp" -H "$H" -H 'Accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}')
[ "$code" = 200 ] || { echo "/mcp answered $code"; exit 1; }
curl -fsS -X DELETE "$B/api/notes/card-test.md" >/dev/null
