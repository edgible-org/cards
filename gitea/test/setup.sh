#!/bin/sh
# Stands in for a person's own setup in test-card (card.yml setup:). A person opens the gitea
# hostname behind the Edgible sign-in, where a new Gitea shows its install page with the database
# filled in, makes the admin under Administrator Account Settings and installs; this submits the
# same form, as the page fills it, with an admin named gitadmin and a random password only this
# run knows. It runs with card.env exported, $COMPOSE set to the test's project, and the test's
# work directory as the current directory.
set -eu
password=$(openssl rand -hex 16)
B="http://127.0.0.1:$GITEA_PORT/"
dir=$(mktemp -d); trap 'rm -rf "$dir"' EXIT
curl -fsS -c "$dir/jar" "$B" -o "$dir/page.html"
grep -q '<title>Installation' "$dir/page.html" || { echo "Gitea did not show its install page"; exit 1; }
# Every field as the page fills it (an unticked box is left out, as a browser does), then the admin.
python3 - "$dir/page.html" "$password" > "$dir/form" <<'PY'
import html, re, sys, urllib.parse
page = open(sys.argv[1]).read()
form = page[page.find("<form"):page.find("</form>")]
fields = {}
for m in re.finditer(r"<input([^>]*)>", form):
    a = m.group(1)
    name = re.search(r'name="([^"]+)"', a)
    if not name:
        continue
    kind = re.search(r'type="([^"]+)"', a)
    if kind and kind.group(1) == "checkbox" and "checked" not in a:
        continue
    value = re.search(r'value="([^"]*)"', a)
    fields[name.group(1)] = html.unescape(value.group(1)) if value else ""
fields.update(admin_name="gitadmin", admin_email="gitadmin@example.com",
              admin_passwd=sys.argv[2], admin_confirm_passwd=sys.argv[2])
sys.stdout.write(urllib.parse.urlencode(fields))  # no newline: it would end the last field
PY
code=$(curl -s -b "$dir/jar" -o "$dir/answer.html" -w '%{http_code}' --data-binary @"$dir/form" \
  -H 'Content-Type: application/x-www-form-urlencoded' "$B")
[ "$code" = 200 ] || { echo "installing answered $code"; exit 1; }
# A refused form comes back as the install page with the reason in a flash message; an accepted
# one with Gitea's own "installing" page, also titled Installation, so look for the message.
if grep -q 'flash-error' "$dir/answer.html"; then
  echo "Gitea refused the install: $(grep -o 'flash-error[^<]*<[^>]*>[^<]*' "$dir/answer.html" | sed 's/.*>//')"; exit 1
fi
# For the admin-signs-in check, in the test's own work directory.
umask 077
printf '%s\n' "$password" > gitea-test-admin-password
