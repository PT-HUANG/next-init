#!/bin/bash

# ============================================================================
# Tailwind CSS v4 安裝器
# ============================================================================

# 取得腳本所在目錄的絕對路徑
INSTALLER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMPLATE_DIR="$INSTALLER_DIR/../templates"

# 載入共用函式庫
source "$INSTALLER_DIR/../lib/common.sh"

# ============================================================================
# 安裝 Tailwind CSS v4
# ============================================================================

install() {
    local project_path="$1"

    info_msg "方案: Tailwind CSS v4 "
    echo ""

    # 建立專案 & 進入專案目錄
    pnpm create next-app@latest "$project_path" --typescript --no-eslint --react-compiler --tailwind --no-src-dir --app --turbopack --import-alias "@/*"
    if [ $? -ne 0 ]; then
        error_msg "Next.js 專案建立失敗"
        return 1
    fi
    cd "$project_path" || return 1

    success_msg "Tailwind CSS v4 安裝完成"

    return 0
}

# 如果直接執行此腳本，則執行安裝
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    install "$1"
fi
