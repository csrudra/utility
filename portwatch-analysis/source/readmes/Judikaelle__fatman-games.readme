# FatMan Games

Bibliothèque de jeux Windows pour Linux (Bazzite, CachyOS, Fedora, Arch…). Tu lui donnes l'installateur d'un jeu (`setup.exe`) : elle l'installe sous Proton **en une seule étape, sans fenêtre Windows**, puis affiche tes jeux **sous forme de cartes avec jaquette**, avec un bouton « Jouer », une entrée dans le menu de ton bureau, le temps de jeu, les réglages par jeu, la sauvegarde des saves et l'ajout à Steam.

GTK4 / libadwaita, Python, `umu-run`. Aucune dépendance à compiler.

## Installation

```bash
git clone https://github.com/Judikaelle/fatman-games.git
cd fatman-games
./install.sh
```

Le script crée :

- la commande `~/.local/bin/fatman-games` (un lien vers le dossier cloné) ;
- l'entrée **FatMan Games** du menu.

Il associe aussi les fichiers `.exe` à l'appli : un double-clic sur un `setup.exe` dans ton gestionnaire de fichiers ouvre la fenêtre d'installation.

### Dépendances

| Distribution | Commande |
|---|---|
| Bazzite / SteamOS-like | rien, tout est déjà présent |
| CachyOS / Arch | `sudo pacman -S --needed python-gobject gtk4 libadwaita umu-launcher icoutils` |
| Fedora | `sudo dnf install python3-gobject gtk4 libadwaita umu-launcher icoutils` |

Il faut aussi un Proton : Proton-CachyOS, GE-Proton ou celui de Steam. Le paquet `proton-cachyos` ou ProtonPlus conviennent. Sans aucun Proton installé, umu télécharge GE-Proton tout seul.

Facultatif : `mangohud` et `gamescope` pour les réglages correspondants, `notify-send` (libnotify) pour les notifications.

## Utilisation

