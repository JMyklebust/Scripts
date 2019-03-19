# Notes for HP BIOS
Password string must contain ``<utf-16/>`` even if the password itself is blank.

All relevant classes exists under root/HP/InstrumentedBIOS

Relevant objects under BIOS class for the most part are:
Name
CurrentValue
PossibleValues

## Method call to change password
Command to set BIOS password (value being the new pasword with ``<utf-16/>`` tag):
Invoke-CimMethod -MethodName SetBIOSSetting -Arguments @{Name="Setup Password";Value="$NewPassword";Password="$OldPassword"}

## Return Codes translation
0 = Success
1 = Not Supported
2 = Unspecified Error
3 = Timeout
4 = Failed
5 = Invalid Parameter
6 = Access Denied
