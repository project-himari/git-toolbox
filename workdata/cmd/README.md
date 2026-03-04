# dirdiff.sh 利用ガイド（社内配布用）

本書は、ファイル／ディレクトリ比較ツール `dirdiff.sh` の利用方法をまとめたものです。
RTLに限らず、コード・テキスト・各種成果物の比較に利用できます。

---

## 1. 目的

`dirdiff.sh` は、比較対象の差分を効率的に確認するためのスクリプトです。

主な用途:

* 委託先納品データの差分確認
* バージョン違いのソース比較
* RTL/コード/テキストの比較
* 改行コード差（CRLF/LF）を無視した比較
* 自動マップ生成後の手動調整による比較

---

## 2. 対応する比較パターン

本ツールは以下をサポートします。

* **file vs file**（対応）
* **dir vs dir**（対応）
* **file vs dir**（非対応、エラー）
* **dir vs file**（非対応、エラー）

> `file vs dir` は曖昧な動作になりやすいため、仕様としてエラーにしています。

---

## 3. 主な機能

* ファイル単体比較（file vs file）
* ディレクトリ比較（dir vs dir）
* 同名（同一相対パス）ファイルの自動マッピング
* 手動マップ指定（完全手動）
* rename マップ指定（一部手動）
* 自動マップの保存・再利用
* 再帰比較（サブディレクトリ含む）
* 拡張子フィルタ
* 改行コード差（CRLF/LF）の無視
* `delta` 利用（未導入環境では `diff -u` にフォールバック）
* サマリ／詳細ログの分離出力
* CI等で使える終了コード

---

## 4. 導入方法

### 4.1 スクリプト配置

`dirdiff.sh` を任意の作業ディレクトリに配置してください。

### 4.2 実行権限付与（初回のみ）

```bash
chmod +x dirdiff.sh
```

---

## 5. 基本的な使い方

## 5.1 ヘルプ表示

```bash
./dirdiff.sh -h
```

---

## 5.2 file vs file 比較

### 通常比較

```bash
./dirdiff.sh before.txt after.txt
```

### 改行コード差（CRLF/LF）を無視して比較

```bash
./dirdiff.sh -I before.txt after.txt
```

---

## 5.3 dir vs dir 比較

### 直下ファイルのみ比較（再帰なし）

```bash
./dirdiff.sh dirA dirB
```

### サブディレクトリを含めて比較（再帰）

```bash
./dirdiff.sh -r dirA dirB
```

### 改行コード差を無視して比較

```bash
./dirdiff.sh -I dirA dirB
```

---

## 6. 出力ファイル

比較結果は `--outdir` 未指定時、以下に出力されます。

* `diff_out/diff_summary.txt` … 件数・一覧（サマリ）
* `diff_out/diff_detail.txt` … 詳細差分
* `diff_out/auto_pairs.tsv` … 比較に使用したペア一覧（dir vs dir のみ）

> file vs file モードでは `auto_pairs.tsv` は生成されません（適用対象外）。

---

## 7. 実務でよく使う実行例

## 7.1 RTL比較（推奨）

```bash
./dirdiff.sh -p rtl rtl_asic rtl_asic_8ki
```

`-p rtl` は以下相当です。

* `-r`（再帰）
* `-I`（CRLF無視）
* `-e "v,sv,vh,svh"`（RTL拡張子フィルタ）

---

## 7.2 テキスト／ドキュメント比較（改行差無視）

```bash
./dirdiff.sh -p text dirA dirB
```

---

## 7.3 汎用コード比較

```bash
./dirdiff.sh -p code src_old src_new
```

---

## 8. オプション一覧（短縮版 / 長い版）

## 8.1 共通オプション（file/dir 両方）

| 短縮       | 長い形式            | 説明                 |
| -------- | --------------- | ------------------ |
| `-h`     | `--help`        | ヘルプ表示              |
| `-I`     | `--ignore-crlf` | 改行コード差（CRLF/LF）を無視 |
| `-o DIR` | `--outdir DIR`  | 出力先ディレクトリ指定        |
| なし       | `--no-progress` | 実行中メッセージを抑制        |

---

## 8.2 dir vs dir 専用オプション

