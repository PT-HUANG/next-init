#!/bin/bash
# 接收來自 main.sh 的參數
readonly PROJECT_PATH="$1"
readonly TAILWIND_CHOICE="$2"
readonly SELECTED_PACKAGES="$3"

# 取得腳本所在目錄
readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 載入共用函式庫
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/packages.sh"

# 顯示標題
echo ""
echo -e "${CYAN} __    _  _______  __   __  _______            ___  _______ "
echo -e "${CYAN}|  |  | ||       ||  |_|  ||       |          |   ||       |"
echo -e "${CYAN}|   |_| ||    ___||       ||_     _|          |   ||  _____|"
echo -e "${CYAN}|       ||   |___ |       |  |   |            |   || |_____ "
echo -e "${CYAN}|  _    ||    ___| |     |   |   |   ___   ___|   ||_____  |"
echo -e "${CYAN}| | |   ||   |___ |   _   |  |   |  |   | |       | _____| |"
echo -e "${CYAN}|_|  |__||_______||__| |__|  |___|  |___| |_______||_______|${NC}"
echo ""
echo -e "${BLUE}🚀 Next.js 專案自動初始化腳本${NC}"
echo ""

# ============================================================
# 步驟 1: 根據選擇執行對應的安裝器
# ============================================================

case "$TAILWIND_CHOICE" in
    "Tailwind CSS v3")
        source "$SCRIPT_DIR/next_installers/tailwind-v3.sh"
        install "$PROJECT_PATH"
        ;;
    "Tailwind CSS v4")
        source "$SCRIPT_DIR/next_installers/tailwind-v4.sh"
        install "$PROJECT_PATH"
        ;;
    "不安裝Tailwind CSS")
        source "$SCRIPT_DIR/next_installers/no-tailwind.sh"
        install "$PROJECT_PATH"
        ;;
    *)
        error_exit "未知的 Tailwind 選項: $TAILWIND_CHOICE"
        ;;
esac

if [ $? -ne 0 ]; then
    error_exit "專案建立失敗"
fi

# ============================================================
# 步驟 2: 核准 pnpm 構建腳本
# ============================================================
echo ""
info_msg "核准 pnpm 構建腳本"
pnpm approve-builds 2>/dev/null || true
success_msg "pnpm 構建腳本已核准"

# ============================================================
# 步驟 3: 安裝必要套件
# ============================================================
echo ""
info_msg "安裝必要套件: dotenv-cli"
pnpm add -D dotenv-cli --silent
if [ $? -ne 0 ]; then
    error_msg "dotenv-cli 安裝失敗"
    exit 1
fi
success_msg "dotenv-cli 安裝成功"

# ============================================================
# 步驟 4: 安裝擴充套件
# ============================================================
install_packages "$SELECTED_PACKAGES"

# ============================================================
# 完成
# ============================================================

exit 0
