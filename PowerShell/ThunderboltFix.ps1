# Change Thundebolt Software user access level to allow users to accept Thundebolt equpiment without being local admin

# Should be launched from a powershell instance running under "SYSTEM" user.
# Can be launched from a batch file with this command and psexec.exe in same folder, must run as admin:
# %~dp0PsExec.exe -accepteula -nobanner -s powershell.exe -ExecutionPolicy Bypass -File "%~dp0TB3Fix.ps1"
# Alternatively look at "ThunderboltFixScheduledTask.ps1"

#Registry key to modify
$RegistryKey = "SYSTEM\CurrentControlSet\Services\ThunderboltService\TbtServiceSettings"

#Store original ACL info
$ACLinfo = Get-Acl "HKLM:\$RegistryKey"

#Modify ACL using .Net methods, and give "SYSTEM" user full access to registry key
$RegKeyDotNETItem = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($RegistryKey,[Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,[System.Security.AccessControl.RegistryRights]::ChangePermissions)
$DotNET_ACL = $RegKeyDotNETItem.GetAccessControl()
$DotNET_AccessRule = New-Object System.Security.AccessControl.RegistryAccessRule ("System","FullControl","Allow")
$DotNET_ACL.SetAccessRule($DotNET_AccessRule)
$RegKeyDotNETItem.SetAccessControl($DotNET_ACL)

#Change property of Item in key to desired value
Set-ItemProperty -Path "HKLM:\$RegistryKey" -Name 'ApprovalLevel' -Value 1

#Reset ACL to what it was before modification
Set-Acl -AclObject $ACLinfo -Path "HKLM:\$RegistryKey"
