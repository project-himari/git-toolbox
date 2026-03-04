# Logic License Checker

Logic License Check ver.4  
Last update: 2024/02/21  
Author: kazama@Shibaura  

本スクリプトは、Cadenceライセンス（例：Xcelium）の  
使用状況確認およびライセンス強制解放（lmremove）を行うための  
cshベースのユーティリティです。

---

# 1. 概要

本スクリプトは以下を提供します：

- ライセンス使用状況の確認
- 定期更新表示（ループ表示）
- ライセンス強制解放（lmremove）
- 特定ライセンスサーバーの全表示

内部で `lmstat` および `lmremove` を使用しています。

---

# 2. ファイル構成

```
lic     ← コマンド実装(メインスクリプトのラッパーファイル)
license_checker.csh   ← メインスクリプト
func_menu.sh          ← メニュー表示用サブスクリプト（自動生成）

````

初回実行時に `func_menu.sh` が自動生成されます。

---

# 3. alias設定

## ① alias設定（推奨）

`.cshrc` に以下を追加してください：

```csh
alias lic 'source <GIT_ROOT>/scripts/utility/license_checker/license_checker.csh'
````

例：

```csh
alias lic 'source /home/user/git/CMVP/scripts/utility/license_checker/license_checker.csh'
```

---

# 4. 使用方法

## 4.1 通常表示

```
lic
```

現在のライセンス使用状況を表示します。

表示例：

```
#=============================================#
#Status of License(Use/Total)
#=============================================#
 2/8 : Xcelium
```

---

## 4.2 ループ表示

```
log_lic -l
```

300秒ごとに自動更新します。

終了するには：

```
Ctrl + C
```

---

## 4.3 更新間隔指定

```
lic -l 60
```

60秒間隔で更新します。

---

## 4.4 ライセンス削除モード

```
lic -rm
```

手順：

1. 対象ライセンス選択
2. 使用中ユーザー選択
3. 確認メッセージ
4. lmremove実行

⚠ 注意：
誤って削除すると他ユーザーの作業に影響します。

---

## 4.5 全ライセンス情報表示

```
lic -a
```

選択したサーバーの全ライセンス情報を表示します。

---

## 4.6 ヘルプ

```
lic -h
```

---

# 5. 設定項目

スクリプト内の「User settings」セクションで変更可能：

```csh
set SERVER1 = '5280@scu-proj'
set SERVER2 = 'xxxx@example'
```

### 対象ライセンス名

```csh
set FEAUTURE_ARRAYS = (Xcelium_Single_Core)
set LABEL_ARRAYS    = (Xcelium)
```

複数追加可能：

```csh
set FEAUTURE_ARRAYS = (Xcelium_Single_Core Genus Conformal)
set LABEL_ARRAYS    = (Xcelium Genus LEC)
set SERVER_ARRAYS   = ($SERVER1 $SERVER1 $SERVER2)
```

---

# 6. 動作要件

* tcsh / bash
* lmstat コマンド使用可能
* lmremove コマンド使用可能
* ライセンスサーバーへの接続可能

---

# 7. 内部動作概要

処理フロー：

1. `git rev-parse --show-toplevel` でルート取得
2. lmstat実行
3. awk/sedで整形
4. メニュー表示（bashサブスクリプト）
5. 結果表示

---

# 8. セキュリティ注意事項

* lmremoveは管理者のみ使用推奨
* 削除ログは残らないため、運用ルールを決めること
* 共有環境では乱用禁止

---

# 9. トラブルシュート

## lmstatが動かない

PATHにCadence環境が入っているか確認：

```
which lmstat
```

---

## gitルートが取得できない

Git管理外ディレクトリで実行していないか確認：

```
git rev-parse --show-toplevel
```

---

# 10. 更新履歴

* ver.4 (2024/02/21)

---

# 11 免責事項

本スクリプトによるライセンス削除により発生した問題について、
作成者は責任を負いません。

運用ルールを定めた上で使用してください。

