# Popup for macOS

[Popup](https://github.com/cshen/Popup_macOS) 是一款 macOS 文本选择增强工具——选中任意文本，一个上下文感知的浮动菜单会立刻弹出。本仓库包含 Popup 的扩展生态和相关工具。

Popup 是 [PopClip](https://www.popclip.app/) 的替代方案。

Popup 支持通过扩展为浮动菜单添加新的操作，让你可以自定义和扩展 Popup 的功能。
目前项目仍在开发中，但核心扩展系统已经可用，你可以立即开始使用和构建扩展。`popext` CLI 工具让你可以轻松管理扩展——无论是来自 GitHub、本地文件夹还是 bundle 文件。

## 仓库内容

| 路径 | 说明 |
|------|------|
| `Casks/popup.rb` | 用于安装 Popup.app 的 Homebrew cask |
| `popext` | CLI 扩展管理器——安装、更新、删除、启用/禁用和列出 Popup 扩展 |
| `extension/` | 示例扩展包，可用于学习或直接使用 |
| `Popup.dmg` | Popup.app 安装磁盘映像 |

## popext — Popup 扩展管理器

`popext` 是一个 bash CLI 工具，用于管理 Popup.app 的扩展。扩展存放在 `~/.config/Popup/extensions/` 目录下。

### 安装

1. 使用 Homebrew 安装 Popup.app：
```bash
brew tap cshen/popup_macos https://github.com/cshen/Popup_macOS
brew install --cask cshen/popup_macos/popup
```
2. 或者双击 `Popup.dmg` 手动安装 Popup.app。
3. 将 `popext` 移动到 PATH 中的某个目录，如 `~/bin/` 或 `/usr/local/bin/`。

```
xattr -cr /Applications/Popup.app/
```
to remove quarantine attribute if you get "can't be opened because it is from an unidentified developer" error.


4. 使用 `popext install` 从各种来源添加扩展：
```bash
# 从 GitHub（支持 owner/repo 缩写或完整 URL）
popext install a_github_repo/google-scholar

# 从本地文件夹
popext install /path/to/MyExtension/

# 从 .popup 打包文件
popext install ~/Downloads/MyExtension.popup

# 从 bundle 文件（每行一个源地址）
popext install ~/Extfile
```

### 管理

```bash
popext list              # 列出所有已安装的扩展
popext update            # 拉取所有 GitHub 扩展的最新版本
popext update my-ext     # 拉取指定扩展的最新版本
popext enable  my-ext    # 启用一个扩展
popext disable my-ext    # 禁用一个扩展（不删除）
popext remove  my-ext    # 彻底删除一个扩展
```

## 示例扩展

### Say（朗读）

使用 macOS 自带的 `say` 命令朗读选中的文本。

| 字段 | 说明 |
|------|------|
| `config.toml` | 定义操作为 `execute_shell_script`，调用 `script.sh {POPUP_PLAIN_TEXT}` |
| `script.sh` | `say "$@"` |

```toml
name = "Say"
description = "Say the selected text"
author = "C Shen"
version = "1.0"
actions = "execute_shell_script"
shell_script = "script.sh {POPUP_PLAIN_TEXT}"
```

### Google Scholar（学术搜索）

在默认浏览器中打开 Google Scholar，搜索选中的文本。

| 字段 | 说明 |
|------|------|
| `config.toml` | 定义操作为 `open_url`，使用 Scholar 搜索 URL |

```toml
name = "Google Scholar"
description = "Search Google Scholar for the selected text"
author = "C. Shen"
version = "1.0"
actions = "open_url"
open_url = "https://scholar.google.com/scholar?hl=en&q={POPUP_URLENCODED_TEXT}"
```

## 编写扩展

完整文档请参见 [Popup 扩展编写指南](https://github.com/cshen/Popup_macOS/blob/main/extension.md)。本仓库中的扩展遵循相同的布局：一个文件夹包含 `config.toml` 描述文件和可选的脚本/图标。

`popext` CLI 扩展管理器的设计细节请参见 [Popup 扩展管理工具说明](https://github.com/cshen/Popup_macOS/blob/main/extension_manage.md)。你可以使用 `popext` 管理自己的扩展。

## 贡献

欢迎为扩展生态做出贡献！Fork 本仓库，将你的扩展包添加到 `extension/` 目录，然后提交 Pull Request。请确保你的扩展遵循标准结构，并在 `config.toml` 中包含所有必要字段。

## 许可证

本项目采用 MIT 许可证。
