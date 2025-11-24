#!/bin/bash
# 脚本名称: venv_manager_whiptail.sh
# 作用: 使用 whiptail 创建一个支持方向键、Tab 和 Enter 键的交互式菜单。

# 定义脚本当前操作的目标虚拟环境名称
VENV_TARGET=".venv"

# 默认语言（en / zh_cn / zh_tw）
LANG_SELECTED="en"

# 本地化文案表（英语 / 简体 / 繁体）
declare -A MSG_EN=(
    [menu_title]="🐍 Python venv Manager (TUI)"
    [menu_instructions]="Select a venv (top) or an action (bottom)."
    [opt_sn]="Enter new target name"
    [opt_c]="Create / initialize target venv"
    [opt_i]="Install packages into target venv"
    [opt_d]="Delete target venv"
    [opt_q]="Quit manager"
    [opt_lang]="Change language (EN / 簡 / 简)"
    [select_target_title]="Target selector"
    [select_target_menu]="Choose a number to switch target, or choose 'Enter new name' to set a custom target."
    [invalid_name]="Invalid name. Do not use spaces, '.' or '..'."
    [confirm_switched]="✅ Target switched to: %s"
    [confirm_set_new]="✅ Target set to new name: %s"
    [msg_exists]="✅ Target '%s' already exists."
    [creating]="🛠️ Creating venv '%s'..."
    [create_success]="🎉 Virtual environment created successfully!"
    [create_failed]="❌ Failed to create virtualenv. Is python3-venv installed?"
    [error_no_env]="⚠️ Target '%s' does not exist. Create it first."
    [install_prompt]="Enter Python package names (space-separated):"
    [installing]="📦 Installing packages: %s ..."
    [install_success]="🎉 Packages installed!\n\nTip: activate manually: source %s/bin/activate"
    [install_failed]="❌ Package installation failed. Check names or network."
    [delete_confirm]="⚠️ Confirm deletion of entire '%s' folder? This is irreversible!"
    [delete_in_progress]="🗑️ Deleting venv '%s'..."
    [delete_success]="✅ Deletion complete. Target reset to default: %s"
    [cancelled]="Operation cancelled."
    [goodbye]="\n👋 Thanks. Goodbye!"
)

declare -A MSG_ZH_CN=(
    [menu_title]="🐍 Python 虚拟环境管理器 (TUI)"
    [menu_instructions]="请选择虚拟环境（上半部分）或操作（下半部分）。"
    [opt_sn]="输入新目标名称"
    [opt_c]="创建/初始化 目标环境"
    [opt_i]="安装依赖包 到目标环境"
    [opt_d]="删除 目标环境"
    [opt_q]="退出管理器"
    [opt_lang]="语言切换 (EN / 簡 / 简)"
    [select_target_title]="目标环境选择器"
    [select_target_menu]="请选择一个序号切换目标，或选择 '输入新名称' 来设置自定义目标。"
    [invalid_name]="目标名称无效。请勿使用空格、单独的点(.)或双点(..)作为名称。"
    [confirm_switched]="✅ 目标环境已切换为: %s"
    [confirm_set_new]="✅ 目标环境已设置为新名称: %s"
    [msg_exists]="✅ 目标 '%s' 已存在。"
    [creating]="🛠️ 正在创建虚拟环境 '%s'..."
    [create_success]="🎉 虚拟环境创建成功！"
    [create_failed]="❌ 错误：创建虚拟环境失败。请检查 'python3-venv' 是否安装。"
    [error_no_env]="⚠️ 目标环境 '%s' 不存在。请先创建。"
    [install_prompt]="请输入要安装的 Python 包名 (空格分隔)："
    [installing]="📦 正在安装包: %s ..."
    [install_success]="🎉 包安装完成！\n\n💡 提示：手动激活：source %s/bin/activate"
    [install_failed]="❌ 错误：包安装失败，请检查包名或网络。"
    [delete_confirm]="⚠️ 确定要删除整个 '%s' 文件夹吗？此操作不可逆！"
    [delete_in_progress]="🗑️ 正在删除虚拟环境 '%s'..."
    [delete_success]="✅ 删除完成！目标已重置为默认值: %s"
    [cancelled]="操作已取消。"
    [goodbye]="\n👋 感谢使用。再见！"
)

