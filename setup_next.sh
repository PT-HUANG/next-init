#!/bin/bash
# 接收來自 main.sh 的參數
readonly PROJECT_PATH="$1"
readonly TAILWIND_CHOICE="$2"
readonly SELECTED_PACKAGES_STRING="$3"

# 將逗號分隔的字串轉換為陣列
IFS=',' read -ra SELECTED_PACKAGES <<< "$SELECTED_PACKAGES_STRING"

# 色彩定義
readonly NC='\033[0m'
readonly BLUE='\033[1;34m'
readonly CYAN='\033[1;36m'
readonly GREEN='\033[1;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[1;31m'

# 訊息輸出函數
info_msg() {
    echo -e "${CYAN}ℹ  $1${NC}"
}

success_msg() {
    echo -e "${GREEN}✅ $1${NC}"
}

error_msg() {
    echo -e "${RED}❌ $1${NC}"
}

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
# 步驟 1: 建立 Next.js 專案 + 安裝 Tailwind CSS + Shadcn UI
# ============================================================
# 根據用戶選擇執行對應的安裝流程
if [[ $TAILWIND_CHOICE == "Tailwind CSS v3 + Shadcn UI(推薦)" ]]; then
    # ========== Tailwind CSS v3 + Shadcn UI ==========
    info_msg "方案: Tailwind CSS v3 + Shadcn UI（推薦）"
    echo ""

    # 1. 建立專案 & 進入專案目錄
    pnpm create next-app@latest "$PROJECT_PATH" --typescript --no-eslint --no-react-compiler --no-tailwind --no-src-dir --app --turbopack --import-alias "@/*"
    if [ $? -ne 0 ]; then
        error_msg "Next.js 專案建立失敗"
        exit 1
    fi
    cd "$PROJECT_PATH" || exit 1

    # 2. 安裝 Tailwind CSS v3
    info_msg "安裝 Tailwind CSS v3 及相關套件"
    pnpm add -D tailwindcss@^3 postcss autoprefixer --silent
    if [ $? -ne 0 ]; then
        error_msg "Tailwind CSS 安裝失敗" 
        exit 1
    fi
    pnpm exec tailwindcss init -p
    if [ $? -ne 0 ]; then
        error_msg "Tailwind CSS 初始化失敗"
        exit 1
    fi

# 配置 tailwind.config.ts
rm -f ./tailwind.config.js
cat > tailwind.config.ts << 'EOF'
import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}

export default config
EOF

# 生成 postcss.config.mjs
rm -f ./postcss.config.js
cat > postcss.config.mjs << 'EOF'
import tailwindcss from 'tailwindcss'
import autoprefixer from 'autoprefixer'

export default {
  plugins: [
    tailwindcss,
    autoprefixer
  ]
}
EOF

# 配置 globals.css
cat > ./app/globals.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF

    success_msg "Tailwind CSS v3 安裝設定完成"
    echo ""

    # 3. 安裝 Shadcn UI(及基本元件)
    info_msg "安裝 Shadcn UI"
    pnpm dlx shadcn@latest init --yes
    if [ $? -ne 0 ]; then
        error_msg "Shadcn UI 初始化失敗"
        exit 1
    fi
    pnpm dlx shadcn@latest add button
    pnpm dlx shadcn@latest add alert-dialog
    pnpm dlx shadcn@latest add checkbox
    success_msg "Shadcn UI 安裝完成"

elif [[ $TAILWIND_CHOICE == "Tailwind CSS v3" ]]; then
    # ========== Tailwind CSS v3 ==========
    info_msg "方案: Tailwind CSS v3"
    echo ""

    # 1. 建立專案
    pnpm create next-app@latest "$PROJECT_PATH" --typescript --no-eslint --no-react-compiler --no-tailwind --no-src-dir --app --turbopack --import-alias "@/*"
    if [ $? -ne 0 ]; then
        error_msg "Next.js 專案建立失敗"
        exit 1
    fi

    # 進入專案目錄
    cd "$PROJECT_PATH" || exit 1

    # 2. 安裝 Tailwind CSS v3
    info_msg "安裝 Tailwind CSS v3 及相關套件"
    pnpm add -D tailwindcss@^3 postcss autoprefixer --silent
    if [ $? -ne 0 ]; then
        error_msg "Tailwind CSS 安裝失敗"
        exit 1
    fi
    pnpm exec tailwindcss init -p
    if [ $? -ne 0 ]; then
        error_msg "Tailwind CSS 初始化失敗"
        exit 1
    fi

