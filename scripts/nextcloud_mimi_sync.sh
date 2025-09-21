#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="$HOME/.config/nextcloud-sync.env"
if [ ! -f "$ENV_FILE" ]; then
  echo "Missing $ENV_FILE"
  exit 1
fi

# shellcheck disable=SC1090
source "$ENV_FILE"

: "${NEXTCLOUD_URL:?Missing NEXTCLOUD_URL}"
: "${NEXTCLOUD_USER:?Missing NEXTCLOUD_USER}"
: "${NEXTCLOUD_PASS:?Missing NEXTCLOUD_PASS}"
: "${LOCAL_DIR:?Missing LOCAL_DIR}"

mkdir -p "$LOCAL_DIR"
nextcloudcmd --non-interactive \
  --user "$NEXTCLOUD_USER" --password "$NEXTCLOUD_PASS" \
  "$LOCAL_DIR" "$NEXTCLOUD_URL"

mkdir -p "$HOME/Mimisbrunnr/Notes/Journal"