1. **Ajouter un jeu** : glisse le `setup.exe` dans la fenêtre, clique sur **Installer un jeu**, ou double-clique sur le `setup.exe`.
2. **Vérifie le nom** proposé. Il est deviné à partir du nom du dossier : `Hades II v1.0 + 2 DLCs [Repack]` donne `Hades II`.
3. **Choisis les deux options** (l'appli retient tes choix pour la fois suivante) :
   - **Installation automatique** (activée par défaut) : l'installateur tourne sans fenêtre, avec ses options par défaut, en général tout le jeu et ses DLC. La carte affiche la quantité de données écrites et le débit. Désactive l'option pour choisir toi-même les composants (langue, DLC facultatifs) dans l'installateur Windows, en gardant le dossier proposé (`C:\Games\<nom>`).
   - **Supprimer l'installateur à la fin** (désactivée par défaut) : le `setup.exe` et ses archives sont supprimés dès que le jeu est prêt.
4. À la fin, tu reçois une **notification**. Si un `.exe` ressort nettement, il est retenu tout seul et le jeu est prêt. Sinon, l'appli te propose les candidats.
   La **musique de l'installateur est coupée**, fréquente dans les repacks, il **ne peut pas ouvrir son site web**, et la vérification QuickSFV et DirectX ne se lancent pas à la fin.
5. Si l'installation automatique ne donne rien, la carte passe en **Échec**. *Journal d'installation* donne le détail, et **Réessayer avec la fenêtre** relance l'installateur normalement.
6. Le jeu apparaît en carte. Lance-le avec **Jouer**, par un double-clic sur la jaquette, depuis le menu du bureau, ou depuis Steam.

### Les cartes

- **Jaquette** : l'appli cherche le nom du jeu sur la boutique Steam (seul le nom est envoyé) et garde l'image dans `cover.jpg`. Sans correspondance, la carte affiche un dégradé avec l'icône du `.exe`. Pour changer la jaquette, remplace `cover.jpg` par n'importe quelle image verticale.
- **Temps de jeu** et date de dernière partie, comptés quelle que soit la façon de lancer le jeu (appli, menu ou Steam).
- **Badges** : *Installation*, avec une barre de progression ; *À configurer*, quand le `.exe` reste à choisir ; *Échec*, quand l'installation automatique n'a rien installé ; *En cours*, avec un bouton Arrêter.
- **Recherche** par nom, avec le champ en haut de la fenêtre.

### Menu « ⋮ » de chaque jeu

| Action | Effet |
|---|---|
| Réglages… | MangoHud, Gamescope, version de Proton, manette Xbox, options de lancement, variables d'environnement |
| Changer le .exe… | Relance la détection, ou permet de choisir le fichier à la main |
| Ajouter à Steam / Retirer de Steam | Raccourci « jeu non-Steam » avec la jaquette, pour Big Picture et la manette |
| Sauvegarder les saves | Archive le profil Windows du jeu (voir plus bas) |
| Restaurer des saves… | Choix d'une sauvegarde par date |
| Ouvrir le dossier | Ouvre `C:\Games` du jeu |
| Journal d'installation / du dernier lancement | Pour comprendre un problème |
| Forcer l'arrêt | Tue tous les processus Windows du jeu |
| Supprimer l'installateur… | Supprime le `setup.exe` téléchargé (définitif, sans corbeille) |
| Désinstaller… | Supprime le jeu. Les saves sont sauvegardées avant (option cochée par défaut) et le raccourci Steam est retiré. |

### Réglages par jeu

- **MangoHud** : affiche les images par seconde, les températures et la charge.
- **Gamescope** : lance le jeu dans une session Gamescope. Les options sont modifiables, par exemple `-f -W 2560 -H 1440 -r 240`.
- **Version de Proton** : celle par défaut, ou n'importe quel Proton installé.
- **Manette vue comme une manette Xbox** (activé par défaut) : hors Steam, Proton ouvre une DualSense ou une DualShock en HID brut et les jeux qui ne lisent que XInput ne la voient pas. Ce réglage ajoute `PROTON_PREFER_SDL=1` pour qu'elle apparaisse comme une manette Xbox. À couper pour un portage PlayStation qui gère lui-même la DualSense (gâchettes adaptatives, gyroscope). Sans effet quand le jeu est lancé depuis Steam : Steam Input s'en occupe.
- **Options de lancement** : arguments passés au `.exe`, par exemple `-dx11 -skipintro`.
- **Variables d'environnement** : par exemple `DXVK_HUD=fps PROTON_ENABLE_NVAPI=1`.

Les réglages sont pris en compte au lancement suivant et notés en tête de `last-run.log`.

### Steam

« Ajouter à Steam » écrit le raccourci dans `userdata/<compte>/config/shortcuts.vdf` et copie la jaquette dans `config/grid/`. Steam réécrit ce fichier quand il se ferme : s'il est ouvert, l'appli te demande l'autorisation de le fermer, puis le relance. Une copie du fichier d'origine est gardée une fois, sous le nom `shortcuts.vdf.fatman-bak`.

### Sauvegarde des saves

La plupart des jeux rangent leurs sauvegardes dans le profil Windows du jeu (`Documents`, `AppData`, `Saved Games`). L'appli archive ce profil entier, sans les caches (shaders, fichiers temporaires, rapports de plantage), dans :

```
<dossier des jeux>/_sauvegardes/<id>-AAAAMMJJ-HHMMSS.tar.gz
```

Une sauvegarde est faite automatiquement avant chaque désinstallation, sauf si tu décoches l'option. Après une réinstallation sous le même nom, *Restaurer des saves…* les remet en place.

## Où sont les choses

```
/mnt/GAMES/FatMan/             (ou ~/Games/FatMan s'il n'y a pas de /mnt/GAMES)
├── _sauvegardes/              ← archives des saves
└── hades-ii/                  ← un dossier par jeu
    ├── game.json              ← nom, .exe, réglages, temps de jeu
    ├── cover.jpg              ← jaquette
    ├── icon.png               ← icône extraite du .exe
    ├── install.log
    ├── last-run.log
    └── pfx/                   ← environnement Windows (préfixe Proton) propre à ce jeu
        └── drive_c/Games/Hades II/
```

- **La liste des jeux correspond au contenu de ce dossier**, il n'y a pas de base de données à part.
- Il y a **un préfixe par jeu** : un jeu ne peut pas abîmer les autres.
- Les entrées du menu sont dans `~/.local/share/applications/fatman-games-*.desktop`.

## Configuration

Le fichier `~/.config/fatman-games/config.json` est facultatif :

```json
{
  "games_dir": "/mnt/GAMES/FatMan",
  "proton": "",
  "auto_install": true,
  "delete_installer": false,
  "mute_installer": true,
  "block_installer_web": true,
  "skip_installer_extras": true,
  "hide_installer_windows": true
}
```

- `games_dir` : dossier des jeux.
- `auto_install`, `delete_installer` : derniers choix de la fenêtre « Installer un jeu », retenus automatiquement.
- `mute_installer` : coupe la musique des installateurs (activé par défaut). Pendant l'installation, l'appli met en sourdine, via `pactl`, les flux audio de l'installateur : ceux qui portent l'étiquette `fatman.install` (posée par `PULSE_PROP`) ou le nom du programme (`setup.tmp`…). Les autres applications ne sont pas touchées, et le jeu garde le son. WirePlumber retient cette sourdine pour le nom `setup.tmp`.
- `block_installer_web` : empêche l'installateur d'ouvrir une page web à la fin (site du repack), en désactivant `winebrowser` pendant l'installation, et retire les lignes que le repack ajoute au fichier `hosts` du préfixe (activé par défaut). Ce `hosts` ne concerne que Wine, jamais Linux.
- `hide_installer_windows` : en installation automatique, l'installateur tourne dans un Gamescope sans affichage (`--backend headless`) : sa fenêtre de progression et les consoles Windows qu'il ouvre même en mode silencieux restent invisibles (activé par défaut, ignoré si Gamescope est absent). « Réessayer avec la fenêtre » n'est jamais caché. Une installation cachée qui n'écrit plus rien pendant 10 minutes est arrêtée (installateur figé sur une erreur invisible) et propose ce bouton.
- `skip_installer_extras` : empêche les programmes que les repacks lancent en fin d'installation de démarrer : la vérification QuickSFV, dont la fenêtre bloque la fin de l'installation, et l'installateur web de DirectX, inutile avec Proton (activé par défaut).
- `proton` : chemin d'un Proton par défaut. S'il est vide, l'appli choisit Proton-CachyOS s'il est présent, sinon le GE-Proton le plus récent, sinon n'importe quel Proton trouvé dans `~/.local/share/Steam/compatibilitytools.d` ou `/usr/share/steam/compatibilitytools.d`.

## Compatibilité des DLL (jeux Xbox PC, mods)

Certains jeux placent à côté de leur `.exe` une DLL système modifiée : couche de compatibilité des versions **Xbox PC / GDK**, chargeur de mods, injecteur. Wine utilise sa propre version de ces DLL et ignore celle du jeu, ce qui peut faire planter le jeu au démarrage. Un jeu Unreal affiche par exemple *« The Game has crashed and will close »*, avec `GDKRuntimeInitialize` dans le rapport.

À chaque lancement, l'appli regarde donc le dossier du `.exe`. Si elle y trouve l'une de ces DLL, elle dit à Wine d'utiliser celle du jeu (`WINEDLLOVERRIDES=…=n,b`) : `winmm`, `version`, `dinput8`, `winhttp`, `xinput1_3`, `xinput1_4`, `xinput9_1_0`, `dsound`, `xgameruntime`, `dbghelp`, `msvcp140_atomic_wait`.

`dxgi`, `d3d11` et `d3d12` sont volontairement exclus : ce sont ceux de DXVK/VKD3D.

Si un jeu plante au tout premier lancement, relance-le une fois avant de chercher plus loin. Les rapports de plantage des jeux Unreal se trouvent dans `pfx/drive_c/users/steamuser/AppData/Local/<Projet>/Saved/Crashes/`.

## Ligne de commande

```bash
fatman-games                         # ouvre la fenêtre
fatman-games chemin/vers/setup.exe   # ouvre la fenêtre et lance l'installation
fatman-games --list                  # liste les jeux (identifiant, état, nom)
fatman-games --play hades-ii         # lance un jeu et attend sa fin (menu et Steam)
```

## Dépannage

- **La première installation met une minute avant d'afficher quelque chose** : Proton crée l'environnement Windows du jeu.
- **La carte reste sur « Installation » quelques minutes après la fermeture de l'installateur** : Proton attend la fin des derniers processus Windows. C'est normal.
- **« Aucun jeu trouvé »** ou badge **Échec** : l'installation a été annulée ou a échoué (archive corrompue, disque plein : voir *Journal d'installation*), ou le jeu a été installé ailleurs. Utilise *Réessayer avec la fenêtre*, ou *Changer le .exe… → Autre fichier…*.
- **Le jeu ne démarre pas** : consulte *Journal du dernier lancement* et, s'il y en a un, le rapport de plantage. Essaie un autre Proton dans *Réglages*. Si l'installateur a laissé un dossier `_Redist` (Visual C++, DirectX), lance ces programmes dans le même préfixe :
  `WINEPREFIX=<dossier du jeu>/pfx GAMEID=umu-default umu-run chemin/vers/vcredist.exe`
