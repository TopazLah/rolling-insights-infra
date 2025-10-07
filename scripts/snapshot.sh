#!/usr/bin/env bash
set -euo pipefail
STAMP=$(date +%Y%m%d-%H%M%S)
BASE="$HOME/infra-backups/$STAMP"
mkdir -p "$BASE"

sudo cp /etc/nginx/sites-available/empirelogicapp.com "$BASE"/
sudo cp /etc/nginx/snippets/watcher-alias.conf "$BASE"/
sudo cp /etc/systemd/system/rollinginsights-api.service "$BASE"/

if [ -f /srv/apps/empirelogic/env/api.env ]; then
  sudo cp /srv/apps/empirelogic/env/api.env "$BASE"/api.env.SECURE
fi

(
  cd "$HOME/infra-backups"
  tar czf "infra-$STAMP.tgz" "$STAMP"
  rm -rf "$STAMP"
)

echo "OK: created $HOME/infra-backups/infra-$STAMP.tgz"
