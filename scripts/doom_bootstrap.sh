#!/usr/bin/env bash
set -euo pipefail

STAMP="$HOME/.local/share/doom_bootstrap.done"
[ -f "$STAMP" ] && exit 0

# Optioneel: token/alternate URLs
[ -f "$HOME/.config/doom.private.env" ] && source "$HOME/.config/doom.private.env"

# Wacht kort op netwerk
for _ in $(seq 1 30); do
  if command -v curl >/dev/null 2>&1 && curl -m 2 -fsSI https://github.com >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

mkdir -p "$HOME/.ssh"
touch "$HOME/.ssh/known_hosts"
chmod 600 "$HOME/.ssh/known_hosts" || true

# GitHub host keys toevoegen (geen prompt)
if ! ssh-keygen -F github.com >/dev/null; then
  ssh-keyscan -t rsa,ecdsa,ed25519 github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null || true
fi

# Doom core
if [ ! -d "$HOME/.config/emacs" ]; then
  echo ">> Cloning Doom core -> ~/.config/emacs"
  git clone --depth 1 https://github.com/doomemacs/doomemacs "$HOME/.config/emacs"
fi

# Oude locatie weg (compat)
rm -rf "$HOME/.emacs.d"

# Privé Doom repo
DOOM_SSH_URL="${DOOM_GIT_URL_SSH:-git@github.com:Itrekr/doom.git}"
DOOM_HTTPS_URL="${DOOM_GIT_URL_HTTPS:-https://github.com/Itrekr/doom.git}"

if [ ! -d "$HOME/.config/doom" ]; then
  echo ">> Cloning your private Doom config -> ~/.config/doom"
  set +e
  git clone "$DOOM_SSH_URL" "$HOME/.config/doom"
  rc=$?
  set -e
  if [ $rc -ne 0 ]; then
    if [ -n "${DOOM_GIT_TOKEN:-}" ]; then
      echo ">> SSH failed; trying HTTPS with token"
      git clone "https://${DOOM_GIT_TOKEN}@${DOOM_HTTPS_URL#https://}" "$HOME/.config/doom"
    else
      echo "!! Cannot clone private repo. Ensure SSH access or set DOOM_GIT_TOKEN in ~/.config/doom.private.env"
      exit 1
    fi
  fi
fi

# Doom install/sync/build
"$HOME/.config/emacs/bin/doom" -y install || true
"$HOME/.config/emacs/bin/doom" -y sync
"$HOME/.config/emacs/bin/doom" -y build

# Emacs-daemon herstarten
systemctl --user restart emacs.service || true

mkdir -p "$(dirname "$STAMP")"
date > "$STAMP"
echo ">> Doom bootstrap complete."
