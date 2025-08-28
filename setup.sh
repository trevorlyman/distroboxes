#!/usr/bin/env bash
set -euo pipefail

BOX_NAME="dev-box"
IMAGE="fedora:latest"
PLAYBOOK_PATH="$(realpath playbook.yaml)"

# Host podman paths
PODMAN_SOCK="$XDG_RUNTIME_DIR/podman/podman.sock"
PODMAN_DATA="$HOME/.local/share/containers"
PODMAN_CONFIG="$HOME/.config/containers"

# Ensure host Podman directories exist
mkdir -p "$PODMAN_DATA"
mkdir -p "$PODMAN_CONFIG"

# 1. Create dev-box if it doesn't already exist
if ! distrobox-list | grep -q "$BOX_NAME"; then
  echo "[*] Creating Distrobox '$BOX_NAME'..."
  distrobox-create \
    --name "$BOX_NAME" \
    --image "$IMAGE" \
    --additional-flags "--env CONTAINER_HOST=unix:///run/host/run/user/$(id -u)/podman/podman.sock"

else
  echo "[*] Distrobox '$BOX_NAME' already exists, skipping creation."
fi

# 2. Enter the box and run Ansible
distrobox-enter "$BOX_NAME" -- bash -c "
echo '[*] Installing Ansible...'
sudo dnf install -y ansible

echo '[*] Running Ansible playbook...'
ansible-playbook '$PLAYBOOK_PATH'
"

echo "[*] Dev Box setup complete!"
