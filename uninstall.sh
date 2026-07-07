#!/usr/bin/env bash
# Retire le mapping stylet Huion (watcher résident + autostart).
set -euo pipefail
echo "Arrêt du watcher et suppression des fichiers…"
pkill -f "[h]uion-map.sh" 2>/dev/null || true
rm -fv "$HOME/.local/bin/huion-map.sh" \
       "$HOME/.config/autostart/huion-map.desktop"
echo "Terminé."
