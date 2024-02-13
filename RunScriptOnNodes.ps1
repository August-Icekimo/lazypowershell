# Author: yr3158
# Date: 1706670549

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
Set-Variable -Name NodeInfoFile  -Value "HVN"               # This is the PATH of Nodes InfoFile.

$helpMessage = @"
"-help":          # Show help message.
"-Plan":        # open middle file with notepad, 
"-Shutdown":    # Run Shutdown Script.
"-RunScript":   # Run Custom Script, Not yet implemented.
"@

# if $args is not empty, check if $args contains "-help"
if ($args -ne $null) {
    if ($args -contains "-help" ) { 
        Write-Host $helpMessage
        exit 
    }
    if ($args -notcontains "-Plan" -and $args -notcontains "-Shutdown" ) { 
        Write-Host $helpMessage
    }    
}
else {
    Write-Host $helpMessage
    exit
}

# Define a Object from Directory Names in the $HVNodes
# This implyes that $HVNodes is an array of Directory Names.
$HVNodes = Get-ChildItem -Path .\$NodeInfoFile -Directory


function GenerateShutdownScriptPerOnNode {
    # For each $Nodes in $HVNodes, Import CSV from .\$NodeInfoFile\$Node\RunningVM.csv into $RunningVMs .
    $HVNodes | ForEach-Object -Process {
    
        $Node = $_.Name
        Write-Host "Reading .\$NodeInfoFile\$Node\RunningVM into $RunningVMs"
        $RunningVMs = Import-Csv -Path .\$NodeInfoFile\$Node\RunningVM.csv
        $RunningVMs | Format-Table

        # define $VMName_Skip as string array
        # $VMName_Skip will be used to skip $VMName if $VMName_Skip contains $VMName            
        $VMName_Skip = @()

        # Iterate through $RunningVMs, write "$Node, $RunningVM.Name" into file ".\$NodeInfoFile\$Node\RunningVM"
        $RunningVMs | ForEach-Object -Process {
            # save $_.Name into $VMName
            $VMName = $_.Name

            # Try to find $VMName AP and DB Pair. If found, remove $VMName from $RunningVMs
            # Currently, AP and DB are in the same Node, and one on one simply paired.
            # If AP and DB are odd nameing rule , such as "Ganymede, Callisto, Io, Europa, Jupiter", 
            # then we need to put them seqentially in same line.
            
            # $VMName contain "AP" or "DB"
            if ($VMName -match "AP") {
                $VM_DBPartner = $VMName -replace "AP", "DB"
                if ($RunningVMs | Where-Object -Property Name -eq $VM_DBPartner) {
                
                    "$Node, $VMName, $VM_DBPartner" | Out-File -Append -FilePath .\$NodeInfoFile\$Node\RunningVM 
                    
                    # add $VM_DBPartner into $VMName_Skip array
                    $VMName_Skip += $VM_DBPartner
                    $VMName_Skip | Format-Table # Debug
                }
            }
            else {
                # if $VMName not exists in array$VMName_Skip, do  echo "$Node, $VMName" into file ".\$NodeInfoFile\$Node\RunningVM"
                if ($VMName_Skip -contains "$VMName") {
                    #Skip this foreach loop
                    Write-Host " !! $Node, $VMName has been add in formor RunningVM"
                }
                else {
                    "$Node, $VMName" | Out-File -Append -FilePath .\$NodeInfoFile\$Node\RunningVM  
                }
            }
        }
        # check if file ".\$NodeInfoFile\$Node\RunningVM" is exists
        if (Test-Path -Path .\$NodeInfoFile\$Node\RunningVM) {
            # open file ".\$NodeInfoFile\$Node\StoppingScript" with notepad
            notepad .\$NodeInfoFile\$Node\RunningVM
        } else {
            Write-Host "$Node\RunningVM is not exists"
        }

    }

    # Ask user iuput "Yes" to continue, comfirm every node RunningVM shutdown sequence.
    Write-Host "You should confirm every node\RunningVM shutdown sequence."
    # If there are CustomScript Override, user can always override them by CustomScript. 
    Write-Host "Manually edit them aside, or use CustomScript Override."
    $confirmContinue = Read-Host -Prompt "Enter No to exit. anything else to Go on"
    if ($confirmContinue -eq "No") {
        exit
    }

    
    $HVNodes | ForEach-Object -Process {

        $Node = $_.Name

        # Createfile ".\$NodeInfoFile\$Node\StoppingScript", and empty it.
        New-Item -Force -Path .\$NodeInfoFile\$Node\StoppingScript -ItemType File
        # Append Start Message into file ".\$NodeInfoFile\$Node\StoppingScript"
        "Write-Host `"Start Shutdown VM on $Node...`"" | Out-File -Append -FilePath .\$NodeInfoFile\$Node\StoppingScript
        
        # create a genShutdownScript function, can accept variable arguments.
        function genShutdownScript {
            param (
                $node, $VMNames
            )
            # Show input parameter
            Write-Host "Get Node: $node"
            Write-Host "Get VMNames: $VMNames"

            foreach ($VMName in $VMNames) {

                Write-Host "Shutdown $VMName on $node ... "  | Out-File -Append -FilePath .\$NodeInfoFile\$Node\StoppingScript
                # Check if customScript Override exist.
                if (Test-Path -Path .\$NodeInfoFile\$Node\"$VMName"_runoff.ps1) {
                    Write-Host "Found $Node\"$VMName"_runoff.ps1 as customScript Override."
                    # Append .\$NodeInfoFile\$Node\"$VMName"_runoff.ps1 directly into file ".\$NodeInfoFile\$Node\StoppingScript"
                    . .\$NodeInfoFile\$Node\"$VMName"_runoff.ps1 | Out-File -Append -FilePath .\$NodeInfoFile\$Node\StoppingScript
                }
                else {
                    # use HereString append script to file ".\$NodeInfoFile\$Node\StoppingScript"
                    @"
if (Get-VM -Name $VMName | select -Property State -eq Running) {
    Stop-VM -Name $VMName
}
Write-Host "$VMName on $node has been shutdown"
"@ |  Add-Content  .\$NodeInfoFile\$Node\StoppingScript
                }
            }

            # open file ".\$NodeInfoFile\$Node\StoppingScript" with notepad
            notepad .\$NodeInfoFile\$Node\StoppingScript

        }
        # check if .\$NodeInfoFile\$Node\StoppingScript exists
        if (Test-Path -Path .\$NodeInfoFile\$Node\StoppingScript) {
            # read each line of .\$NodeInfoFile\$Node\RunningVM into genShutdownScript 
            Get-Content -Path .\$NodeInfoFile\$Node\RunningVM | ForEach-Object -Process { genShutdownScript $_ }
        }

    }
}

# Warning: Workflow ParallelStopVMs is not supported in PowerShell 6+
function RunShutdownScriptFileOnNode {
    Workflow ParallelStopVMs {
        foreach -Parallel -ThrottleLimit 4 ( $Node in $HVNodes) {
            InlineScript { 
                Write-Host "Running Shutown Script on $Node ..."
                try {
                    Invoke-Command -ComputerName $Node -FilePath .\$NodeInfoFile\$Node\StoppingScript
                }
                finally {
                    Write-Host "$Node : Shutdown Script has been finished."
                }
            }
        }
    }
    ParallelStopVMs
}

# Argument contains "-Plan"
if ($args -contains "-Plan") {
    GenerateShutdownScriptPerOnNode
}

# Argument contains "-Shutdown"
if ($args -contains "-Shutdown") {
    # Check if powershell version is less than 6
    if ($PSVersionTable.PSVersion.Major -lt 6) {
        RunShutdownScriptFileOnNode
    }
    else {
        $HVNodes | ForEach-Object -Parallel -ThrottleLimit 4 {
            $Node = $_.Name
            Write-Host "Running Shutown Script on $Node ..."
            notepad .\$NodeInfoFile\$Node\StoppingScript
            Write-Host "Invoke-Command -ComputerName $Node -FilePath .\$NodeInfoFile\$Node\StoppingScript" # Dry-run First
            Write-Host "$Node : Shutdown Script has been finished."
        }
    }
}

# Reserve function for future use

# Check if input argument contains "-ScriptFile", if so, pass next args "ScriptFileName" to RunScriptFileOnNode
if ($args -contains "-ScriptFile") {
    $ScriptFileName = $args[($args.IndexOf("-ScriptFile") + 1)]
    RunScriptFileOnNode($ScriptFileName)
}
function RunScriptFileOnNode {
    param (
        $ScriptFileName
    )
    if ($null -eq $ScriptFileName) {
        # Read input from user, then relpace $MyScriptFile with user input
        $MyScriptFile = Read-Host -Prompt "Input a script filename"
        # if $MyScriptFile is null, set to default filename, lead to Get-VM
        if (-not $MyScriptFile) {
            $MyScriptFile = "ShowNodePWStest.ps1"
        }
    }

    # Run .\$MyScriptPath\$MyScriptFile on each node in $HVNodes
    $HVNodes | ForEach-Object -Process {
        $Node = $_.Name
        Write-Host "Running .\$MyScriptPath\$MyScriptFile on $Node"
        Invoke-Command -ComputerName $Node -FilePath .\$MyScriptPath\$MyScriptFile
    }
}