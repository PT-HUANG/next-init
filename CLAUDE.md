# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Next.js project initialization toolkit that automates the creation and configuration of Next.js projects. It's an interactive CLI tool written in Bash that uses `gum` for user interface and `pnpm` as the package manager.

## Project Structure

The project has been refactored into a modular architecture for better maintainability:

```
next-init/
├── lib/                              # 共用函式庫
│   ├── common.sh                     # 顏色定義、訊息輸出、錯誤處理、依賴檢查
│   └── packages.sh                   # 套件安裝邏輯（Zustand, Zod, MUI, SWR, Axios）
├── templates/                        # 配置檔案模板
│   ├── tailwind-v3.config.ts        # Tailwind v3 配置模板
│   ├── postcss-v3.config.mjs        # PostCSS v3 配置
│   ├── postcss-v4.config.mjs        # PostCSS v4 配置
│   ├── globals-v3.css               # Tailwind v3 全域樣式
│   └── globals-v4.css               # Tailwind v4 全域樣式
├── tailwind_installers/              # Tailwind 安裝器（每個選項一個檔案）
│   ├── tailwind-v3-shadcn.sh        # Tailwind v3 + Shadcn UI
│   ├── tailwind-v3.sh               # Tailwind v3
│   ├── tailwind-v4-shadcn.sh        # Tailwind v4 + Shadcn UI
│   ├── tailwind-v4.sh               # Tailwind v4
│   └── no-tailwind.sh               # 不安裝 Tailwind
├── main.sh                           # 主入口點，處理使用者互動
├── setup_next.sh                     # 協調安裝流程，調用 tailwind_installers
└── setup_config.sh                   # 配置 next.config.ts
```

## Architecture

### 1. main.sh - 主入口點和使用者互動
- 驗證依賴（`gum`, `pnpm`）
- 呈現互動式選單（使用 `gum`）
- 收集使用者輸入：專案路徑、名稱、套件選擇
- 協調執行 setup_next.sh 和 setup_config.sh
- **保留所有原始的 UI 設計**：顏色、emoji、ASCII art、gum 界面

### 2. lib/common.sh - 共用函式庫
提供所有腳本使用的共用功能：
- **顏色常數**：`NC`, `RED`, `GREEN`, `YELLOW`, `BLUE`, `CYAN`
- **訊息函式**：`error_exit()`, `error_msg()`, `success_msg()`, `info_msg()`, `warning_msg()`
- **檢查函式**：`check_command()`, `check_file()`, `check_directory()`

### 3. lib/packages.sh - 套件安裝管理
- `install_package()` - 安裝單一套件
- `install_packages()` - 批次安裝套件
- 支援套件：Zustand, Zod, Material UI, SWR, Axios

### 4. tailwind_installers/ - 模組化的 Tailwind 安裝器
每個安裝器都是獨立的可執行腳本，包含：
- 獨立的 `install()` 函式
- 載入 `lib/common.sh` 以使用共用函式
- 使用 `templates/` 中的配置模板
- 可以單獨執行或被 `setup_next.sh` source 調用

**安裝器對應關係：**
- `tailwind-v3-shadcn.sh` → "Tailwind CSS v3 + Shadcn UI(推薦)"
- `tailwind-v3.sh` → "Tailwind CSS v3"
- `tailwind-v4-shadcn.sh` → "Tailwind CSS v4 + Shadcn UI"
- `tailwind-v4.sh` → "Tailwind CSS v4"
- `no-tailwind.sh` → "不安裝"

### 5. templates/ - 配置檔案模板
所有配置檔案模板集中管理，避免在腳本中使用 heredoc。

### 6. setup_next.sh - 協調安裝流程
- 顯示 ASCII art 標題
- 使用 `case` 語句根據選擇調用對應的 installer
- 執行後續步驟：核准 pnpm builds、安裝 dotenv-cli、安裝擴充套件

### 7. setup_config.sh - Next.js 配置
- 生成 `next.config.ts` with `output: "standalone"`（Docker 最佳化）
- 必須在專案目錄中執行

## Common Commands

### 執行初始化工具
```bash
./main.sh
```

### 直接執行單一安裝器（用於測試）
```bash
./tailwind_installers/tailwind-v3-shadcn.sh /path/to/project
```

### 腳本執行流程
```bash
main.sh
  ├─ 檢查依賴 (gum, pnpm, 檔案結構)
  ├─ 收集使用者輸入（專案路徑、名稱、套件）
  └─ 調用 setup_next.sh
       ├─ 根據選擇 source 對應的 installer
       ├─ 執行 installer 的 install() 函式
       ├─ 核准 pnpm builds
       ├─ 安裝 dotenv-cli
       └─ 調用 lib/packages.sh 安裝擴充套件
```

## Modifying the Project

### 新增 Tailwind 配置選項
1. 在 `tailwind_installers/` 創建新的安裝器腳本
2. 在 `templates/` 創建所需的配置模板
3. 在 `main.sh` 的 `setup_packages()` 函式中添加選項
4. 在 `setup_next.sh` 的 `case` 語句中添加對應分支

### 新增套件選項
1. 在 `main.sh` 的 `setup_packages()` 中的 gum choose 添加選項
2. 在 `lib/packages.sh` 的 `install_package()` 中添加對應的 case

### 修改配置模板
直接編輯 `templates/` 中的檔案，所有使用該模板的 installer 會自動使用新配置。

### 修改訊息輸出
編輯 `lib/common.sh` 中的訊息函式，所有腳本會一致使用新格式。

**重要**：不要修改任何 UI 相關的輸出格式、顏色、emoji 或訊息措辭，這些是專案的設計風格。

## Key Design Decisions

### 為什麼使用模組化架構？
1. **可維護性** - 每個 Tailwind 選項獨立，修改時不會互相影響
2. **可擴展性** - 新增配置選項只需創建新檔案
3. **減少重複** - 配置模板集中管理
4. **易於測試** - 每個 installer 可以獨立執行

### 為什麼使用 templates/?
- 避免在 shell 腳本中使用大量 heredoc
- 配置檔案更容易編輯和閱讀
- 可以輕鬆比較不同版本的配置差異

### source vs 執行
Installers 被 `setup_next.sh` source（而非執行），這樣：
- installer 的 `install()` 函式可以改變當前工作目錄
- 返回碼可以正確傳遞給父腳本
- 同時支援獨立執行（用於測試）

## Dependencies

**必需的系統依賴：**
- `gum` - Terminal UI toolkit (https://github.com/charmbracelet/gum)
- `pnpm` - Package manager (https://pnpm.io)

**可選安裝的套件：**
- Zustand (state management)
- Zod (schema validation)
- Material UI (component library)
- SWR (data fetching)
- Axios (HTTP client)

## Testing

在修改後測試腳本：

```bash
# 測試完整流程
./main.sh

# 測試單一 installer
./tailwind_installers/tailwind-v3-shadcn.sh /tmp/test-project

# 檢查檔案權限
ls -la lib/ tailwind_installers/ templates/
```
