<#
.SYNOPSIS
    Script will attempt to collect MDM Diagnostic Logs.
#>
###############################
#	Globally Used Variables   #
###############################
$runTime = Get-Date -uFormat "%H-%M-%S"
$outPutFilename = "mdmdiags-$runTime.txt"
$diagFileName = "mdmdiags-$runTime.zip"
#endRegion

###########################
#	Collect Diagnostics   #
###########################

# Collect diag logs
Write-Host "Collecting Autopilot Diagnostics" -ForegroundColor Yellow
Start-Process "C:\windows\System32\MdmDiagnosticsTool.exe" -ArgumentList "-area Autopilot -zip C:\Temp\Wintune\AutopilotDiag\$diagFileName" -NoNewWindow -Wait
Start-Sleep -Seconds 15

if(Test-Path "C:\Temp\Wintune\AutopilotDiag\$diagFileName"){
    Write-Host "Diagnostic Logs collected successfully" -ForegroundColor Yellow
} else {
    Write-Host "Error collecting Diagnostic Logs, please try again." -ForegroundColor Red
    Return
}
#endRegion

#################################
#	Download Community Script   #
#################################

if(!(Get-InstalledScript Get-AutopilotDiagnosticsCommunity)){
    try {
        Write-Host "Installing Get-AutopilotDiagnosticsCommunity script..."
        Install-Script -Name Get-AutopilotDiagnosticsCommunity -Force
		$env:PATH += ";C:\Program Files\PowerShell\Scripts" # Manually update path to save restarting session.
    }
    catch {
        Write-Host "Error Downloading Script."
        Return
    }
}
# Run the script
Write-Host "Exporting all data here, $outPutFilename" -ForegroundColor Yellow
Get-AutopilotDiagnosticsCommunity.ps1 -ZIPFile "C:\Temp\Wintune\AutopilotDiag\$diagFileName" -Online *>&1 | Tee-Object -FilePath "C:\Temp\Wintune\AutopilotDiag\$outPutFilename"
#endRegion

Write-Host "Completed Get-MDMDiagnostics flow" -ForegroundColor Green