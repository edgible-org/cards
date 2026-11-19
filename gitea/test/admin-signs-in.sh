# A check for test-card, run after Verify with card.env exported and HOSTNAME_<APP> set.
# After the setup, the admin test/setup.sh made in the install page signs in to the API over the
# public hostname, the install page is gone, and nobody can register.
set -eu
password=$(cat gitea-test-admin-password)
curl -fsS -u "gitadmin:$password" "https://$HOSTNAME_GITEA/api/v1/user" | grep -q '"is_admin":true'
curl -fsS "https://$HOSTNAME_GITEA/" | grep -q '<title>Installation' && { echo "the install page is still served"; exit 1; }
curl -fsS "https://$HOSTNAME_GITEA/user/sign_up" | grep -q 'Registration is disabled' || { echo "registration is not off"; exit 1; }
exit 0
