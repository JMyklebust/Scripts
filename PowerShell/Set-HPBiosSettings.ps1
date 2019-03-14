Param(
    [Parameter(Mandatory=$true)]
    [string]$Computer
)

#Create Session with basic error checking
Try {
    
    $Session = New-CimSession -ComputerName $Computer -ErrorAction Stop
}
catch {
    Write-Warning "Unable to create CIM session to $Computer!"
    Write-Warning "Stopping script!..."
    break
}

#Get CIM class object
$HPBIOS = Get-CimInstance -Namespace root/HP/InstrumentedBIOS -ClassName HP_BIOSSettingInterface -CimSession $Session

#Save password as secure string
$PasswordAuto = Read-Host -Prompt "Enter current BIOS password (or leave blank)" -asSecureString

#Convert Secure string to plaintext
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($PasswordAuto)
$PasswordPlainText = "<utf-16/>" + [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

#Change BIOS settings.
$HPBIOS | Invoke-CimMethod -MethodName SetBIOSSetting -Arguments @{Name="Virtualization Technology (VTx)";Value="Enable";Password="$PasswordPlainText"}
$HPBIOS | Invoke-CimMethod -MethodName SetBIOSSetting -Arguments @{Name="Virtualization Technology for Directed I/O (VTd)";Value="Enable";Password="$PasswordPlainText"}

#Remove variable with password in it.
Remove-Variable PasswordPlainText

#End session connection
Remove-CimSession $Session


<#Notes
Password string must contain <utf-16/> even if the password itself is blank.

Use Get-HPBiosSettings.ps1 to discover bios items
All relevant classes exists under root/HP/InstrumentedBIOS

Relevant objects under BIOS class for the most part are:
Name
CurrentValue
PossibleValues

Command to set BIOS password (value being the new pasword with <utf-16/> tag):
$HPBIOS | Invoke-CimMethod -MethodName SetBIOSSetting -Arguments @{Name="Setup Password";Value="$NewPassword";Password="$OldPassword"}

Return Codes mapping
0 = Success
1 = Not Supported
2 = Unspecified Error
3 = Timeout
4 = Failed
5 = Invalid Parameter
6 = Access Denied

#>