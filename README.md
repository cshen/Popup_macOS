# Popup for macOS

[Popup](https://github.com/cshen/Popup_macOS) is a macOS text-selection enhancement tool — select any text and a context-aware floating menu appears instantly. This repo contains the extension ecosystem and tooling around Popup.

Popup is served as an alternative to [PopClip](https://www.popclip.app/), which is not freeware. I have been using PopClip for years and wanted to create a free and open-source alternative that I can customize and extend. With Github Copilot, now it becomes possible. 
Popup is built with Swift. 

Popup supports extensions that can add new actions to the floating menu, allowing you to customize and extend Popup's functionality.
It's a work in progress, but the core extension system is functional and you can start using and building extensions today. The `popext` CLI tool makes it easy to manage your extensions, whether they're sourced from GitHub, local folders, or bundle files.

## What's in this repo

| Path | Description |
|------|-------------|
| `popext` | CLI extension manager — install, update, remove, enable/disable, and list Popup extensions |
| `extension/` | Example extension bundles to learn from or use directly |
| `Popup.dmg` | Popup.app disk image for installation |

## popext — Popup Extension Manager

`popext` is a bash CLI that manages extensions for Popup.app. Extensions live in `~/.config/Popup/extensions/`.

### Install

1. Double click `Popup.dmg` to install Popup.app.
2. Move `popext` to a folder in your PATH, e.g.`~/bin/`, `/usr/local/bin/`.
3. Use `popext install` to add extensions from various sources:
```bash
# From GitHub (owner/repo shorthand or full URL)
popext install a_github_repo/google-scholar

# From a local folder
popext install /path/to/MyExtension/

# From a .popup bundle
popext install ~/Downloads/MyExtension.popup

# From a bundle file (one source per line)
popext install ~/Extfile
```

### Manage

```bash
popext list              # List all installed extensions
popext update            # Pull latest for all GitHub extensions
popext update my-ext     # Pull latest for a specific extension
popext enable  my-ext    # Enable an extension
popext disable my-ext    # Disable an extension
popext remove  my-ext    # Remove an extension entirely
```

## Example Extensions

### Say Words

Reads the selected text aloud using macOS `say` command.

| Field | Value |
|-------|-------|
| `config.toml` | Defines action as `execute_shell_script` calling `script.sh {POPUP_PLAIN_TEXT}` |
| `script.sh` | `say "$@"` |

```toml
name = "Say"
description = "Say the selected text"
author = "C Shen"
version = "1.0"
actions = "execute_shell_script"
shell_script = "script.sh {POPUP_PLAIN_TEXT}"
```

### Search Google Scholar

Opens a Google Scholar search for the selected text in the default browser.

| Field | Value |
|-------|-------|
| `config.toml` | Defines action as `open_url` with a Scholar search URL |

```toml
name = "Google Scholar"
description = "Search Google Scholar for the selected text"
author = "C. Shen"
version = "1.0"
actions = "open_url"
open_url = "https://scholar.google.com/scholar?hl=en&q={POPUP_URLENCODED_TEXT}"
```

## Authoring Extensions

See the [Popup extension authoring guide](https://github.com/cshen/Popup_macOS/blob/main/extension.md) for full documentation on writing your own extensions. Bundled extensions in this repo follow the same layout: a folder with a `config.toml` descriptor and optional scripts/icons.

See the [Popup extension managment tool](https://github.com/cshen/Popup_macOS/blob/main/extension_manage.md) for the design detail of `popext`, the CLI extension manager. You can use `popext` to manage your own extensions.

## Contributing
Contributions to the extension ecosystem are welcome! Fork the repo, add your extension bundle to the `extension/` directory, and submit a pull request. Please ensure your extension follows the standard structure and includes a `config.toml` with all required fields.

## License
This project is licensed under the MIT License. 

