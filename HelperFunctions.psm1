<#
    .Synopsis
        Module script loads the various modules into the console app.
    .NOTES
        Created by: Will H
        Created Date:
        Change Notes:
#>


#####################
#   Log Function    #
#####################

$logFile = (New-Item -ItemType File -Path "C:\temp\Wintune\Logs\test.log" -Force).FullName
function LogDebug {
    param (
        [string]$message,
        [ValidateSet("INFO", "ERROR", "DEBUG", "SUCCESS")][string]$level = "INFO",
        [switch]$toHost,
        [switch]$toLogFile
    )
    <#
        .SYNOPSIS
        Logs a message to the console and/or a log file.
        .EXAMPLE
        LogDebug -message "Test Message" -level "ERROR" -toHost
    #>
    $logEntry = "$(Get-Date -UFormat '%d/%m/%Y') - $(Get-Date -UFormat '%H:%M:%S') - $level - $message"
    if ($toHost) {
        $color = switch ($level) {
            "INFO" { "Yellow" }
            "ERROR" { "Red" }
            "DEBUG" { "Cyan" }
            "SUCCESS" { "Green" }
        }
        Write-Host $logEntry -ForegroundColor $color
    }
    if ($toLogFile) {
        Add-Content -Path $logFile -Value $logEntry
    }
}
#endRegion

###################################
#   Connect to Microsoft Graph    #
###################################

function ConnectMGGraph {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $TenantId
    )

    LogDebug -message "Begin Connecting to Microsoft Graph function..." -toLogFile
    LogDebug -message "Checking for modules..." -toHost -toLogFile
    # Install Modules if not already installed
    $requiredModules = @("Microsoft.Graph.Authentication", "Microsoft.Graph.Beta.Devices.CorporateManagement", "Microsoft.Graph.Beta.DeviceManagement")
    foreach ($module in $requiredModules) {
        if (!(Get-Module -ListAvailable -Name $module)) {
            LogDebug -message "Module $module is not installed. Attempting to install..." -toHost -toLogFile
            try {
                Install-Module -Name $module -Force -Scope CurrentUser -AllowClobber
                LogDebug -message "Module $module installed successfully." -level SUCCESS -toHost -toLogFile
            }
            catch {
                LogDebug -message "Failed to install module $module. Please install it manually." -toHost -toLogFile
            }
        }
        else {
            LogDebug -message "Module $module is already installed." -toHost -toLogFile
        }
    }

    Start-Sleep -Seconds 2 # More pleasent experience for end user.
    if ($null -eq (Get-MgContext).Account) {
        Write-Host "Connecting to Graph now, a separate window should launch..." -ForegroundColor Yellow
        # Connect to Graph
        $requiredScopes = @(
            'DeviceManagementManagedDevices.Read.All',
            'DeviceManagementApps.Read.All',
            'Group.Read.All',
            'User.Read.All'
        )
        # Connect to Graph
        Connect-MgGraph -Scopes $requiredScopes -TenantId $TenantId -NoWelcome
    }
    LogDebug -message "You are connected!" -level SUCCESS -toHost
    Get-MgContext | Select Account, @{ l = 'PermissionScopes'; e = { $_.Scopes -join "`n" } } | fl
    Start-Sleep -Seconds 2 # More pleasent experience for end user.

    LogDebug -message "End of Connecting to Microsoft Graph function..." -toLogFile
}
#endRegion

####################################
#   Connect to Exhchange Online    #
####################################

function ConnectExchangeOnline {

    LogDebug -message "Begin Connect Exchange Online function..." -toLogFile

    if ($null -eq (Get-MgContext).Account) {
        LogDebug -message "Not logged into Microsoft Graph" -level ERROR -toLogFile
        LogDebug -message "There's been an error in the sing in flow, Microsoft Graph Authentication failed, please restart app" -level ERROR -toHost -toLogFile
        return
    }

    LogDebug -message "Checking for Exchange Online modules..." -toHost -toLogFile
    # Install Modules if not already installed
    $requiredModules = @("ExchangeOnlineManagement")
    foreach ($module in $requiredModules) {
        if (!(Get-Module -ListAvailable -Name $module)) {
            LogDebug -message "Module $module is not installed. Attempting to install..." -toHost -toLogFile
            try {
                Install-Module -Name $module -Force -Scope CurrentUser -AllowClobber
                LogDebug -message "Module $module installed successfully." -level SUCCESS -toHost -toLogFile
            }
            catch {
                LogDebug -message "Failed to install module $module. Please install it manually." -toHost -toLogFile
            }
        }
        else {
            LogDebug -message "Module $module is already installed." -toHost -toLogFile
        }
    }


    # Connect to Exchagne Online
    if ($null -eq (Get-ConnectionInformation).UserPrincipalName) {
        LogDebug -message "Trying to connect to Exchange Online" -toHost -toLogFile
        try {
            Connect-ExchangeOnline -UserPrincipalName (Get-MgContext).Account
        }
        catch {
            LogDebug -message "Error Authenticating with Exchange online" -level ERROR -toHost -toLogFile
            LogDebug -message "$($Error[0].Exception.Message)" -level ERROR -toHost -toLogFile
        }
    }

    LogDebug -message "Successfully authenticated to Exchange Online" -level SUCCESS -toHost -toLogFile
    LogDebug -message "PS: Sorry for the exchange output crud if that just came up..." -level SUCCESS -toHost -toLogFile
    Start-Sleep -Seconds 2

    LogDebug -message "End of Connect Exchange Online function..." -toLogFile

}
#endregion

#####################
#   Menu Function   #
#####################

function Show-Menu {
    param (
        [string]$Title = 'Windows Intune Troubleshooting Tools'
    )
    Clear-Host
    Write-Host $Wintune -ForegroundColor Cyan
    Write-Host "================ $Title ================"
    Write-Host " "
    Write-Host " Log File: $logFile"
    Write-Host " "
    Write-Host "0: Press '0' to Authenticate with Microsoft Graph, Exchange Onlin and EntraId."
    Write-Host "1: Press '1' for this option."
    Write-Host "2: Press '2' for this option."
    Write-Host "3: Press '3' for this option."
    Write-Host "Q: Press 'Q' to quit."
}
#endRegion