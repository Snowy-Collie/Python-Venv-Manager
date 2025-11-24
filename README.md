# 🐍 Python venv Manager (TUI)

Language / 語言切換 — Default: English  
[English](#) · [简体中文](README.zh-cn.md) · [繁體中文](README.zh-tw.md)

---

Part I — Shortcuts & UI
- Default language: English (switch via "Language" menu or press L in menu).
- Shortcuts:
  - ↑ / ↓ : move selection
  - Enter : confirm / open
  - Tab : switch focus (menu ↔ buttons)
  - Esc / Cancel : back / close dialog
  - L : open Language menu
  - Q : Quit (select Quit)
- UI layout: top = detected venvs (select to switch), bottom = actions (Create / Install / Delete / Language / Quit)

Part II — Quick start
1. Make script executable:
   chmod +x venv_manager.sh
2. Run:
   ./venv_manager.sh
3. Requirements:
   - bash (v4+), whiptail, python3. To create venvs you may need python3-venv:
     sudo apt install whiptail python3-venv

Part III — Features & Notes
- Detection: scans current directory for folders containing bin/activate (includes hidden .venv).
- Target: default target is .venv. You can select an existing venv or enter a custom name.
- Create: runs python3 -m venv [target].
- Install: input space-separated package names; installs using target venv's pip (or python -m pip).
- Delete: confirmation required; removes target folder (rm -rf).
- Localization: UI strings are localized to English, 简体中文, 繁體中文. Language selection applies immediately.
- Activation: the script does not change your shell. After installing, activate manually:
  source [target]/bin/activate

Troubleshooting
- If whiptail is missing:
  sudo apt update && sudo apt install whiptail
- If creating a venv fails, ensure python3-venv is installed.

Files
- Script: ./venv_manager.sh
- This README: ./README.md
- Optional translations: ./README.zh-cn.md, ./README.zh-tw.md

License / Contribution
- Edit localization table at top of venv_manager.sh to update texts.
- Small, focused PRs welcome.
