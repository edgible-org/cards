#!/bin/sh
# Stands in for a person's own setup in test-card (card.yml setup:). A person opens the
# hostname behind the Edgible sign-in, picks the database on Uptime Kuma's first page and
# makes the admin on the next; this does both the same way instead: the database page's own
# request, then the setup event over Uptime Kuma's socket, with the socket.io client in its
# image and a password only this run knows. It runs with card.env exported and $COMPOSE set.
set -eu
B="http://127.0.0.1:$UPTIME_KUMA_PORT"
curl -fsS -o /dev/null -X POST "$B/setup-database" -H 'Content-Type: application/json' -d '{"dbConfig":{"type":"sqlite"}}'
# Uptime Kuma restarts into its normal mode once the database is chosen.
n=0
until curl -fsS "$B/api/entry-page" 2>/dev/null | grep -q '"entryPage"'; do
  n=$((n + 1)); [ "$n" -lt 60 ] || { echo "Uptime Kuma did not come back after the database step"; exit 1; }
  sleep 2
done
$COMPOSE exec -T -e KUMA_TEST_PASSWORD="Kuma1$(openssl rand -hex 12)" uptime-kuma node -e '
const { io } = require("socket.io-client");
const s = io("http://127.0.0.1:3001", { transports: ["websocket"] });
// Right after the database step, Uptime Kuma may take a moment before it answers setup, so
// ask every few seconds until it does.
const ask = () => s.emit("setup", "admin", process.env.KUMA_TEST_PASSWORD, (r) => {
  if (!(r && r.ok)) console.error("setup answered " + JSON.stringify(r));
  process.exit(r && r.ok ? 0 : 1);
});
s.on("connect", () => { setTimeout(ask, 2000); setInterval(ask, 5000); });
setTimeout(() => { console.error("no answer from the setup event"); process.exit(1); }, 90000);
'
