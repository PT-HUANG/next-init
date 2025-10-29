#!/bin/bash

# ============================================================================
# 常數定義
# ============================================================================

# 取得腳本所在目錄
    readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 載入共用函式庫
source "$SCRIPT_DIR/lib/common.sh"

# 全域變數定義
BASE_PATH=""
PROJECT_NAME=""
PROJECT_PATH=""
TAILWIND_OPTION=""
PACKAGES_ARRAY=()
SELECTED_PACKAGES=""

# ============================================================================
# 使用說明函式
# ============================================================================

show_usage() {
    echo ""
    echo -e "${BLUE}📖 使用說明${NC}"
    echo ""
    echo -e "  這是一個 Next.js 專案自動化初始化工具"
    echo -e "  可協助您快速建立 Next.js 專案，安裝套件並進行基礎設定"
    echo ""
    echo -e "  ${CYAN}步驟 1${NC} - 檢查必要的執行檔案"
    echo -e "    • 檢查所有必要執行腳本"
    echo ""
    echo -e "  ${CYAN}步驟 2${NC} - 設定專案路徑、專案名稱"
    echo -e "    • 輸入專案路徑（預設為腳本所在目錄）"
    echo -e "    • 輸入專案名稱（如果沒輸入則退出）"
    echo ""
    echo -e "  ${CYAN}步驟 3${NC} - 建立 Next.js 專案"
    echo -e "    • 使用 pnpm create next-app 建立專案"
    echo -e "    • 可選套件(單選)："
    echo -e "      - Tailwind CSS v3 + Shadcn UI"
    echo -e "      - Tailwind CSS v3"
    echo -e "      - Tailwind CSS v4 + Shadcn UI"
    echo -e "      - Tailwind CSS v4"
    echo -e "      - 不安裝"
    echo -e "    • 擴充套件(多選)："
    echo -e "      - Zustand"
    echo -e "      - Zod"
    echo -e "      - Material UI"
    echo -e "      - SWR"
    echo -e "      - Axios"
    echo ""
    echo -e "  ${CYAN}步驟 4${NC} - 設定 next.config.ts"
    echo -e "    • 啟用 standalone 輸出模式（Docker 最佳化）"
    echo -e "    • 關閉 ESLint 建置檢查"
    echo ""
}

# ============================================================================
# 環境檢查函式
# ============================================================================

