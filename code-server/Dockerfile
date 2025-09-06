# 使用官方 Code Server 映像檔作為基礎，它基於 Ubuntu
FROM codercom/code-server:ubuntu

# 設定環境變數，避免apt-get的互動式設定
ENV DEBIAN_FRONTEND=noninteractive
USER root
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

# 切換回 coder 使用者
USER coder