# 配置 tailwind.config.ts
rm -f ./tailwind.config.js
cat > tailwind.config.ts << 'EOF'
import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}

export default config
EOF

# 生成 postcss.config.mjs
rm -f ./postcss.config.js
cat > postcss.config.mjs << 'EOF'
import tailwindcss from 'tailwindcss'
import autoprefixer from 'autoprefixer'

export default {
  plugins: [
    tailwindcss,
    autoprefixer
  ]
}
EOF

# 配置 globals.css
cat > ./app/globals.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF

    success_msg "Tailwind CSS v3 安裝設定完成"

elif [[ $TAILWIND_CHOICE == "Tailwind CSS v4 + Shadcn UI" ]]; then
    # ========== Tailwind CSS v4 + Shadcn UI ==========
    info_msg "方案: Tailwind CSS v4 + Shadcn UI"
    echo ""

    # 1. 建立專案 & 進入專案目錄
    pnpm create next-app@latest "$PROJECT_PATH" --yes
    if [ $? -ne 0 ]; then
        error_msg "Next.js 專案建立失敗"
        exit 1
    fi
    cd "$PROJECT_PATH" || exit 1

    # 2. 安裝 Shadcn UI
    info_msg "安裝 Shadcn UI"
    pnpm dlx shadcn@latest init --yes
    if [ $? -ne 0 ]; then
        error_msg "Shadcn UI 初始化失敗"
        exit 1
    fi
    pnpm dlx shadcn@latest add button
    pnpm dlx shadcn@latest add alert-dialog
    pnpm dlx shadcn@latest add checkbox
    success_msg "Shadcn UI 安裝成功"

elif [[ $TAILWIND_CHOICE == "Tailwind CSS v4" ]]; then
    # ========== Tailwind CSS v4 ==========
    info_msg "方案: Tailwind CSS v4 "
    echo ""

    # 建立專案
    pnpm create next-app@latest "$PROJECT_PATH" --yes
    if [ $? -ne 0 ]; then
        error_msg "Next.js 專案建立失敗"
        exit 1
    fi

    # 進入專案目錄
    cd "$PROJECT_PATH" || exit 1
    success_msg "Next.js 專案建立完成（使用 Tailwind CSS v4）"

else
    # ========== 不安裝 Tailwind CSS ==========
    info_msg "方案: 不安裝 Tailwind CSS"
    echo ""

    # 建立專案（不含 Tailwind）
    pnpm create next-app@latest "$PROJECT_PATH" --typescript --no-eslint --no-react-compiler --no-tailwind --no-src-dir --app --turbopack --import-alias "@/*"
    if [ $? -ne 0 ]; then
        error_msg "Next.js 專案建立失敗"
        exit 1
    fi

    # 進入專案目錄
    cd "$PROJECT_PATH" || exit 1
    success_msg "Next.js 專案建立完成（不含 Tailwind CSS）"
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
if [ ${#SELECTED_PACKAGES[@]} -gt 0 ]; then
    for package in "${SELECTED_PACKAGES[@]}"; do
        echo ""
        case "$package" in
            "Zustand")
                info_msg "安裝 Zustand"
                pnpm add zustand --silent
                if [ $? -eq 0 ]; then
                    success_msg "Zustand 安裝成功"
                else
                    error_msg "Zustand 安裝失敗"
                fi
                ;;

            "Zod")
                info_msg "安裝 Zod (資料驗證)"
                pnpm add zod --silent
                if [ $? -eq 0 ]; then
                    success_msg "Zod 安裝成功"
                else
                    error_msg "Zod 安裝失敗"
                fi
                ;;

            "Material UI")
                info_msg "安裝 Material UI"
                pnpm add @mui/material @mui/icons-material @emotion/react @emotion/styled --silent
                if [ $? -eq 0 ]; then
                    success_msg "Material UI 安裝成功"
                else
                    error_msg "Material UI 安裝失敗"
                fi
                ;;

            "SWR")
                info_msg "安裝 SWR"
                pnpm add swr --silent
                if [ $? -eq 0 ]; then
                    success_msg "SWR 安裝成功"
                else
                    error_msg "SWR 安裝失敗"
                fi
                ;;

            "Axios")
                info_msg "安裝 Axios"
                pnpm add axios --silent
                if [ $? -eq 0 ]; then
                    success_msg "Axios 安裝成功"
                else
                    error_msg "Axios 安裝失敗"
                fi
                ;;

            *)
                error_msg "未知的套件: $package"
                ;;
        esac
    done

else
    echo ""
    info_msg "未選擇任何擴充套件"
fi

# ============================================================
# 完成
# ============================================================

exit 0
