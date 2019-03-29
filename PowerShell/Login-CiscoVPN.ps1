#source http://www.cze.cz
#this script is tested with "Cisco AnyConnect Secure Mobility Client version 3.0.5080"

## 2019-02-26 Updated by <jens-kristian.myklebust@atea.no>
# Added script parameter for VPN address and Username
# Changed password handling so that password is not exposed in plaintext in console or script.
# Added relative paths to Cisco VPN (to handle both x64 and x86)
# General tidying up of variable names
# Tested with AnyConnect 4.5.03040 on Win10 1809 Enterprise

Param(
    # VPN Host Url or IP-address
    $VPNAddress = "",

    #Username
    $Username = $env:USERNAME
)

#Promt for password and store as secure string
$Password = Read-Host -Prompt "Password" -asSecureString


#Check for Cisco VPN location
#Handles both x64 Windows and x86 Windows (and both x64 and x86 client on x64 Windows)
$AnyConnectRootFolder = "$env:ProgramFiles\Cisco\Cisco AnyConnect Secure Mobility Client"
$x86AnyConnectRootFolder = "${env:ProgramFiles(x86)}\Cisco\Cisco AnyConnect Secure Mobility Client"

if (Test-Path $AnyConnectRootFolder){
    $AnyConnect_vpncli = "$AnyConnectRootFolder\vpncli.exe"
    $AnyConnect_vpnui = "$AnyConnectRootFolder\vpnui.exe"
}
elseif (!(Test-Path $AnyConnectRootFolder) -and (Test-Path $x86AnyConnectRootFolder)){
    $AnyConnect_vpncli = "$x86AnyConnectRootFolder\vpncli.exe"
    $AnyConnect_vpnui = "$x86AnyConnectRootFolder\vpnui.exe"
}
else {
    "Unable to find Cisco AnyConnect Client"
    "Stopping script...."
    Pause
    Break
}

#****************************************************************************
#**** Please do not modify code below unless you know what you are doing ****
#****************************************************************************

#Convert password secure string to binary string for further use
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)

Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop

#set foreground window function
#this function is called in Start-VPNConnect
Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class Win {
        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool SetForegroundWindow(IntPtr hWnd);
    }
"@ -ErrorAction Stop

#Start connection function
Function Start-VPNConnect{
    Start-Process -FilePath $AnyConnect_vpncli -ArgumentList "connect $VPNAddress"
    $counter = 0; $ProcessHandle = 0;
    while($counter++ -lt 1000 -and $ProcessHandle -eq 0){
        Start-Sleep -Milliseconds 10 
        $ProcessHandle = (Get-Process vpncli).MainWindowHandle
    }
    #if it takes more than 10 seconds then display message
    if($ProcessHandle -eq 0){
        Write-Output "Could not start VPNUI it takes too long."
    }
    else{
        [void] [Win]::SetForegroundWindow($ProcessHandle)
    }
}


#Stop vpnui process if running
Get-Process -Name vpnui -ErrorAction SilentlyContinue | ForEach-Object {$Id = $_.Id; Stop-Process $Id; Write-Output "Process vpnui with id: $Id was stopped"}
#Stop vpncli process if running
Get-Process -Name vpncli -ErrorAction SilentlyContinue | ForEach-Object {$Id = $_.Id; Stop-Process $Id; Write-Output "Process vpncli with id: $Id was stopped"}


#Disconnect exsisting VPN sessions
Write-Output "Trying to terminate remaining vpn connections"
Start-Process -FilePath $AnyConnect_vpncli -ArgumentList "disconnect" -wait

#Start the VPN session
Write-Output "Connecting to VPN address ""$VPNAddress"" as user ""$Username""."
Start-VPNConnect

#Send username to vpncli window
[System.Windows.Forms.SendKeys]::SendWait("$Username{Enter}")
#Convert password binary string into plaintext and sendt to vpncli window
[System.Windows.Forms.SendKeys]::SendWait([System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)+"{Enter}")

#Clear binary string pointer (prevents easily recovering the password from memory)
[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)

#Wait for vpncli to finnish before continuing
Wait-Process -Name vpncli

#Restart vpnui
Start-Process -FilePath $AnyConnect_vpnui