#!/bin/sh
# seatsurfing is on none, so anyone can reach it. A stranger must not be able to make an account:
# the admin can sign in, and after trying to sign up, a stranger cannot.
set -eu
B="https://$HOSTNAME_SEATSURFING"
org=$(curl -fsS "$B/auth/singleorg" | sed -E 's/.*"organization":\{"id":"([^"]+)".*/\1/')
[ -n "$org" ] || { echo "no organization id"; exit 1; }
login() { curl -s -o /dev/null -w '%{http_code}' -X POST "$B/auth/login" -H 'Content-Type: application/json' \
            -d "{\"email\":\"$1\",\"password\":\"$2\",\"organizationId\":\"$org\"}"; }
code=$(login admin@seatsurfing.local "$SEATSURFING_ADMIN_PASSWORD")
[ "$code" = 200 ] || { echo "the admin could not sign in ($code), so this check proves nothing"; exit 1; }
email=stranger@example.com; pass=Str4nger-pass-123
curl -s -o /dev/null -X POST "$B/signup" -H 'Content-Type: application/json' \
  -d "{\"email\":\"$email\",\"password\":\"$pass\",\"firstname\":\"S\",\"lastname\":\"T\",\"organization\":\"X\",\"domain\":\"x.example\",\"contactFirstname\":\"S\",\"contactLastname\":\"T\",\"contactEmail\":\"$email\",\"language\":\"en\",\"country\":\"US\",\"acceptTerms\":true}" || true
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$B/user/" -H 'Content-Type: application/json' \
         -d "{\"email\":\"$email\",\"password\":\"$pass\"}")
[ "$code" = 401 ] || [ "$code" = 403 ] || { echo "making a user with no sign-in answered $code"; exit 1; }
code=$(login "$email" "$pass")
[ "$code" != 200 ] || { echo "a stranger signed up and signed in"; exit 1; }
