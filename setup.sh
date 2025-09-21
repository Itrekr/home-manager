#!/usr/bin/env bash
set -e

HM_CHANNEL_URL="https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz"
SECRETS_DIR="$HOME/Mimisbrunnr/.secrets"
SSH_DIR="$HOME/.ssh"

echo "=== 1) Link NixOS configuration to this repo ==="
sudo ln -sf "$HOME/.config/home-manager/configuration.nix" /etc/nixos/configuration.nix

echo "=== 2) (Optional) fonts passthrough symlink ==="
mkdir -p "$HOME/.local/share"
ln -sf "$HOME/.config/home-manager/fonts" "$HOME/.local/share/fonts" || true

echo "=== 3) Add Home-Manager 24.05 channel for ROOT and update ==="
# Nodig voor <home-manager/nixos> tijdens nixos-rebuild
if ! sudo nix-channel --list | grep -q "^home-manager "; then
  sudo nix-channel --add "$HM_CHANNEL_URL" home-manager
fi
sudo nix-channel --update

echo "=== 4) Symlink secrets from Nextcloud (if present) ==="
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR" || true

for f in id_ed25519 id_ed25519.pub id_rsa id_rsa.pub known_hosts.old novi_key novi_key.pub oscar_lab oscar_lab.pub root_usage; do
  [ -e "${SECRETS_DIR}/${f}" ] && ln -sf "${SECRETS_DIR}/${f}" "${SSH_DIR}/${f}" || true
done
[ -e "${SECRETS_DIR}/openai_api_key" ] && ln -sf "${SECRETS_DIR}/openai_api_key" "$HOME/.openai_api_key" || true
[ -e "${SECRETS_DIR}/.gnupg" ] && ln -sf "${SECRETS_DIR}/.gnupg" "$HOME/.gnupg" || true
[ -e "${SECRETS_DIR}/doom.private.env" ] && ln -sf "${SECRETS_DIR}/doom.private.env" "$HOME/.config/doom.private.env" || true

echo "=== 5) Rebuild NixOS (HM module applies your home) ==="
sudo nixos-rebuild switch

echo "=== 6) Enable user services ==="
systemctl --user daemon-reload || true
systemctl --user enable --now emacs.service || true
systemctl --user enable --now nextcloud-mimi-sync.timer nextcloud-mimi-sync.service || true

# Doom bootstrap alleen als ~/.config/doom nog niet bestaat
if [ ! -d "$HOME/.config/doom" ]; then
  echo "Enabling doom-bootstrap.service (will clone your private repo)..."
  systemctl --user enable --now doom-bootstrap.service || true
else
  echo "~/.config/doom exists — not enabling doom-bootstrap."
  systemctl --user disable --now doom-bootstrap.service 2>/dev/null || true
fi

echo "=== Done. Rebooting… ==="
sudo reboot
