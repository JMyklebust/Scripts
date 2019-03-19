# Scripts relating to HP computers

Here are scripts relating to functions on HP computers.

## Script descriptions

* ``Get-HPBiosSettings.ps1`` - Will gather the the current BIOS settings and possible values of a computer and store them in a CSV.
* ``Set-HPBiosSetting.ps1`` - Basic script that wil ask for a setting name and the desired value, optionally supports password.
* ``Set-HPBiosSettings.ps1`` - Expands on the previous script and allows setting predefined settings in one go, built for SCCM TS in mind but not thoroughly tested.
* ``Set-HPBiosSettingsRemote.ps1`` - Allows changing settings on a remote computer, will return results in a table.

## Notes for HP BIOS
Password string must contain ``<utf-16/>`` even if the password itself is blank.

All relevant classes exists under root/HP/InstrumentedBIOS

Relevant objects under BIOS class for the most part are:
Name
CurrentValue
PossibleValues

### Method call to change password
Command to set BIOS password (value being the new password with ``<utf-16/>`` tag):
Invoke-CimMethod -MethodName SetBIOSSetting -Arguments @{Name="Setup Password";Value="$NewPassword";Password="$OldPassword"}

### Return Codes translation
* 0 = Success
* 1 = Not Supported
* 2 = Unspecified Error
* 3 = Timeout
* 4 = Failed
* 5 = Invalid Parameter
* 6 = Access Denied
