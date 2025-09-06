# 使用官方 Code Server 映像檔作為基礎，它基於 Ubuntu
FROM codercom/code-server:ubuntu

# 設定環境變數，避免apt-get的互動式設定
ENV DEBIAN_FRONTEND=noninteractive

# 安裝 Java、Python、Go、PowerShell 等環境
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y openjdk-17-jdk python3 python3-pip golang-go wget && \
    wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y powershell && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 直接在容器內生成插件清單，避免外部檔案傳輸問題
# 請將你自己完整的插件清單複製到此處
RUN cat > /tmp/vscode-extensions-list.txt << EOF
amazonwebservices.amazon-q-vscode
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
vscjava.vscode-maven
EOF

# 安裝所有列在清單中的 VS Code 插件
RUN while read line; do \
    echo "正在安裝插件: $line"; \
    code-server --install-extension "$line" --force; \
done < /tmp/vscode-extensions-list.txt

# 切換回 coder 使用者，以非 root 身份運行服務，增加安全性
USER coder