| 短縮        | 長い形式                   | 説明                            |
| --------- | ---------------------- | ----------------------------- |
| `-r`      | `--recursive`          | 再帰比較（サブディレクトリ含む）              |
| `-e LIST` | `--ext LIST`           | 拡張子フィルタ（カンマ区切り）               |
| `-p NAME` | `--profile NAME`       | プロファイル適用（`all/text/rtl/code`） |
| `-m FILE` | `--map FILE`           | 完全手動マップを使用                    |
| `-R FILE` | `--rename-map FILE`    | renameマップを自動マップに上書き適用         |
| `-D FILE` | `--dump-auto-map FILE` | 生成したペアマップを保存                  |
| `-M`      | `--exit-after-map`     | マップ生成のみ行い、比較せず終了              |

---

## 8.3 file vs file で使用不可のオプション

file vs file モードでは以下は使用できません（エラーになります）。

* `-r`, `--recursive`
* `-e`, `--ext`
* `-p`, `--profile`
* `-m`, `--map`
* `-R`, `--rename-map`
* `-D`, `--dump-auto-map`
* `-M`, `--exit-after-map`

---

## 9. プロファイル（`-p` / `--profile`）

プロファイルは **dir vs dir** の時によく使う組み合わせを短く呼び出すための機能です。

## 9.1 `all`

* 再帰なし
* CRLF無視なし
* 拡張子フィルタなし

```bash
./dirdiff.sh -p all dirA dirB
```

---

## 9.2 `text`

* 再帰あり
* CRLF無視あり
* 拡張子フィルタなし

```bash
./dirdiff.sh -p text dirA dirB
```

---

## 9.3 `rtl`

* 再帰あり
* CRLF無視あり
* 拡張子フィルタ: `v,sv,vh,svh`

```bash
./dirdiff.sh -p rtl rtl_asic rtl_asic_8ki
```

---

## 9.4 `code`

* 再帰あり
* CRLF無視あり
* 拡張子フィルタ（例）:
  `c,cc,cpp,h,hpp,py,sh,tcl,mk,make,txt,md,json,yaml,yml`

```bash
./dirdiff.sh -p code src_old src_new
```

---

## 10. 自動マップ / 手動マップの使い分け

dir vs dir 比較では、比較対象ペア（before ↔ after）を「マップ」として扱います。

### 10.1 自動マップ（通常運用）

* 同一相対パスのファイルを自動で対応付け
* beforeのみ存在 → remove
* afterのみ存在 → add

生成されたマップは自動的に以下へ保存されます。

* `diff_out/auto_pairs.tsv`

---

### 10.2 renameマップ（推奨）

ファイル名変更がある場合のみ、対応関係を手で指定します。
それ以外は自動マップを使用します。

#### 例: `rename_map.txt`

```txt
old_name.v	new_name.v
sub/old_ctrl.sv	sub/new_ctrl.sv
```

実行例:

```bash
./dirdiff.sh -p rtl rtl_asic rtl_asic_8ki -R rename_map.txt
```

---

### 10.3 完全手動マップ（`-m`）

比較ペアをすべて手動で指定したい場合に使用します。
従来の `filemap.txt` 運用に相当します。

#### 例: `filemap.txt`（タブ区切り推奨）

```txt
CB.v	CB.v
-	cre_ecc_add.v
cre_ecc_ctrl.sv	cre_ecc_ctrl.sv
MPC.v	MPC.v
```

実行例:

```bash
./dirdiff.sh rtl_asic rtl_asic_8ki -m filemap.txt
```

---

## 11. 自動マップを保存して編集する運用（推奨）

### 11.1 まず自動マップだけ生成して保存（比較はしない）

```bash
./dirdiff.sh -p rtl rtl_asic rtl_asic_8ki -D auto_map.tsv -M
```

* `-D auto_map.tsv` : マップを任意ファイルへ保存
* `-M` : 比較処理を行わず終了（マップ生成のみ）

### 11.2 `auto_map.tsv` を手動編集

必要に応じてペアを調整してください。

### 11.3 編集済みマップで比較実行

```bash
./dirdiff.sh rtl_asic rtl_asic_8ki -m auto_map.tsv
```

