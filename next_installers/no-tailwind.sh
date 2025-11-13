#!/bin/bash

# ============================================================================
# 不安裝 Tailwind CSS
# ============================================================================

# 取得腳本所在目錄的絕對路徑
INSTALLER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 載入共用函式庫
source "$INSTALLER_DIR/../lib/common.sh"

# ============================================================================
# 建立 Next.js 專案（不含 Tailwind）
# ============================================================================

install() {
    local project_path="$1"

    info_msg "方案: 不安裝 Tailwind CSS"
    echo ""

    # 建立專案 & 進入專案目錄
    pnpm create next-app@latest "$project_path" --typescript --no-eslint --react-compiler --no-tailwind --no-src-dir --app --turbopack --import-alias "@/*"
    if [ $? -ne 0 ]; then
        error_msg "Next.js 專案建立失敗"
        return 1
    fi
    cd "$project_path" || return 1

    success_msg "Next.js 專案建立完成（不含 Tailwind CSS）"
    return 0
}

# 如果直接執行此腳本，則執行安裝
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    install "$1"
fi
