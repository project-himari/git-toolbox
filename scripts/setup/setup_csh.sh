#!/bin/bash

#========================================#
# Ubuntu初期化スクリプト + tcsh設定
#========================================#

# Rootチェック
if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] Please run as root (e.g. sudo ./init-system.sh)"
    exit 1
fi

echo "=== システム初期化を開始します ==="

#----------------------------------------#
# 2. ロケールとタイムゾーン設定
#----------------------------------------#
echo "[INFO] Setting locale and timezone..."
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8

#----------------------------------------#
# 3. tcsh のログインシェル設定
#----------------------------------------#
echo "[INFO] Setting tcsh as default shell..."

# ユーザー名取得
CURRENT_USER=$(logname)

# tcsh が存在するか確認
if [ -x /bin/tcsh ]; then
    chsh -s /bin/tcsh "$CURRENT_USER"
    echo "[INFO] ログインシェルを tcsh に変更しました（ユーザー: $CURRENT_USER）"
else
    echo "[ERROR] /bin/tcsh が見つかりません。インストールに失敗した可能性があります。"
fi

#----------------------------------------#
# 4. .cshrc テンプレート作成
#----------------------------------------#
echo "[INFO] Creating .cshrc template..."

cat <<EOF > "/home/$CURRENT_USER/.cshrc"
#==============================================================#
# 基本設定 / Basic Configuration
#==============================================================#

umask 007  # ファイル作成時のパーミッション / Default permission mask

# PATH設定 / Set executable search paths
set path = ($path /bin /usr/bin /usr/sbin /usr/local/bin ~/cmd .)
# 追加ツールのパス（必要に応じて変更） / Add custom tool paths
set path = ($path /tools/Xilinx/Vivado/2024.2/bin /home/USERNAME/Tool/XLM2025.03.004/bin)

# 履歴設定 / Command history
set history = 100

# ファイル補完候補表示（tcshのみ）/ Show completion candidates (tcsh only)
set autolist

# 自動ログアウト無効化 / Disable auto logout
unset autologout

# Ctrl-Dでのログアウト防止 / Prevent logout via Ctrl-D
set ignoreeof

# コアダンプサイズ制限 / Limit core dump size
limit coredumpsize 1

# ファイル補完有効化 / Enable filename completion
set filec

#==============================================================#
# プロンプト設定 / Prompt Configuration
#==============================================================#
set prompt = "$ "  # ユーザー名@ホスト名:カレントディレクトリ / User@Host:CurrentDir

#==============================================================#
# 文字化け対策 / Encoding Settings to Prevent Mojibake
#==============================================================#

# ロケール設定 / Locale settings
setenv LANG "en_US.UTF-8"  # 推奨: UTF-8（日本語と英語の混在に強い）/ Recommended: UTF-8 for multilingual support
# setenv LANG "ja_JP.eucJP"
# setenv LANG "ja_JP.UTF-8"
# setenv LANG "C"

# SVNエディタ設定 / Default editor for SVN
setenv SVN_EDITOR vim

#==============================================================#
# エイリアス定義 / Alias Definitions
#==============================================================#

# 基本操作 / Basic commands
alias ll      'ls -la --color=auto'     # 詳細表示 / Detailed listing
alias ls      'ls -aF --color=auto'     # 隠しファイル含む / Show hidden files
alias rm      'rm -iv'                  # 削除確認付き / Confirm before delete
alias cp      'cp -rp'                  # 再帰＋パーミッション保持 / Recursive copy with permissions
alias c       'clear'                   # 画面クリア / Clear screen
alias hi      'history'                 # コマンド履歴 / Show command history
alias psu     'ps -u `whoami`'          # 自分のプロセス表示 / Show own processes

# VNC関連 / VNC operations
setenv DISPLAY :1  # VNCディスプレイ番号 / VNC display number
alias vncoff  "vncserver -kill $DISPLAY"  # VNC停止 / Stop VNC server
alias vncon   "vncserver $DISPLAY -localhost no -geometry 1920x1080 -depth 24"  # VNC起動 / Start VNC server
alias vncls   "vncserver -list"           # VNC一覧 / List VNC sessions


# VSCode CLI（環境に応じて変更）/ VSCode CLI (adjust path as needed)
#alias code '/home/USERNAME/.vscode-server/bin/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/bin/remote-cli/code'

#==============================================================#
# ユーザースクリプト / User Scripts
#==============================================================#
alias vicsh   'vi ~/.cshrc'                      # この設定ファイルを編集 / Edit this file
alias socsh   'so ~/.cshrc'                      # この設定ファイルを再読み込み / Reload this file
EOF

chown "$CURRENT_USER":"$CURRENT_USER" "/home/$CURRENT_USER/.cshrc"

#----------------------------------------#
# 6. 完了メッセージ
#----------------------------------------#
echo "=== 初期化完了！ ==="
echo "次回ログイン時から tcsh が使用されます。"
echo "必要に応じて VNC や Cadence 環境の構築を続けてください。"
