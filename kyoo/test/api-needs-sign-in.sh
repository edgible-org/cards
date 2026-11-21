# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# Kyoo's API turns away a caller with no account, on the device itself (the hostname is behind
# the Edgible sign-in, so the device is where a stranger would have to be).
set -eu
code=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$KYOO_PORT/api/shows")
case "$code" in 401|403) ;; *) echo "the API answered $code without an account"; exit 1;; esac
