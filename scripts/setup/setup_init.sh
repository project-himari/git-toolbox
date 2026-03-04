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
# 1. パッケージ更新と基本ツールの導入
#----------------------------------------#
apt update && apt upgrade -y

echo "[INFO] Installing core tools..."
apt install -y \
    git \
    curl \
    wget \
    unzip \
    zip \
    tree \
    vim \
    nano \
    net-tools \
    build-essential \
    software-properties-common \
    locales \
    tcsh \
    python3 \
    python3-pip \
    pandoc \
    evince \
    bzip2 \
    git-lfs

# Git LFS 初期化
git lfs install

# pip環境の再読み込み
export PATH="$HOME/.local/bin:$PATH"
hash -r

# pipツール（xlsx2csvなど）
pip3 install --upgrade pip
pip3 install xlsx2csv

#----------------------------------------#
# 2. ロケールとタイムゾーン設定
#----------------------------------------#
echo "[INFO] Setting locale and timezone..."
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8


#----------------------------------------#
# 3. Git初期設定
#----------------------------------------#
echo "[INFO] Gitの初期設定..."
# ユーザー名の入力を促す
read -p "Gitのユーザー名を入力してください: " USERNAME

# メールアドレスの入力を促す
read -p "Gitのメールアドレスを入力してください: " EMAIL


# Gitの設定を適用
git config --global user.name "$USERNAME"
git config --global user.email "$EMAIL"
git config --global core.editor 'code --wait'
git config --global merge.tool 'code --wait "$MERGED"'
git config --global push.default simple


echo "Gitの設定が完了しました！"
git config --global --list
