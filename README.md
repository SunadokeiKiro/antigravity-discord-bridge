# Antigravity-Discord Bridge

このプロジェクトは、Macデスクトップ上のAIエージェント「Antigravity (Agent)」と、スマホ等のDiscordクライアントを橋渡しするシステムです。
スマホからDiscord経由で指示を出すことで、Mac上のAIにコーディング作業（実装、ビルド、テスト）をリモートで依頼できるようになります。

## 🌟 特徴
- **リモート操作**: Discordからチャット感覚でAIに指示を出せます。
- **デスクトップ連携**: Antigravityのウィンドウ操作を自動化し、作業中の画面（スクリーンショット）をDiscordで確認できます。
- **セキュア**: `.env` やAPIキーなどの機密情報はログ出力時にマスクされます。

## 🛠️ 前提条件 (Prerequisites)
- **OS**: macOS (AppleScriptを使用するため)
- **Python**: 3.12以上 (推奨: `uv` による管理)
- **Node.js**: (推奨: `pm2` によるプロセス管理用)
- **Antigravity**: Google製のAIコーディングエージェント (`agy` CLI)
- **Development Tools**: プロジェクトに応じたビルドツール (Android SDK, Node.js等)

## 🚀 セットアップ (Setup)

### 1. 依存関係のインストール
`uv` を使用してPythonパッケージをインストールします。

```bash
uv sync
```

### 2. 環境変数の設定
`.env` ファイルを作成し、Discord Botのトークンを設定します。

```bash
cp .env.example .env
# .envを編集して DISCORD_TOKEN を設定
```

### 3. プロジェクト連携の設定
`mapping.json` を作成し、DiscordのチャンネルIDとローカルのプロジェクトパスを紐付けます。

```json
{
  "123456789012345678": "/Users/username/git/my-android-app",
  "987654321098765432": "/Users/username/git/another-project"
}
```
※ `{"mappings": { ... }}` の形式でも記述可能です（詳細設定を行う場合）。

## 🎮 使い方 (Usage)

### Botの起動
```bash
# 開発用（直接実行）
uv run python main_bridge.py

# 本番運用（PM2推奨）
pm2 start main_bridge.py --interpreter python3
```

### Discordコマンド

#### 1. 基本的な指示
プロジェクトのチャンネルで話しかけるだけです。
> `ボタンの色を赤にして`
> `READMEを日本語に翻訳して`

Botは自動的に以下のフローを実行します:
1. `git commit` (作業前の自動バックアップ)
2. Antigravityに指示を伝達
3. ファイル変更を監視 (最大5分)
4. 完了後、Diffとスクリーンショットを返信

#### 2. ユーティリティコマンド

| コマンド | 説明 |
| :--- | :--- |
| `!screen` | `/screen` | プロジェクトウィンドウを撮影。`full` または `all` を付けると画面全体を撮影。して送信します。 |
| **`!verify`** | エージェントを介さず、手動で検証フロー（Diff確認）を実行します。 |
| **`!reset`** | 強制的に「新しいチャット」を開き、エージェントの状態をリセットします。 |

## ⚠️ トラブルシューティング

### "AppleScript Error" / "UI Scripting"
このBotは `osascript` を使用してウィンドウを操作するため、ターミナル（またはPython/PM2）に **アクセシビリティ権限** が必要です。

1. `システム設定` > `プライバシーとセキュリティ` > `アクセシビリティ` を開く。
2. `Terminal` (または `iTerm`, `VSCode`など実行元のアプリ) を許可リストに追加する。
3. `python` 自体が求められる場合もあるので、その場合は表示に従って許可する。



## 🖥️ Mac miniでの常時運用 (Deployment)

Mac miniなどのサーバーとして運用する場合、以下の設定を行ってください。

### 1. スリープの防止
MacがスリープするとBotも停止します。以下のいずれかの方法でスリープを防いでください。

- **設定:** `システム設定` > `ディスプレイ` > `詳細設定` > `ディスプレイがオフのときに自動でスリープさせない` をONにする。
- **コマンド:** 付属の `run_bridge.sh` を使用する（`caffeinate` コマンドでスリープを抑制します）。

### 2. プロセス管理

#### 簡単な方法 (`run_bridge.sh`)
付属のスクリプトを使用すると、クラッシュ時の自動再起動とスリープ防止が適用されます。

```bash
chmod +x run_bridge.sh
./run_bridge.sh
```

#### 推奨される方法 (PM2)
Node.jsのツール `pm2` を使うと、ログ管理やMac起動時の自動実行が可能です。

```bash
# 1. PM2のインストール
npm install -g pm2

# 2. 起動
pm2 start main_bridge.py --interpreter python3 --name "agy-bridge"

# 3. ログ確認
pm2 logs agy-bridge

# 4. Mac起動時に自動起動するように設定
pm2 startup
pm2 save
```

### 3. ディスプレイについて (Headless)
モニターを接続していない場合、GPUアクセラレーションやスクリーンショット機能が制限されることがあります。
- 画面共有やスクリーンショットが真っ黒になる場合、**HDMIダミープラグ ($5程度)** を挿しておくと解決します。
- ユーザーログオンが必要ですので、「自動ログイン」を有効にしておくことを推奨します。
