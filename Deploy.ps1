#!/usr/bin/env pwsh
param (
    [switch]$help = $false,
    [switch]$Dryrun = $false,
    [switch]$deploy = $false,
    [string]$MD5,
    [string]$ZIP
)
# 以下為上版的檔案清單，可直接填入變數，取代PackageUp.txt
$FileList = @'
src/struts.xml
'@
# 以下為上版的壓縮檔案資訊，使用 MD5 SHA256來確認
$MD5 = "Hash=SHA1"
$ZIP = "PackageUp-05141549.zip"
$InputFileList = @()

function helpMessage {
    Write-Host "
    "-help":          # Show help message.
    "-MD5 hash":      # input MD5 hash value
    "-ZIP name":      # input zipfile name.
    "-Dryrun":        # Dry-Run
    "
}
function CreatePackageList {
    # dump $FileList to PackageUp.txt if $FileList is not empty
    if ($FileList -ne '') {
        $FileList | Out-File -FilePath .\PackageUp.txt
    }

    # check if another PackageUp.txt exists
    if (!(Test-Path -Path .\PackageUp.txt) -or $help) {
        Write-Host "
      [PackageUp.txt] NOT FOUND. PLEASE create PackageUp.txt from git .
    ============================= REF CMD : ===========================
     git log -nameonly -p -3 > PackageUp.txt # For 3 Generation commits
    Then EDIT .\PackageUp.txt, only include files you want to package.
    Or fill into variable `$FileList in PackageUp.ps1.
    =====================[PackageUp.txt not found]====================="
        exit
    }
    # read .\PackageUp.txt file, add each line to $InputFileList

}
function PackageUpZip {
    $timestamp = Get-Date -Format "MMddHHmm"
    $TEMPDIR = [System.IO.Path]::GetTempPath() + "DEPLOY_$timestamp"
    $ArchiveFile = "PackageUp-$timestamp.zip"
    # Create $TEMPDIR if it doesn't exist
    if (!(Test-Path -Path $TEMPDIR)) {
        New-Item -Path $TEMPDIR -ItemType Directory | Out-Null
    }

    # Parse $InputFileList, repalce regex ^src with ^build, replace regex .java$ with .class$ , Path replace / with \
    foreach ($InputFile in $InputFileList) {
        $InputFileName = $InputFile -creplace 'src', 'build\classes' -creplace '.java', '.class' -replace '/', '\'

        # Copy $InputFileName to $TEMPDIR with relative path
        $CopyTemp = "$TEMPDIR\$InputFileName"
        $TargetDir = Split-Path -Parent $CopyTemp
        # Test if $TargetDir exists,  or create it quietly
        if (!(Test-Path -Path $TargetDir)) {
            New-Item -Path $TargetDir -ItemType Directory | Out-Null
        }
        Copy-Item -Recurse -Path $InputFileName -Destination $TargetDir
    }
    # Loop through each folder in $TEMPDIR and zip it
    $PACKS = (Get-ChildItem -Directory -Path $TEMPDIR)
    foreach ($PACK in $PACKS) {
        Write-Host "Zipping $PACK"
        Compress-Archive -Path $TEMPDIR\$PACK -DestinationPath .\$ArchiveFile -CompressionLevel Fastest -Update
    }

    # Caculate $ArchiveFile MD5 hash and show it
    $ArchiveFileMD5 = Get-FileHash -Path $ArchiveFile
    Write-Host "MD5: $ArchiveFileMD5"
    # Move $ArchiveFile to Z:(DEV_SHARE_Folder) and delete $TEMPDIR
    # Once you donnot have Z:, you should have D: instead.
    if (Test-Path -Path Z:) {
        Move-Item $ArchiveFile Z:\
    }
    else {
        Move-Item $ArchiveFile D:\
    }
    Remove-Item -Path $TEMPDIR -Recurse -Force
    Remove-Item -Path .\PackageUp.txt
    
}

if ($MyInvocation.MyCommand.Name -eq "PackageUp.ps1") {
    # check if filename is PackageUp.ps1, go through the archive files part
    CreatePackageList
    $InputFileList = Get-Content -Path .\PackageUp.txt
    PackageUpZip
}
# if $deploy is $true, or filename is rename to Deploy.ps1, go through the deploy part
# Deploy part.
if ($deploy -or $MyInvocation.MyCommand.Name -eq "Deploy.ps1") {

    function verifyMD5 {
        if (!(Test-Path -Path $ZIP)) {
            Write-Host "File $ZIP not found."
            exit
        }
        else {
            #check if $MD5 is not null
            if ($null -ne $MD5) {
                $ZipMD5 = Get-FileHash -Path $ZIP
                Write-Host "MD5: $ZipMD5"
                if ($ZipMD5.Hash -ne $MD5) {
                    Write-Host "MD5 not match."
                    exit
                }
                else {
                    Write-Host "MD5 match."
                }
            }
        }

    }

    # if $MD5 or $ZIP is not null, or just want help message
    if ($null -ne $MD5 -or $null -ne $ZIP -or $help) {
        {
            helpMessage
            exit
        }
        CreatePackageList
        $InputFileList = Get-Content -Path .\PackageUp.txt    
        function BackUpClass {
            Write-Host "Backing up..."
            $timestamp = Get-Date -Format "MMddHHmm"
            $TEMPDIR = [System.IO.Path]::GetTempPath() + "BACKUP_$timestamp"
            $ArchiveFile = "PackageUp-$timestamp.zip"
            # Create $TEMPDIR if it doesn't exist
            if (!(Test-Path -Path $TEMPDIR)) {
                New-Item -Path $TEMPDIR -ItemType Directory | Out-Null
            }

            # Parse $InputFileList, repalce regex ^src with ^build, replace regex .java$ with .class$ , Path replace / with \
            foreach ($InputFile in $InputFileList) {
                $InputFileName = $InputFile -creplace 'src', 'build\classes' -creplace '.java', '.class' -replace '/', '\'

                # Copy $InputFileName to $TEMPDIR with relative path
                $CopyTemp = "$TEMPDIR\$InputFileName"
                $TargetDir = Split-Path -Parent $CopyTemp
                # Test if $TargetDir exists,  or create it quietly
                if (!(Test-Path -Path $TargetDir)) {
                    New-Item -Path $TargetDir -ItemType Directory | Out-Null
                }
                Copy-Item -Recurse -Path $InputFileName -Destination $TargetDir
            }
            # Loop through each folder in $TEMPDIR and zip it
            $PACKS = (Get-ChildItem -Directory -Path $TEMPDIR)
            foreach ($PACK in $PACKS) {
                Write-Host "Zipping $PACK"
                Compress-Archive -Path $TEMPDIR\$PACK -DestinationPath .\$ArchiveFile -CompressionLevel Fastest -Update
            }
            # Move $ArchiveFile to Backup and delete $TEMPDIR
            $backupDate = Get-Date -Format "YYYYMMdd"
            $backupPath = "D:\Code/ Backup\$backupDate\HRM_webapps\HRM\"
            if (!(Test-Path -Path $backupPath)) {
                New-Item -Path $backupPath -ItemType Directory | Out-Null
            }
            Move-Item $ArchiveFile $backupPath
            Remove-Item -Path $TEMPDIR -Recurse -Force
        }
        
        BackUpClass # Not functional yet

        verifyMD5
        Write-Host "Extracting...$ZIP"
        # stop tomcat server
        Stop-Service -Name "Tomcat9"
        Expand-Archive -Path $ZIP -DestinationPath . -Force
        Start-Service -Name "Tomcat9"
        Remove-Item -Path $ZIP
    }
}