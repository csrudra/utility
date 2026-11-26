# Scarlett Fusion Lab — PROJET CLÔTURÉ

> **« Je m'avoue vaincu. Microsoft et Rockstar Games ont gagné cette manche. »**
>
> — Décision du mainteneur, **24 novembre 2026**

**Statut : recherche interrompue, dépôt public conservé en archive statique.**
Aucun nouveau développement, essai de compatibilité d'un jeu commercial,
portage ou contournement n'est prévu dans ce projet.

## Le constat

Ce laboratoire indépendant tentait d'étudier les limites de compatibilité
entre différentes plateformes et un PC Windows modeste. Nous avons testé des
capacités GPU, le comportement de la mémoire graphique et de nombreuses
hypothèses techniques. **Nous n'avons pas obtenu de monde jouable ni de
personnage contrôlable.** Afficher une fenêtre ou traduire des opérations
graphiques n'est pas une preuve de compatibilité complète.

J'arrête ici les tentatives. Je préfère désormais consacrer mon énergie au
développement de mon propre jeu : **Tactical Contested Extraction (TCE)**.

## Dépôt assaini

Pour réduire les risques liés à la propriété intellectuelle, la branche
publique actuelle ne conserve que des **outils de diagnostic GPU génériques**
que nous avons écrits, la documentation de clôture et les notices légales.

Ont été retirés de l'arborescence publiée : les lanceurs de titres,
les patchs de runtimes, les adaptations d'émulateurs, les rapports liés à
un titre commercial, les détails de fichiers de jeu et les instructions
de reproduction associées.

**Aucun jeu, asset, texture, shader de jeu, firmware, SDK console propriétaire,
clé, exécutable Xbox, DLL commerciale, dump ou archive du titre n'est
distribué par cet état du dépôt.** Ce projet n'est affilié ni à
Microsoft ni à Rockstar Games. Les marques appartiennent à leurs titulaires.

## Outils conservés

- `Get-HostGpu.ps1` : informations de base sur le GPU installé.
- `Probe-D3D12.ps1` et `tools/d3d12_caps.cpp` : diagnostic matériel
  Direct3D 12 et estimations de budget DXGI pour le processus de la sonde.
- `tests/Check-HostGpu.ps1` et `tests/Check-PowerShellSyntax.ps1` :
  vérifications locales.

Les outils utilisent les API Windows et ne chargent aucune donnée de jeu.
Le rapport de budget DXGI concerne **le processus de la sonde**, pas un
autre logiciel.

### Vérification de base

Sur Windows avec PowerShell 7 et Visual Studio C++ / Windows SDK :

```powershell
.\tests\Check-PowerShellSyntax.ps1
.\tests\Check-HostGpu.ps1
.\Probe-D3D12.ps1
```

Les exécutables générés restent exclusivement en local dans `build/`.
Ce dépôt ne fournit aucun binaire précompilé.

## Avis d'archivage et droits

Voir [PROJECT_CLOSED.md](PROJECT_CLOSED.md),
[SECURITY.md](SECURITY.md), [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)
et [LICENSE](LICENSE).

La suppression de fichiers d'une branche ne supprime **pas nécessairement**
les anciennes copies, les archives de GitHub, l'historique des issues ou les
clones. Ce nettoyage réduit la surface de publication actuelle ; **il ne
constitue pas une garantie juridique contre une notification DMCA**.

*Merci à celles et ceux qui ont participé aux tests. Fin de l'expérience.*
