# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# onedev is on none, so this goes through the public hostname: a wrong password is refused,
# and the admin OneDev made at first start signs in to the API with the password the card made.
set -eu
B="https://$HOSTNAME_ONEDEV/~api/users"
code=$(curl -sS -o /dev/null -w '%{http_code}' -u "admin:wrong-$ONEDEV_ADMIN_PASSWORD" "$B?offset=0&count=100")
[ "$code" = 401 ] || [ "$code" = 403 ] || { echo "a wrong password answered $code"; exit 1; }
body=$(curl -sS -u "admin:$ONEDEV_ADMIN_PASSWORD" "$B?offset=0&count=100") || { echo "the API did not answer"; exit 1; }
echo "$body" | grep -Eq '"name" *: *"admin"' || { echo "the admin could not read its own user: $(echo "$body" | head -c 200)"; exit 1; }
# It is public, so nobody may sign themselves up or read it without an account.
settings=$(curl -sS -u "admin:$ONEDEV_ADMIN_PASSWORD" "https://$HOSTNAME_ONEDEV/~api/settings/security") || { echo "the settings did not answer"; exit 1; }
echo "$settings" | grep -Eq '"enableSelfRegister" *: *false' || { echo "self-registration is not off: $(echo "$settings" | head -c 300)"; exit 1; }
echo "$settings" | grep -Eq '"enableAnonymousAccess" *: *false' || { echo "anonymous access is not off: $(echo "$settings" | head -c 300)"; exit 1; }
