<#
    .Synopsis
        Script will attempt to download the script to test attestation readiness and run it.
    .DESCRIPTION
        I did not create the attestation test script, I wrote only the code below to launch it.
        You can find the module and author here, https://www.powershellgallery.com/packages/Autopilottestattestation/1.0.0.34.
    .NOTES
        Created by: Will H
        Created Date: 16th March 25
        Change Notes:
#>

###############################
#	Globally Used Variables   #
###############################
$runTime = Get-Date -uFormat "%H-%M-%S"
$outPutFilename = "attestationtest-$runTime.txt"
#endRegion

############################
#	Download the Script   #
############################

if (!(Get-Module -ListAvailable -Name Autopilottestattestation)) {
    Write-Host "Requred Module is not installed, installing now..." -ForegroundColor Yellow
    try {
        Install-Module -Name Autopilottestattestation -Scope CurrentUser
    }
    catch {
        Write-Host "There's been an error whilst installing the required module..." -ForegroundColor Red
        $_
        return
    }
}
Write-Host "Required module already installed, proceeding..." -ForegroundColor Yellow
#endRegion

######################
#   Execute script   #
######################
Write-Host "Executing attestattion testing command..." -ForegroundColor Yellow
try {
    test-autopilotattestation *>&1 | Tee-Object -FilePath "C:\Temp\Wintune\Reports\$outPutFilename"
}
catch {
    $_
    return
}

Write-Host "Exported console output to C:\Temp\Wintune\Reports\$outPutFilename" -ForegroundColor Yellow
#endRegion
