# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# A collection can be made, filled and searched through the dashboard hostname (org would
# normally stop a script, so this talks to the port on this machine), and the port listens on
# 127.0.0.1 only.
set -eu
B="http://127.0.0.1:${QDRANT_PORT:-6333}"; H='Content-Type: application/json'
curl -fsS -X PUT "$B/collections/card_test" -H "$H" -d '{"vectors":{"size":4,"distance":"Cosine"}}' | grep -q true
curl -fsS -X PUT "$B/collections/card_test/points?wait=true" -H "$H" \
  -d '{"points":[{"id":1,"vector":[0.1,0.2,0.3,0.4],"payload":{"n":"a"}},{"id":2,"vector":[0.9,0.1,0.1,0.1],"payload":{"n":"b"}}]}' | grep -q completed
curl -fsS -X POST "$B/collections/card_test/points/search" -H "$H" -d '{"vector":[0.1,0.2,0.3,0.4],"limit":1}' | grep -q '"id":1'
curl -fsS -X DELETE "$B/collections/card_test" | grep -q true
curl -fsS "$B/dashboard/" | grep -qi qdrant
