# Extension Development Guide

Each extension consists of a folder with files in it. The folder than gets compressed and given file extension ".popup" 
(which is the file extension for Popup extensions, and it's in zip format) and then imported into Popup. 
You can also import the folder directly into SnipDo without compressing it. 

If you want to see how the existing extensions are made of, simply rename the file extension from ".popup" to ".zip", unpack it and look at the contents.The folder HAS to have one file containg all the extension properties in it. This file has to be a TOML formatted file with file extension ".toml" 
and it defines the extension. You can generate json files with your favourite Text Editor or an online Editor to check your syntax. A file defines an object of type extension. An extension can have multiple Actions.

The following tables shows the properties in the .toml file. 
| Property    | Type   | Description |
| ---         | ---    | --- |
| name        | string | The name of the extension. This is the name that shows up in Popup. |
| description | string | A short description of the extension. This is shown in Popup when the user clicks on the extension. |
| author      | string | The name of the author of the extension. This is shown in Popup when the user clicks on the extension. |
| version     | string | The version of the extension. This is shown in Popup when the user clicks on the extension. |
| icon        | string | The path to the icon of the extension. This is shown in Popup when the user clicks on the extension. |
| actions     | string | An actions such as open URL. |
| shell script| string | The script file. Place file in same folder, and chmod +x the file. This is the script that gets executed when the user clicks on the extension. The is optional. When this is provided, action defined above is ignored. |


Each action is one of several available action types. If one of these keys is set the other action types will be ignored.
These types are:
• Open Url
• Execute shell (or Python, perl, etc) script

### Open URL action
The URL specified will be opened in the default browser. To pass the text to the URL simply add one of the following string to it (including brackets):

- {POPUP_PLAIN_TEXT} 
- {POPUP_URLENCODED_TEXT}

POPUP_PLAIN_TEXT passes the text plain, POPUP_URLENCODED_TEXT passes the text in the URL format (so spaces are replaced with %20, etc).

Example:
```toml
name = "Google Search"
description = "Search Google for the selected text"
author = "John Doe"
version = "1.0"
icon = "google.png"
actions = "open_url"
open_url = "https://www.google.com/search?q={POPUP_URLENCODED_TEXT}"
```
A simple use case for this is to open the selected text in a specific app using its URL scheme. For example, to open the selected text in Bear, you canuse the following URL:
```
bear://x-callback-url/create?text={POPUP_PLAIN_TEXT}
```

You can find the URL schemes for different apps online. Here are some resources to find URL schemes for different apps:
https://raw.githubusercontent.com/SKaplanOfficial/macOS-URL-Schemes-for-macOS-Applications/refs/heads/main/README.md
https://jc0b.computer/posts/spelunking-for-url-schemes/

### Execute shell script action
The script file specified will be executed when the user clicks on the extension. The text is passed to the script as an argument. To pass the text to the script simply add one of the following string to the script (including brackets):
- {POPUP_PLAIN_TEXT}
- {POPUP_URLENCODED_TEXT}

Example:
```toml
name = "Run Script"
description = "Run a shell script with the selected text as an argument"
author = "John Doe"
version = "1.0"
icon = "script.png"
actions = "execute_shell_script"
shell_script = "script.sh {POPUP_PLAIN_TEXT}"
```
In this example, when the user clicks on the extension, the script "script.sh" will be executed with the selected text as an argument. The script file should be placed in the same folder as the .toml file and should have execute permissions (chmod +x script.sh).

---

## Implementation Plan

This section describes **how the extension system will be built inside the Popup macOS app**. The spec above defines the user-facing contract; this plan defines the code architecture and the order of work.

---

### Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| TOML parsing | Hand-rolled (no SPM dependency) | Extension `.toml` files are always flat `key = "value"` pairs — no arrays, nested tables, or multiline strings. A 20-line parser is sufficient and avoids dependency complexity. |
| Extension storage | `~/.config/Popup/extensions/<name>/` | XDG-style config directory; one sub-folder per extension; persists across app updates. |
| Icon rendering in popup | `AnyPopupAction` gains an optional `iconURL: URL?` field | When non-nil, `ActionButton` loads `NSImage(contentsOf:)` instead of an SF Symbol. Keeps backward compatibility with all built-in actions (their `iconURL` stays `nil`). |
| Script execution | `Foundation.Process`, launch script directly (no shell wrapper) | The script's **shebang line** (`#!/usr/bin/env python3`, `#!/bin/bash`, etc.) tells the OS which interpreter to use. The app sets the execute bit and calls the script path directly — it does not need to know or care about the language. Text substitution is applied to any arguments defined in `shell_script`. Fire-and-forget (no output capture). |
| Text substitution | Replace `{POPUP_PLAIN_TEXT}` / `{POPUP_URLENCODED_TEXT}` before opening URL or spawning process | Applied to both the URL template and the shell command string. |
| Import: `.popup` file | `unzip` via `Process` into the extensions directory | `.popup` is a zip — use the system `unzip` binary. |
| Import: folder | Copy entire folder with `FileManager.copyItem` | Allows dragging an unpacked extension folder directly. |
| Enable / disable state | JSON file at `~/.config/Popup/extensions_state.json` | Maps extension folder names to `true`/`false`. Kept alongside the extensions so everything is under `~/.config/Popup/` and portable. |
| Default icon | SF Symbol `gearshape` | When an extension's `icon` field is empty, or the icon file is missing/unreadable, the popup button falls back to the `gearshape` SF Symbol. No broken-image state. |

---

### New Files

Where possible, new code is isolated to these files to minimize merge conflicts with ongoing work in `main` branch.

| File | Responsibility |
|------|---------------|
| `Popup/ExtensionModel.swift` | `PopupExtension` struct, TOML parser, text-substitution helpers |
| `Popup/ExtensionManager.swift` | Singleton: scan Extensions directory, import, delete, toggle, load all |
| `Popup/ExtensionAction.swift` | `ExtensionAction` conforming to `PopupAction`; handles `open_url` and `execute_shell_script` |

---

### Modified Files

| File | What changes |
|------|-------------|
| `Popup/Action.swift` | `AnyPopupAction` gains `iconURL: URL?`; `AnyPopupAction.build()` appends enabled extension actions |
| `Popup/PopupView.swift` | `ActionButton` renders `NSImage` from `iconURL` when set (fallback: SF Symbol) |
| `Popup/SettingsView.swift` | New "Extensions" section: list, import, delete, enable/disable toggle |
| `Popup.xcodeproj/project.pbxproj` | Add 3 new Swift source files |

---

### Phase 1 — Data Layer (`ExtensionModel.swift`)

**`PopupExtension` struct**

```swift
struct PopupExtension: Identifiable {
    let id: String            // folder name (unique)
    let folderURL: URL        // absolute path to installed extension folder
    var name: String
    var description: String
    var author: String
    var version: String
    var iconFileName: String  // e.g. "google.png" — file inside folderURL
    var actionType: ActionType  // .openURL | .executeShellScript
    var openURL: String?        // used when actionType == .openURL
    var shellScript: String?    // used when actionType == .executeShellScript
    // Runtime state (not in TOML)
    var enabled: Bool
}

enum ActionType { case openURL, executeShellScript }
```

**TOML parser (flat key = "value" only)**

```
func parseTOML(_ content: String) -> [String: String]
```

- Skip blank lines and lines starting with `#`
- Match `key = "value"` (with optional surrounding whitespace)
- Return a plain `[String: String]` dictionary

**Text substitution**

```
func substitutePlaceholders(_ template: String, plainText: String) -> String
```
- Replaces `{POPUP_PLAIN_TEXT}` with `plainText`
- Replaces `{POPUP_URLENCODED_TEXT}` with `plainText.addingPercentEncoding(...)`

---

### Phase 2 — Extension Manager (`ExtensionManager.swift`)

```swift
class ExtensionManager: ObservableObject {
    static let shared = ExtensionManager()
    @Published var extensions: [PopupExtension] = []

    // ~/.config/Popup/extensions/
    let extensionsDirectory: URL

    func loadAll()          // scan directory, parse each .toml, populate `extensions`
    func `import`(from url: URL) throws   // .popup zip or plain folder
    func delete(_ ext: PopupExtension) throws
    func setEnabled(_ ext: PopupExtension, enabled: Bool)  // persists to extensions_state.json
}
```

**Import logic:**
1. If `url` has extension `.popup`: run `unzip -o <url> -d <extensionsDirectory>` via `Process`
2. If `url` is a directory: `FileManager.copyItem(at: url, to: extensionsDirectory/<name>)`
3. After either, call `loadAll()` to refresh

**loadAll logic:**
1. Create `extensionsDirectory` (`~/.config/Popup/extensions/`) if it doesn't exist
2. Enumerate immediate subdirectories
3. For each, find the first `*.toml` file
4. Parse it, build `PopupExtension`
5. Read `enabled` from `~/.config/Popup/extensions_state.json` (default: `true` if not present)

**extensions_state.json format:**
```json
{
  "DuckDuckGo": true,
  "RunScript":  false
}
```
`setEnabled()` reads this file, updates the key, and writes it back atomically.

---

### Phase 3 — Extension Actions (`ExtensionAction.swift`)

```swift
struct ExtensionAction: PopupAction {
    let id: String           // "ext.<folderName>"
    let title: String        // from TOML name
    let icon: String         // SF Symbol fallback: "puzzlepiece.extension"
    let iconURL: URL?        // path to icon PNG file in extension folder
    let isAvailable = true

    private let ext: PopupExtension

    func execute(text: String, modifiers: NSEvent.ModifierFlags) {
        switch ext.actionType {
        case .openURL:
            // substitute placeholders, open URL
        case .executeShellScript:
            // substitute placeholders in script string, run via Process
        }
    }
}
```

**Shell script execution:**
- The value of `shell_script` in the TOML is the script filename (optionally followed by arguments), e.g. `script.sh {POPUP_PLAIN_TEXT}`
- Resolve the script's full path: `ext.folderURL.appendingPathComponent(scriptName)`
- Ensure execute bit is set on the script file (`chmod +x`) before first run
- Launch directly: `Process()`, `executableURL = scriptFileURL`, `arguments = [substitutedArg1, ...]`
- The **shebang line** in the script (`#!/usr/bin/env python3`, `#!/bin/bash`, etc.) is respected by the OS — the app does not need to know or care about the scripting language

---

### Phase 4 — Action Integration (`Action.swift` + `PopupView.swift`)

**`AnyPopupAction` — add `iconURL: URL?`**

```swift
struct AnyPopupAction: Identifiable {
    ...
    let iconURL: URL?   // non-nil for extension actions only
}
```

`init<A: PopupAction>(_ action: A)`: set `iconURL = nil` for all existing actions.
Add a second initialiser or update the wrapper to accept `iconURL` from `ExtensionAction`.

**`AnyPopupAction.build()` — append extension actions**

```swift
// After all built-in actions:
for ext in ExtensionManager.shared.extensions where ext.enabled {
    actions.append(AnyPopupAction(ExtensionAction(ext: ext)))
}
```

**`ActionButton` — render custom icon when `iconURL` is set**

```swift
// Inside buttonLabel():
if let url = action.iconURL, let img = NSImage(contentsOf: url) {
    Image(nsImage: img).resizable().frame(width: 16, height: 16)
} else {
    Image(systemName: action.icon)
}
```

---

### Phase 5 — Settings UI (`SettingsView.swift`)

New section **"Extensions"** added after "Excluded Applications":

```
┌─ Extensions ────────────────────────────────────────────┐
│  [Import Extension…]                                    │
│                                                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │ 🔲 [icon]  Google Search          v1.0           │   │
│  │            Search Google — John Doe    [Delete]  │   │
│  ├──────────────────────────────────────────────────┤   │
│  │ 🔲 [icon]  Run Script             v2.1           │   │
│  │            Runs script.sh — Jane Doe   [Delete]  │   │
│  └──────────────────────────────────────────────────┘   │
│  (Toggle to enable/disable each extension)              │
└─────────────────────────────────────────────────────────┘
```

- **Import Extension…** button → `NSOpenPanel` (allows files with `.popup` extension + directories)
- Each row: toggle (enable/disable) + icon image + name + version + description + author + Delete button
- On Delete: confirm with `NSAlert` before removing

---

### Phase 6 — Project File + Build

- Add `ExtensionModel.swift`, `ExtensionManager.swift`, `ExtensionAction.swift` to `Popup.xcodeproj/project.pbxproj` (follow same UUID pattern `BFBF00XX...BFBF` used for existing files)
- Run `bash build.sh` to verify clean compile
- Test with a sample extension folder and a `.popup` zip

---

### Sample Extension for Testing

```
TestExtension/
├── extension.toml
└── icon.png
```

`extension.toml`:
```toml
name = "DuckDuckGo"
description = "Search DuckDuckGo for the selected text"
author = "Test"
version = "1.0"
icon = "icon.png"
actions = "open_url"
open_url = "https://duckduckgo.com/?q={POPUP_URLENCODED_TEXT}"
```

Check this webpage for SF Symbols to use as icons in your extensions (or create your own PNG icons):
https://github.com/andrewtavis/sf-symbols-online/blob/master/README_dark.md

---

### Out of Scope (not in this iteration)

- Multiple actions per extension (spec says "An extension can have multiple Actions" but all examples show one; defer until needed)
- Extension update/upgrade flow
- Extension sandboxing or signature verification
- GUI extension builder / wizard

---

## Implementation Status

All six phases above have been implemented and are shipping in the main branch.

### Post-implementation bug fixes

**Import: `.popup` file recognised as `.popup.zip`**

macOS registers `.popup` as a zip UTType, so `NSOpenPanel` appends `.zip` to the returned URL (e.g. `MyExt.popup.zip`). The original code checked `pathExtension == "popup"` and fell through to the folder-check branch, producing a misleading error.

Fix applied:
- Never check `pathExtension` to detect zip/folder — use `FileManager.fileExists(isDirectory:)` first.
- If it is **not** a directory it is treated as a zip regardless of the extension.
- Unzip always targets a UUID temp directory under `FileManager.temporaryDirectory`; after extraction, each sub-folder found is copied to `extensionsDirectory` and the temp dir is cleaned up with `defer`.
- For flat zips (no containing sub-folder), the folder name is derived by stripping `.zip` / `.popup` suffixes from the filename.

**`extensions_state.json` not updated on import**

`loadAll()` used `stateMap[folderName] ?? true` in memory but never wrote the default (`true`) back to disk. So a freshly imported extension only appeared in the JSON after the user manually toggled its switch.

Fix applied:
- After building the loaded array, `loadAll()` detects any new IDs not yet in the state map, writes `true` for them, and also removes stale IDs for deleted extensions.
- `saveStateMap()` is only called when `stateChanged == true` to avoid unnecessary disk writes.

