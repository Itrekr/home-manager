#!/usr/bin/env bash
set -e

HM_CHANNEL_URL="https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz"
SECRETS_DIR="$HOME/Mimisbrunnr/.secrets"
SSH_DIR="$HOME/.ssh"

echo "=== Step 1: Link Home Manager configuration to NixOS configuration ==="
sudo ln -sf ~/.config/home-manager/configuration.nix /etc/nixos/configuration.nix

echo "=== Step 2: Set up fonts directory (optional passthrough) ==="
mkdir -p ~/.local/share
ln -sf ~/.config/home-manager/fonts ~/.local/share/fonts || true

echo "=== Step 3: Add Home Manager channel and update ==="
if ! nix-channel --list | grep -q "^home-manager "; then
  sudo nix-channel --add "$HM_CHANNEL_URL" home-manager
fi
sudo nix-channel --update

echo "=== Step 4: Install Home Manager if missing ==="
if ! command -v home-manager >/dev/null 2>&1; then
  sudo nix-shell '<home-manager>' -A install
fi

echo "=== Step 5: Switch Home Manager configuration ==="
home-manager switch -f ~/.config/home-manager/home.nix

echo "=== Step 6: Symlink secrets from Nextcloud (if present) ==="
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR" || true

# Standaard SSH keys (als ze bestaan in Nextcloud)
for f in id_ed25519 id_ed25519.pub id_rsa id_rsa.pub known_hosts.old novi_key novi_key.pub oscar_lab oscar_lab.pub root_usage; do
  [ -f "${SECRETS_DIR}/${f}" ] && ln -sf "${SECRETS_DIR}/${f}" "${SSH_DIR}/${f}" || true
done

# API keys & GPG
[ -f "${SECRETS_DIR}/openai_api_key" ] && ln -sf "${SECRETS_DIR}/openai_api_key" "$HOME/.openai_api_key" || true
[ -d "${SECRETS_DIR}/.gnupg" ] && ln -sf "${SECRETS_DIR}/.gnupg" "$HOME/.gnupg" || true

# Optioneel: doom.private.env token/URL fallback
[ -f "${SECRETS_DIR}/doom.private.env" ] && ln -sf "${SECRETS_DIR}/doom.private.env" "$HOME/.config/doom.private.env" || true

echo "Secrets symlinked."

echo "=== Step 7: Enable user services (conditional doom-bootstrap) ==="
systemctl --user daemon-reload || true
systemctl --user enable --now nextcloud-mimi-sync.timer nextcloud-mimi-sync.service || true

if [ ! -d "$HOME/.config/doom" ]; then
  echo "Enabling doom-bootstrap.service (private repo will be cloned)..."
  systemctl --user enable --now doom-bootstrap.service || true
else
  echo "~/.config/doom bestaat al — doom-bootstrap wordt niet geactiveerd."
  systemctl --user disable --now doom-bootstrap.service 2>/dev/null || true
fi

echo "=== Step 8: Rebuild NixOS and reboot ==="
sudo nixos-rebuild switch
sudo reboot
