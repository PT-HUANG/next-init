#!/bin/bash

# ============================================================================
# 套件安裝管理模組
# ============================================================================

# 載入共用函式庫
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/common.sh"

# ============================================================================
# 安裝擴充套件
# ============================================================================

install_package() {
    local package_name="$1"

    case "$package_name" in
        "Zustand")
            info_msg "安裝 Zustand"
            pnpm add zustand --silent
            if [ $? -eq 0 ]; then
                success_msg "Zustand 安裝成功"
            else
                error_msg "Zustand 安裝失敗"
                return 1
            fi
            ;;

        "Zod")
            info_msg "安裝 Zod (資料驗證)"
            pnpm add zod --silent
            if [ $? -eq 0 ]; then
                success_msg "Zod 安裝成功"
            else
                error_msg "Zod 安裝失敗"
                return 1
            fi
            ;;

        "Material UI")
            info_msg "安裝 Material UI"
            pnpm add @mui/material @mui/icons-material @emotion/react @emotion/styled --silent
            if [ $? -eq 0 ]; then
                success_msg "Material UI 安裝成功"
            else
                error_msg "Material UI 安裝失敗"
                return 1
            fi
            ;;

        "SWR")
            info_msg "安裝 SWR"
            pnpm add swr --silent
            if [ $? -eq 0 ]; then
                success_msg "SWR 安裝成功"
            else
                error_msg "SWR 安裝失敗"
                return 1
            fi
            ;;

        "Axios")
            info_msg "安裝 Axios"
            pnpm add axios --silent
            if [ $? -eq 0 ]; then
                success_msg "Axios 安裝成功"
            else
                error_msg "Axios 安裝失敗"
                return 1
            fi
            ;;

        *)
            error_msg "未知的套件: $package_name"
            return 1
            ;;
    esac

    return 0
}

# ============================================================================
# 批次安裝套件
# ============================================================================

install_packages() {
    local packages_string="$1"

    # 將逗號分隔的字串轉換為陣列
    IFS=',' read -ra PACKAGES <<< "$packages_string"

    if [ ${#PACKAGES[@]} -gt 0 ]; then
        for package in "${PACKAGES[@]}"; do
            echo ""
            install_package "$package"
        done
    else
        echo ""
        info_msg "未選擇任何擴充套件"
    fi
}
