#!/bin/csh -h
set tmp = "/tmp/.X11-unix"
# シンボリックリンクかどうかを判定
if ( -l $tmp ) then
    echo "$tmp はシンボリックリンクです。処理を実行します。"

    sudo unlink $tmp
    mkdir $tmp
    sudo chown root $tmp
    sudo chgrp root $tmp
    sudo chmod 1777 $tmp
else
    echo "$tmp はシンボリックリンクではありません。処理をスキップします。"
endif


# VNC desktop enviroment install
sudo apt update
sudo apt install -y tigervnc-standalone-server tigervnc-common xfce4 xfce4-goodies dbus-x11 x11-apps
sudo sed -i -e 's|Exec=xfce4-terminal --preferences|Exec=xfce4-terminal --working-directory=$HOME|e' /usr/share/applications/xfce4-terminal.desktop


# /etc/hosts checker (for lmstat)
set cadence_license_server = "192.168.10.100" 
set file = "/etc/hosts"

sudo unlink /lib64/ld-lsb-x86-64.so.3
sudo ln -s /lib64/ld-linux-x86-64.so.2 /lib64/ld-lsb-x86-64.so.3


# grepで確認（sudo権限が必要なので一時ファイルを使う）
if ( `grep  "$cadence_license_server" $file | wc -l` == 0 ) then
    echo "$cadence_license_server" | sudo tee -a $file > /dev/null
    echo "追記しました: $cadence_license_server"
else
    echo "すでに存在しています: $cadence_license_server"
endif


mkdir -p ~/.vnc
cat <<EOF > ~/.vnc/xstartup
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
unset GPG_AGENT_INFO
export DISPLAY=:1 
export XDG_SESSION_TYPE=x11
export GDK_BACKEND=x11
vncconfig -nowin &
exec dbus-launch startxfce4

EOF

chmod +x ~/.vnc/xstartup

#VNC
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8
echo "\n\n"
echo "この後の操作は以下の通りです。"
echo "#=========================================================================#"
echo "#VNCパスワードの設定"
echo "#=========================================================================#"
echo "vncpasswd というコマンドをたたいて8文字以上のパスワードを設定してください。" 
echo ""
echo "#=========================================================================#"
echo "VNCサーバーの起動"
echo "#=========================================================================#"
echo "以下のコマンドをたたいてください。"
echo "vncserver :1 -geometry 1920x1080 -depth 24 -localhost no" 
echo '・:1　はディスプレイ番号(ポート5901)'
echo '・-localhost no を指定すると外部からの接続も可能'
echo '・setenv DISPLAY  :1  をcshrcに追加してください。'
