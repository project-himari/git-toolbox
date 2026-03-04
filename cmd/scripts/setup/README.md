
# Setup Scripts (`scripts/setup/`)

このディレクトリには、開発環境（Ubuntu/WSL想定）の初期セットアップを自動化するスクリプトが入っています。  
**初回セットアップは `setup_init.sh` → `setup_csh.sh` → `setup_cadence_env.sh` → `setup_git_hooks.sh`** の順で実行する想定です。

>  重要  
> - すべてのスクリプトは **root 権限（sudo）** が必要です（内部で `apt` / `chsh` / `.git/hooks` 書き込み等を行うため）。  
> - 実行前に `scripts/setup` 配下へ移動せず、リポジトリのルートから実行する運用を推奨します（パスずれ防止）。

---

## 推奨実行手順（初回）

```bash
sudo bash scripts/setup/setup_init.sh
sudo bash scripts/setup/setup_csh.sh
sudo bash scripts/setup/setup_cadence_env.sh
bash scripts/setup/setup_git_hooks.sh
````

* `setup_init.sh` / `setup_csh.sh` / `setup_cadence_env.sh` はパッケージ導入やシェル変更のため sudo 必須です
* `setup_git_hooks.sh` は `.git/hooks` にファイルコピーするだけのため、通常は sudo 不要です（環境により必要な場合あり）

---

## 各スクリプトの説明

### 1. `setup_cadence_env.sh`

Cadenceツール（例：Xcelium）を使用するために必要な依存パッケージをインストールします。

**主な処理**

* `apt update`
* Cadence実行で要求されがちなユーティリティを導入

  * `autofs`, `nfs-common`（ネットワークマウント関連）
  * `ldap-utils`（認証/ディレクトリ連携で必要になることがある）
  * `ksh`（Cadenceが前提とすることがある）
  * `tigervnc-*`（リモートGUI利用想定）
* Perl XML/LDAP/SSL 系の依存ライブラリを導入
* DNSツール（bind9）関連を導入

**実行例**

```bash
sudo bash scripts/setup/setup_cadence_env.sh
```

**注意**

* インストール対象は Ubuntu/Debian 系を想定しています。
* 社内環境によって不要なパッケージがある場合は、適宜削減してください。

---

### 2. `setup_csh.sh`（初回のみ）

tcsh をログインシェルとして使う前提の初期設定を行います。初回のみ実行してください。

**主な処理**

* locale を `en_US.UTF-8` に設定
* 現在ユーザー（`logname`）のログインシェルを `/bin/tcsh` に変更（`chsh`）
* `~/.cshrc` をテンプレート生成

  * PATH、履歴、補完、プロンプト
  * 文字化け対策（LANG）
  * エイリアス（ls/ll/rm/cp など）
  * VNC起動/停止関連のエイリアス例

**実行例**

```bash
sudo bash scripts/setup/setup_csh.sh
```

**注意**

* `chsh` により次回ログインからシェルが tcsh になります。
* `.cshrc` 内のパス（Cadence/Xilinx 等）は環境に合わせて更新してください。

---

### 3. `setup_git_hooks.sh`

プロジェクトで配布している Git hooks を `.git/hooks/` に反映します。
（コミット前チェックやフォーマットチェック等を hooks で統一する場合に使用）

**主な処理**

* リポジトリルートを取得（`git rev-parse --show-toplevel`）
* `scripts/git_files_backup/hooks/*` を `.git/hooks/` にコピー
* 実行権限を付与

**実行例**

```bash
bash scripts/setup/setup_git_hooks.sh
```

**注意（パス）**

* hooks の配置元は `scripts/git_files_backup/hooks/` を前提としています。ディレクトリ名を変更した場合は本スクリプトも更新してください。
* `chmod +x ../.git/hooks/*` の相対パスは実行位置によってずれる可能性があります。
  可能なら以下のように **絶対パス**で chmod する運用が安全です。

  * `chmod +x "$PROJECT_ROOT/.git/hooks/"*`

---

### 4. `setup_init.sh`（初回実行用）

Ubuntu 環境をプロジェクト作業に必要な状態へ初期化します（基本ツール導入＋Git初期設定）。

**主な処理**

* `apt update && apt upgrade -y`
* 基本ツールのインストール（例）

  * `git`, `curl`, `wget`, `vim`, `tree`, `build-essential`, `python3/pip`
  * `tcsh`, `locales`
  * ドキュメント系：`pandoc`, `evince`
  * LFS：`git-lfs`
* Git LFS 初期化（`git lfs install`）
* pipツール導入（例：`xlsx2csv`）
* locale を `en_US.UTF-8` に設定
* Gitのグローバル設定

  * user.name / user.email（ユーザー入力）
  * editor / merge.tool / push.default など

**実行例**

```bash
sudo bash scripts/setup/setup_init.sh
```

**注意**

* スクリプト内で `EMAIL` の入力が抜けているため、実行時にエラーになります。
  `read -p "Gitのメールアドレスを入力してください: " EMAIL` を追加してください。
* `core.editor` に `code --wait` を設定しています。VSCodeが入っていない環境では変更が必要です。

---

## 期待するディレクトリ構成

* Git hooks の配置元：

  * `scripts/git_files_backup/hooks/`
* 本READMEとセットアップスクリプト：

  * `scripts/setup/`

---

