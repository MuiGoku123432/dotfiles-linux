# Auto-start Hyprland on tty1 only — leaves other TTYs available for recovery.
if [ -z "${WAYLAND_DISPLAY:-}" ] && [ "$(tty)" = "/dev/tty1" ]; then
  if command -v uwsm >/dev/null 2>&1; then
    exec uwsm start hyprland-uwsm.desktop
  else
    exec Hyprland
  fi
fi
