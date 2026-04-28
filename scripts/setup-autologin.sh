#!/usr/bin/env bash
# Configure TTY autologin → Hyprland on tty1.
# Removes SDDM, sets multi-user.target as default, drops in autologin override.
# Idempotent: safe to re-run.
set -euo pipefail

USER_NAME="${SUDO_USER:-${USER}}"
OVERRIDE_DIR="/etc/systemd/system/getty@tty1.service.d"
OVERRIDE_FILE="$OVERRIDE_DIR/autologin.conf"

info() { printf '\033[1;34m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m==> %s\033[0m\n' "$*"; }

# 1. Disable SDDM if present
if systemctl is-enabled sddm >/dev/null 2>&1; then
  info "Disabling SDDM..."
  sudo systemctl disable sddm
fi
if rpm -q sddm >/dev/null 2>&1; then
  warn "SDDM is installed. To remove fully:  sudo dnf remove sddm"
fi

# 2. Boot to multi-user.target (no graphical DM)
CURRENT_TARGET=$(systemctl get-default)
if [[ "$CURRENT_TARGET" != "multi-user.target" ]]; then
  info "Setting default target to multi-user.target (was $CURRENT_TARGET)..."
  sudo systemctl set-default multi-user.target
else
  info "Default target already multi-user.target"
fi

# 3. Drop in agetty autologin override for tty1
info "Configuring autologin for user '$USER_NAME' on tty1..."
sudo mkdir -p "$OVERRIDE_DIR"
sudo tee "$OVERRIDE_FILE" >/dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\\\u' --noclear --autologin $USER_NAME %I \$TERM
EOF

sudo systemctl daemon-reload
info "Autologin configured. Reboot to test."
