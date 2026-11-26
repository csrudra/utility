# Demon's Souls PC

Lanceur PC pour **Demon's Souls** (remake PS5, Bluepoint 2020), à partir de **ta propre copie** du jeu.
Depuis la 0.2, le jeu tourne sur **KytyPS5 optimisé pour Demon's Souls** (le fork de
[chenxiao07](https://github.com/chenxiao07/KytyPS5)) : **60 FPS en jeu** sur un PC de jeu récent.

> Aucun fichier du jeu n'est fourni. Il te faut un dump PS5 déchiffré de Demon's Souls que tu as obtenu légalement.

## État (version 0.2.3)

- **Moteur** : KytyPS5 de chenxiao07. Le jeu n'est pas converti : le moteur lit ton dump tel quel, sans le
  modifier. Testé : écran titre, « Continuer » avec une sauvegarde, partie en jeu.
- **Performances** : **60 FPS stables en jeu** en 2560 × 1440 sur Ryzen 7 9800X3D + RTX 5070 (1 % bas : 58).
  D'après chenxiao07 : ~60 FPS sur i9-14900K + RTX 5090, 40-60 sur une carte de 8 Go, ~30 sur Steam Deck.
- **Conseillé** : 32 Go de RAM et 12 Go de mémoire vidéo ; 16 Go d'espace libre (caches de shaders).
- **Versions du jeu obligatoires : PPSA01341 01.007 (conseillée, testée) ou 01.005.** Les autres (01.000, 01.004…)
  sont refusées : les optimisations du moteur ne s'y appliquent pas (rendu plus lourd, plus de saccades). Mets ton
  dump à jour avec le patch 01.007.
- **Génération d'images** (0.2.2) : NVIDIA DLSS ×2 à ×4 (RTX 40/50) et AMD FSR 3 ×2 (toutes cartes), calée sur le
  rafraîchissement de l'écran. Sur un écran 165 Hz : jeu jusqu'à 82 FPS en ×2 (~70-80 mesurés sur 9800X3D + RTX 5070),
  soit ~150-160 images affichées.
- **Mise à l'échelle** (0.2.2) : NVIDIA DLSS (Qualité à Ultra Performance) et DLAA, AMD FSR 3.
- **Objectifs** (0.2.2) : Fluide, Équilibré ou Silencieux, réglés selon ton PC avec la raison de chaque réglage.
- **Lanceur en plein écran et 100 % manette** (0.2.3) : s'ouvre en plein écran (ou en fenêtre si tu le choisis), se
  pilote entièrement à la manette (Xbox, DualSense, DualShock 4…) ; c'est lui qui s'ouvre au **Jouer** de RecompLauncher.
- Pas encore : mode en ligne.

## Premier lancement : préparation des shaders (obligatoire)

Au premier **Jouer**, une fenêtre « Préparation des shaders » prépare **tous** les shaders et pipelines du jeu pour ta
carte graphique, dans tous les mondes. Sans elle, le jeu se fige (parfois plusieurs secondes) la première fois qu'une
zone ou un effet apparaît : c'était la cause des saccades signalées en 0.2.0.

- Deux étapes : la **compilation des pipelines**, puis la **traduction des shaders PS5** pour ton PC (le moteur, caché,
  qui affichait sinon « Preparing shaders » avant ou pendant la partie).
- Durée : **~40 min** sur un Ryzen 7 9800X3D, **1 h 30 à 2 h ou plus** sur un PC plus modeste ; processeur à fond.
- **Obligatoire** : le jeu ne se lance qu'une fois tout prêt, puis tout seul. Fermer la fenêtre arrête la préparation
  sans lancer le jeu ; ce qui est fait est gardé et la suite reprend au prochain lancement. En cas d'échec, la
  fenêtre propose de réessayer.
- À refaire seulement après une mise à jour du moteur ou du **pilote graphique** (le cache est propre au pilote).
  Les installations préparées en 0.2.0 (mode rapide) refont une passe complète, en reprenant ce qui est déjà fait.
- Page Installation → **« Précompiler les shaders »** : la même préparation, lancée à la main.

## Jouer

### Avec le lanceur seul

1. Télécharge `DemonsSoulsPC.exe` depuis la dernière release et lance-le.
2. Choisis le dossier d'installation (par défaut `C:\DemonsSoulsPC`, hors OneDrive) : le lanceur télécharge son
   runtime (55 Mo, vérifié par SHA-256).
3. Indique le dossier de ton dump (celui qui contient `eboot.bin`, `sce_module` et `sce_sys`). Il n'est jamais
   modifié.
4. Règle l'affichage, puis **Jouer**.

Windows SmartScreen peut avertir au premier lancement (exe non signé) : « Informations complémentaires » puis
« Exécuter quand même ».

### Plein écran et manette (0.2.3)

- Le lanceur s'ouvre **en plein écran**. Le bouton en haut à droite (ou **F11**, **Alt+Entrée**, le bouton
  **Vue / Create** de la manette) passe en fenêtre ; ce choix est gardé pour les fois suivantes.
