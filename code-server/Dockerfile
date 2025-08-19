FROM linuxserver/code-server:latest

# 切換至 root 使用者以安裝軟體
USER root

# 安裝 Python, Java 和 Git
RUN apt-get update && \
    apt-get install -y \
    python3 \
    python3-pip \
    openjdk-17-jdk \
    git && \
    rm -rf /var/lib/apt/lists/*

# 安裝 VS Code 擴充功能
# 您可以在 Open VSX Registry (https://open-vsx.org/) 找到擴充功能的 ID
RUN code-server --install-extension ms-python.python && \
    code-server --install-extension vscjava.vscode-java-pack && \
    code-server --install-extension GitLab.gitlab-workflow && \
    code-server --install-extension GitHub.vscode-pull-request-github

# 切換回預設使用者
USER abc