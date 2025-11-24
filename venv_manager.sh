#!/bin/bash
# 脚本名称: venv_manager_whiptail.sh
# 作用: 使用 whiptail 创建一个支持方向键、Tab 和 Enter 键的交互式菜单。

# 定义脚本当前操作的目标虚拟环境名称
VENV_TARGET=".venv"

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
    
    # 构造 whiptail 菜单需要的 key/description 列表
    # 选项从 1 开始编号
    local COUNT=1
    for VENV_DIR in "${VENV_ARRAY[@]}"; do
        options+=("$COUNT" "$VENV_DIR (现有环境)")
        COUNT=$((COUNT+1))
    done

    # 添加自定义输入选项
    options+=("N" "输入新名称")

    result=$(whiptail --title "目标环境选择器" \
                      --menu "请选择一个序号切换目标，或选择 '输入新名称' 来创建新目标。" \
                      20 60 12 \
                      "${options[@]}" 3>&1 1>&2 2>&3) # 捕获 whiptail 的输出

    if [ $? -eq 0 ]; then # 检查用户是否按下了 OK
        if [[ "$result" =~ ^[0-9]+$ ]] && [ "$result" -gt 0 ] && [ "$result" -le "$VENV_FOUND" ]; then
            # 用户选择了序号
            local INDEX=$((result-1))
            VENV_TARGET="${VENV_ARRAY[$INDEX]}"
            whiptail --title "确认" --msgbox "✅ 目标环境已切换为: $VENV_TARGET" 8 40
        elif [ "$result" == "N" ]; then
            # 用户选择输入新名称
            local new_target=$(whiptail --title "输入新目标" --inputbox "请输入新的目标环境名称：" 8 40 "$VENV_TARGET" 3>&1 1>&2 2>&3)
            
            if [ $? -eq 0 ] && [ -n "$new_target" ]; then
                if [[ "$new_target" =~ [[:space:]] || "$new_target" == "." || "$new_target" == ".." ]]; then
                    whiptail --title "错误" --msgbox "❌ 目标名称无效。请勿使用空格、单独的点(.)或双点(..)作为名称。" 8 50
                else
                    VENV_TARGET="$new_target"
                    whiptail --title "确认" --msgbox "✅ 目标环境已设置为新名称: $VENV_TARGET" 8 40
                fi
            fi
        fi
    fi
}

# 1. TUI：创建/初始化目标环境
create_venv_tui() {
    if [ -d "$VENV_TARGET" ]; then
        whiptail --title "提示" --msgbox "✅ 目标环境 '$VENV_TARGET' 已存在。" 8 40
        return
    fi
    
    whiptail --title "创建中" --msgbox "🛠️ 正在创建虚拟环境 '$VENV_TARGET'..." 8 40
    
    # 在非图形化模式下执行创建命令
    python3 -m venv "$VENV_TARGET"
    
    if [ $? -eq 0 ]; then
        whiptail --title "成功" --msgbox "🎉 虚拟环境创建成功！" 8 40
    else
        whiptail --title "失败" --msgbox "❌ 错误：创建虚拟环境失败。请检查 'python3-venv' 是否安装。" 8 60
    fi
}

# 2. TUI：安装依赖包
install_packages_tui() {
    if [ ! -d "$VENV_TARGET" ]; then
        whiptail --title "错误" --msgbox "⚠️ 目标环境 '$VENV_TARGET' 不存在。请先创建 (选项 1)。" 8 60
        return
    fi

    local packages=$(whiptail --title "安装依赖" \
                             --inputbox "请输入要安装的 Python 包名 (空格分隔)：" \
                             8 60 "" 3>&1 1>&2 2>&3)

    if [ $? -eq 0 ] && [ -n "$packages" ]; then
        whiptail --title "安装中" --msgbox "📦 正在使用环境中的 pip 安装包: $packages ..." 8 60
        
        ./"$VENV_TARGET"/bin/pip install $packages
        
        if [ $? -eq 0 ]; then
            whiptail --title "成功" --msgbox "🎉 包安装完成！\n\n💡 提示：手动激活：source $VENV_TARGET/bin/activate" 10 60
        else
            whiptail --title "失败" --msgbox "❌ 错误：包安装失败，请检查包名或网络。" 8 60
        fi
    elif [ $? -eq 0 ]; then
        whiptail --title "取消" --msgbox "操作已取消，未输入任何包名。" 8 40
    fi
}

