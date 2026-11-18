#!/bin/sh
# wordpress is public: nobody may register or run the installer.
set -eu
B="https://$HOSTNAME_WORDPRESS"
curl -s -o /dev/null -w '%{redirect_url}' "$B/wp-login.php?action=register" | grep -q 'registration=disabled' || { echo "registration is not disabled"; exit 1; }
curl -sL "$B/wp-admin/install.php" | grep -qi 'already installed' || { echo "the installer is still offered"; exit 1; }
