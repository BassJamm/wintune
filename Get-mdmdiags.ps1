<#
.SYNOPSIS
    Script will attempt to collect MDM Diagnostic Logs.
#>

# Collect diag logs
Write-Host "Collecting Autopilot Diagnostics" -ForegroundColor Yellow
Start-Process "C:\windows\System32\MdmDiagnosticsTool.exe" -ArgumentList "-area Autopilot -zip C:\Temp\Wintune\mdmdiags.zip" -NoNewWindow
Start-Sleep -Seconds 2

if(Test-Path 'C:\Temp\Wintune\mdmdiags.zip'){
    Write-Output "Diagnostic Logs collected successfully" -ForegroundColor Green
} else {
    Write-Host "Error collecting Diagnostic Logs, please try again." -ForegroundColor Red
    Return
}

# Download Community Script
if(!(Get-InstalledScript Get-AutopilotDiagnosticsCommunity)){
    try {
        Write-Host "Installing Get-AutopilotDiagnosticsCommunity script..."
        Install-Script -Name Get-AutopilotDiagnosticsCommunity
    }
    catch {
        Write-Host "Error Downloading Script."
        Return
    }
}
# Run the script
$fileName = "C:\Temp\Wintune\mdmdiags-$(Get-Date -uFormat "%H-%M-%S").txt"
Write-Host "Writing output to here, $fileName"
Get-AutopilotDiagnosticsCommunity -ZIPFile C:\Temp\Wintune\mdmdiags.zip -Online *>&1 | Tee-Object -FilePath $fileName