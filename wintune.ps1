$Wintune = @"


                                                        XX
      XXXXXXX  XXXXXXX  XXXXXXXXXXX                    XXX
       XXX        XX        XX                         XX
       XXX       XXX        XX                        XXX
       XXX  XXX  XXX       XXX       XXXXXXXXX      XXXXXXXXXXX   XXXXX  XXXXX   XXXXXXXXXX        XXXXXXX
       XXX XXXX  XX        XXX        XXXX  XXX       XXX           XX     XXX     XXXX  XXX     XXX    XXX
       XXX XXXX XXX        XXX        XXX    XXX      XX            XX     XXX    XXXX   XXX    XXX      XX
       XX XXXXX XXX        XX         XX     XXX      XX           XXX     XX     XXX     XX    XX       XXX
       XX XX XX XX        XXX        XXX     XX      XXX           XXX     XX     XX     XXX   XXX       XXX
       XXXXX XXXXX        XXX        XXX     XX      XXX           XXX    XXX     XX     XXX   XXXXXXXXXXXXX
       XXXX  XXXXX        XXX        XXX    XXX      XXX           XX     XXX     XX     XXX   XXX
       XXXX  XXXX         XX         XX     XXX      XXX          XXX     XXX    XXX     XX    XXX
      XXXXX  XXXX         XX         XX     XXX      XX           XXX    XXX     XXX     XX    XXX       XX
      XXXX   XXXX        XXX        XXX     XXX      XX     XXX   XXX  XXXXX     XXX    XXX     XXX    XXXX
      XXXX   XXXX    XXXXXXXXXXX  XXXXXXX XXXXXX      XXXXXXX      XXXXXXXXXX  XXXXXX  XXXXX     XXXXXXXX



"@

###################################
#   Create Folder Paths needed    #
###################################

$folders = @('Reports', 'Logs')
try {
    foreach ($folder in $folders) {
        New-Item -Path C:\Temp\Wintune -Name $folder -ItemType Directory -Force
    }
}
catch {
    Write-Error $_.Exception.Message
}
#endRegion

#################################
#   Load Functions into session #
#################################