---

## 12. ログの見方

## 12.1 サマリ (`diff_summary.txt`)

件数と一覧を確認できます。

主な項目:

* `#Same files`
* `#Different files`
* `#Added files`
* `#Removed files`
* `#Missing files`

---

## 12.2 詳細 (`diff_detail.txt`)

ファイルごとの差分内容を確認できます。

代表的な出力:

* `[no difference]` … 差分なし
* `[difference]` … 差分あり
* `[add_file]` … after側にのみ存在
* `[remove_file]` … before側にのみ存在
* `[missing]` … マップ指定はあるが実ファイルが見つからない

---

## 13. 終了コード（自動化向け）

`dirdiff.sh` は終了コードで結果を判定できます。

| 終了コード | 意味                                |
| ----- | --------------------------------- |
| `0`   | 差分なし（同一）                          |
| `1`   | 差分あり（内容差のみ）                       |
| `2`   | add/remove/missing が存在（差分有無に関わらず） |
| `3`   | 引数不正 / 実行エラー                      |

### 例（CIやスクリプトから呼ぶ場合）

```bash
./dirdiff.sh -p rtl rtl_asic rtl_asic_8ki
rc=$?

if [ $rc -eq 0 ]; then
  echo "No differences"
elif [ $rc -eq 1 ]; then
  echo "Content differences found"
elif [ $rc -eq 2 ]; then
  echo "Add/Remove/Missing detected"
else
  echo "Execution error"
fi
```

---

## 14. 注意事項

### 14.1 mapファイル中のファイル名に空白は非対応

`--map` / `--rename-map` のマップファイルは、スペースを含むファイル名を想定していません。
（通常のソースコード比較では問題になりにくい想定）

### 14.2 `file vs dir` はエラー

仕様上、曖昧さ回避のためサポートしていません。

### 14.3 `delta` 未導入時の挙動

`delta` コマンドが存在しない場合は、自動的に `diff -u` を使用します。

---

## 15. 推奨運用（社内向け）

### 15.1 通常の比較

まずは自動マップ + プロファイルで実行

```bash
./dirdiff.sh -p rtl rtl_asic rtl_asic_8ki
```

### 15.2 ファイル名変更がある場合

renameマップを使用

```bash
./dirdiff.sh -p rtl rtl_asic rtl_asic_8ki -R rename_map.txt
```

### 15.3 比較対応を厳密に調整したい場合

自動マップをダンプして手動修正 → `-m` で再利用

```bash
./dirdiff.sh -p rtl rtl_asic rtl_asic_8ki -D auto_map.tsv -M
./dirdiff.sh rtl_asic rtl_asic_8ki -m auto_map.tsv
```

---

## 16. トラブルシュート

### 16.1 `Permission denied`

実行権限を付与してください。

```bash
chmod +x dirdiff.sh
```

### 16.2 `Path not found`

指定したファイル／ディレクトリのパスを確認してください。

```bash
pwd
ls
```

### 16.3 `Unknown option`

ヘルプを参照してオプション名を確認してください。

```bash
./dirdiff.sh -h
```

### 16.4 `file vs dir` でエラーになる

仕様です。以下のどちらかに揃えて実行してください。

* file vs file
* dir vs dir

---

## 17. 補足（よく使うコマンド例まとめ）

### file vs file（改行コード差無視）

```bash
./dirdiff.sh -I before.txt after.txt
```

### dir vs dir（RTL比較）

```bash
./dirdiff.sh -p rtl rtl_asic rtl_asic_8ki
```

### dir vs dir（汎用テキスト比較）

```bash
./dirdiff.sh -p text dirA dirB
```

### 自動マップのみ生成

```bash
./dirdiff.sh -p rtl rtl_asic rtl_asic_8ki -D auto_map.tsv -M
```

### 編集済みマップで比較

```bash
./dirdiff.sh rtl_asic rtl_asic_8ki -m auto_map.tsv
```

---

## 18. 改訂履歴（テンプレート）

* `YYYY/MM/DD` 初版作成
* `YYYY/MM/DD` file vs file 対応を反映
* `YYYY/MM/DD` プロファイル説明を追加

---