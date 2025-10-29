#!/bin/bash

# ============================================================================
# Tailwind CSS v4 + Shadcn UI 安裝器
# ============================================================================

# 取得腳本所在目錄的絕對路徑
INSTALLER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMPLATE_DIR="$INSTALLER_DIR/../templates"

# 載入共用函式庫
source "$INSTALLER_DIR/../lib/common.sh"

# ============================================================================
# 安裝 Tailwind CSS v4 + Shadcn UI
# ============================================================================

install() {
    local project_path="$1"

    info_msg "方案: Tailwind CSS v4 + Shadcn UI"
    echo ""

    # 1. 建立專案 & 進入專案目錄
    pnpm create next-app@latest "$project_path" --yes
    if [ $? -ne 0 ]; then
        error_msg "Next.js 專案建立失敗"
        return 1
    fi
    cd "$project_path" || return 1

    # 2. 安裝 Tailwind CSS v4
    info_msg "Tailwind CSS v4"
    pnpm add -D tailwindcss @tailwindcss/postcss
    if [ $? -ne 0 ]; then
        error_msg "Tailwind CSS v4 初始化失敗"
        return 1
    fi

    # 配置 postcss.config.mjs
    cp "$TEMPLATE_DIR/postcss-v4.config.mjs" ./postcss.config.mjs

    # 配置 globals.css
    cp "$TEMPLATE_DIR/globals-v4.css" ./app/globals.css

    # 3. 安裝 Shadcn UI
    info_msg "安裝 Shadcn UI"
    pnpm dlx shadcn@latest init --yes
    if [ $? -ne 0 ]; then
        error_msg "Shadcn UI 初始化失敗"
        return 1
    fi
    pnpm dlx shadcn@latest add button
    pnpm dlx shadcn@latest add alert-dialog
    pnpm dlx shadcn@latest add checkbox
    success_msg "Shadcn UI 安裝成功"

    return 0
}

# 如果直接執行此腳本，則執行安裝
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    install "$1"
fi
