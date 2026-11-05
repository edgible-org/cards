# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# rybbit-analytics serves the tracking script, and nothing of the dashboard's API or sign-in.
set -eu
B="https://$HOSTNAME_RYBBIT_ANALYTICS"
curl -fsS "$B/api/script.js" | grep -q .
for p in /api/auth/get-session /api/health /api/sites; do
  code=$(curl -s -o /dev/null -w '%{http_code}' "$B$p")
  [ "$code" = 404 ] || { echo "$p answered $code on the tracking hostname"; exit 1; }
done
