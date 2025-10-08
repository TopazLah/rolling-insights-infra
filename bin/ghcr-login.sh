#!/usr/bin/env bash
set -euo pipefail

INFRA_DIR="/home/deploy/infra-sync"
ENC_FILE="$INFRA_DIR/env/ghcr.env.json.enc"
TMP_ENV="$(mktemp /tmp/ghcr.env.XXXXXX)"

cleanup() {
  [ -f "$TMP_ENV" ] && shred -u "$TMP_ENV" >/dev/null 2>&1 || rm -f "$TMP_ENV"
}
trap cleanup EXIT

# ודא שקובץ המפתח והקובץ המוצפן קיימים
export SOPS_AGE_KEY_FILE="/home/deploy/.config/sops/age/keys.txt"
[ -f "$SOPS_AGE_KEY_FILE" ] || { echo "SOPS key file missing: $SOPS_AGE_KEY_FILE" >&2; exit 1; }
[ -f "$ENC_FILE" ] || { echo "Encrypted file missing: $ENC_FILE" >&2; exit 1; }

# פענוח ל-dotenv זמני (KEY=VALUE), הרשאות הדוקות
/usr/local/bin/sops -d --output-type json "$ENC_FILE" \
  | jq -r 'to_entries|.[]|"\(.key)=\(.value)"' > "$TMP_ENV"
chmod 600 "$TMP_ENV"

# טעינת משתנים לסשן סגור (ללא הדפסה), ואז login
set -a
# shellcheck source=/dev/null
. "$TMP_ENV"
set +a

# שימוש בנתיב המלא לדוקר
/usr/bin/docker login ghcr.io -u "$GHCR_USER" -p "$GHCR_TOKEN"
