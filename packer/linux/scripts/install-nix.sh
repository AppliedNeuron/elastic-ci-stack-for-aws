#!/usr/bin/env bash
# Install Determinate Nix. Cache/auth setup is bk-configure-nix.sh, run at instance boot.
set -euo pipefail

NIX_INSTALLER_VERSION="v3.21.8"
NIX_DAEMON_PROFILE=/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

echo "Installing Determinate Nix ${NIX_INSTALLER_VERSION}..."
curl --proto '=https' --tlsv1.2 -sSf -L "https://install.determinate.systems/nix/tag/${NIX_INSTALLER_VERSION}" \
  | sudo sh -s -- install linux \
    --no-confirm \
    --init systemd

# shellcheck source=/dev/null
. "${NIX_DAEMON_PROFILE}"
echo "Nix installation complete: $(nix --version)"
