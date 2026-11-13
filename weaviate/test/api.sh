# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# A collection can be made, filled and searched by vector (the published hostname is api-key,
# which would stop a script, so this talks to the port on this machine).
set -eu
B="http://127.0.0.1:${WEAVIATE_PORT:-8080}"; H='Content-Type: application/json'
curl -fsS -X POST "$B/v1/schema" -H "$H" -d '{"class":"CardTest","vectorizer":"none"}' | grep -q CardTest
curl -fsS -X POST "$B/v1/batch/objects" -H "$H" -d '{"objects":[
 {"class":"CardTest","properties":{"n":"a"},"vector":[0.1,0.2,0.3,0.4]},
 {"class":"CardTest","properties":{"n":"b"},"vector":[0.9,0.1,0.1,0.1]}]}' | grep -q SUCCESS
curl -fsS -X POST "$B/v1/graphql" -H "$H" \
  -d '{"query":"{ Get { CardTest(nearVector:{vector:[0.1,0.2,0.3,0.4]}, limit:1){ n } } }"}' | grep -q '"n":"a"'
curl -fsS -X DELETE "$B/v1/schema/CardTest"
