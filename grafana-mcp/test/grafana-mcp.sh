# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# An MCP client's whole path through Edgible: with a fresh Edgible API key it opens a
# session over Streamable HTTP and lists the tools. The server is read-only by default, so
# Grafana's search tools must be there and its write tools must not. A wrong key is refused.
# It needs no Grafana: listing tools does not reach one. The key is deleted afterwards.
set -eu
B="https://$HOSTNAME_GRAFANA_MCP/mcp"
app=${HOSTNAME_GRAFANA_MCP%%.*}
tmp=$(mktemp -d)
key_id=
cleanup() {
  [ -z "$key_id" ] || edgible app api-keys delete --app "$app" --key-id "$key_id" --yes >/dev/null 2>&1 || true
  rm -rf "$tmp"
}
trap cleanup EXIT
edgible -o json app api-keys create --app "$app" --name grafana-mcp-test \
  --expires "$(date -u -v+1d +%F 2>/dev/null || date -u -d tomorrow +%F)" 2>/dev/null > "$tmp/key.json"
key_id=$(jq -er .keyData.id "$tmp/key.json")
jq -er .apiKey "$tmp/key.json" > "$tmp/key"

# POST one JSON-RPC message; the answer may be JSON or a server-sent event stream.
rpc() {
  curl -sS -D "$tmp/headers" -o "$tmp/body" -w '%{http_code}' "$B" \
    -H "Authorization: Bearer $(cat "$tmp/key")" \
    -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' \
    ${session:+-H "Mcp-Session-Id: $session"} --data "$1"
}
answer() { sed -n 's/^data: //p' "$tmp/body" | grep . || cat "$tmp/body"; }

code=$(curl -sS -o /dev/null -w '%{http_code}' "$B" -H 'Authorization: Bearer wrong-key' \
  -H 'Content-Type: application/json' --data '{}')
[ "$code" = 401 ] || { echo "a wrong key answered $code"; exit 1; }

session=
code=$(rpc '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"grafana-mcp-test","version":"1"}}}')
[ "$code" = 200 ] || { echo "initialize answered $code"; exit 1; }
answer | jq -e '.result.serverInfo.name' >/dev/null || { echo "initialize gave no serverInfo"; exit 1; }
session=$(sed -n 's/^[Mm]cp-[Ss]ession-[Ii]d: *\([^[:space:]]*\).*/\1/p' "$tmp/headers")

rpc '{"jsonrpc":"2.0","method":"notifications/initialized"}' >/dev/null

code=$(rpc '{"jsonrpc":"2.0","id":2,"method":"tools/list"}')
[ "$code" = 200 ] || { echo "tools/list answered $code"; exit 1; }
answer | jq -e '.result.tools | map(.name) | index("search_dashboards")' >/dev/null || { echo "no search_dashboards tool listed"; exit 1; }
answer | jq -e '.result.tools | map(.name) | index("update_dashboard") | not' >/dev/null || { echo "a write tool is listed in read-only mode"; exit 1; }
