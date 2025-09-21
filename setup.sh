#!/usr/bin/env bash
set -e

HM_CHANNEL_URL="https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz"
SECRETS_DIR="$HOME/Mimisbrunnr/.secrets"
SSH_DIR="$HOME/.ssh"

echo "=== Step 1: Link NixOS configuration to this repo ==="
sudo ln -sf "$HOME/.config/home-manager/configuration.nix" /etc/nixos/configuration.nix

echo "=== Step 2: (Optional) fonts passthrough symlink ==="
mkdir -p "$HOME/.local/share"
ln -sf "$HOME/.config/home-manager/fonts" "$HOME/.local/share/fonts" || true

echo "=== Step 3: Add Home-Manager 24.05 channel for ROOT and update ==="
# We need the HM module available at <home-manager/nixos> during nixos-rebuild
if ! sudo nix-channel --list | grep -q "^home-manager "; then
  sudo nix-channel --add "$HM_CHANNEL_URL" home-manager
fi
sudo nix-channel --update

echo "=== Step 4: Symlink secrets from Nextcloud (if present) ==="
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR" || true

# Common SSH keys (only link if present)
for f in id_ed25519 id_ed25519.pub id_rsa id_rsa.pub known_hosts.old novi_key novi_key.pub oscar_lab oscar_lab.pub root_usage; do
  [ -e "${SECRETS_DIR}/${f}" ] && ln -sf "${SECRETS_DIR}/${f}" "${SSH_DIR}/${f}" || true
done

# API keys & GPG
[ -e "${SECRETS_DIR}/openai_api_key" ] && ln -sf "${SECRETS_DIR}/openai_api_key" "$HOME/.openai_api_key" || true
[ -e "${SECRETS_DIR}/.gnupg" ] && ln -sf "${SECRETS_DIR}/.gnupg" "$HOME/.gnupg" || true
[ -e "${SECRETS_DIR}/doom.private.env" ] && ln -sf "${SECRETS_DIR}/doom.private.env" "$HOME/.config/doom.private.env" || true

echo "=== Step 5: Rebuild NixOS (Home-Manager module applies your home) ==="
sudo nixos-rebuild switch

echo "=== Step 6: Enable user services ==="
systemctl --user daemon-reload || true
systemctl --user enable --now nextcloud-mimi-sync.timer nextcloud-mimi-sync.service || true

# Doom bootstrap only if ~/.config/doom is missing; otherwise disable it
if [ ! -d "$HOME/.config/doom" ]; then
  echo "Enabling doom-bootstrap.service (will clone your private repo)..."
  systemctl --user enable --now doom-bootstrap.service || true
else
  echo "~/.config/doom exists — not enabling doom-bootstrap."
  systemctl --user disable --now doom-bootstrap.service 2>/dev/null || true
fi

echo "=== Done. Rebooting… ==="
sudo reboot
