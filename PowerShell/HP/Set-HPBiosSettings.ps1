# Script for setting HP bios settings.
# This is set as a function with the possibility of running changing multiple settings in one script run

function Set-BIOSSetting {
    param (
        # Bios setting name, use exactly what the .name parameter of the setting is.
        [Parameter(Mandatory=$True)]
        [String]$Name,

        # Desired value of the setting.
        [Parameter(Mandatory=$True)]
        [String]$Value,

        # Optionally enter password.
        # !!! Don't use this unless absolutely necceccary.
        # Use HP BCU tool to clear and set password using a binary file, that will prevent possible password leakage in logs
        [Parameter(Mandatory=$false)]
        [String]$Password
    )

    # Run command and store returncode
    $ReturnCode = (
        Get-CimInstance -Namespace root/HP/InstrumentedBIOS -ClassName HP_BIOSSettingInterface |
         Invoke-CimMethod -MethodName SetBIOSSetting -Arguments @{Name="$Name";Value="$Value";Password="<utf-16/>$Password"}
         ).Return

    # Return code translaton and messages
    if ($ReturnCode -eq 0){
        Return Write-Output -Message "SUCCSESS: Setting BIOS setting; $Name was successful."
    }
    elseif ($ReturnCode -eq 1){
        Return Write-Error -Message "Setting BIOS setting; $Name failed with the error: ""Not Supported""" -ErrorId "1" 
    }
    elseif ($ReturnCode -eq 2){
        Return Write-Error -Message "Setting BIOS setting; $Name failed with the error: ""Unspecified Error""" -ErrorId "2" 
    }
    elseif ($ReturnCode -eq 3){
        Return Write-Error -Message "Setting BIOS setting; $Name failed with the error: ""Timeout""" -ErrorId "3" 
    }
    elseif ($ReturnCode -eq 4){
        Return Write-Error -Message "Setting BIOS setting; $Name failed with the error: ""Failed""" -ErrorId "4" 
    }
    # This warns instead of errors, to allow running a wide set of settings for different models with the same script.
    elseif ($ReturnCode -eq 5){
        Return Write-Warning -Message "Setting BIOS setting; $Name failed with the error: ""Invalid Parameter"""
    }
    elseif ($ReturnCode -eq 6){
        Return Write-Error -Message "Setting BIOS setting; $Name failed with the error: ""Access Denied""" -ErrorId "6" 
    }

}


# Sample settings
Set-BIOSSetting -Name "Active Management (AMT)" -Value "Disable"
Set-BIOSSetting -Name "Virtualization Technology (VTx)" -Value "Enable"
Set-BIOSSetting -Name "Virtualization Technology for Directed I/O (VTd)" -Value "Enable"