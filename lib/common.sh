#!/bin/bash

# ============================================================================
# 共用函式庫 - 顏色定義、訊息輸出、錯誤處理
# ============================================================================

# 顏色定義
readonly NC='\033[0m'
readonly RED='\033[1;31m'
readonly GREEN='\033[1;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[1;34m'
readonly CYAN='\033[1;36m'

# ============================================================================
# 訊息輸出函式
# ============================================================================

# 印出錯誤訊息並退出
error_exit() {
    echo -e "${RED}❌ $1${NC}" >&2
    exit "${2:-1}"
}

# 印出錯誤訊息（不退出）
error_msg() {
    echo -e "${RED}❌ $1${NC}" >&2
}

# 印出成功訊息
success_msg() {
    echo -e "${GREEN}✅ $1${NC}"
}

# 印出資訊訊息
info_msg() {
    echo -e "${CYAN}ℹ  $1${NC}"
}

# 印出警告訊息
warning_msg() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# ============================================================================
# 依賴檢查函式
# ============================================================================

# 檢查命令是否存在
check_command() {
    local cmd="$1"
    local install_url="$2"

    if ! command -v "$cmd" &> /dev/null; then
        error_exit "找不到 $cmd，請先安裝: $install_url"
    fi
}

# 檢查檔案是否存在
check_file() {
    local file_path="$1"
    local error_message="$2"

    if [ ! -f "$file_path" ]; then
        error_exit "${error_message:-檔案不存在: $file_path}"
    fi
}

# 檢查目錄是否存在
check_directory() {
    local dir_path="$1"
    local error_message="$2"

    if [ ! -d "$dir_path" ]; then
        error_exit "${error_message:-目錄不存在: $dir_path}"
    fi
}
