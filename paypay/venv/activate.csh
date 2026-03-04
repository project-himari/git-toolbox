# 1) venvに必要なものを入れる（1回だけ）
sudo apt update
sudo apt install -y python3-full python3-venv

# 2) 作業フォルダへ（好きな場所でOK）
mkdir -p ../paypay_scrape
cd ../paypay_scrape

# 3) 仮想環境作成＆有効化（tcsh）
python3 -m venv .venv
source .venv/bin/activate.csh

# 4) 仮想環境の中にインストール
python -m pip install -U pip
python -m pip install playwright pandas

# 5) PlaywrightのOS依存ライブラリを入れる（←追加：sudo必要）
sudo ./.venv/bin/python -m playwright install-deps

# 6) Playwright本体（ブラウザ）を入れる
python -m playwright install

# 7) 確認
python -c "import playwright; print('ok')"
python -m playwright --version