# 3. TUI：删除目标环境
delete_venv_tui() {
    if [ ! -d "$VENV_TARGET" ]; then
        whiptail --title "提示" --msgbox "⚠️ 目标环境 '$VENV_TARGET' 不存在，无需删除。" 8 40
        return
    fi
    
    if whiptail --title "警告" --yesno "⚠️ 确定要删除整个 '$VENV_TARGET' 文件夹吗？此操作不可逆！" 8 50; then
        whiptail --title "删除中" --msgbox "🗑️ 正在删除虚拟环境 '$VENV_TARGET'..." 8 40
        rm -rf "$VENV_TARGET"
        
        if [ "$VENV_TARGET" != ".venv" ]; then
            VENV_TARGET=".venv"
        fi
        whiptail --title "成功" --msgbox "✅ 删除完成！目标已重置为默认值: $VENV_TARGET" 8 60
    else
        whiptail --title "取消" --msgbox "操作已取消。" 8 40
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
            desc="$v (当前目标)"
        fi
        options+=("$tag" "$desc")
        idx=$((idx+1))
    done

    # 添加专用项与操作项（显示在列表下方）
    options+=("SN" "输入新目标名称")
    options+=("C"  "创建/初始化 目标环境")
    options+=("I"  "安装依赖包 到目标环境")
    options+=("D"  "删除 目标环境")
    options+=("Q"  "退出管理器")

    local CMD
    CMD=$(whiptail --title "🐍 Python 虚拟环境管理器 TUI" \
                   --menu "请选择虚拟环境（上半部分）或操作（下半部分）。\n\n当前目录: $(pwd)\n当前目标: $VENV_TARGET" \
                   24 70 16 \
                   "${options[@]}" 3>&1 1>&2 2>&3)

    local status=$?
    if [ "$status" -ne 0 ]; then
        return 0
    fi

    case "$CMD" in
        V*)
            # 用户从发现的虚拟环境列表中选择一个（例如 V1）
            local ID=${CMD#V}
            local sel_index=$((ID-1))
            if [ $sel_index -ge 0 ] && [ $sel_index -lt ${#VENV_ARRAY[@]} ]; then
                VENV_TARGET="${VENV_ARRAY[$sel_index]}"
                whiptail --title "确认" --msgbox "✅ 目标环境已切换为: $VENV_TARGET" 8 40
            fi
            ;;
        "SN")
            # 输入新目标名称
            local new_target=$(whiptail --title "输入新目标" --inputbox "请输入新的目标环境名称：" 8 40 "$VENV_TARGET" 3>&1 1>&2 2>&3)
            if [ $? -eq 0 ] && [ -n "$new_target" ]; then
                if [[ "$new_target" =~ [[:space:]] || "$new_target" == "." || "$new_target" == ".." ]]; then
                    whiptail --title "错误" --msgbox "❌ 目标名称无效。请勿使用空格、单独的点(.)或双点(..)作为名称。" 8 50
                else
                    VENV_TARGET="$new_target"
                    whiptail --title "确认" --msgbox "✅ 目标环境已设置为新名称: $VENV_TARGET" 8 40
                fi
            fi
            ;;
        "C") create_venv_tui ;;
        "I") install_packages_tui ;;
        "D") delete_venv_tui ;;
        "Q") return 1 ;;
    esac

    return 0
}


# --- 启动 ---

check_whiptail

while main_menu; do
    : # 保持循环直到 main_menu 返回非零值
done

echo -e "\n👋 感谢使用。再见！"
