# Tablette Huion — mapping du stylet multi-écran

## Le problème

Sur un poste **multi-écran**, le stylet Huion (Kamvas) pilote **tous les écrans** au lieu
d'être restreint à la dalle de la tablette : la zone active est étirée sur toute la surface
X, le pointage devient inutilisable.

De plus, le nom du périphérique **n'est pas stable** : en mode propriétaire il apparaît
tantôt `HUION … Pen (0)`, tantôt `HUION … Pen Pen (0)` (le fameux souci « pen pen »).

## Pourquoi `xsetwacom` ne marche pas ici

En **mode propriétaire** (activé pour la pression), la tablette n'est pas gérée par le pilote
`wacom` : `xsetwacom --list devices` ne renvoie rien. On utilise donc **`xinput
map-to-output`**, générique.

## La commande

Restreindre le stylet à l'écran de la tablette (ici `HDMI-0`) :

```bash
xinput map-to-output "$(xinput list --name-only | grep -i huion | grep -F '(0)' | head -1)" HDMI-0
```

Le `grep huion + "(0)"` retrouve le device quel que soit son nom instable (« Pen » /
« Pen Pen »). Noms d'écrans : `xrandr --listmonitors`.

## Pourquoi le mapping « sautait » au démarrage

Course d'initialisation :

```
boot / branchement
      │
      ├── règle udev (ACTION=="add", VID/PID)  →  uclogic-probe  →  MODE PROPRIÉTAIRE
      │        └──►  RÉ-ÉNUMÉRATION USB : le device est renommé ("Pen" ↔ "Pen Pen")
      │
      └── autostart : mapping en une seule passe  →  mappe… l'ancien device
                                                     → mapping PERDU après ré-énumération
```

Le mapping n'était appliqué **qu'une fois** au login ; s'il gagnait la course avant la
ré-énumération du mode propriétaire, il était ensuite perdu → « pas à chaque démarrage ».

## La correction : un mapping *résident*

`huion-map.sh` (installé dans `~/.local/bin/`) :

1. mappe une première fois au login (attente jusqu'à 30 s que le device apparaisse) ;
2. **reste résident** et écoute les événements via `udevadm monitor --udev -s input` ;
3. **re-mappe à chaque ajout** de périphérique input (ré-énumération mode propriétaire,
   rebranchement, hotplug d'écran).

Idempotent, une seule instance (garde `pgrep`). Installé en autostart. Activer sans re-login :
```bash
setsid ~/.local/bin/huion-map.sh >/dev/null 2>&1 &
```
Changer d'écran : `./install.sh --output=DP-2` (ou `KAMVAS_OUTPUT` dans `settings.env`).

## Pression (mode propriétaire) — géré ailleurs

Ce pack ne gère **que** le mapping écran (niveau utilisateur). La **pression** passe par le
mode propriétaire Huion (`uclogic-probe`) + un pont Wintab, gérés au niveau système dans le
dépôt [`flashcs6linux_deploy`](https://github.com/gurppt/flashcs6linux_deploy) :

- `system/huion-proprietary-mode.{service,sh}` + `70-huion-proprietary-mode.rules` :
  bascule la tablette en mode propriétaire au branchement (root, via udev/systemd) ;
- `xwintab/` : pont Wintab pour la pression dans les applis Windows (Wine).

C'est justement ce mode propriétaire qui provoque la ré-énumération USB → d'où l'intérêt du
watcher résident ci-dessus.

## Dépannage express

```bash
xinput list --name-only | grep -i huion      # le stylet est-il vu ? quel nom ?
xrandr --listmonitors                         # noms d'écrans
pgrep -af huion-map.sh                         # le watcher résident tourne-t-il ?
DISPLAY=:0 ~/.local/bin/huion-map.sh &         # relancer manuellement
```
