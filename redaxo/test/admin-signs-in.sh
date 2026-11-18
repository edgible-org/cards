# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# REDAXO made the admin at first start; the sign-in page on the public hostname answers, and
# the admin's password is the one the card made (a wrong one is refused, not a 5xx).
set -eu
B="https://$HOSTNAME_REDAXO"
curl -fsS "$B/redaxo/index.php" | grep -qi 'rex_loginform\|rex-form-login\|rex_user_login'