declare -A MSG_ZH_TW=(
    [menu_title]="🐍 Python 虛擬環境管理器 (TUI)"
    [menu_instructions]="請選擇虛擬環境（上半部）或操作（下半部）。"
    [opt_sn]="輸入新目標名稱"
    [opt_c]="建立/初始化 目標環境"
    [opt_i]="安裝相依套件 到目標環境"
    [opt_d]="刪除 目標環境"
    [opt_q]="離開管理器"
    [opt_lang]="語言切換 (EN / 簡 / 繁)"
    [select_target_title]="目標環境選擇器"
    [select_target_menu]="請選擇一個序號切換目標，或選擇 '輸入新名稱' 來設定自訂目標。"
    [invalid_name]="目標名稱無效。請勿使用空格、單獨的點(.)或雙點(..)作為名稱。"
    [confirm_switched]="✅ 目標環境已切換為: %s"
    [confirm_set_new]="✅ 目標環境已設定為新名稱: %s"
    [msg_exists]="✅ 目標 '%s' 已存在。"
    [creating]="🛠️ 正在建立虛擬環境 '%s'..."
    [create_success]="🎉 虛擬環境建立成功！"
    [create_failed]="❌ 錯誤：建立虛擬環境失敗。請檢查 'python3-venv' 是否安裝。"
    [error_no_env]="⚠️ 目標環境 '%s' 不存在。請先建立。"
    [install_prompt]="請輸入要安裝的 Python 套件名稱 (以空格分隔)："
    [installing]="📦 正在安裝套件: %s ..."
    [install_success]="🎉 套件安裝完成！\n\n💡 提示：手動啟用：source %s/bin/activate"
    [install_failed]="❌ 錯誤：套件安裝失敗，請檢查套件名稱或網路。"
    [delete_confirm]="⚠️ 确定要刪除整個 '%s' 資料夾嗎？此操作不可逆！"
    [delete_in_progress]="🗑️ 正在刪除虛擬環境 '%s'..."
    [delete_success]="✅ 刪除完成！目標已重設為預設值: %s"
    [cancelled]="操作已取消。"
    [goodbye]="\n👋 感謝使用。再見！"
)

# 简单的翻译函数：tr KEY
tr() {
    local key="$1"
    local -n M
    case "$LANG_SELECTED" in
        en) M=MSG_EN ;;
        zh_cn) M=MSG_ZH_CN ;;
        zh_tw) M=MSG_ZH_TW ;;
        *) M=MSG_EN ;;
    esac
    echo "${M[$key]}"
}

# 返回语言显示名称（用于确认提示）
lang_label() {
    case "$1" in
        en) echo "English" ;;
        zh_cn) echo "简体中文" ;;
        zh_tw) echo "繁體中文" ;;
        *) echo "$1" ;;
    esac
}

# 语言切换菜单（在主菜单中可调用）
language_menu() {
    local choice
    choice=$(whiptail --title "$(tr menu_title) - Language" \
        --menu "$(tr menu_instructions)\n\nCurrent: $(lang_label "$LANG_SELECTED")\n\nChoose language:" 14 60 4 \
        "en" "English (default)" \
        "zh_cn" "简体中文" \
        "zh_tw" "繁體中文" 3>&1 1>&2 2>&3)
    if [ $? -eq 0 ] && [ -n "$choice" ]; then
        LANG_SELECTED="$choice"
        whiptail --title "$(tr menu_title)" --msgbox "$(printf "$(tr confirm_set_new)" "$(lang_label "$LANG_SELECTED")")" 8 50
    fi
}

# --- 辅助函数 ---

# 检查 whiptail 是否安装
check_whiptail() {
    if ! command -v whiptail &> /dev/null; then
        echo -e "\n❌ 错误：whiptail 工具未安装。"
        echo "请运行以下命令安装："
        echo -e "\n\033[33msudo apt install whiptail\033[0m"
        exit 1
    fi
}

# 扫描当前目录，获取所有虚拟环境列表
get_venv_list() {
    # 列出当前目录下所有包含 bin/activate 的子目录（包括以点开头的隐藏目录）
    find . -maxdepth 1 -type d ! -path . -print0 | while IFS= read -r -d '' dir; do
        if [ -f "$dir/bin/activate" ]; then
            echo "${dir#./}"
        fi
    done
}

