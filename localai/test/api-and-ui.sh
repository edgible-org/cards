# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# The API lists models and the web UI answers, through the port on this machine (org and
# api-key would normally stop a script), and the port listens on 127.0.0.1 only.
set -eu
B="http://127.0.0.1:${LOCALAI_PORT:-8080}"
curl -fsS "$B/v1/models" | grep -q '"object"'
curl -fsS "$B/readyz" >/dev/null
curl -fsSL "$B/" | grep -qi localai