try {
    Invoke-RestMethod 'https://sauksscripting.blob.core.windows.net/public-wintune/HelperFunctions.psm1' | `
        Out-File C:\Temp\Wintune\helperfunctions.psm1
    Import-Module C:\Temp\Wintune\helperfunctions.psm1
}
catch {
    Write-Error "Failed to import the helper functions..."
    Throw
}
#endRegion

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
    Write-Host "Log File: C:\Temp\Wintune\Logs"
    Write-Host " "
    Write-Host "Press the corresponding number for each option below."
    Write-Host " "
	Write-Host "[e] Open Explorere to the WIntune File Location"
    Write-Host "[0] Authenticate with Microsoft Graph, Exchange Online and EntraId."
    Write-Host "[1] Get Autopilot Information: Collects all sorts of Autopilot data."
    Write-Host "[2] (WIP) Get Policy Deployment Data: Collects info from Providers Regkey and SideCar."
    Write-Host "[3] Get Win32 App Results: Returns application deployment info to Out-GridView\CSV File or Both."
    Write-Host "[4] View Intune Management Extensions Logs."
    Write-Host "[Q] Quit."
}
#endRegion

########################
#   Menu Entry Point   #
########################

do {
    Show-Menu
    Write-Host " "
    $choice = Read-Host "Please make a selection"
    switch ($choice) {
		"e" {
			Invoke-Item "C:\Temp\wintune"
		}
        "0" {
            Clear-Host
            ConnectMGGraph
            Start-Sleep -Milliseconds 300
            ConnectExchangeOnline
        } "1" {
            clear-host
            Invoke-RestMethod 'https://sauksscripting.blob.core.windows.net/public-wintune/Get-mdmdiags.ps1' | Invoke-Expression
        } "2" {
            clear-host
            "Collect and Review policy deployment Data"
        } "3" {
            clear-host
            $output = Read-Host -Prompt "Do you want to output to out-gridview(o), to a csv file(f) or both(b)? write the corresponding letter"
            switch ($output) {
                "f" {
                    Write-Host "Writing to file..." -ForegroundColor Yellow
                    Invoke-RestMethod 'https://sauksscripting.blob.core.windows.net/public-wintune/Get-Win32Appresults.ps1' | `
                        Invoke-Expression | `
                        Export-Csv 'C:\Temp\Wintune\Reports\Win32AppResults.csv' -NoTypeInformation
                }
                "o" {
                    Write-Host "Out-Gridview selected..." -ForegroundColor Yellow
                    $win32apps = Invoke-RestMethod 'https://sauksscripting.blob.core.windows.net/public-wintune/Get-Win32Appresults.ps1' | Invoke-Expression
                    $win32apps | Out-GridView -Wait -Title 'Win32 App Results'
                }
                "b" {
                    Write-Host "Writing to console and csv file..." -ForegroundColor Yellow
                    Write-Output 'Data wil be been exported to C:\Temp\Wintune\Reports'
                    Start-Sleep -Milliseconds 300
                    $win32apps = Invoke-RestMethod 'https://sauksscripting.blob.core.windows.net/public-wintune/Get-Win32Appresults.ps1' | Invoke-Expression
                    $win32apps | Out-GridView -Title 'Win32 App Results'
                    $win32apps | Export-Csv 'C:\Temp\Wintune\Reports\Win32AppResults.csv' -NoTypeInformation
                }
                Default {}
            }
        } "4"{
            ParseIMELogs | Out-GridView -Title "Intune Management Extension Logs"
        }"q" {
            return
        }
    }
    pause
}
until ($input -eq "q")
#endRegion

# SIG # Begin signature block
# MIIblwYJKoZIhvcNAQcCoIIbiDCCG4QCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUWhtdzOPGC5L3DXjUXP8D+yRm
# JAigghYNMIIDBjCCAe6gAwIBAgIQVzBaM68akp9McDhf4UP7eDANBgkqhkiG9w0B
# AQsFADAbMRkwFwYDVQQDDBBBVEEgQXV0aGVudGljb2RlMB4XDTI1MDMwMTEwMzc0
# MloXDTI2MDMwMTEwNTc0MlowGzEZMBcGA1UEAwwQQVRBIEF1dGhlbnRpY29kZTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANnxxD+UDYwGgP1cWrFQKwY2
# jUvrke8IcVCr6gBLGcX1jqpCi1zI0wUYXniAkPKqteYjKXEI3scaqK0CXg3UbXxn
# K9sPMRbPMK59K9Hj51l1HLx4yaYrI8nBKcDuJwk9uYxDHHIQIUePMjYtxjJRAAEX
# WCjjaKFFFKNllo6MbWKwYI0Xt7ghWFKgOMBxHaKtG2j+E197O2m/SUi8b8gdeKqs
# ReC99S7KDlw/2DCHVB5sOL0FI//pqqNBdMovkK03XIK3s+UVmTME1B0rHiiIT9/6
# w8cIiARis1h9xKD6AM7CkbCWv6I3FRzfjfXcUj3pHw8ciBWm2jMzXWHJQJDyv10C
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBS6L6g9Rxe+NMM0/j6xHEUtcTNwSjANBgkqhkiG9w0BAQsFAAOCAQEA
# mRgeiE4V6GE+KLz2RydXdtB+GI3AFX1xsLqchuZGgem93M7FY0SmCXT4NC/PF1UY
# HRxx5Tq7piojxWv5Gy9Ut1NJ18dyhtuGn5LIcez5c+TcLnukva8+10SCnPTPj9fK
# F6NRyQgorrkJ/gpn8bchjcagFFz09HtIXTHf95cGd3qoEq8qmXBPJDSstUdDEa9G
# epuSlVckZrHHx5Vuzgjq18drREU6Dlz5rTh73HukJy43mmsSK7l5NVukvvwNBl3Z
# TkdJxcq+MnAGP8Tm9Ab01g5DICEhX+TRHhEuy4pRGzIlr2L/h3BH7nECDxQXPs3T
# uQOrw5fiI7VTJmn+12HutzCCBY0wggR1oAMCAQICEA6bGI750C3n79tQ4ghAGFow
# DQYJKoZIhvcNAQEMBQAwZTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0
# IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNl
# cnQgQXNzdXJlZCBJRCBSb290IENBMB4XDTIyMDgwMTAwMDAwMFoXDTMxMTEwOTIz
# NTk1OVowYjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcG
# A1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3Rl
# ZCBSb290IEc0MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAv+aQc2je
# u+RdSjwwIjBpM+zCpyUuySE98orYWcLhKac9WKt2ms2uexuEDcQwH/MbpDgW61bG
# l20dq7J58soR0uRf1gU8Ug9SH8aeFaV+vp+pVxZZVXKvaJNwwrK6dZlqczKU0RBE
# EC7fgvMHhOZ0O21x4i0MG+4g1ckgHWMpLc7sXk7Ik/ghYZs06wXGXuxbGrzryc/N
# rDRAX7F6Zu53yEioZldXn1RYjgwrt0+nMNlW7sp7XeOtyU9e5TXnMcvak17cjo+A
# 2raRmECQecN4x7axxLVqGDgDEI3Y1DekLgV9iPWCPhCRcKtVgkEy19sEcypukQF8
# IUzUvK4bA3VdeGbZOjFEmjNAvwjXWkmkwuapoGfdpCe8oU85tRFYF/ckXEaPZPfB
# aYh2mHY9WV1CdoeJl2l6SPDgohIbZpp0yt5LHucOY67m1O+SkjqePdwA5EUlibaa
# RBkrfsCUtNJhbesz2cXfSwQAzH0clcOP9yGyshG3u3/y1YxwLEFgqrFjGESVGnZi
# fvaAsPvoZKYz0YkH4b235kOkGLimdwHhD5QMIR2yVCkliWzlDlJRR3S+Jqy2QXXe
# eqxfjT/JvNNBERJb5RBQ6zHFynIWIgnffEx1P2PsIV/EIFFrb7GrhotPwtZFX50g
# /KEexcCPorF+CiaZ9eRpL5gdLfXZqbId5RsCAwEAAaOCATowggE2MA8GA1UdEwEB
# /wQFMAMBAf8wHQYDVR0OBBYEFOzX44LScV1kTN8uZz/nupiuHA9PMB8GA1UdIwQY
# MBaAFEXroq/0ksuCMS1Ri6enIZ3zbcgPMA4GA1UdDwEB/wQEAwIBhjB5BggrBgEF
# BQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBD
# BggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0
# QXNzdXJlZElEUm9vdENBLmNydDBFBgNVHR8EPjA8MDqgOKA2hjRodHRwOi8vY3Js
# My5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMBEGA1Ud
# IAQKMAgwBgYEVR0gADANBgkqhkiG9w0BAQwFAAOCAQEAcKC/Q1xV5zhfoKN0Gz22
# Ftf3v1cHvZqsoYcs7IVeqRq7IviHGmlUIu2kiHdtvRoU9BNKei8ttzjv9P+Aufih
# 9/Jy3iS8UgPITtAq3votVs/59PesMHqai7Je1M/RQ0SbQyHrlnKhSLSZy51PpwYD
# E3cnRNTnf+hZqPC/Lwum6fI0POz3A8eHqNJMQBk1RmppVLC4oVaO7KTVPeix3P0c
# 2PR3WlxUjG/voVA9/HYJaISfb8rbII01YBwCA8sgsKxYoA5AY8WYIsGyWfVVa88n
# q2x2zm8jLfR+cWojayL/ErhULSd+2DrZ8LaHlv1b0VysGMNNn3O3AamfV6peKOK5
# lDCCBq4wggSWoAMCAQICEAc2N7ckVHzYR6z9KGYqXlswDQYJKoZIhvcNAQELBQAw
# YjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQ
# d3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290
# IEc0MB4XDTIyMDMyMzAwMDAwMFoXDTM3MDMyMjIzNTk1OVowYzELMAkGA1UEBhMC
# VVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBU
# cnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTCCAiIwDQYJ
# KoZIhvcNAQEBBQADggIPADCCAgoCggIBAMaGNQZJs8E9cklRVcclA8TykTepl1Gh
# 1tKD0Z5Mom2gsMyD+Vr2EaFEFUJfpIjzaPp985yJC3+dH54PMx9QEwsmc5Zt+Feo
# An39Q7SE2hHxc7Gz7iuAhIoiGN/r2j3EF3+rGSs+QtxnjupRPfDWVtTnKC3r07G1
# decfBmWNlCnT2exp39mQh0YAe9tEQYncfGpXevA3eZ9drMvohGS0UvJ2R/dhgxnd
# X7RUCyFobjchu0CsX7LeSn3O9TkSZ+8OpWNs5KbFHc02DVzV5huowWR0QKfAcsW6
# Th+xtVhNef7Xj3OTrCw54qVI1vCwMROpVymWJy71h6aPTnYVVSZwmCZ/oBpHIEPj
# Q2OAe3VuJyWQmDo4EbP29p7mO1vsgd4iFNmCKseSv6De4z6ic/rnH1pslPJSlREr
# WHRAKKtzQ87fSqEcazjFKfPKqpZzQmiftkaznTqj1QPgv/CiPMpC3BhIfxQ0z9JM
# q++bPf4OuGQq+nUoJEHtQr8FnGZJUlD0UfM2SU2LINIsVzV5K6jzRWC8I41Y99xh
# 3pP+OcD5sjClTNfpmEpYPtMDiP6zj9NeS3YSUZPJjAw7W4oiqMEmCPkUEBIDfV8j
# u2TjY+Cm4T72wnSyPx4JduyrXUZ14mCjWAkBKAAOhFTuzuldyF4wEr1GnrXTdrnS
# DmuZDNIztM2xAgMBAAGjggFdMIIBWTASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1Ud
# DgQWBBS6FtltTYUvcyl2mi91jGogj57IbzAfBgNVHSMEGDAWgBTs1+OC0nFdZEzf
# Lmc/57qYrhwPTzAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUHAwgw
# dwYIKwYBBQUHAQEEazBpMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2Vy
# dC5jb20wQQYIKwYBBQUHMAKGNWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9E
# aWdpQ2VydFRydXN0ZWRSb290RzQuY3J0MEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6
# Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3JsMCAG
# A1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATANBgkqhkiG9w0BAQsFAAOC
# AgEAfVmOwJO2b5ipRCIBfmbW2CFC4bAYLhBNE88wU86/GPvHUF3iSyn7cIoNqilp
# /GnBzx0H6T5gyNgL5Vxb122H+oQgJTQxZ822EpZvxFBMYh0MCIKoFr2pVs8Vc40B
# IiXOlWk/R3f7cnQU1/+rT4osequFzUNf7WC2qk+RZp4snuCKrOX9jLxkJodskr2d
# fNBwCnzvqLx1T7pa96kQsl3p/yhUifDVinF2ZdrM8HKjI/rAJ4JErpknG6skHibB
# t94q6/aesXmZgaNWhqsKRcnfxI2g55j7+6adcq/Ex8HBanHZxhOACcS2n82HhyS7
# T6NJuXdmkfFynOlLAlKnN36TU6w7HQhJD5TNOXrd/yVjmScsPT9rp/Fmw0HNT7ZA
# myEhQNC3EyTN3B14OuSereU0cZLXJmvkOHOrpgFPvT87eK1MrfvElXvtCl8zOYdB
# eHo46Zzh3SP9HSjTx/no8Zhf+yvYfvJGnXUsHicsJttvFXseGYs2uJPU5vIXmVnK
# cPA3v5gA3yAWTyf7YGcWoWa63VXAOimGsJigK+2VQbc61RWYMbRiCQ8KvYHZE/6/
# pNHzV9m8BPqC3jLfBInwAM1dwvnQI38AC+R2AibZ8GV2QqYphwlHK+Z/GqSFD/yY
# lvZVVCsfgPrA8g4r5db7qS9EFUrnEw4d2zc4GqEr9u3WfPwwgga8MIIEpKADAgEC
# AhALrma8Wrp/lYfG+ekE4zMEMA0GCSqGSIb3DQEBCwUAMGMxCzAJBgNVBAYTAlVT
# MRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1
# c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0EwHhcNMjQwOTI2
# MDAwMDAwWhcNMzUxMTI1MjM1OTU5WjBCMQswCQYDVQQGEwJVUzERMA8GA1UEChMI
# RGlnaUNlcnQxIDAeBgNVBAMTF0RpZ2lDZXJ0IFRpbWVzdGFtcCAyMDI0MIICIjAN
# BgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAvmpzn/aVIauWMLpbbeZZo7Xo/ZEf
# GMSIO2qZ46XB/QowIEMSvgjEdEZ3v4vrrTHleW1JWGErrjOL0J4L0HqVR1czSzvU
# Q5xF7z4IQmn7dHY7yijvoQ7ujm0u6yXF2v1CrzZopykD07/9fpAT4BxpT9vJoJqA
# sP8YuhRvflJ9YeHjes4fduksTHulntq9WelRWY++TFPxzZrbILRYynyEy7rS1lHQ
# KFpXvo2GePfsMRhNf1F41nyEg5h7iOXv+vjX0K8RhUisfqw3TTLHj1uhS66YX2LZ
# PxS4oaf33rp9HlfqSBePejlYeEdU740GKQM7SaVSH3TbBL8R6HwX9QVpGnXPlKdE
# 4fBIn5BBFnV+KwPxRNUNK6lYk2y1WSKour4hJN0SMkoaNV8hyyADiX1xuTxKaXN1
# 2HgR+8WulU2d6zhzXomJ2PleI9V2yfmfXSPGYanGgxzqI+ShoOGLomMd3mJt92nm
# 7Mheng/TBeSA2z4I78JpwGpTRHiT7yHqBiV2ngUIyCtd0pZ8zg3S7bk4QC4RrcnK
# J3FbjyPAGogmoiZ33c1HG93Vp6lJ415ERcC7bFQMRbxqrMVANiav1k425zYyFMyL
# NyE1QulQSgDpW9rtvVcIH7WvG9sqYup9j8z9J1XqbBZPJ5XLln8mS8wWmdDLnBHX
# gYly/p1DhoQo5fkCAwEAAaOCAYswggGHMA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMB
# Af8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMCAGA1UdIAQZMBcwCAYGZ4EM
# AQQCMAsGCWCGSAGG/WwHATAfBgNVHSMEGDAWgBS6FtltTYUvcyl2mi91jGogj57I
# bzAdBgNVHQ4EFgQUn1csA3cOKBWQZqVjXu5Pkh92oFswWgYDVR0fBFMwUTBPoE2g
# S4ZJaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNB
# NDA5NlNIQTI1NlRpbWVTdGFtcGluZ0NBLmNybDCBkAYIKwYBBQUHAQEEgYMwgYAw
# JAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBYBggrBgEFBQcw
# AoZMaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0
# UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGluZ0NBLmNydDANBgkqhkiG9w0BAQsFAAOC
# AgEAPa0eH3aZW+M4hBJH2UOR9hHbm04IHdEoT8/T3HuBSyZeq3jSi5GXeWP7xCKh
# VireKCnCs+8GZl2uVYFvQe+pPTScVJeCZSsMo1JCoZN2mMew/L4tpqVNbSpWO9QG
# FwfMEy60HofN6V51sMLMXNTLfhVqs+e8haupWiArSozyAmGH/6oMQAh078qRh6wv
# JNU6gnh5OruCP1QUAvVSu4kqVOcJVozZR5RRb/zPd++PGE3qF1P3xWvYViUJLsxt
# vge/mzA75oBfFZSbdakHJe2BVDGIGVNVjOp8sNt70+kEoMF+T6tptMUNlehSR7vM
# +C13v9+9ZOUKzfRUAYSyyEmYtsnpltD/GWX8eM70ls1V6QG/ZOB6b6Yum1HvIiul
# qJ1Elesj5TMHq8CWT/xrW7twipXTJ5/i5pkU5E16RSBAdOp12aw8IQhhA/vEbFkE
# iF2abhuFixUDobZaA0VhqAsMHOmaT3XThZDNi5U2zHKhUs5uHHdG6BoQau75KiNb
# h0c+hatSF+02kULkftARjsyEpHKsF7u5zKRbt5oK5YGwFvgc4pEVUNytmB3BpIio
# wOIIuDgP5M9WArHYSAR16gc0dP2XdkMEP5eBsX7bf/MGN4K3HP50v/01ZHo/Z5lG
# LvNwQ7XHBx1yomzLP8lx4Q1zZKDyHcp4VQJLu2kWTsKsOqQxggT0MIIE8AIBATAv
# MBsxGTAXBgNVBAMMEEFUQSBBdXRoZW50aWNvZGUCEFcwWjOvGpKfTHA4X+FD+3gw
# CQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcN
# AQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUw
# IwYJKoZIhvcNAQkEMRYEFF1xbuO7QO/vWivcoCs5wsF2ULcfMA0GCSqGSIb3DQEB
# AQUABIIBAMVivQmj7ZwhyperTPkD6au1vu2FNPRCs6rFJBZilK81/QQkFonA+Kzn
# TxbLGzApZ7Ss+y71kcodwNW7LRlbNa8vn3XEcIxjcmcKPKS8fyf1rAoCCRECHynB
# Ke4Ns2hVhNkzUCPhuut9wXJ2eu68lMUMcge/i1uVwqa4JFKr1tvbUhi5azhiPOgt
# RVG7ot+i9F/Rwj03js8ejvF3epW/MeTEas7Cv5KNRKfOjUrBi2J0Jum9bB9yKCnK
# 6dE7kvBM0HBbAsbnODhflvwqqugFzHySBY+hCzjf7YkKWPCwK9Gpa7qPleBWtid6
# xmlMY3MiVuEnUGA+EVHFUx9YGsQRgZmhggMgMIIDHAYJKoZIhvcNAQkGMYIDDTCC
# AwkCAQEwdzBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4x
# OzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGlt
# ZVN0YW1waW5nIENBAhALrma8Wrp/lYfG+ekE4zMEMA0GCWCGSAFlAwQCAQUAoGkw
# GAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjUwMzAx
# MTA1MDExWjAvBgkqhkiG9w0BCQQxIgQgiOjmS8guJrbBw9N1e82rVPKM5i/ejFfr
# TckrDvXZ9tkwDQYJKoZIhvcNAQEBBQAEggIAKpl7xNWfyQkecIQIlQ7IxZtSidU2
# JuBOIU3svq74AOjTwesVCfhJS01jBaniJV7zLBM2Bnk1LxepQJUyHj+KfNWEf4jr
# Jv25UpNENsmQnxrMNWWTQ9GMHp80kI2IXpYxdqwZg9RYrVD03sUrtZP+uZOU3crO
# ggg/2J8fbDiVW3jAMi6xRnIub+L5RLI86HM4m0yliblorniSO03sGKExm5sFYJjb
# 629kyt2CVe3AX5/aQx8xjKkgTPz2Y7IHOVYerRTRH7dCv5ldDXSRGbMnGvdQ/nKV
# RfLQr9yNeeASH8iHKqtotmFV4LjGzKjMKHCEkBM9sLakYiAAT0iohgkWn9p6XuX5
# uLIj7rm0HQx9nA6+HN3G3op1UcJieUtaRLK7mpWQVqP0A8Gptr4goZdsgpTq9thg
# xW3JPriE1QrgN8EmGFhRP+rSk/RNPe+cgXgti7owm2kS1YlklOlVaiH9fxa73o6/
# tUFbmA3gMtVK4c1uChIsL28u6UwPCTR1oQrQ3dkpGYOVgOeh4KD9pOAvtLhsl7nC
# pq+AzEQiLVXE/KUyGrE4Btq221fKSqKYkbbxK5mXQaZyfLUKmfaVIT4wkYmkYtc/
# 9ST3sISQoxG85hq7uolaFD7QbjzGqz3kz/XKWhSuP/rfPpjN9TS4kNktdKTR6zhh
# XSWJZJJYFmPCHk0=
# SIG # End signature block
