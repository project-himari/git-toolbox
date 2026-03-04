#!/bin/bash

echo "タグ種別を選択してください:"
echo "1 : release（正式リリース）"
echo "2 : provide（途中リリース）"
echo "3 : received（受領データ）"
echo "4 : キャンセル"
read -p "番号を入力してください（1〜4）: " TYPE_NUM

case $TYPE_NUM in
  1) TYPE="release" ;;
  2) TYPE="provide" ;;
  3) TYPE="received" ;;
  4) echo "操作をキャンセルしました"; exit 0 ;;
  *) echo "無効な選択です"; exit 1 ;;
esac

read -p "component名を入力してください（空欄でもOK）: " COMPONENT
read -p "タグを付けるコミットID（空欄ならHEAD）: " COMMIT

DATE=$(date +%y%m%d)
TAG="${TYPE}_${DATE}"
if [ -n "$COMPONENT" ]; then
  TAG="${TAG}_${COMPONENT}"
fi
COMMIT=${COMMIT:-HEAD}

echo ""
echo "以下の内容でタグを作成します:"
echo "------------------------------"
echo "タグ名       : $TAG"
echo "対象コミット : $COMMIT"
echo "------------------------------"
read -p "この内容で進めますか？ (y/n): " CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "タグ作成をキャンセルしました"
  exit 0
fi

git tag "$TAG" "$COMMIT"
git push origin "$TAG"

echo "タグ '$TAG' をリモートにpushしました"
