#!/bin/sh
# Stands in for a person's own setup in test-card (card.yml setup:). A person opens the
# hostname behind the Edgible sign-in and answers Wiki.js's setup page; this answers it
# through the same endpoint instead, with a random password that only this test run knows.
# It runs with card.env exported, $COMPOSE set to the test's project, HOSTNAME_WIKI_JS set,
# and the test's work directory as the current directory.
set -eu
password=$(openssl rand -hex 16)
$COMPOSE exec -T -e WIKI_JS_TEST_PASSWORD="$password" -e WIKI_JS_SITE_URL="https://$HOSTNAME_WIKI_JS" wiki-js node -e '
const B = "http://127.0.0.1:3000";
(async () => {
  const r = await fetch(B + "/finalize", {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify({
      adminEmail: "admin@example.org",
      adminPassword: process.env.WIKI_JS_TEST_PASSWORD,
      adminPasswordConfirm: process.env.WIKI_JS_TEST_PASSWORD,
      siteUrl: process.env.WIKI_JS_SITE_URL,
      telemetry: false,
    }),
  });
  const body = await r.text();
  if (!r.ok || body.includes("\"ok\":false")) { console.error("setup answered " + r.status + ": " + body); process.exit(1); }
})();
'
# For the admin-signs-in check, in the test's own work directory.
umask 077
printf '%s\n' "$password" > wiki-js-test-admin-password
