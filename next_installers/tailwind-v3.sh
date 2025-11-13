#!/bin/bash

# ============================================================================
# Tailwind CSS v3 安裝器
# ============================================================================

# 取得腳本所在目錄的絕對路徑
INSTALLER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMPLATE_DIR="$INSTALLER_DIR/../templates"

# 載入共用函式庫
source "$INSTALLER_DIR/../lib/common.sh"

# ============================================================================
# 安裝 Tailwind CSS v3
# ============================================================================

install() {
    local project_path="$1"

    info_msg "方案: Tailwind CSS v3"
    echo ""

    # 1. 建立專案
    pnpm create next-app@latest "$project_path" --yes
    if [ $? -ne 0 ]; then
        error_msg "Next.js 專案建立失敗"
        return 1
    fi

    # 進入專案目錄
    cd "$project_path" || return 1

    # 2. 解除安裝 Tailwind CSS v4
    pnpm remove tailwindcss -D
    rm -rf globals.css

    # 3. 安裝 Tailwind CSS v3
    info_msg "安裝 Tailwind CSS v3 及相關套件"
    pnpm add -D tailwindcss@^3 postcss autoprefixer --silent
    if [ $? -ne 0 ]; then
        error_msg "Tailwind CSS 安裝失敗"
        return 1
    fi
    pnpm exec tailwindcss init -p
    if [ $? -ne 0 ]; then
        error_msg "Tailwind CSS 初始化失敗"
        return 1
    fi

    # 配置 tailwind.config.ts
    rm -f ./tailwind.config.js
    cp "$TEMPLATE_DIR/tailwind-v3.config.ts" ./tailwind.config.ts

    # 生成 postcss.config.mjs
    rm -f ./postcss.config.js
    cp "$TEMPLATE_DIR/postcss-v3.config.mjs" ./postcss.config.mjs

    # 配置 globals.css
    cat "$TEMPLATE_DIR/globals-v3.css" > ./app/globals.css.tmp
    cat ./app/globals.css >> ./app/globals.css.tmp
    mv ./app/globals.css.tmp ./app/globals.css

    success_msg "Tailwind CSS v3 安裝設定完成"

    return 0
}

# 如果直接執行此腳本，則執行安裝
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    install "$1"
fi
