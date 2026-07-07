# Mapping stylet Huion multi-écran

Restreint le stylet d'une tablette **Huion** (Kamvas) à **son propre écran** sur un poste
multi-écran, au lieu de l'étaler sur toutes les dalles. Mapping **résident** : il se
ré-applique automatiquement à chaque (ré)apparition du périphérique (hotplug, ré-énumération
du mode propriétaire, souci de nommage « Pen » / « Pen Pen »).

## Installation

```bash
cd ~/softs/huion_mapping
./install.sh --output=HDMI-0 --start   # écran cible + activation immédiate
```

- `--output=NAME` : écran cible (voir `xrandr --listmonitors`). Défaut : `HDMI-0`.
- `--start` : lance le watcher tout de suite (sinon, actif au prochain login).

Désinstaller : `./uninstall.sh`

## Contenu

| Fichier | Rôle |
|---|---|
| `install.sh` / `uninstall.sh` | (dé)installation |
| `settings.env` | écran cible (`KAMVAS_OUTPUT`) |
| `huion-map.sh.in` | watcher résident (template) → `~/.local/bin/huion-map.sh` |
| `huion-map.desktop.in` | autostart (template) → `~/.config/autostart/` |
| `docs/tablette-huion.md` | explication complète (souci « pen pen », course au boot, pression) |

## Commande de secours (rappel)

```bash
xinput map-to-output "$(xinput list --name-only | grep -i huion | grep -F '(0)' | head -1)" HDMI-0
```

## Voir aussi

La **pression** (mode propriétaire + Wintab) est gérée à part, au niveau système, dans
[`flashcs6linux_deploy`](https://github.com/gurppt/flashcs6linux_deploy). Ce pack-ci ne gère
que le **mapping écran** du stylet (niveau utilisateur). Détails dans `docs/tablette-huion.md`.
