#!/usr/bin/env bash
# JARVIS startup notification cascade.
# Called from hypr/UserConfigs/Startup_Apps.conf on login.
set -euo pipefail

N() { notify-send -a "JARVIS" -t "$1" "$2" "$3"; }

sleep 0.5
N 3000 "JARVIS ONLINE" "Booting subsystems..."

sleep 1.2
N 2500 "SYSTEMS NOMINAL" "All cores responding."

sleep 1.0
N 2500 "ENVIRONMENT READY" "Wayland compositor active."

sleep 0.8
N 4000 "WELCOME BACK" "$(date '+%A, %B %-d')"
