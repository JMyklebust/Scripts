# This snippet will test if shell is running as admin, if not ask for elevation.

function Test-IsAdmin {
([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "544")
}

function CheckAdmin{
    if ((Test-IsAdmin)){
        "Script is runnin as elevated all good!"
        Pause
    }
    elseif (!(Test-IsAdmin)){
        "Not running as admin trying to elevate"
        Start-Process Powershell -ArgumentList "-File $PSCommandPath -Noexit" -Verb Runas
        Pause
    }
}

CheckAdmin