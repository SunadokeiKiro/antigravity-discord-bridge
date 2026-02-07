# 📄 System Specification: Antigravity-Discord Bridge for Android

## 1. 概要
本プロジェクトは、Mac miniをAI開発サーバーとして運用し、スマホ（Discord）から自律型AIエージェント「Antigravity」を操作するためのブリッジ・システムである。
Discordをインターフェースとすることで、場所を選ばず、チャット形式でAIにコーディング作業（実装、ビルド、テスト）を依頼し、その結果（Diffやスクリーンショット）を受け取ることができる。

---

## 2. アーキテクチャ構成

### A. 通信フロー
1.  **スマホ (Discord):** 特定のチャンネル（プロジェクト別）に指示を送信。
2.  **Mac mini (Bridge):** Discord Botがメッセージを受信し、該当するディレクトリへ移動。
3.  **Antigravity (AI Engine):** `agy` CLIを起動し、実装タスクを自律的に開始。
4.  **Feedback:** 実装結果、ビルド成否、差分（Git Diff）をDiscordに返信。

### B. 依存関係とツール
- **Runtime:** Python 3.12+ (asyncio), Node.js (for PM2)
- **Package Manager:** `uv` (Python), `pnpm` (Node.js)
- **AI Agent:** Google Antigravity (`agy` CLI)
- **Development:** 各種ビルドツール (Gradle, npm等)
- **Security:** `python-dotenv`, Git (Local-only)

---

## 3. 実装要件 (Requirements)

### 1) マルチプロジェクト管理
- `mapping.json` でDiscordチャンネルIDとローカルパスを紐付ける（`{"id": "path"}` 形式）。
- `uv` のキャッシュ機能を活用し、全プロジェクトでライブラリを高速共有する。

### 2) 自律実行 (Autonomous Flow)
- 指示受信時、自動で `git commit` を行い、作業前のスナップショットを作成する。
- `asyncio.create_subprocess_exec` を使用し、非同期で `agy` を実行。長時間タスクでもDiscord Botがタイムアウトしない設計にする。



### 4) Macデスクトップ連携機能 (New)
- **スクリーンショット:** `!screen` コマンドまたはタスク完了時に、Antigravityのウィンドウを自動撮影してDiscordに送信する。
- **ウィンドウ制御:** `osascript` (AppleScript) を使用してAntigravityウィンドウの特定、フォーカス、およびキー入力（新規チャット作成等）を制御する。

### 5) セキュリティと秘匿
- **Secret Masking:** Discordにログを流す際、`.env` 内の変数やAPIキーを正規表現で検出し、`[SECRET_MASKED]` に置換する。

---

## 4. コマンド仕様 (Commands)

### A. 自動化フロー (Default)
Discordに自然言語で指示を送ると、自動的に以下のフローが実行される。
1. `git commit` (バックアップ)
2. Antigravityウィンドウのフォーカス / 新規チャット作成
3. 指示の貼り付け & 実行
4. ファイル監視 (最大5分)
5. `git diff` の抽出 & 送信
6. 自動スクリーンショット送信

### B. ユーティリティコマンド
| コマンド | エイリアス | 動作 |
| :--- | :--- | :--- |
| `!reset` | `!new`, `/reset` | 新規チャットを強制的に開き、指示待ち状態にする。 |
| `!screen` | `/screen` | プロジェクトウィンドウを撮影。`full` または `all` を付けると画面全体を撮影。 |
| `!verify` | `/verify` | Antigravityを介さず、手動で検証フロー (Diff確認) を実行する。 |

---

## 5. ローカライズ (Localization)
- ユーザーへの応答メッセージは全て**日本語 (Japanese)** で統一する。

---

## 6. 運用コマンド
- **Botの永続化:** `pm2 start main_bridge.py --interpreter python3`
- **スリープ防止:** `caffeinate -dis &`
