# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# The API (org and api-key would normally stop a script, so this talks to the port on this
# machine) is up, lists voices, and speaks a short sentence into audio.
set -eu
B="http://127.0.0.1:${KOKORO_FASTAPI_PORT:-8880}"
curl -fsS "$B/health" >/dev/null
curl -fsS "$B/v1/audio/voices" | grep -q 'voices'
curl -fsS -X POST "$B/v1/audio/speech" -H 'Content-Type: application/json' \
  -d '{"model":"kokoro","input":"Hello from Edgible.","voice":"af_heart","response_format":"mp3"}' \
  -o /tmp/kokoro-test.mp3
[ "$(wc -c < /tmp/kokoro-test.mp3)" -gt 1000 ]
