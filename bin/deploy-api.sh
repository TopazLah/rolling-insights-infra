#!/usr/bin/env bash
set -euo pipefail

IMAGE_REPO="ghcr.io/topazlah/rolling-insights-api"
TAG="${1:-latest}"
FULL_TAG="${IMAGE_REPO}:${TAG}"

echo "[deploy-api] Using: ${FULL_TAG}"

cd ~/infra-sync

# התחברות לרג'יסטרי אם יש סקריפט
if [ -x ./bin/ghcr-login.sh ]; then
  ./bin/ghcr-login.sh
fi

# גיבוי compose ועדכון שורת ה-image
TS="$(date -u +%Y%m%dT%H%M%SZ)"
cp docker-compose.yml docker-compose.yml.bak.$TS
sed -i.bak.$TS "s|^\([[:space:]]*image:\s*\).*|\1${FULL_TAG}|" docker-compose.yml

# משיכה, ריסטרט, בדיקות
docker compose pull api
sudo systemctl restart infra-sync-api.service

echo "[deploy-api] Waiting for health..."
for i in $(seq 1 30); do
  if curl -fsS https://api.empirelogicapp.com/health >/dev/null 2>&1; then
    echo "[deploy-api] HEALTH OK on try $i"
    exit 0
  fi
  sleep 1
done

echo "[deploy-api] HEALTH FAIL"
exit 1
