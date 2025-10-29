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
│   └── packages.sh                   # 套件安裝邏輯（Shadcn UI, Zustand, Zod, MUI, SWR, Axios）
├── templates/                        # 配置檔案模板
│   ├── tailwind-v3.config.ts        # Tailwind v3 配置模板
│   ├── postcss-v3.config.mjs        # PostCSS v3 配置
│   ├── postcss-v4.config.mjs        # PostCSS v4 配置
│   ├── globals-v3.css               # Tailwind v3 全域樣式
│   └── globals-v4.css               # Tailwind v4 全域樣式
├── next_installers/                  # Next.js 配置安裝器（每個選項一個檔案）
│   ├── tailwind-v3.sh               # Tailwind v3
│   ├── tailwind-v4.sh               # Tailwind v4
│   └── no-tailwind.sh               # 不安裝 Tailwind
├── main.sh                           # 主入口點，處理使用者互動
├── setup_next.sh                     # 協調安裝流程，調用 next_installers
└── setup_config.sh                   # 配置 next.config.ts
```

## Architecture

### 1. main.sh - 主入口點和使用者互動
- 驗證依賴（`gum`, `pnpm`）
- 呈現互動式選單（使用 `gum`）
- 收集使用者輸入：專案路徑、名稱、Tailwind 選項、擴充套件
- **智慧選單**：根據 Tailwind 選擇條件顯示 Shadcn UI 選項
- 協調執行 setup_next.sh 和 setup_config.sh
- **保留所有原始的 UI 設計**：顏色、emoji、ASCII art、gum 界面

### 2. lib/common.sh - 共用函式庫
提供所有腳本使用的共用功能：
- **顏色常數**：`NC`, `RED`, `GREEN`, `YELLOW`, `BLUE`, `CYAN`
- **訊息函式**：`error_exit()`, `error_msg()`, `success_msg()`, `info_msg()`, `warning_msg()`
- **檢查函式**：`check_command()`, `check_file()`, `check_directory()`

### 3. lib/packages.sh - 套件安裝管理
- `install_package()` - 安裝單一套件（包含 Shadcn UI）
- `install_packages()` - 批次安裝套件
- 支援套件：Shadcn UI, Zustand, Zod, Material UI, SWR, Axios
- **Shadcn UI 依賴檢查**：自動檢測 Tailwind 配置檔案是否存在

### 4. next_installers/ - 模組化的 Next.js 配置安裝器
每個安裝器都是獨立的可執行腳本，包含：
- 獨立的 `install()` 函式
- 載入 `lib/common.sh` 以使用共用函式
- 使用 `templates/` 中的配置模板
- 可以單獨執行或被 `setup_next.sh` source 調用

**安裝器對應關係：**
- `tailwind-v3.sh` → "Tailwind CSS v3"
- `tailwind-v4.sh` → "Tailwind CSS v4"
- `no-tailwind.sh` → "不安裝Tailwind CSS"

### 5. templates/ - 配置檔案模板
所有配置檔案模板集中管理，避免在腳本中使用 heredoc。

### 6. setup_next.sh - 協調安裝流程
- 顯示 ASCII art 標題
- 使用 `case` 語句根據選擇調用對應的 Next.js installer
- 執行後續步驟：核准 pnpm builds、安裝 dotenv-cli、安裝擴充套件（含 Shadcn UI）

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
./next_installers/tailwind-v3.sh /path/to/project
```

### 腳本執行流程
```bash
main.sh
  ├─ 檢查依賴 (gum, pnpm, 檔案結構)
  ├─ 收集使用者輸入
  │   ├─ 專案路徑、名稱
  │   ├─ Tailwind 選項（單選：v3, v4, 不安裝）
  │   └─ 擴充套件（多選：Shadcn UI*, Zustand, Zod, MUI, SWR, Axios）
  │       *僅在選擇 Tailwind 時顯示
  └─ 調用 setup_next.sh
       ├─ 根據選擇 source 對應的 Next.js installer
       ├─ 執行 installer 的 install() 函式
       ├─ 核准 pnpm builds
       ├─ 安裝 dotenv-cli
       └─ 調用 lib/packages.sh 安裝擴充套件（含 Shadcn UI）
```

## Modifying the Project

### 新增 Next.js 配置選項（如新的 CSS 框架）
1. 在 `next_installers/` 創建新的安裝器腳本
2. 在 `templates/` 創建所需的配置模板
3. 在 `main.sh` 的 `setup_packages()` 函式中添加選項
4. 在 `setup_next.sh` 的 `case` 語句中添加對應分支

### 新增擴充套件選項
1. 在 `main.sh` 的 `setup_packages()` 函式中：
   - 根據需求決定加入哪個 gum choose 區塊（有 Tailwind 或無 Tailwind）
   - 如果套件需要特定依賴（如 Shadcn 需要 Tailwind），加入有 Tailwind 區塊
2. 在 `lib/packages.sh` 的 `install_package()` 中添加對應的 case
3. 如果套件有依賴需求，在 case 中加入檢查邏輯

### 修改配置模板
直接編輯 `templates/` 中的檔案，所有使用該模板的 installer 會自動使用新配置。

### 修改訊息輸出
編輯 `lib/common.sh` 中的訊息函式，所有腳本會一致使用新格式。

**重要**：不要修改任何 UI 相關的輸出格式、顏色、emoji 或訊息措辭，這些是專案的設計風格。

## Key Design Decisions

### 為什麼使用模組化架構？
1. **可維護性** - 每個配置選項獨立，修改時不會互相影響
2. **可擴展性** - 新增配置選項只需創建新檔案
3. **減少重複** - 配置模板集中管理
4. **易於測試** - 每個 installer 可以獨立執行

### 為什麼將 Shadcn UI 從 Tailwind 安裝器分離？
1. **避免組合爆炸** - Tailwind v3/v4 × Shadcn 有/無 = 4 個檔案，未來加入其他 UI library 會更多
2. **更靈活** - 使用者可以自由選擇 UI library 組合
3. **職責分離** - Tailwind 安裝器只負責 Tailwind，UI library 由 packages.sh 處理
4. **智慧 UI** - 根據 Tailwind 選擇動態顯示相容的套件選項
5. **依賴檢查** - 安裝 Shadcn 時自動檢測 Tailwind 配置檔案

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
- Shadcn UI (component library, 需要 Tailwind CSS)
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
./next_installers/tailwind-v3.sh /tmp/test-project

# 檢查檔案權限
ls -la lib/ next_installers/ templates/
```
