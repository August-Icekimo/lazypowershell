#!/bin/sh

# ==============================================================================
# PackUp.sh - 用於打包 HRM 專案檔案的腳本
#
# 功能:
# 1. 讀取 'PackageUp.txt' 清單：
#    - 對於 .java 檔案：自動對應 'build/classes/' 下的 .class 檔案。
#      * 包含主類別 (Main Class)。
#      * 自動偵測並包含所有內部類別 (Inner Classes, e.g. Class$Inner.class)。
#    - 對於非 .java 檔案 (如 .sql, .xml)：直接複製原始檔案。
# 2. 建立封存檔：
#    - 產生 .tar.gz (Linux) 與 .zip (Windows) 兩種格式。
#    - 維持原始目錄結構。
# 3. 安全驗證：計算並顯示兩個封存檔的 SHA256 校驗和。
# 4. 發佈：將封存檔移動到共享目錄 (需要 sudo 權限)。
#
# 使用方式:
# 1. 編輯 'PackageUp.txt'，填入要打包的檔案路徑 (一行一個)。
#    範例：
#      src/com/hrm/MyClass.java
#      Stored Procedure/my_proc.sql
# 2. 執行腳本：./PackUp.sh
#
# ==============================================================================

set -e # 如果任何指令執行失敗，立即中止腳本

# --- 組態設定 ---
# 已編譯 .class 檔案的來源基礎目錄
CLASS_BASE_DIR="build/classes"
# 最終打包封存檔的目標位置 (需要 sudo 寫入權限)
SHARE_DIR="/media/share"
# 包含來源檔案清單的檔案名稱
FILE_LIST="PackageUp.txt"

# --- 用於美化輸出的顏色代碼 ---
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_YELLOW='\033[1;33m'
COLOR_BLUE='\033[0;34m'
COLOR_NC='\033[0m' # 清除顏色

# --- 函數定義 ---

info() {
    echo -e "${COLOR_BLUE}[資訊]${COLOR_NC} $1"
}

success() {
    echo -e "${COLOR_GREEN}[成功]${COLOR_NC} $1"
}

error() {
    echo -e "${COLOR_RED}[錯誤]${COLOR_NC} $1" >&2
}

warn() {
    echo -e "${COLOR_YELLOW}[警告]${COLOR_NC} $1" >&2
}

# 腳本結束時執行的清理函數
cleanup() {
    info "正在清理..."
    if [ -n "$WORK_DIR" ] && [ -d "$WORK_DIR" ]; then
        rm -rf "$WORK_DIR"
        info "已移除臨時工作目錄: $WORK_DIR"
    fi
    # 您可以取消註解以下程式碼，讓腳本在打包後自動刪除 PackageUp.txt
    # if [ -f "$FILE_LIST" ]; then
    #     rm "$FILE_LIST"
    #     info "已移除 $FILE_LIST."
    # fi
}

