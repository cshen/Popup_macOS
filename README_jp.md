# Popup for macOS

[Popup](https://github.com/cshen/Popup_macOS) は、macOS 向けのテキスト選択強化ツールです。テキストを選択するだけで、コンテキストに応じたフローティングメニューが即座に表示されます。このリポジトリには、Popup の拡張機能エコシステムと関連ツールが含まれています。

Popup はフリーウェアではない [PopClip](https://www.popclip.app/) の代替として提供されています。私は長年 PopClip を使用してきましたが、自由にカスタマイズ・拡張できる無料のオープンソース代替ツールを作りたいと考えていました。GitHub Copilot の登場により、それが実現可能になりました。
Popup は Swift で構築されています。

Popup は拡張機能をサポートしており、フローティングメニューに新しいアクションを追加することで、Popup の機能を自由にカスタマイズ・拡張できます。
現在も開発中ですが、コア拡張システムは機能しており、今すぐ拡張機能を使い始めたり作成したりすることができます。`popext` CLI ツールを使用すると、GitHub、ローカルフォルダ、バンドルファイルなど、さまざまなソースから拡張機能を簡単に管理できます。

## このリポジトリの内容

| パス | 説明 |
|------|-------------|
| `popext` | CLI 拡張機能マネージャー — Popup 拡張機能のインストール、更新、削除、有効/無効化、一覧表示 |
| `extension/` | 学習用またはそのまま使えるサンプル拡張機能バンドル |
| `Popup.dmg` | インストール用 Popup.app ディスクイメージ |

## popext — Popup 拡張機能マネージャー

`popext` は、Popup.app の拡張機能を管理する bash CLI です。拡張機能は `~/.config/Popup/extensions/` に保存されます。

### インストール

1. `Popup.dmg` をダブルクリックして Popup.app をインストールします。
2. `popext` を PATH が通っているフォルダ（例: `~/bin/`、`/usr/local/bin/`）に移動します。
3. `popext install` を使用して、さまざまなソースから拡張機能を追加できます:
```bash
# GitHub から (owner/repo の省略形または完全な URL)
popext install a_github_repo/google-scholar

# ローカルフォルダから
popext install /path/to/MyExtension/

# .popup バンドルから
popext install ~/Downloads/MyExtension.popup

# バンドルファイルから (1行に1つのソース)
popext install ~/Extfile
```

### 管理

```bash
popext list              # インストール済みの全拡張機能を一覧表示
popext update            # すべての GitHub 拡張機能を最新に更新
popext update my-ext     # 特定の拡張機能を最新に更新
popext enable  my-ext    # 拡張機能を有効化
popext disable my-ext    # 拡張機能を無効化
popext remove  my-ext    # 拡張機能を完全に削除
```

## サンプル拡張機能

### Say Words

選択したテキストを macOS の `say` コマンドを使用して読み上げます。

| フィールド | 値 |
|-------|-------|
| `config.toml` | アクションを `execute_shell_script` として定義し、`script.sh {POPUP_PLAIN_TEXT}` を呼び出し |
| `script.sh` | `say "$@"` |

```toml
name = "Say"
description = "選択したテキストを読み上げます"
author = "C Shen"
version = "1.0"
actions = "execute_shell_script"
shell_script = "script.sh {POPUP_PLAIN_TEXT}"
```

### Google Scholar 検索

選択したテキストで Google Scholar 検索をデフォルトブラウザで開きます。

| フィールド | 値 |
|-------|-------|
| `config.toml` | アクションを `open_url` として定義し、Scholar 検索 URL を指定 |

```toml
name = "Google Scholar"
description = "選択したテキストを Google Scholar で検索します"
author = "C. Shen"
version = "1.0"
actions = "open_url"
open_url = "https://scholar.google.com/scholar?hl=en&q={POPUP_URLENCODED_TEXT}"
```

## 拡張機能の作成

独自の拡張機能を作成するための完全なドキュメントについては、[Popup 拡張機能作成ガイド](https://github.com/cshen/Popup_macOS/blob/main/extension.md) を参照してください。このリポジトリに含まれる拡張機能も、`config.toml` 記述子とオプションのスクリプト/アイコンを持つフォルダという同じレイアウトに従っています。

CLI 拡張機能マネージャーである `popext` の設計詳細については、[Popup 拡張機能管理ツール](https://github.com/cshen/Popup_macOS/blob/main/extension_manage.md) を参照してください。`popext` を使用して独自の拡張機能を管理できます。

## コントリビューション

拡張機能エコシステムへの貢献を歓迎します！リポジトリをフォークし、`extension/` ディレクトリに拡張機能バンドルを追加して、プルリクエストを送信してください。拡張機能が標準構造に従い、すべての必須フィールドを含む `config.toml` を備えていることを確認してください。

## ライセンス

このプロジェクトは MIT ライセンスの下で提供されています。
