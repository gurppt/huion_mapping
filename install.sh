#!/usr/bin/env bash
# =============================================================================
#  Mapping stylet Huion multi-écran — installeur
#  Installe un mapping RÉSIDENT (stylet restreint à l'écran de la tablette,
#  re-appliqué à chaque hotplug / ré-énumération du mode propriétaire).
# =============================================================================
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/settings.env"

DO_START=0
for a in "$@"; do case "$a" in
  --output=*) KAMVAS_OUTPUT="${a#*=}";;
  --start)    DO_START=1;;
  -h|--help)  echo "Usage: ./install.sh [--output=HDMI-0] [--start]"; exit 0;;
  *) echo "option inconnue: $a"; exit 1;; esac; done

info(){ printf '\033[1;34m[info]\033[0m %s\n' "$*"; }
ok(){   printf '\033[1;32m[ OK ]\033[0m %s\n' "$*"; }

command -v xinput >/dev/null || info "xinput absent -> sudo apt install xinput"
command -v xrandr >/dev/null || info "xrandr absent -> sudo apt install x11-xserver-utils"

info "Écran cible du stylet : $KAMVAS_OUTPUT"
command -v xrandr >/dev/null && { info "Écrans détectés :"; DISPLAY=${DISPLAY:-:0} xrandr --listmonitors 2>/dev/null | sed 's/^/    /' || true; }

mkdir -p "$HOME/.local/bin" "$HOME/.config/autostart"
render(){ sed -e "s#@KAMVAS_OUTPUT@#$KAMVAS_OUTPUT#g" -e "s#@HOME@#$HOME#g" "$1"; }
render "$HERE/huion-map.sh.in"      > "$HOME/.local/bin/huion-map.sh"
chmod +x "$HOME/.local/bin/huion-map.sh"
render "$HERE/huion-map.desktop.in" > "$HOME/.config/autostart/huion-map.desktop"
ok "mapping résident installé (autostart actif au prochain login)"

if [ "$DO_START" = 1 ]; then
  pkill -f "[h]uion-map.sh" 2>/dev/null || true
  setsid "$HOME/.local/bin/huion-map.sh" >/dev/null 2>&1 &
  ok "watcher lancé maintenant (PID $!)"
else
  info "Lancer sans re-login :  setsid ~/.local/bin/huion-map.sh >/dev/null 2>&1 &"
fi
info "Doc : docs/tablette-huion.md   |   Désinstaller : ./uninstall.sh"
