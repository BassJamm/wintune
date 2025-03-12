<#
    .Synopsis
        Script to get Win32 App results from the WinApp32 registry keys.
    .NOTES
        Created by: Will H
        Created Date: 15th Feb 25
        Change Notes:
     .EXAMPLE
        $results = .\Get-Win32Appresults.ps1
     .EXAMPLE
        \Get-Win32Appresults.ps1 | Out-Gridview
     .EXAMPLE
        .\Get-Win32Appresults.ps1 | Export-Csv -Path .\Win32AppResults.csv -NoTypeInformation
#>

###################
#    Functions    #
###################

function Get-ComplianceStateMessage {
    param (
        [int]$StateId
    )

    switch ($StateId) {
        1 { return "Installed" }
        2 { return "NotInstalled" }
        4 { return "Error" }
        5 { return "Unknown" }
        100 { return "Cleanup" }
        default { return "Unknown State ID" }
    }
}

function Get-ComplianceApplicability {
    param (
        [int]$ApplicabilityId
    )

    switch ($ApplicabilityId) {
        0 { return "Applicable" }
        1 { return "RequirementsNotMet" }
        3 { return "HostPlatformNotApplicable" }
        1000 { return "ProcessorArchitectureNotApplicable" }
        1001 { return "MinimumDiskSpaceNotMet" }
        1002 { return "MinimumOSVersionNotMet" }
        1003 { return "MinimumPhysicalMemoryNotMet" }
        1004 { return "MinimumLogicalProcessorCountNotMet" }
        1005 { return "MinimumCPUSpeedNotMet" }
        1006 { return "FileSystemRequirementRuleNotMet" }
        1007 { return "RegistryRequirementRuleNotMet" }
        1008 { return "ScriptRequirementRuleNotMet" }
        1009 { return "NotTargetedAndSupersedingAppsNotApplicable" }
        1010 { return "AssignmentFiltersCriteriaNotMet" }
        1011 { return "AppUnsupportedDueToUnknownReason" }
        1012 { return "UserContextAppNotSupportedDuringDeviceOnlyCheckin" }
        2000 { return "COSUMinimumApiLevelNotMet" }
        2001 { return "COSUManagementMode" }
        2002 { return "COSUUnsupported" }
        2003 { return "COSUAppIncompatible" }
        default { return "Unknown Applicability ID" }
    }
}

function Get-ComplianceDesiredState {
    param (
        [int]$DesiredStateId
    )

    switch ($DesiredStateId) {
        0 { return "None" }
        1 { return "Not Present" }
        2 { return "Present" }
        3 { return "Unknown" }
        4 { return "Available" }
        default { return "Unknown Desired State ID" }
    }
}

function Get-ComplianceTargetingMethod {
    param (
        [int]$TargetingMethodId
    )

    switch ($TargetingMethodId) {
        0 { return "TargetedApplication" }
        1 { return "DependencyOfTargetedApplication" }
        default { return "Unknown Targeting Method" }
    }
}

function Get-ComplianceTargetType {
    param (
        [int]$targetId
    )

    switch ($targetId) {
        0 { "None" }
        1 { "User" }
        2 { "Device" }
        3 { "Both Device and User" }
        default { "Unknown Target Type" }
    }
}

function Get-ComplianceInstallContext {
    param (
        [int]$contextId
    )

    switch ($contextId) {
        1 { "User" }
        2 { "Device" }
    }
}

function Get-EnforcementStateMessage {
    param (
        [int]$StateId
    )

    $stateMessageEnforcementState = @{
        0    = "Success"
        1000 = "Success"
        1003 = "SuccessFastNotify"
        1004 = "SuccessButDependencyFailedToInstall"
        1005 = "SuccessButDependencyWithRequirementsNotMet"
        1006 = "SuccessButDependencyPendingReboot"
        1007 = "SuccessButDependencyWithAutoInstallOff"
        1008 = "SuccessButIOSAppStoreUpdateFailedToInstall"
        1009 = "SuccessVPPAppHasUpdateAvailable"
        1010 = "SuccessButUserRejectedUpdate"
        1011 = "SuccessUninstallPendingReboot"
        1012 = "SuccessSupersededAppUninstallFailed"
        1013 = "SuccessSupersededAppUninstallPendingReboot"
        1014 = "SuccessSupersedingAppsDetected"
        1015 = "SuccessSupersededAppsDetected"
        1016 = "SuccessAppRemovedBySupersedence"
        1017 = "SuccessButDependencyBlockedByManagedInstallerPolicy"
        1018 = "SuccessUninstallingSupersededApps"
        2000 = "InProgress"
        2007 = "InProgressDependencyInstalling"
        2008 = "InProgressPendingReboot"
        2009 = "InProgressDownloadCompleted"
        2010 = "InProgressPendingUninstallOfSupersededApps"
        2011 = "InProgressUninstallPendingReboot"
        2012 = "InProgressPendingManagedInstaller"
        3000 = "RequirementsNotMet"
        4000 = "Unknown"
        5000 = "Error"
        5003 = "ErrorDownloadingContent"
        5006 = "ErrorConflictsPreventInstallation"
        5015 = "ErrorManagedInstallerAppLockerPolicyNotApplied"
        5999 = "ErrorWithImmediateRetry"
        6000 = "NotAttempted"
        6001 = "NotAttemptedDependencyWithFailure"
        6002 = "NotAttemptedPendingReboot"
        6003 = "NotAttemptedDependencyWithRequirementsNotMet"
        6004 = "NotAttemptedAutoInstallOff"
        6005 = "NotAttemptedDependencyWithAutoInstallOff"
        6006 = "NotAttemptedWithManagedAppNoLongerPresent"
        6007 = "NotAttemptedBecauseUserRejectedInstall"
        6008 = "NotAttemptedBecauseUserIsNotLoggedIntoAppStore"
        6009 = "NotAttemptedSupersededAppUninstallFailed"
        6010 = "NotAttemptedSupersededAppUninstallPendingReboot"
        6011 = "NotAttemptedUntargetedSupersedingAppsDetected"
        6012 = "NotAttemptedDependencyBlockedByManagedInstallerPolicy"
        6013 = "NotAttemptedUnsupportedOrIndeterminateSupersededApp"
    }
    # Looks up the reference in the hashtable above.
    return $stateMessageEnforcementState[$StateId] -or "Unknown State ID: $StateId"
}

