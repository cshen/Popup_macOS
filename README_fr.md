# Popup for macOS

[Popup](https://github.com/cshen/Popup_macOS) est un outil d'amélioration de la sélection de texte pour macOS — sélectionnez n'importe quel texte et un menu flottant contextuel apparaît instantanément. Ce dépôt contient l'écosystème d'extensions et les outils associés à Popup.

Popup se veut une alternative à [PopClip](https://www.popclip.app/), qui n'est pas un logiciel gratuit. J'utilise PopClip depuis des années et je souhaitais créer une alternative gratuite et open source que je peux personnaliser et étendre. Avec GitHub Copilot, c'est désormais possible.
Popup est développé en Swift.

Popup prend en charge les extensions qui permettent d'ajouter de nouvelles actions au menu flottant, vous permettant de personnaliser et d'étendre les fonctionnalités de Popup.
C'est un travail en cours, mais le système d'extensions principal est fonctionnel et vous pouvez commencer à utiliser et à créer des extensions dès aujourd'hui. L'outil CLI `popext` facilite la gestion de vos extensions, qu'elles proviennent de GitHub, de dossiers locaux ou de fichiers bundle.

## Contenu de ce dépôt

| Chemin | Description |
|------|-------------|
| `Casks/popup.rb` | Cask Homebrew pour installer Popup.app |
| `popext` | Gestionnaire d'extensions en CLI — installer, mettre à jour, supprimer, activer/désactiver et lister les extensions Popup |
| `extension/` | Exemples de bundles d'extensions pour apprendre ou utiliser directement |
| `Popup.dmg` | Image disque de Popup.app pour l'installation |

## popext — Gestionnaire d'extensions Popup

`popext` est un CLI bash qui gère les extensions pour Popup.app. Les extensions se trouvent dans `~/.config/Popup/extensions/`.

### Installation

1. Installez Popup.app avec Homebrew :
```bash
brew tap cshen/popup_macos https://github.com/cshen/Popup_macOS
brew install --cask cshen/popup_macos/popup
```
2. Ou double-cliquez sur `Popup.dmg` pour installer Popup.app manuellement.
3. Déplacez `popext` dans un dossier de votre PATH, par exemple `~/bin/`, `/usr/local/bin/`.
4. Utilisez `popext install` pour ajouter des extensions depuis différentes sources :
```bash
# Depuis GitHub (raccourci owner/repo ou URL complète)
popext install a_github_repo/google-scholar

# Depuis un dossier local
popext install /path/to/MyExtension/

# Depuis un bundle .popup
popext install ~/Downloads/MyExtension.popup

# Depuis un fichier bundle (une source par ligne)
popext install ~/Extfile
```

### Gestion

```bash
popext list              # Lister toutes les extensions installées
popext update            # Mettre à jour toutes les extensions GitHub
popext update my-ext     # Mettre à jour une extension spécifique
popext enable  my-ext    # Activer une extension
popext disable my-ext    # Désactiver une extension
popext remove  my-ext    # Supprimer complètement une extension
```

## Exemples d'extensions

### Say Words

Lit le texte sélectionné à voix haute en utilisant la commande `say` de macOS.

| Champ | Valeur |
|-------|-------|
| `config.toml` | Définit l'action comme `execute_shell_script` appelant `script.sh {POPUP_PLAIN_TEXT}` |
| `script.sh` | `say "$@"` |

```toml
name = "Say"
description = "Lire le texte sélectionné à voix haute"
author = "C Shen"
version = "1.0"
actions = "execute_shell_script"
shell_script = "script.sh {POPUP_PLAIN_TEXT}"
```

### Recherche Google Scholar

Ouvre une recherche Google Scholar pour le texte sélectionné dans le navigateur par défaut.

| Champ | Valeur |
|-------|-------|
| `config.toml` | Définit l'action comme `open_url` avec une URL de recherche Scholar |

```toml
name = "Google Scholar"
description = "Rechercher le texte sélectionné sur Google Scholar"
author = "C. Shen"
version = "1.0"
actions = "open_url"
open_url = "https://scholar.google.com/scholar?hl=en&q={POPUP_URLENCODED_TEXT}"
```

## Création d'extensions

Consultez le [guide de création d'extensions Popup](https://github.com/cshen/Popup_macOS/blob/main/extension.md) pour une documentation complète sur l'écriture de vos propres extensions. Les extensions incluses dans ce dépôt suivent la même structure : un dossier avec un descripteur `config.toml` et des scripts/icônes optionnels.

Consultez [l'outil de gestion d'extensions Popup](https://github.com/cshen/Popup_macOS/blob/main/extension_manage.md) pour les détails de conception de `popext`, le gestionnaire d'extensions en CLI. Vous pouvez utiliser `popext` pour gérer vos propres extensions.

## Contribution

Les contributions à l'écosystème d'extensions sont les bienvenues ! Forkez le dépôt, ajoutez votre bundle d'extension dans le répertoire `extension/` et soumettez une pull request. Veuillez vous assurer que votre extension suit la structure standard et inclut un `config.toml` avec tous les champs requis.

## Licence

Ce projet est sous licence MIT.
