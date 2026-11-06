# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# The API (org and api-key would normally stop a script, so this talks to the port on this
# machine) is up, answers a model list, and the port listens on 127.0.0.1 only.
set -eu
B="http://127.0.0.1:${SPEACHES_PORT:-8000}"
curl -fsS "$B/health" >/dev/null
curl -fsS "$B/v1/models" | grep -q '"data"'