function Get-EnforcementTargetingMethod {
    param (
        [int]$TargetingMethodId
    )

    switch ($TargetingMethodId) {
        0 { return "TargetedApplication" }
        1 { return "DependencyOfTargetedApplication" }
        default { return "Unknown Targeting Method" }
    }
}

# Check for Graph Connection
if (!((Get-MgContext).Account)) {
    Write-Host "Not connect to MG Graph, run again and press option 0 to authenticate" -ForegroundColor Red
    Break
}

# Collect all intune apps
$intuneApps = Get-MgBetaDeviceAppManagementMobileApp -All

# Get the Win32Apps registry key
$Win32appKey = "HKLM:SOFTWARE\Microsoft\IntuneManagementExtension\Win32Apps"

# get valid Contexts(GUIDs) in the Win32Apps key
$regKeys = gci -Path $win32appKey -Force -ErrorAction SilentlyContinue
$getValidContexts = $regKeys | ? { ([System.Guid]::TryParse((Split-Path -Path $_.Name -Leaf), [System.Management.Automation.PSReference]([guid]::empty))) } | Select -ExpandProperty Name

# initialize $appKeyResults array to hold results of win32app policies found under each context (for both device and users)
$appKeyResults = @()

Foreach ($getApp in $getValidContexts) {
    # get apps under each context
    $appKeys = gci -Path "$win32appKey\$(Split-Path -Path $getApp -Leaf)" -Force -ErrorAction SilentlyContinue
    foreach ($key in ($appKeys | ? name -notmatch GRS)) {

        # Get the key properties
        $keyValues = Get-ItemProperty -Path REGISTRY::$key

        # Cheeky host update to show progress, DEBUG ONLY
        #Write-Host "Working on: $($keyValues.PSPath -replace 'Microsoft.PowerShell.Core\\Registry::','')" -ForegroundColor Yellow

        # Get the subkeys
        $subKeys = gci $keyValues.PSPath -ErrorAction SilentlyContinue

        # Initialise array to store subkey values
        $subkeyData = @()

        # Get the subkey values
        foreach ($subkey in $subKeys) {
            $subkeyData += Get-ItemProperty -Path REGISTRY::$subkey -ErrorAction SilentlyContinue
        }

        # Convert the JSON strings to objects (annoying)
        $complianceMessages = "$($subkeyData.ComplianceStateMessage)" | ConvertFrom-Json
        $enforcementState = "$($subkeyData.EnforcementStateMessage)" | ConvertFrom-Json

        # Bulding a custom object and adding the results to the $appKeyResults array, outside the loop.
        $appKeyResults += [PSCustomObject]@{
            AppRegParent              = if (!(Split-Path $keyValues.PSParentPath -Leaf *>&1)){ "" } else { Split-Path $keyValues.PSParentPath -Leaf }
            AppGuid                   = $keyValues.PSChildName -replace '_\d+$'
            AppName                   = ($intuneApps | ? id -match ($keyValues.PSChildName -replace '_\d+$')).DisplayName
            ComplianceApplicability   = Get-ComplianceApplicability -ApplicabilityId $complianceMessages.Applicability
            ComplianceDesiredState    = Get-ComplianceDesiredState -DesiredStateId $complianceMessages.DesiredState
            ComplianceState           = Get-ComplianceStateMessage -StateId  $complianceMessages.ComplianceState
            ComplianceErrorCode       = if (!($complianceMessages.ErrorCode)) { "Null" } else { $complianceMessages.ErrorCode }
            ComplianceTargetingMethod = Get-ComplianceTargetingMethod -TargetingMethodId $complianceMessages.TargetingMethod
            ComplianceInstallContext  = Get-ComplianceInstallContext -contextId $complianceMessages.InstallContext
            ComplianceInstallType     = Get-ComplianceTargetType -targetId $complianceMessages.TargetType
            EnforcementState          = Get-EnforcementStateMessage -StateId $enforcementState.EnforcementState
            EnforcementErrorCode      = Get-ComplianceTargetingMethod -TargetingMethodId $enforcementState.ErrorCode
            EnforcemntTargetingMethod = Get-EnforcementTargetingMethod -TargetingMethodId $enforcementState.TargetingMethod
            ProductVersion            = $complianceMessages.ProductVersion
            AssignmentFilters         = if(!($complianceMessages.AssignmentFilterIds)){ "None" } else { $complianceMessages.AssignmentFilterIds -join "," }
            RegPath                   = $keyValues.PSPath -replace "Microsoft.PowerShell.Core\\Registry::", ""
        }
    }
}

return $appKeyResults