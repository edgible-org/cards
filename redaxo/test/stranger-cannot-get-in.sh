#!/bin/sh
# redaxo is public: its setup must not be open to a stranger, and the backend must ask for a login.
set -eu
B="https://$HOSTNAME_REDAXO"
page=$(curl -sL "$B/redaxo/index.php?page=setup")
echo "$page" | grep -qi 'rex_user_login' || { echo "the setup page did not ask for a login"; exit 1; }
if curl -sL "$B/redaxo/index.php?page=users/users" | grep -qi 'rex-page-users'; then echo "the user admin answered with no sign-in"; exit 1; fi
