# 🐍 Python venv 管理器 (TUI)

Language / 語言切換 — 默认: English  
[English](README.md) · [简体中文](#) · [繁體中文](README.zh-tw.md)

---

第 I 部分 — 快捷键与界面
- 默认语言：English（可通过主菜单中的“Language”项或按 L 切换）。
- 快捷键：
  - ↑ / ↓ : 移动选择
  - Enter : 确认 / 打开
  - Tab : 切换焦点（菜单 ↔ 按钮）
  - Esc / Cancel : 返回 / 关闭对话框
  - L : 打开语言菜单
  - Q : 退出（选择 Quit）
- 界面布局：上方 = 检测到的 venv（选择以切换），下方 = 操作（Create / Install / Delete / Language / Quit）

第 II 部分 — 快速开始
1. 使脚本可执行：
   chmod +x venv_manager.sh
2. 运行：
   ./venv_manager.sh
3. 依赖：
   - bash (v4+)、whiptail、python3。若要创建 venv 可能需安装 python3-venv：
     sudo apt install whiptail python3-venv

第 III 部分 — 功能与说明
- 检测：扫描当前目录，查找包含 bin/activate 的文件夹（包含隐藏的 .venv）。
- 目标：默认目标为 .venv。可选择现有 venv 或输入自定义名称。
- 创建：运行 python3 -m venv [target]。
- 安装：输入以空格分隔的包名，使用目标 venv 的 pip 安装（或 python -m pip）。
- 删除：需确认，随后使用 rm -rf 删除目标文件夹。
- 本地化：界面字符串支持 English、简体中文、繁體中文，切换即时生效。
- 激活：脚本不会改变当前 shell；安装完成后请手动激活：
  source [target]/bin/activate

故障排查
- 若缺少 whiptail：
  sudo apt update && sudo apt install whiptail
- 若创建 venv 失败，确保已安装 python3-venv。

文件
- 脚本：./venv_manager.sh
- 本文件：./README.md（English）
- 其它翻译：./README.zh-cn.md, ./README.zh-tw.md

许可 / 贡献
- 在脚本顶部编辑本地化表以更新文本。
- 欢迎小而集中的 PR。