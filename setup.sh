#!/usr/bin/env bash
set -euo pipefail

BOX_NAME="dev-box"
IMAGE="fedora:latest"
PLAYBOOK_PATH="$(realpath playbook.yaml)"

# 1. Create dev-box if it doesn't already exist
if ! distrobox-list | grep -q "$BOX_NAME"; then
  echo "[*] Creating Distrobox '$BOX_NAME'..."
  distrobox-create \
    --name "$BOX_NAME" \
    --image "$IMAGE" \
    --nvidia \
    --additional-flags "--volume /var/run/docker.sock:/var/run/docker.sock:rw" \
    --additional-flags "--env DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1"

else
  echo "[*] Distrobox '$BOX_NAME' already exists, skipping creation."
fi

# 2. Enter the box and run Ansible
distrobox-enter "$BOX_NAME" -- bash -c "
echo '[*] Installing dependencies...'
# The moby-engine package provides the 'docker' command-line client
sudo dnf install -y ansible
echo '[*] Running Ansible playbook...'
ansible-playbook '$PLAYBOOK_PATH'
"

echo "[*] Dev Box setup complete!"