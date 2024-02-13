# Author: yr3158
# Date: 1706669537

# Check if this script is running with admin privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Please run this script with admin privileges."
    exit
}

# Environment variables
Set-Variable -Name DomainController -Value "HyperVAD-2019"  # Change this to your domain controller
Set-Variable -Name Bastion -Value $env:COMPUTERNAME         # This is your bastion node, may it last at last
Set-Variable -Name MyScriptPath                             # This is where your script is
Set-Variable -Name MyScriptFile                             # This is the name of your Custom script(e.g for sutdown script)
Set-Variable -Name NodeInfoFile  -Value "HVN"               # This is the PATH of Nodes Info Files.

# Ask Domain Controller for list of running nodes.
#   Get-ADComputer -Filter 'Enabled -eq "True"' # This snippet will list all enabled nodes in the domain
$HVNodes = Invoke-Command -ComputerName $DomainController -ScriptBlock { Get-ADComputer -Filter 'Enabled -eq "True"' } | Select-Object -Property Name

# Run Get-VM on each node in $HVNodes
# Store results in $NodeInfoFile\$HVNodes\RunningVM
# This file structure will be used in later management scripts, like RunScriptOnNodes.ps1
$HVNodes | ForEach-Object -Process {

    $Node = $_.Name
    Write-Host "Running Get-VM on $Node"

    # Check if $node directory exists, if not, create it
    if (-not (Test-Path -Path .\$NodeInfoFile\$Node)) {
        New-Item -Force -Path .\$NodeInfoFile\$Node -ItemType Directory
    }
    # Run Get-VM remotely, select only running VMs Name property and store in $HVNodes\RunningVM
    Invoke-Command -ComputerName $Node -ScriptBlock { Get-VM | Where-Object -Property State -eq "Running" | Select-Object -Property Name } | Export-Csv -Encoding UTF8 -Path .\$NodeInfoFile\$Node\RunningVM.csv

    # Run Get-NetAdapter remotely, store in $HVNodes\NetAdapters
    # Invoke-Command -ComputerName $Node -ScriptBlock {Get-NetAdapter} | Out-File -FilePath .\$Node\NetAdapters
    # Run Get-VMSwitch remotely, store in $HVNodes\VMSwitchs
    # Invoke-Command -ComputerName $Node -ScriptBlock {Get-VMSwitch } | Out-File -FilePath .\$Node\VMSwitchs

}

# remove Bastion from $HVNodes
# $HVNodes = $HVNodes | Where-Object -Property Name -ne $Bastion

function ResolveNodeIP {

    # for each node in $HVNodes, find out its IP
    $HVNodes | ForEach-Object -Process {
        $Node = $_.Name
        $NodeIP = (Resolve-DnsName -Name $Node -Type A).IPAddress
        $NodeIP
    }
}

# If Wake on lan is enabled, collect MAC address of each node can be used to wake it up after power resume.