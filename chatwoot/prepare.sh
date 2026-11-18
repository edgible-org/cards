#!/bin/sh
# Prepare for the chatwoot card: make the account and its admin before Chatwoot is public.
# Sign-up is closed in the Compose file (ENABLE_ACCOUNT_SIGNUP=false), so this is the only way in.
# Run it after Start and before Publish, from the directory that holds chatwoot/:
#   sh chatwoot/prepare.sh
set -eu
cd "$(dirname "$0")"
set -a; . ./card.env; set +a
COMPOSE=${COMPOSE:-docker compose --env-file card.env -f docker-compose.yml}

# Chatwoot reads its database password and app secret only from the environment, so the script
# runs through the secrets loader, as the service does. The loader also sets the admin's password,
# the human secret chatwoot-secrets made on this machine.
$COMPOSE exec -T -e CHATWOOT_ADMIN_EMAIL="$CHATWOOT_ADMIN_EMAIL" -e CHATWOOT_ACCOUNT_NAME="${CHATWOOT_ACCOUNT_NAME:-Support}" \
  chatwoot sh /run/card-secrets/.load sh -c \
  'export POSTGRES_PASSWORD="$CHATWOOT_DB_PASSWORD" SECRET_KEY_BASE="$CHATWOOT_SECRET_KEY_BASE" && exec bundle exec rails runner -' <<'RUBY'
email = ENV.fetch("CHATWOOT_ADMIN_EMAIL")
unless User.exists?(email: email)
  account = Account.create!(name: ENV.fetch("CHATWOOT_ACCOUNT_NAME"))
  user = User.new(name: "Admin", email: email, password: ENV.fetch("CHATWOOT_ADMIN_PASSWORD"),
                  password_confirmation: ENV.fetch("CHATWOOT_ADMIN_PASSWORD"))
  user.skip_confirmation!
  user.save!
  AccountUser.create!(account_id: account.id, user_id: user.id, role: :administrator)
end
RUBY
echo "the account is made; the admin signs in with CHATWOOT_ADMIN_EMAIL and CHATWOOT_ADMIN_PASSWORD"