# --- 主要打包邏輯 ---
main() {
    info "開始執行打包程序..."

    # 1. 檢查 PackageUp.txt 是否存在
    if [ ! -f "$FILE_LIST" ]; then
        error "'$FILE_LIST' 不存在，請先建立該檔案。"
        echo "============================= 參考指令 : ==========================="
        echo " git log --name-only -p -3 > $FILE_LIST"
        echo "然後編輯該檔案，僅保留您希望打包的檔案路徑。"
        echo "==================================================================="
        exit 1
    fi

    # 2. 建立一個臨時工作目錄
    # `trap` 指令確保 cleanup 函數會在腳本結束時 (無論是正常結束或發生錯誤) 被呼叫
    WORK_DIR=$(mktemp -d -p "/tmp" "hrm-package-$(date +%Y%m%d-%H%M%S)-XXXX")
    trap cleanup EXIT
    info "已建立臨時工作目錄: $WORK_DIR"

    # 3. 複製 .class 檔案到工作目錄
    info "正在處理檔案清單並複製 .class 檔案..."
    # 透過 grep 過濾掉空白行與註解，只將有效的檔案路徑傳遞給迴圈
    grep -v -E '^[[:space:]]*$|^[[:space:]]*#' "$FILE_LIST" | while IFS= read -r line; do
        
        # 判斷是否為 Java 原始檔
        if echo "$line" | grep -q "\.java$"; then
            # --- 處理 Java 檔案 ---
            
            # 將 .java 路徑轉換為 .class 檔案的基礎路徑 (不含副檔名)
            # 例如：src/com/hrm/File.java -> build/classes/com/hrm/File
            base_path=$(echo "$line" | sed -e "s|^src/|$CLASS_BASE_DIR/|" -e 's/\.java$//')
            
            found_any=false
            
            # 搜尋主類別檔案 (.class) 以及任何內部類別檔案 ($*.class)
            # 注意：若無符合檔案，Glob cache pattern 會保持原樣，故需在迴圈內檢查 -f
            for f in "${base_path}.class" "${base_path}"\$*.class; do
                if [ -f "$f" ]; then
                    rsync -R "$f" "$WORK_DIR"
                    found_any=true
                    
                    # 檢查是否為 Inner Class (檔名包含 $)
                    case "$f" in
                        *\$*)
                            warn "  -> [注意] 發現 Inner Class 並已加入: $f"
                            ;;
                        *)
                            info "  -> 已加入: $f"
                            ;;
                    esac
                fi
            done
            
            if [ "$found_any" = false ]; then
                warn "  -> 找不到對應的 .class 檔案: $line (搜尋路徑: ${base_path}.class 及 \$*.class)"
            fi
            
        else
            # --- 處理非 Java 檔案 (如 .sql, .xml 等) ---
            # 直接檢查檔案是否存在於專案目錄中
            
            if [ -f "$line" ]; then
                rsync -R "$line" "$WORK_DIR"
                info "  -> 已加入 (非 Java 檔案): $line"
            else
                warn "  -> 找不到檔案: $line"
            fi
        fi
    done

    # 計算實際複製到工作目錄中的檔案數量
    FILE_COUNT=$(find "$WORK_DIR" -type f | wc -l)

    if [ "$FILE_COUNT" -eq 0 ]; then
        error "找不到任何有效的 .class 檔案可供打包，程序中止。"
        exit 1
    fi
    success "已複製 $FILE_COUNT 個 .class 檔案。"

    # 4. 建立 .tar.gz 與 .zip 封存檔
    CWD=$(pwd)
    TIMESTAMP=$(date +%Y%m%d-%H%M)
    ARCHIVE_FILE="PackageUp-${TIMESTAMP}.tgz"
    ARCHIVE_ZIP_FILE="PackageUp-${TIMESTAMP}.zip"
    
    info "正在建立封存檔: $ARCHIVE_FILE (及 $ARCHIVE_ZIP_FILE)"
    # 進入臨時目錄進行打包，以確保封存檔內部不會包含臨時目錄的路徑
    (
        cd "$WORK_DIR" || exit 1
        tar -czf "$CWD/$ARCHIVE_FILE" .
        # 使用 -q (quiet) 模式減少 zip 的輸出，除非發生錯誤
        zip -r -q "$CWD/$ARCHIVE_ZIP_FILE" .
    )
    
    if [ ! -f "$ARCHIVE_FILE" ] || [ ! -f "$ARCHIVE_ZIP_FILE" ]; then
        error "建立封存檔失敗 (部分或全部檔案遺失)，程序中止。"
        exit 1
    fi
    success "兩種封存檔皆已成功建立。"

    # 5. 計算並顯示 SHA256 校驗和
    info "正在計算 SHA256 校驗和..."
    CHECKSUM_TGZ=$(sha256sum "$ARCHIVE_FILE" | awk '{print $1}')
    CHECKSUM_ZIP=$(sha256sum "$ARCHIVE_ZIP_FILE" | awk '{print $1}')
    
    echo -e "--------------------------------------------------"
    echo -e "  [TGZ] 檔案:  ${COLOR_YELLOW}$ARCHIVE_FILE${COLOR_NC}"
    echo -e "  [TGZ] SHA256:  ${COLOR_YELLOW}$CHECKSUM_TGZ${COLOR_NC}"
    echo -e "  ----------------------------------------------"
    echo -e "  [ZIP] 檔案:  ${COLOR_YELLOW}$ARCHIVE_ZIP_FILE${COLOR_NC}"
    echo -e "  [ZIP] SHA256:  ${COLOR_YELLOW}$CHECKSUM_ZIP${COLOR_NC}"
    echo -e "--------------------------------------------------"

    # 6. 使用 sudo 將封存檔移動到共享位置
    info "準備將封存檔移動至 '$SHARE_DIR/'"
    warn "此操作需要動用管理者(sudo)權限。"
    
    # 使用 `sudo test` 檢查目標目錄是否存在，因為目前使用者可能沒有讀取權限
    if ! sudo test -d "$SHARE_DIR"; then
        error "目標目錄 '$SHARE_DIR' 不存在或無法存取，程序中止。"
        exit 1
    fi

    # 移動两个檔案
    sudo mv "$ARCHIVE_FILE" "$ARCHIVE_ZIP_FILE" "$SHARE_DIR/"
    
    if [ $? -eq 0 ]; then
        success "封存檔已成功移動至 $SHARE_DIR/"
        success "  -> $ARCHIVE_FILE"
        success "  -> $ARCHIVE_ZIP_FILE"
    else
        error "移動封存檔失敗。檔案可能仍保留在目前目錄。"
        exit 1
    fi

    info "打包程序已完成。"
}

# --- 腳本進入點 ---
main