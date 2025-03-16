# WIntune Troubleshooting Application

This small patch work of scripts is a compilation of tasks that I regularly carry out on an EntraID joined deivce.
They include Enrolment troubleshooting during Autopilot provisioning, application and policy deployments and tooling
to parse the Intune Management Extension Logs.

I did not write all of these scripts, credits and here you can get the scripts are all noted in the ps1 files themselves.

## Script Releases and Versioning

Each commit will upload any new functionality\changes directly to a blob storage account container in Azure. It can
be executred directly from this location using the command below or also outputted to a file if you wish:

I will also create releases on Github for stable vesions that have been tested thorougly.

`irm https://sauksscripting.blob.core.windows.net/public-wintune/Wintune.ps1 | iex`
