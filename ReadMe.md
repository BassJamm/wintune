# WIntune Troubleshooting Application

This small patch work of scripts is a compilation of tasks that I regularly carry out on an EntraID joined deivce.
They include Enrolment troubleshooting during Autopilot provisioning, application and policy deployments and tooling
to parse the Intune Management Extension Logs.

I did not write all of these scripts, credits and here you can get the scripts are all noted in the ps1 files themselves.

## Script Releases and Versioning

### Stable Versions

Releases will be created on Github for stable versions that have been tested.

> Create method to launch a stable version using IRM.

### Most up to date

> There might be stuff in this version that may not work as I test.

Each commit will upload any new functionality\changes directly to a blob storage account container in Azure. It can
be executred directly from this location using the command below or also outputted to a file if you wish:

`irm https://sauksscripting.blob.core.windows.net/public-wintune/Wintune.ps1 | iex`

## Functionality

### Working

- [X] Creates Local File Structure on first run.
- [X] Authenticate with Microsoft Graph and Exchange Online.
- [X] Get Autopilot Information - Uses the Community Script 'Get-AutopilotDiagnosticsCommunity'.
- [X] Get Win32 App Results - Original script created by PMPC, I have re-written.
- [X] Review IME Logs - Parses and outputs to Out-Gridview for better viewing.
- [X] List Device Synchronsation history - Lists the types of syncs the device has done.

### Work In Progress

- [ ] List of Policy settings durrently deployed to device.
- [ ] Check WHfB health - Will review kerberos health.
