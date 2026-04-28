# Auto-start Hyprland on tty1 only — leaves other TTYs available for recovery.
if [ -z "${WAYLAND_DISPLAY:-}" ] && [ "$(tty)" = "/dev/tty1" ]; then
  exec Hyprland
fi
