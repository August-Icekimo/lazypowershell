#!/bin/sh

# --- 變數宣告區 ---
# 映像檔名稱，需要與上一步驟一致
IMAGE_NAME="my-awesome-code-server"

# 容器名稱
CONTAINER_NAME="my_dev_container"

# 你的專案目錄路徑
PROJECT_PATH="/home/icekimo/Projects/my_awesome_project"

# 這是Code Server所有設定檔與插件的儲存目錄
VSCODE_PERSISTENT_PATH="/home/icekimo/CodeServerData"

# 標記插件是否已安裝的檔案
INSTALLED_FLAG_FILE="${VSCODE_PERSISTENT_PATH}/.extensions_installed"

# 設定 Code Server 密碼
# 建議從環境變數讀取密碼，避免將密碼明文寫在腳本中
# 如果環境變數 CODE_SERVER_PASSWORD 未設定，則使用預設值
CODE_SERVER_PASSWORD="${CODE_SERVER_PASSWORD:-MyStrongPassword@7677}"


# 這是Code Server在容器內運行的端口
CONTAINER_PORT="8080"

# 這是你從瀏覽器連線時使用的端口
HOST_PORT="8080"

# 找出你當前使用者的UID和GID，用於容器內的權限映射
USER_ID=$(id -u)
GROUP_ID=$(id -g)
echo "偵測到 UID: ${USER_ID}, GID: ${GROUP_ID}"

# --- 插件清單 (HereDoc) ---
# 這個清單只會在初次設定時使用
EXTENSION_LIST="amazonwebservices.amazon-q-vscode
cweijan.vscode-office
docker.docker
dotjoshjohnson.xml
esbenp.prettier-vscode
fyzhu.git-pretty-graph
github.copilot
github.copilot-chat
google.gemini-cli-vscode-ide-companion
google.geminicodeassist
madhavd1.javadoc-tools
mechatroner.rainbow-csv
mk12.better-git-line-blame
ms-azuretools.vscode-containers
ms-ceintl.vscode-language-pack-zh-hant
ms-mssql.data-workspace-vscode
ms-mssql.mssql
ms-mssql.sql-bindings-vscode
ms-mssql.sql-database-projects-vscode
ms-python.debugpy
ms-python.isort
ms-python.python
ms-python.vscode-pylance
ms-vscode-remote.remote-containers
ms-vscode.hexeditor
ms-vscode.powershell
redhat.java
rooveterinaryinc.roo-cline
shd101wyy.markdown-preview-enhanced
taoklerks.poor-mans-t-sql-formatter-vscode
tomoki1207.pdf
visualstudioexptteam.intellicode-api-usage-examples
visualstudioexptteam.vscodeintellicode
vscjava.vscode-gradle
vscjava.vscode-java-debug
vscjava.vscode-java-dependency
vscjava.vscode-java-pack
vscjava.vscode-java-test
vscjava.vscode-maven"

# --- 檢查與準備 ---
# 確保專案目錄存在
if [ ! -d "$PROJECT_PATH" ]; then
    echo "錯誤！指定的專案目錄 $PROJECT_PATH 不存在，請檢查路徑後再試。"
    exit 1
fi

# 確保設定檔目錄存在，如果不存在則自動創建並設定權限
if [ ! -d "$VSCODE_PERSISTENT_PATH" ]; then
    echo "警告！持久化目錄 $VSCODE_PERSISTENT_PATH 不存在，正在創建中..."
    mkdir -p "$VSCODE_PERSISTENT_PATH"
    if [ $? -ne 0 ]; then
        echo "錯誤！無法創建持久化目錄，請檢查權限。"
        exit 1
    fi
    chown "${USER_ID}:${GROUP_ID}" "$VSCODE_PERSISTENT_PATH"
fi

# --- 執行指令 ---
# 檢查是否需要進行一次性初始化
if [ ! -f "$INSTALLED_FLAG_FILE" ]; then
    echo "真是令人興奮啊！首次啟動，正在進行插件安裝..."

    # 逐一為每個插件啟動一個臨時容器來進行安裝
    # 這種方法雖然較慢，但隔離性最強，最為穩健
    INSTALL_SUCCESS=0
    for extension in ${EXTENSION_LIST}; do
        echo "--> 正在安裝插件: ${extension}"
        docker run --rm \
            -u "${USER_ID}:${GROUP_ID}" \
            -v "${VSCODE_PERSISTENT_PATH}:/home/coder" \
            "${IMAGE_NAME}" \
            code-server --install-extension "${extension}"
        
        if [ $? -ne 0 ]; then
            echo "錯誤！安裝插件 ${extension} 失敗。"
            INSTALL_SUCCESS=1 # 標記為失敗
        fi
    done
    # 在安裝完成後，創建標記檔案，標示初始化已完成
    if [ ${INSTALL_SUCCESS} -eq 0 ]; then
        echo "插件安裝成功！正在創建標記檔案..."
        touch "$INSTALLED_FLAG_FILE"
        chown "${USER_ID}:${GROUP_ID}" "$INSTALLED_FLAG_FILE"
    else
        echo "錯誤！插件安裝失敗。請檢查日誌後再試。"
        exit 1
    fi
fi

# 移除可能已存在的舊容器
if [ "$(docker ps -a -q -f name=${CONTAINER_NAME})" ]; then
    echo "正在移除舊容器: ${CONTAINER_NAME}..."
    docker rm --force "${CONTAINER_NAME}"
fi

# 啟動你的主要 Code Server 容器
echo "正在啟動主要 Code Server 容器..."
docker run \
    --name "${CONTAINER_NAME}" \
    -d \
    -p ${HOST_PORT}:${CONTAINER_PORT} \
    -v "${PROJECT_PATH}:/home/coder/project" \
    --restart unless-stopped \
    -v "${VSCODE_PERSISTENT_PATH}:/home/coder" \
    -u "${USER_ID}:${GROUP_ID}" \
    -e PUID="${USER_ID}" \
    -e PGID="${GROUP_ID}" \
    -e PASSWORD="${CODE_SERVER_PASSWORD}" \
    "${IMAGE_NAME}"

echo "Code Server 已成功啟動！請在瀏覽器中訪問 http://你的LXC_IP地址:8080"
