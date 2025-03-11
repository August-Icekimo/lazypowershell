<# 用來測試TOMCAT服務的簡易腳本
 # 囿於現狀用舊版.NET Framework version: v4.0.30319 PSVersion: 5.1
 # 用法:    .\CheckURL.ps1
 #>

 #測試URL清單
$URLLists = @(
    "https://www.google.com.tw/",
    "https://www.linkedin.com/",
    "https://www.reddit.com/",
    "https://evernote.com/",
    "https://www.facebook.com/"
    )


#define function WebCheck accept URL as parameter
function WebCheck {
    param (
        $Uri
    )
    # Set error action preference to continue so we can handle errors gracefully
    $ErrorActionPreference = 'Continue'

    try {
        Write-Host "`n[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Starting connection test..." -ForegroundColor Cyan
    
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

        Write-Host "Attempting to connect to $Uri" -ForegroundColor Yellow
    
        $WebRequest = [System.Net.WebRequest]::Create($Uri)
        $WebRequest.Timeout = 30000  # 30 seconds timeout
    
        Write-Host "Sending request..." -ForegroundColor Yellow
        $Response = $WebRequest.GetResponse()
    
        $Stream = $Response.GetResponseStream()
        $Reader = New-Object System.IO.StreamReader($Stream)
        $Content = $Reader.ReadToEnd()
    
        # Display success message with status code
        Write-Host "`n✔ Connection Test Successful" -ForegroundColor Green
        Write-Host "  Status Code: $([int]$Response.StatusCode) - $($Response.StatusDescription)" -ForegroundColor Green
        Write-Host "  Server: $($Response.Server)" -ForegroundColor Green
        Write-Host "  Content Length: $($Response.ContentLength) bytes" -ForegroundColor Green
    
        # Cleanup
        $Reader.Close()
        $Response.Close()
    } 
    catch {
        Write-Host "`n❌ Connection Failed!" -ForegroundColor Red
    
        # Detailed error information
        $errorDetails = @{
            TimeStamp    = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            ErrorMessage = $_.Exception.Message
            ErrorType    = $_.Exception.GetType().FullName
            TargetObject = $_.TargetObject
        }

        # Display detailed error information
        Write-Host "`nError Details:" -ForegroundColor Red
        Write-Host "  Time: $($errorDetails.TimeStamp)" -ForegroundColor DarkRed
        Write-Host "  Type: $($errorDetails.ErrorType)" -ForegroundColor DarkRed
        Write-Host "  Message: $($errorDetails.ErrorMessage)" -ForegroundColor DarkRed
    
        # Handle specific error types
        switch -Regex ($_.Exception.GetType().FullName) {
            'WebException' {
                $webException = $_.Exception
                Write-Host "`nWeb Exception Details:" -ForegroundColor Magenta
                Write-Host "  Status: $($webException.Status)" -ForegroundColor DarkMagenta
                if ($webException.Response) {
                    Write-Host "  Status Code: $([int]$webException.Response.StatusCode) - $($webException.Response.StatusDescription)" -ForegroundColor DarkMagenta
                }
            }
            'TimeoutException' {
                Write-Host "`nConnection timed out. Please check if the server is accessible." -ForegroundColor Yellow
            }
            'AuthenticationException' {
                Write-Host "`nSSL/TLS authentication failed. Certificate validation issue." -ForegroundColor Yellow
            }
        }
    
        # Write to error stream for logging purposes
        Write-Error $_.Exception.Message
    }
    finally {
        if ($Reader) { $Reader.Dispose() }
        if ($Response) { $Response.Dispose() }
        Write-Host "`n[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Test completed.`n" -ForegroundColor Cyan
    }

} 

# loop through the URL list and call WebCheck function
foreach ($Uri in $URLLists) {
    WebCheck -Uri $Uri
}