- **« Disque des jeux introuvable »** : le disque qui contient `games_dir` n'est pas monté.

## Désinstaller l'appli

```bash
./uninstall.sh
```

Ce script retire la commande et les entrées du menu. **Les jeux et les sauvegardes restent** dans le dossier des jeux.

## Développement

```
fatman-games            point d'entrée (CLI + fenêtre)
fatman_games/
  config.py             réglages, Proton disponibles
  detect.py             nom du jeu, recherche du .exe, DLL à privilégier
  library.py            un jeu = un dossier + game.json
  proton.py             umu-run : installation, lancement, temps de jeu, arrêt
  covers.py             jaquettes (boutique Steam)
  steam.py              raccourcis « jeux non-Steam » (VDF binaire)
  saves.py              sauvegarde / restauration des saves
  repack.py             suppression de l'installateur téléchargé (avec garde-fous)
  desktop.py            entrées de menu, icônes, notifications
  audio.py              sourdine de la musique des installateurs (PipeWire)
  ui.py                 fenêtre GTK4 / libadwaita (grille de cartes)
tests/test_core.py      python3 -m unittest discover -s tests
```

**Détection du `.exe`** : l'appli écarte les dossiers système et redistribuables, les utilitaires (désinstalleur, rapporteur de plantage, assistants…) et les fichiers de moins de 200 Ko. Elle classe les autres selon leur taille, leur ressemblance avec le nom du jeu, et donne un bonus aux binaires Unreal `-Win64-Shipping` / `-WinGDK-Shipping`.

