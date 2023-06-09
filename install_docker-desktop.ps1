# Download file from DockerHUb 
Set-Variable -Name fileURL -Value "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe?_gl=1*121f225*_ga*NDk2MTI4MDIwLjE2NjY3NjYzNjQ.*_ga_XJWPQMJYHQ*MTY4NjEwODc2OC4yLjEuMTY4NjEwODg0My41OC4wLjA."
try {
    Invoke-WebRequest -Uri $fileURL -OutFile "D:\DockerDesktopInstaller.exe"
}
catch {
    Write-Host "下載失敗"
}

Start-Process 'D:\DockerDesktopInstaller.exe' -Wait install

# add the user to the docker-users group.
# Get current username
Set-Variable -Name userName -Value $env:username

Add-LocalGroupMember -Name docker-users -Member $userName

# 更新WSL
wsl --update

# 將預設容器類型設定為 Windows 容器
& $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchDaemon .