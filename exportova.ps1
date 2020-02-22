# 定義所需要的參數
$ESXHost = "192.168.15.102"
$password = ConvertTo-SecureString 'password' -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ('root', $password)
    # $password = ""
$DestinationPath = "D:\"
# 檢查與安裝VMware.PowerCLI
Try {
    Get-Module -ListAvailable -Name VMware.PowerCLI
} Catch {
    Set-PSRepository -InstallationPolicy Trusted -Name PSGallery
    Install-Module VMware.PowerCLI -scope CurrentUser
}

# 嘗試連上ESXi主機
Try {
    Connect-viServer -server $ESXHost -Credential $credential
} Catch {
    $ErrorMessage = $_.Exception.Message
    Write-Output "Connection Fail:\n\r $ErrorMessage"
    Break
} Finally {
    Write-Output "Connection to $ESXHost established."
}

# 取得目前關機狀態VM名稱
$OFFVM = (get-VM | Where-Object {$_.PowerState -eq "PoweredOff" })
# 將主機逐一匯出成OVA格式
Foreach ($VMNAME in $OFFVM.Name) {
# 清除Snapshot、附接的光碟
    Try {
        Get-Snapshot $VMNAME | Remove-Snapshot -Confirm:$false
        # Get-VM $VMNAME | Shutdown-VMGuest -Confirm:$false
        Get-VM $VMNAME | Get-CDDrive | Set-CDDrive -NoMedia -Confirm:$false
    } Catch {
        $ErrorMessage = $_.Exception.Message
        Write-Output "Clean snapshot & attachMedia Fail:\n\r $ErrorMessage"
        Break
    }
# 開始匯出
    Try{
        Get-VM $VMNAME | Export-VApp -Destination $DestinationPath -Format OVA
    } Catch {
        $ErrorMessage = $_.Exception.Message
        Write-Output "Clean snapshot & attachMedia Fail:\n\r $ErrorMessage"
        Write-Host "$VMNAME is failed to backup."
        # Break
    } Finally {
        Write-Host "$VMNAME is backup to $DestinationPath."
    }

}