- **À la manette** : croix ou stick gauche = se déplacer, **A / ×** = choisir (ouvre aussi les listes), **B / ○** =
  retour, **X / □** = info ⓘ du réglage, **LB / RB** = page précédente / suivante, **Start / Options** = Jouer,
  **Y / △** = Quitter. Un cadre doré montre le réglage choisi et un bandeau rappelle les boutons.
- Manettes Xbox (et compatibles XInput : SCUF, 8BitDo…), DualSense et DualShock 4 (USB et Bluetooth), lues seulement
  quand le lanceur est au premier plan et sans jamais rien leur envoyer.

### Avec RecompLauncher

Le dépôt contient un `recomplauncher.json` : RecompLauncher installe le zip `DemonsSoulsPC-v<version>-Windows-x64.zip`,
lance `DemonsSoulsPC.exe --prepare "<dump>"` (runtime + mise en place, lignes `progress`). Son bouton **Jouer**
lance `DemonsSoulsPC.exe --launcher` (0.2.3) : le lanceur s'ouvre en plein écran (ou en fenêtre si tu l'as choisi),
tu règles ce que tu veux puis **Jouer** ; il se cache pendant la partie et se ferme avec le jeu, en rendant à
RecompLauncher le code de fin du jeu (ses messages en cas de plantage restent valables). La préparation des shaders
s'ouvre au premier lancement. Un dump dans une autre version que 01.007 ou 01.005 est refusé avec un message.

### Mise à jour

- **Depuis la 0.2.2** : automatique ; seul le lanceur change (même runtime, pas de nouvelle préparation des shaders).
- **Depuis la 0.2.0 / 0.2.1** : automatique ; le lanceur télécharge le runtime 0.2.2 (DLSS, génération d'images).
  Tes sauvegardes, réglages et caches de shaders sont gardés.
- **Depuis la 0.1** : automatique ; tes sauvegardes sont reprises (copie de secours dans `Build\saves-0.1`), l'ancien
  jeu converti est supprimé et tes réglages sont convertis.

## Réglages

Le plus simple : choisis un **Objectif** (page Graphismes), le lanceur règle le reste pour ton PC. La bulle ⓘ donne la
raison de chaque réglage. Changer un réglage à la main passe en **Personnalisé**.

| Objectif | Sur un Ryzen 7 9800X3D + RTX 5070 et un écran 165 Hz |
|---|---|
| **Fluide** (le plus de FPS) | génération d'images ×2 calée sur l'écran, Reflex, graphismes comme sur PS5 |
| **Équilibré** (60 FPS, plus belle image) | 60 FPS + VSync, NVIDIA DLAA, sans génération d'images |
| **Silencieux** (60 FPS, carte au repos) | 60 FPS + VSync, DLSS Qualité, graphismes « bas » |

Sur ce jeu, c'est surtout le **processeur** qui limite (~70 FPS même sur un 9800X3D) : baisser les graphismes ou
activer DLSS/FSR donne peu de FPS en plus. Le vrai gain, c'est la génération d'images.

| Réglage | Effet |
|---|---|
| Génération d'images | **NVIDIA DLSS ×2/×3/×4** (RTX 40 pour ×2, RTX 50 jusqu'à ×4, Reflex inclus) ou **AMD FSR 3 ×2** (toutes cartes récentes). Le jeu tourne à « rafraîchissement de l'écran ÷ facteur » (165 Hz : ×2 → 82, ×3 → 55, ×4 → 41), jamais sous 40 ; sur un écran 60 Hz, elle n'apporte rien. VSync indisponible avec elle : utilise G-Sync/FreeSync |
| Mise à l'échelle | **Celle du jeu**, **NVIDIA DLSS** Qualité / Équilibré / Performance / Ultra Performance, **DLAA**, ou **AMD FSR 3** ; sortie à la taille de la fenêtre. Avec DLSS en plus de la génération d'images NVIDIA, celle-ci peut se couper par moments |
| Graphismes | **Standard** (le jeu comme sur PS5), **Bas** ou **Très bas** (ombres et détails lointains réduits, textures plus petites) |
| Images/s | **30** (stable), **60** (celle du jeu, conseillée) ou **jusqu'à 120** (sans génération d'images) |
| Résolution | 720p à 1440p, et 21:9 (2560 × 1080, 3440 × 1440) |
| Plein écran, VSync, compteur de FPS (F8 en jeu) | comme d'habitude ; le compteur compte les images générées |

Manette conseillée (prise en charge par le moteur) ; au clavier, J/L/K/I = ×/○/□/△.
Sauvegardes : `Build\Engine\_SaveData`. Réglages : `Build\dspc-settings.json`.

## Lignes de commande

| Commande | Rôle |
|---|---|
| `DemonsSoulsPC.exe --prepare "<dump>"` | installe ou met à jour le runtime à côté de l'exe, puis met le jeu en place (sans fenêtre) |
| `DemonsSoulsPC.exe --launcher` | ouvre le lanceur (bouton Jouer de RecompLauncher) ; après la partie, il se ferme avec le code de fin du jeu |
| `DemonsSoulsPC.exe --play` | lance le jeu avec les réglages enregistrés (préparation des shaders d'abord si besoin) |
| `DemonsSoulsPC.exe --precompile` | préparation complète des shaders (pipelines puis traduction), sans fenêtre (lignes `progress`) |
| `DemonsSoulsPC.exe --translate` | seulement la traduction des shaders par le moteur (caché), code 0 une fois faite |
| `DemonsSoulsPC.exe --run [options]` | lance le jeu avec les options du moteur données (`-Width 1920 -Height 1080`, `-Set KYTY_X=1`…), sans passer par la préparation ; sans `-Set`, la traduction des shaders se fait avant le jeu |
| `DemonsSoulsPC.exe --remove-game` | retire la mise en place (le dump n'est pas touché) |

Journaux : dossier `Logs`, celui que joint le rapport de RecompLauncher.
- `dspc-summary.log` : le résumé de la dernière partie (PC, versions, réglages, shaders, FPS par minute, problèmes
  signalés par le moteur, code de fin). À lire en premier. Comme le rapport de RecompLauncher n'envoie qu'un seul
  `.log`, ce résumé est aussi recopié à la fin de `engine-last.log` et de `game-run.log`.
- `engine-last.log` : l'essentiel du journal du moteur de la dernière partie.
- `dspc-launch.log` (options passées au moteur), `game-run.log`, `precompile.log`, `setup.log`, `dspc-error.log`.

Le nom d'utilisateur Windows est masqué dans le résumé. Les journaux complets du moteur sont dans
`Build\Engine\logs` (les 10 dernières parties).

## Construire

- Lanceur : `MSBuild DemonsSoulsPC.App\DemonsSoulsPC.App.csproj -restore -p:Configuration=Release`
  (.NET Framework 4.8, un seul exe : les DLL sont embarquées).
- Runtime : `Tools\release\make_runtime.ps1` (reprend la release Windows `v20261121` de chenxiao07/KytyPS5, commit
  `65433d2e`, sans ses scripts .cmd ni son lanceur ; ajoute `SOURCE.txt`, `engine-version.txt`, NVIDIA Streamline
  2.14.16 avec DLSS / DLSS-G / Reflex (`-Streamline`) et `amd_fidelityfx_vk.dll` du FidelityFX SDK 1.1.4
  (`-FidelityFx`)).
- Zip RecompLauncher : `Tools\release\make_launcher_zip.ps1 -Version 0.2.3`.
- Icône (originale, aucune image du jeu) : `Tools\release\make_icon.ps1`.

## Crédits et licences

- **[chenxiao07/KytyPS5](https://github.com/chenxiao07/KytyPS5)** : le moteur (émulateur KytyPS5 optimisé pour
  Demon's Souls), distribué sans modification dans le runtime sous **licence GPL-2.0** (texte dans
  `Build\Engine\LICENSE`, code source : lien dans `Build\Engine\SOURCE.txt`). Sur ton PC, le lanceur y retouche
  deux choses, décrites dans `SOURCE.txt` : le mode « économie de mémoire » (coupé : il ralentissait le jeu sur la
  plupart des PC de 32 Go) et le titre de la fenêtre (« Demon's Souls PC »). Rien de modifié n'est distribué.
- **NVIDIA Streamline, DLSS, DLSS Frame Generation et Reflex** (licence MIT pour Streamline, licences NVIDIA DLSS et
  Reflex jointes) et **AMD FidelityFX SDK / FSR 3** (licence MIT) : fichiers redistribuables d'origine, dans le
  runtime.
- **[KytyPS5](https://github.com/KytyPS5/KytyPS5) / Kyty** (InoriRus et contributeurs) : l'émulateur d'origine.
- **[AkiBot](https://github.com/Razoc/AkiBot)** et son amont **[pcportastrobot](https://github.com/imnotsharingmyname/pcportastrobot)** :
  le lanceur dont ce projet est dérivé.
- Demon's Souls appartient à Sony Interactive Entertainment. Projet non officiel, sans lien avec Sony, Bluepoint ni
  les auteurs de KytyPS5.
