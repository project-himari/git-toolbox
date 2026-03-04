from playwright.sync_api import sync_playwright
import pandas as pd

URLS = {
    "jp_stock": "https://www.paypay-sec.co.jp/stock/list/",
    "us_stock": "https://www.paypay-sec.co.jp/us-stock/list/",
    "fund":     "https://www.paypay-sec.co.jp/fund/list/",
    "jp_cfd":   "https://www.paypay-sec.co.jp/cfd/list/",
}

def scrape_table(page, url: str) -> pd.DataFrame:
    page.goto(url, wait_until="networkidle")
    page.wait_for_timeout(1000)

    # まず「画面内の表っぽいもの」を探して抜く（サイト側変更に耐えるための汎用寄り）
    tables = page.locator("table")
    if tables.count() == 0:
        raise RuntimeError("tableが見つかりません（DOM構造が違う可能性）")

    table = tables.first

    headers = table.locator("thead tr th")
    if headers.count() == 0:
        # thead無しのケース
        headers = table.locator("tr").first.locator("th,td")

    cols = [headers.nth(i).inner_text().strip() for i in range(headers.count())]
    cols = [c if c else f"col_{i}" for i, c in enumerate(cols)]

    rows = []
    body_rows = table.locator("tbody tr")
    if body_rows.count() == 0:
        body_rows = table.locator("tr").nth(1)  # だめなら後で調整

    for r in range(table.locator("tbody tr").count()):
        tds = table.locator("tbody tr").nth(r).locator("td,th")
        row = [tds.nth(i).inner_text().strip() for i in range(tds.count())]
        if any(row):
            rows.append(row)

    # 行の列数が不揃いなら切り詰め/パディング
    maxlen = max((len(r) for r in rows), default=len(cols))
    cols = (cols + [f"col_{i}" for i in range(len(cols), maxlen)])[:maxlen]
    rows = [ (r + [""] * (maxlen - len(r)))[:maxlen] for r in rows ]

    return pd.DataFrame(rows, columns=cols)

def main():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        for key, url in URLS.items():
            df = scrape_table(page, url)
            out = f"paypaysec_{key}.csv"
            df.to_csv(out, index=False, encoding="utf-8-sig")
            print(f"[OK] {key}: {len(df)} rows -> {out}")

        browser.close()

if __name__ == "__main__":
    main()