# --- TUI 核心功能 ---

# 0. TUI：设置/更改目标环境名称
set_target_venv_tui() {
    local VENV_ARRAY=($(get_venv_list))
    local VENV_FOUND=${#VENV_ARRAY[@]}
    local options=()
    local result # 存储 whiptail 的输出
    
    # 构造选项
    local COUNT=1
    for VENV_DIR in "${VENV_ARRAY[@]}"; do
        options+=("$COUNT" "$VENV_DIR ($(tr opt_c))")
        COUNT=$((COUNT+1))
    done

    options+=("N" "$(tr opt_sn)")

    result=$(whiptail --title "$(tr select_target_title)" \
                      --menu "$(tr select_target_menu)" \
                      20 60 12 \
                      "${options[@]}" 3>&1 1>&2 2>&3)

    if [ $? -eq 0 ]; then
        if [[ "$result" =~ ^[0-9]+$ ]] && [ "$result" -gt 0 ] && [ "$result" -le "$VENV_FOUND" ]; then
            local INDEX=$((result-1))
            VENV_TARGET="${VENV_ARRAY[$INDEX]}"
            whiptail --title "$(tr menu_title)" --msgbox "$(printf "$(tr confirm_switched)" "$VENV_TARGET")" 8 50
        elif [ "$result" == "N" ]; then
            local new_target=$(whiptail --title "$(tr opt_sn)" --inputbox "$(tr opt_sn):" 8 40 "$VENV_TARGET" 3>&1 1>&2 2>&3)
            if [ $? -eq 0 ] && [ -n "$new_target" ]; then
                if [[ "$new_target" =~ [[:space:]] || "$new_target" == "." || "$new_target" == ".." ]]; then
                    whiptail --title "$(tr menu_title)" --msgbox "$(tr invalid_name)" 8 50
                else
                    VENV_TARGET="$new_target"
                    whiptail --title "$(tr menu_title)" --msgbox "$(printf "$(tr confirm_set_new)" "$VENV_TARGET")" 8 50
                fi
            fi
        fi
    fi
}

# 1. TUI：创建/初始化目标环境
create_venv_tui() {
    if [ -d "$VENV_TARGET" ]; then
        whiptail --title "$(tr menu_title)" --msgbox "$(printf "$(tr msg_exists)" "$VENV_TARGET")" 8 50
        return
    fi
    
    whiptail --title "$(tr menu_title)" --msgbox "$(printf "$(tr creating)" "$VENV_TARGET")" 8 50
    
    python3 -m venv "$VENV_TARGET"
    
    if [ $? -eq 0 ]; then
        whiptail --title "$(tr menu_title)" --msgbox "$(tr create_success)" 8 50
    else
        whiptail --title "$(tr menu_title)" --msgbox "$(tr create_failed)" 8 60
    fi
}

# 2. TUI：安装依赖包
install_packages_tui() {
    if [ ! -d "$VENV_TARGET" ]; then
        whiptail --title "$(tr menu_title)" --msgbox "$(printf "$(tr error_no_env)" "$VENV_TARGET")" 8 60
        return
    fi

    # 找到可执行的 pip（优先 venv 中的 pip）
    local pip_exec=""
    if [ -x "$VENV_TARGET/bin/pip" ]; then
        pip_exec="$VENV_TARGET/bin/pip"
    elif [ -x "$VENV_TARGET/bin/python" ]; then
        pip_exec="$VENV_TARGET/bin/python -m pip"
    else
        whiptail --title "$(tr menu_title)" --msgbox "$(tr install_failed)" 8 60
        return
    fi

    local packages=$(whiptail --title "$(tr opt_i)" \
                             --inputbox "$(tr install_prompt)" \
                             8 60 "" 3>&1 1>&2 2>&3)

    if [ $? -eq 0 ] && [ -n "$packages" ]; then
        whiptail --title "$(tr menu_title)" --msgbox "$(printf "$(tr installing)" "$packages")" 8 60

        # 安全地拆分包名并传给 pip
        read -r -a PKG_ARR <<<"$packages"
        if [[ "$pip_exec" == *" -m pip" ]]; then
            $pip_exec install "${PKG_ARR[@]}"
        else
            "$pip_exec" install "${PKG_ARR[@]}"
        fi

        if [ $? -eq 0 ]; then
            whiptail --title "$(tr menu_title)" --msgbox "$(printf "$(tr install_success)" "$VENV_TARGET")" 10 60
        else
            whiptail --title "$(tr menu_title)" --msgbox "$(tr install_failed)" 8 60
        fi
    elif [ $? -eq 0 ]; then
        whiptail --title "$(tr menu_title)" --msgbox "$(tr cancelled)" 8 40
    fi
}

# 3. TUI：删除目标环境
delete_venv_tui() {
    if [ ! -d "$VENV_TARGET" ]; then
        whiptail --title "$(tr menu_title)" --msgbox "$(printf "$(tr error_no_env)" "$VENV_TARGET")" 8 40
        return
    fi
    
    if whiptail --title "$(tr menu_title)" --yesno "$(printf "$(tr delete_confirm)" "$VENV_TARGET")" 8 60; then
        whiptail --title "$(tr menu_title)" --msgbox "$(printf "$(tr delete_in_progress)" "$VENV_TARGET")" 8 50
        rm -rf "$VENV_TARGET"
        
        VENV_TARGET=".venv"
        whiptail --title "$(tr menu_title)" --msgbox "$(printf "$(tr delete_success)" "$VENV_TARGET")" 8 60
    else
        whiptail --title "$(tr menu_title)" --msgbox "$(tr cancelled)" 8 40
    fi
}

# --- 主程序逻辑 ---

main_menu() {
    local VENV_ARRAY=($(get_venv_list))
    local options=()
    local idx=1

    # 将发现的 venv 列在菜单顶部（可直接选择切换）
    for v in "${VENV_ARRAY[@]}"; do
        local tag="V$idx"
        local desc="$v"
        if [ "$v" == "$VENV_TARGET" ]; then
            desc="$v ($(tr opt_c))"
        fi
        options+=("$tag" "$desc")
        idx=$((idx+1))
    done

    # 添加专用项与操作项（显示在列表下方）
    options+=("SN" "$(tr opt_sn)")
    options+=("C"  "$(tr opt_c)")
    options+=("I"  "$(tr opt_i)")
    options+=("D"  "$(tr opt_d)")
    options+=("L"  "$(tr opt_lang)")
    options+=("Q"  "$(tr opt_q)")

    local CMD
    CMD=$(whiptail --title "$(tr menu_title)" \
                   --menu "$(tr menu_instructions)\n\n当前目录: $(pwd)\n当前目标: $VENV_TARGET" \
                   24 70 16 \
                   "${options[@]}" 3>&1 1>&2 2>&3)

    local status=$?
    if [ "$status" -ne 0 ]; then
        return 0
    fi

    case "$CMD" in
        V*)
            local ID=${CMD#V}
            local sel_index=$((ID-1))
            if [ $sel_index -ge 0 ] && [ $sel_index -lt ${#VENV_ARRAY[@]} ]; then
                VENV_TARGET="${VENV_ARRAY[$sel_index]}"
                whiptail --title "$(tr menu_title)" --msgbox "$(printf "$(tr confirm_switched)" "$VENV_TARGET")" 8 50
            fi
            ;;
        "SN")
            local new_target=$(whiptail --title "$(tr opt_sn)" --inputbox "$(tr opt_sn):" 8 40 "$VENV_TARGET" 3>&1 1>&2 2>&3)
            if [ $? -eq 0 ] && [ -n "$new_target" ]; then
                if [[ "$new_target" =~ [[:space:]] || "$new_target" == "." || "$new_target" == ".." ]]; then
                    whiptail --title "$(tr menu_title)" --msgbox "$(tr invalid_name)" 8 50
                else
                    VENV_TARGET="$new_target"
                    whiptail --title "$(tr menu_title)" --msgbox "$(printf "$(tr confirm_set_new)" "$VENV_TARGET")" 8 50
                fi
            fi
            ;;
        "C") create_venv_tui ;;
        "I") install_packages_tui ;;
        "D") delete_venv_tui ;;
        "L") language_menu ;;
        "Q") return 1 ;;
    esac

    return 0
}


# --- 启动 ---

check_whiptail

while main_menu; do
    : # 保持循环直到 main_menu 返回非零值
done

echo -e "\nBye!"
