# This script is intendend mainly for setting BIOS settings on a remote computer.
# You will be prompted to enter the BIOS password.
# To reduce the possibility of password leaking, you should run this from a remote management server.


Param(
    [Parameter(Mandatory=$true)]
    [string]$Computer
)

# Create Session with basic error checking
Try {
    
    $Session = New-CimSession -ComputerName $Computer -ErrorAction Stop
}
catch {
    Write-Warning "Unable to create CIM session to $Computer!"
    Write-Warning "Stopping script!..."
    break
}

# Get CIM class object
$HPBIOS = Get-CimInstance -Namespace root/HP/InstrumentedBIOS -ClassName HP_BIOSSettingInterface -CimSession $Session

# Save password as secure string
$PasswordAuto = Read-Host -Prompt "Enter current BIOS password (or leave blank)" -asSecureString

# Convert Secure string to plaintext
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($PasswordAuto)
$PasswordPlainText = "<utf-16/>" + [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

function Set-BIOSSetting {
    param (
        [Parameter(Mandatory=$True)]
        $Name,
        [Parameter(Mandatory=$True)]
        $Value
    )

    $ReturnCode = ($HPBIOS | Invoke-CimMethod -MethodName SetBIOSSetting -Arguments @{Name="$Name";Value="$Value";Password="$PasswordPlainText"}).Return

    # Translate return codes
    # Since this is intended to return to a remote console, no further error handling is implemented.
    switch ($ReturnCode){
        0 { $ReturnMessage = "Success" }
        1 { $ReturnMessage = "Not Supported" }
        2 { $ReturnMessage = "Unspecified Error" }
        3 { $ReturnMessage = "Timeout" }
        4 { $ReturnMessage = "Failed" }
        5 { $ReturnMessage = "Invalid Parameter" }
        6 { $ReturnMessage = "Access Denied" }
    }
    $ReturnTable = @{
        "BIOSItem"=$Name;
        "BIOSValue"=$Value;
        "ReturnMessage"=$ReturnMessage;
        "ReturnCode"=$ReturnCode;           
    }

    Return [pscustomobject]$ReturnTable

}

Set-BIOSSetting -Name "Active Management (AMT)" -Value "Disable"
Set-BIOSSetting -Name "Virtualization Technology (VTx)" -Value "Enable"
Set-BIOSSetting -Name "Virtualization Technology for Directed I/O (VTd)" -Value "Enable"

# Remove variable with password in it.
Remove-Variable PasswordPlainText

# End session connection
Remove-CimSession $Session

