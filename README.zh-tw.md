# 🐍 Python venv 管理器 (TUI)

Language / 語言切換 — 預設: English  
[English](README.md) · [简体中文](README.zh-cn.md) · [繁體中文](#)

---

第 I 部分 — 快捷鍵與介面
- 預設語言：English（可透過主選單的 “Language” 項或按 L 切換）。
- 快捷鍵：
  - ↑ / ↓ : 移動選擇
  - Enter : 確認 / 開啟
  - Tab : 切換焦點（選單 ↔ 按鈕）
  - Esc / Cancel : 返回 / 關閉對話框
  - L : 開啟語言選單
  - Q : 退出（選擇 Quit）
- 介面佈局：上方 = 偵測到的 venv（選擇以切換），下方 = 操作（Create / Install / Delete / Language / Quit）

第 II 部分 — 快速開始
1. 使腳本可執行：
   chmod +x venv_manager.sh
2. 執行：
   ./venv_manager.sh
3. 需求：
   - bash (v4+)、whiptail、python3。若要建立 venv，可能需安裝 python3-venv：
     sudo apt install whiptail python3-venv

第 III 部分 — 功能與說明
- 偵測：掃描當前目錄，尋找包含 bin/activate 的資料夾（包含隱藏的 .venv）。
- 目標：預設目標為 .venv。可選擇現有 venv 或輸入自訂名稱。
- 建立：執行 python3 -m venv [target]。
- 安裝：輸入以空格分隔的套件名稱，使用目標 venv 的 pip 安裝（或 python -m pip）。
- 刪除：需確認，然後 rm -rf 刪除目標資料夾。
- 本地化：介面字串支援 English、簡體中文、繁體中文，切換立即生效。
- 啟用：腳本不會改變當前 shell；安裝完成後請手動啟用：
  source [target]/bin/activate

故障排除
- 若缺少 whiptail：
  sudo apt update && sudo apt install whiptail
- 若建立 venv 失敗，請確認已安裝 python3-venv。

檔案
- 腳本：./venv_manager.sh
- 此檔：./README.md（English）
- 其它翻譯：./README.zh-cn.md, ./README.zh-tw.md

授權 / 貢獻
- 在腳本頂部編輯本地化表以更新文字。
- 歡迎小而集中的 PR。