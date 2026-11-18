# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# passbolt is on none, so this asks the app on the machine: its health check says it is ready,
# and public registration is closed.
set -eu
B="http://127.0.0.1:$PASSBOLT_PORT"
curl -fsS "$B/healthcheck/status.json" | grep -q '"body":"OK"'
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST -H 'Content-Type: application/json' \
  -d '{"username":"nobody@example.org","profile":{"first_name":"A","last_name":"B"}}' "$B/users/register.json")
[ "$code" != 200 ] || { echo "public registration answered $code"; exit 1; }
