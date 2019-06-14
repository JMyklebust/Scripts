#Change Thundebolt Software user access level to allow users to accept Thundebolt equpiment without being local admin

# This is an example of using ThunderboltFix.ps1 though a scheduled task to run in SYSTEM context.
# No dependencies on other software, beyond what is build-in in Windows.

#Create Script payload
$TBFix ={

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
    
}

#Encode payload script in a base64 string
$TBFixEncoded = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($TBFix))


#Create action for scheduled task
$action = New-ScheduledTaskAction -Execute powershell.exe -Argument "-noprofile -encodedcommand $TBFixEncoded"
#Create task
$Taskname = "Run Thundebolt User Access Fix"
Register-ScheduledTask -Action $action -TaskName $Taskname -RunLevel Highest -User S-1-5-18 -Force
#Run task 
Start-ScheduledTask -TaskName $Taskname
#Remove task
Unregister-ScheduledTask -TaskName $Taskname -Confirm:$false