check_dependencies() {
    # 檢查 setup_next.sh
    check_file "$SCRIPT_DIR/setup_next.sh" "在腳本目錄找不到 setup_next.sh: $SCRIPT_DIR"

    # 檢查 setup_config.sh
    check_file "$SCRIPT_DIR/setup_config.sh" "在腳本目錄找不到 setup_config.sh: $SCRIPT_DIR"

    # 檢查 lib 目錄及其內容
    check_directory "$SCRIPT_DIR/lib" "找不到 lib 目錄: $SCRIPT_DIR/lib"
    check_file "$SCRIPT_DIR/lib/common.sh" "找不到 lib/common.sh"
    check_file "$SCRIPT_DIR/lib/packages.sh" "找不到 lib/packages.sh"

    # 檢查 next_installers 目錄及其內容
    check_directory "$SCRIPT_DIR/next_installers" "找不到 next_installers 目錄: $SCRIPT_DIR/next_installers"
    check_file "$SCRIPT_DIR/next_installers/tailwind-v3.sh" "找不到 next_installers/tailwind-v3.sh"
    check_file "$SCRIPT_DIR/next_installers/tailwind-v4.sh" "找不到 next_installers/tailwind-v4.sh"
    check_file "$SCRIPT_DIR/next_installers/no-tailwind.sh" "找不到 next_installers/no-tailwind.sh"

    # 檢查 templates 目錄及其內容
    check_directory "$SCRIPT_DIR/templates" "找不到 templates 目錄: $SCRIPT_DIR/templates"
    check_file "$SCRIPT_DIR/templates/tailwind-v3.config.ts" "找不到 templates/tailwind-v3.config.ts"
    check_file "$SCRIPT_DIR/templates/postcss-v3.config.mjs" "找不到 templates/postcss-v3.config.mjs"
    check_file "$SCRIPT_DIR/templates/postcss-v4.config.mjs" "找不到 templates/postcss-v4.config.mjs"
    check_file "$SCRIPT_DIR/templates/globals-v3.css" "找不到 templates/globals-v3.css"
    check_file "$SCRIPT_DIR/templates/globals-v4.css" "找不到 templates/globals-v4.css"

    # 授予執行權限
    chmod +x "$SCRIPT_DIR"/*.sh
    chmod +x "$SCRIPT_DIR/lib"/*.sh
    chmod +x "$SCRIPT_DIR/next_installers"/*.sh

    success_msg "確認所有必要檔案存在"
}

# ============================================================================
# 使用者輸入函式
# ============================================================================

setup_project() {
    local project_path
    local project_name

    # 設定專案路徑
    project_path=$(gum input \
        --prompt "➡️  請輸入專案路徑: " \
        --value "$SCRIPT_DIR" \
        --header "")

    local exit_code=$?

    # 檢查 gum 是否被取消（ESC 或 Ctrl+C）
    if [ $exit_code -ne 0 ]; then
        error_exit "已取消操作"
    fi

    # 檢查是否有輸入，若無則使用腳本所在目錄
    if [ -z "$project_path" ]; then
        BASE_PATH="$SCRIPT_DIR"
        echo "使用腳本所在目錄"
    else
        # 驗證路徑是否存在
        if [ ! -d "$project_path" ]; then
            error_exit "指定的路徑不存在: $project_path"
        fi
        BASE_PATH="$project_path"
    fi

    # 設定專案名稱
    project_name=$(gum input \
        --prompt "➡️  請輸入專案名稱: " \
        --placeholder "my-app" \
        --header "")

    exit_code=$?

    # 檢查 gum 是否被取消（ESC 或 Ctrl+C）
    if [ $exit_code -ne 0 ]; then
        error_exit "已取消操作"
    fi

    # 檢查是否有輸入
    if [ -z "$project_name" ]; then
        error_exit "未輸入專案名稱"
    fi

    PROJECT_NAME="$project_name"
    PROJECT_PATH="$BASE_PATH/$PROJECT_NAME"

    # 檢查專案目錄是否已存在
    if [ -d "$PROJECT_PATH" ]; then
        error_exit "專案目錄已存在: $PROJECT_PATH"
    fi

    success_msg "專案路徑及名稱設定完成"
}

# ============================================================================
# 套件選擇函式
# ============================================================================

setup_packages() {
    # 單選: Tailwind CSS 選項
    TAILWIND_OPTION=$(gum choose \
        --header "➡️  請選擇 Tailwind CSS 選項 (單選):" \
        --header.foreground white \
        "Tailwind CSS v3" \
        "Tailwind CSS v4" \
        "不安裝Tailwind CSS")

    local exit_code=$?

    # 檢查是否取消操作
    if [ $exit_code -ne 0 ]; then
        error_exit "已取消操作"
    fi

    # 檢查是否有選擇
    if [ -z "$TAILWIND_OPTION" ]; then
        error_exit "未選擇 Tailwind CSS 選項"
    fi

    echo ""
    success_msg "已選擇套件:$TAILWIND_OPTION"
    echo ""

    # 多選: 擴充套件
    local selected_items

    # 根據 Tailwind 選擇決定是否顯示 Shadcn UI
    if [[ "$TAILWIND_OPTION" == "不安裝Tailwind CSS" ]]; then
        # 沒有安裝 Tailwind，不顯示 Shadcn UI
        selected_items=$(gum choose \
            --no-limit \
            --header "選擇要安裝的擴充套件 (多選，使用空白鍵選擇，Enter 確認)" \
            --header.foreground white\
            "Zustand" \
            "Zod" \
            "Material UI" \
            "SWR" \
            "Axios")
    else
        # 有安裝 Tailwind，顯示 Shadcn UI 選項
        selected_items=$(gum choose \
            --no-limit \
            --header "選擇要安裝的擴充套件 (多選，使用空白鍵選擇，Enter 確認)" \
            --header.foreground white\
            "Shadcn UI (推薦)" \
            "Zustand" \
            "Zod" \
            "Material UI" \
            "SWR" \
            "Axios")
    fi

    exit_code=$?

    # 檢查是否取消操作
    if [ $exit_code -ne 0 ]; then
        error_exit "已取消操作"
    fi

    # 將選擇的套件存入陣列
    if [ -n "$selected_items" ]; then
        # 將多行結果轉換為陣列
        while IFS= read -r package; do
            PACKAGES_ARRAY+=("$package")
        done <<< "$selected_items"
    fi

    # 顯示選擇結果並轉換為字串
    if [ ${#PACKAGES_ARRAY[@]} -eq 0 ]; then
        success_msg "未選擇任何擴充套件"
    else
        success_msg "已選擇套件:"
        for package in "${PACKAGES_ARRAY[@]}"; do
            echo -e "  • $package"
        done
        # 將陣列轉換為以逗號分隔的字串
        SELECTED_PACKAGES=$(IFS=,; echo "${PACKAGES_ARRAY[*]}")
    fi

}

# ============================================================================
# 專案建立函式
# ============================================================================
setup_next() {
    info_msg "執行 setup_next.sh 建立 Next.js 專案"

    if "$SCRIPT_DIR/setup_next.sh" "$PROJECT_PATH" "$TAILWIND_OPTION" "$SELECTED_PACKAGES"; then
        :
    else
        error_exit "Next.js 專案建立失敗"
    fi
}

# ============================================================================
# next.config 設定函式
# ============================================================================

setup_config() {
    # 檢查專案目錄是否存在
    [ ! -d "$PROJECT_PATH" ] && error_exit "專案目錄不存在: $PROJECT_PATH"

    # subshell: 直接在專案目錄中執行 setup_config.sh
    if (cd "$PROJECT_PATH" && "$SCRIPT_DIR/setup_config.sh"); then
        success_msg "next.config.ts 設定成功"
    else
        error_exit "next.config.ts 設定失敗"
    fi
}

# ============================================================================
# 顯示結果函式
# ============================================================================

show_completion_message() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}🎉 專案初始化完成！${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BLUE}📁 專案名稱:${NC} $PROJECT_NAME"
    echo -e "${BLUE}📍 專案位置:${NC} $PROJECT_PATH"
    echo ""
}

# ============================================================================
# 主函式
# ============================================================================

main() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     Next.js 專案自動化初始化工具       ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"

    # 先檢查 gum 是否已安裝
    check_command "gum" "https://github.com/charmbracelet/gum"

    # 檢查 pnpm
    check_command "pnpm" "https://pnpm.io/zh-TW/"

    # 顯示選單讓用戶選擇
    CHOICE=$(gum choose --header "" \
        "🚀 開始新專案" \
        "📖 查看使用說明")

    local exit_code=$?

    # 檢查是否取消操作
    if [ $exit_code -ne 0 ]; then
        echo -e "${RED}❌ 已取消操作${NC}"
        exit 0
    fi

    # 根據選擇執行對應操作
    if [[ "$CHOICE" == "📖 查看使用說明" ]]; then
        show_usage
        exit 0
    fi

    # 步驟 1: 檢查依賴
    echo -e "\n${BLUE}[步驟 1] 檢查環境${NC}"
    check_dependencies
    
    # 步驟 2: 設定專案名稱
    echo -e "\n${BLUE}[步驟 2] 設定專案路徑名稱${NC}"
    setup_project
    
    # 步驟 3: 選擇套件
    echo -e "\n${BLUE}[步驟 3] 選擇套件${NC}"
    setup_packages
    
    # 步驟 4: 安裝 Next.js 及所選套件
    echo -e "\n${BLUE}[步驟 4] 設定環境變數${NC}"
    setup_next
    
    # 顯示完成訊息
    show_completion_message
}

# 捕捉錯誤並清理
trap 'echo -e "\n${RED}程式被中斷${NC}"; exit 1' INT TERM

# 執行主函式
main "$@"