**Installation automatique** : l'appli lit le début du `setup.exe` pour reconnaître son type, puis passe les options silencieuses correspondantes.

| Type | Reconnu par | Mode automatique |
|---|---|---|
| Inno Setup (la plupart des repacks) | `JR.Inno.Setup` dans le manifeste | `/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- /DIR=C:\Games\<nom>` |
| NSIS | `Nullsoft.NSIS` | `/S /D=C:\Games\<nom>` |
| MSI | extension `.msi` | `msiexec /i … /qn TARGETDIR=… INSTALLDIR=…` |
| autre | — | pas de mode automatique : l'installateur s'ouvre |

En mode fenêtre, Inno Setup reçoit quand même `/DIR=C:\Games\<nom>`, pour que ce dossier soit proposé par défaut. Le `.exe` est retenu sans question si l'installateur a renvoyé 0 et si le premier candidat devance le deuxième d'au moins 5 points de score, ou s'il est seul. Certains repacks lancent à la fin l'installation de Visual C++ ou DirectX, dont une petite fenêtre peut alors apparaître.

**Suppression de l'installateur** : le dossier téléchargé n'est supprimé en entier que s'il contient le `setup.exe` et ses archives `.bin`, et que ce n'est ni le dossier personnel, ni Téléchargements, Bureau ou Documents, ni le dossier des jeux. Sinon, seuls le `setup.exe` et ses `.bin` sont supprimés.
