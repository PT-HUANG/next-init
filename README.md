# Next.js Project Initialization Toolkit

Next.js 專案自動化初始化工具，透過互動式 CLI 介面快速建立和配置 Next.js 專案。

## ✨ 特色功能

- 🎨 **互動式介面** - 使用 `gum` 提供友善的終端機 UI 體驗
- 🎯 **模組化架構** - 清晰的目錄結構，易於維護和擴展
- ⚡ **智慧選單** - 根據選擇動態顯示相容的套件選項
- 🔧 **多樣化配置** - 支援 Tailwind CSS v3/v4 或不使用 Tailwind
- 📦 **套件整合** - 一鍵安裝常用的 React 生態系套件
- 🐳 **Docker 最佳化** - 自動配置 `standalone` 輸出模式

## 📋 系統需求

### 必需依賴

- [gum](https://github.com/charmbracelet/gum) - Terminal UI toolkit
- [pnpm](https://pnpm.io) - 套件管理工具

## 🚀 快速開始

### 1. 克隆專案

```bash
git clone https://github.com/yourusername/next-init.git
cd next-init
```

### 2. 執行初始化工具

```bash
./main.sh
```

### 3. 按照互動式提示完成設定

工具會引導你完成以下步驟：

1. **設定專案路徑** - 輸入專案存放位置（預設為當前目錄）
2. **設定專案名稱** - 輸入專案名稱
3. **選擇 Tailwind CSS** - 選擇版本或不安裝
4. **選擇擴充套件** - 多選你需要的套件

## 📦 支援的套件

### CSS 框架

- **Tailwind CSS v3** - 傳統配置方式
- **Tailwind CSS v4** - 新版本配置（CSS-first）
- **不安裝 Tailwind** - 使用其他 CSS 方案

### UI 元件庫

- **Shadcn UI** ⭐ (需要 Tailwind CSS) - 可自訂的 React 元件庫
- **Material UI** - Google Material Design 元件庫

### 狀態管理

- **Zustand** - 輕量級狀態管理

### 資料處理

- **Zod** - TypeScript-first 資料驗證
- **SWR** - React Hooks 資料獲取
- **Axios** - Promise 基礎的 HTTP 客戶端

## 📁 專案結構

```
next-init/
├── lib/                              # 共用函式庫
│   ├── common.sh                     # 顏色定義、訊息輸出、錯誤處理
│   └── packages.sh                   # 套件安裝邏輯
├── templates/                        # 配置檔案模板
│   ├── tailwind-v3.config.ts        # Tailwind v3 配置
│   ├── tailwind-v4.config.ts        # Tailwind v4 配置
│   ├── postcss-v3.config.mjs        # PostCSS v3 配置
│   ├── postcss-v4.config.mjs        # PostCSS v4 配置
│   ├── globals-v3.css               # Tailwind v3 全域樣式
│   └── globals-v4.css               # Tailwind v4 全域樣式
├── next_installers/                  # Next.js 配置安裝器
│   ├── tailwind-v3.sh               # Tailwind v3 安裝器
│   ├── tailwind-v4.sh               # Tailwind v4 安裝器
│   └── no-tailwind.sh               # 無 Tailwind 安裝器
├── main.sh                           # 主入口點
├── setup_next.sh                     # 協調安裝流程
├── setup_config.sh                   # 配置 next.config.ts
├── CLAUDE.md                         # Claude Code 專案指南
└── README.md                         # 本文件
```

## 🔧 進階使用

### 單獨測試安裝器

你可以單獨執行某個安裝器來測試：

```bash
# 測試 Tailwind v3 安裝器
./next_installers/tailwind-v3.sh /path/to/test-project

# 測試 Tailwind v4 安裝器
./next_installers/tailwind-v4.sh /path/to/test-project

# 測試無 Tailwind 安裝器
./next_installers/no-tailwind.sh /path/to/test-project
```

### 查看使用說明

```bash
./main.sh
# 選擇 "📖 查看使用說明"
```

## 🛠️ 開發指南

### 新增 Next.js 配置選項

1. 在 `next_installers/` 建立新的安裝器腳本
2. 在 `templates/` 建立所需的配置模板
3. 在 `main.sh` 的 `setup_packages()` 函式中添加選項
4. 在 `setup_next.sh` 的 `case` 語句中添加對應分支

範例：

```bash
# next_installers/my-framework.sh
#!/bin/bash
source "$(dirname "$0")/../lib/common.sh"

install() {
    local project_path="$1"
    info_msg "安裝 My Framework"
    # 你的安裝邏輯...
    success_msg "My Framework 安裝成功"
}

[ "${BASH_SOURCE[0]}" == "${0}" ] && install "$@"
```

### 新增擴充套件選項

1. 在 `main.sh` 的 `setup_packages()` 函式中添加選項
2. 在 `lib/packages.sh` 的 `install_package()` 中添加對應的 case

範例：

```bash
# 在 lib/packages.sh 中
"My Package")
    info_msg "安裝 My Package"
    pnpm add my-package --silent
    if [ $? -eq 0 ]; then
        success_msg "My Package 安裝成功"
    else
        error_msg "My Package 安裝失敗"
        return 1
    fi
    ;;
```

### 模組化架構

- **關注點分離** - 每個腳本負責單一功能
- **可重用性** - 共用函式庫集中管理
- **可測試性** - 每個安裝器可獨立執行測試

## 📝 工作流程

```
main.sh
  ├─ 檢查依賴 (gum, pnpm, 檔案結構)
  ├─ 收集使用者輸入
  │   ├─ 專案路徑、名稱
  │   ├─ Tailwind 選項（單選）
  │   └─ 擴充套件（多選，智慧顯示）
  └─ 調用 setup_next.sh
       ├─ 根據選擇載入對應的安裝器
       ├─ 執行安裝器的 install() 函式
       ├─ 核准 pnpm builds
       ├─ 安裝 dotenv-cli
       ├─ 安裝擴充套件
       └─ 調用 setup_config.sh 配置 next.config.ts
```