# Exit the script if any command fails
set -e

# Step 1: Link Home Manager configuration to NixOS configuration
echo "Linking Home Manager configuration..."
sudo ln -sf ~/.config/home-manager/configuration.nix /etc/nixos/configuration.nix

# Step 2: Set up fonts directory
echo "Setting up fonts directory..."
mkdir -p ~/.local/share
ln -sf ~/.config/home-manager/fonts ~/.local/share/fonts

# Step 3: Add Home Manager channel and update
echo "Adding and updating Home Manager channel..."
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
sudo nix-channel --update

# Step 4: Install Home Manager
echo "Installing Home Manager..."
sudo nix-shell '<home-manager>' -A install

# Step 5: Run home-manager switch
echo "Switching Home Manager configuration..."
home-manager switch

# Step 6: Create symlinks for secrets in Nextcloud folder
echo "Setting up symlinks for secrets..."

SECRETS_DIR="/home/oscar/Mimisbrunnr/.secrets"
SSH_DIR="$HOME/.ssh"

# Ensure the .ssh directory exists
mkdir -p "$SSH_DIR"

# Create symlinks for each secret file if it exists
ln -sf "${SECRETS_DIR}/id_ed25519" "${SSH_DIR}/id_ed25519"
ln -sf "${SECRETS_DIR}/id_ed25519.pub" "${SSH_DIR}/id_ed25519.pub"
ln -sf "${SECRETS_DIR}/id_rsa" "${SSH_DIR}/id_rsa"
ln -sf "${SECRETS_DIR}/id_rsa.pub" "${SSH_DIR}/id_rsa.pub"
ln -sf "${SECRETS_DIR}/known_hosts.old" "${SSH_DIR}/known_hosts.old"
ln -sf "${SECRETS_DIR}/novi_key" "${SSH_DIR}/novi_key"
ln -sf "${SECRETS_DIR}/novi_key.pub" "${SSH_DIR}/novi_key.pub"
ln -sf "${SECRETS_DIR}/oscar_lab" "${SSH_DIR}/oscar_lab"
ln -sf "${SECRETS_DIR}/oscar_lab.pub" "${SSH_DIR}/oscar_lab.pub"
ln -sf "${SECRETS_DIR}/root_usage" "${SSH_DIR}/root_usage"
ln -sf "${SECRETS_DIR}/openai_api_key" "$HOME/.openai_api_key"
ln -sf "${SECRETS_DIR}/.gnupg" "$HOME/.gnupg"

echo "Symlinks for secrets have been set up."

# Step 7: Rebuild NixOS and reboot
echo "Rebuilding NixOS and rebooting..."
sudo nixos-rebuild switch
sudo reboot
