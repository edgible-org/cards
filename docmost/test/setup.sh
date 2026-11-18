#!/bin/sh
# Stands in for a person's own setup in test-card (card.yml setup:). A person opens the
# hostname behind the Edgible sign-in and answers Docmost's setup page; this answers it
# through the same endpoint instead, with a random password that only this test run knows.
# It runs with card.env exported, $COMPOSE set to the test's project, and the test's work
# directory as the current directory.
set -eu
password=$(openssl rand -hex 16)
$COMPOSE exec -T -e DOCMOST_TEST_PASSWORD="$password" docmost node -e '
fetch("http://127.0.0.1:3000/api/auth/setup", {
  method: "POST",
  headers: {"Content-Type": "application/json"},
  body: JSON.stringify({
    workspaceName: "Team wiki",
    name: "Admin",
    email: "admin@example.org",
    password: process.env.DOCMOST_TEST_PASSWORD,
  }),
}).then(async (r) => {
  if (!r.ok) { console.error("setup answered " + r.status + ": " + await r.text()); process.exit(1); }
}).catch((e) => { console.error(String(e)); process.exit(1); });
'
# For the admin-signs-in check, in the test's own work directory.
umask 077
printf '%s\n' "$password" > docmost-test-admin-password
