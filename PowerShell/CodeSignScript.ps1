# This script allows you to quickly sign you scripts with a code signing certificate from you Windows certificate storage.
# In case of there being muliple signing certificates you will be prompted on which to use.
# This will also timestamp the signing time to allow a script to be used even when the signing cert has expired and the file is not tampered with.
# You may use your own timestamp server or use the default one by Comodo CA
# It is reccomended that you sign this script before using it to sign others.
#
# Bonus: This script also supports drag and drop signing.
# Create shortcut with the "Target" "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -file "C:\PATHTOSCRIPT\SignScript.ps1"" and "Start In" "C:\PATHTOSCRIPT"

param (
    $TimeStampServer = "http://timestamp.comodoca.com/authenticode",
    [Parameter(Mandatory=$True,ValueFromRemainingArguments=$true)]
    $ScriptFilePath
)

$cert = (Get-ChildItem cert:currentuser\my\ -CodeSigningCert)

do{
    Write-Host "Multiple possible certificates detected" -ForegroundColor Yellow
    Write-Host  "Enter thumbprint of the cert you want to use (use * to auto-complete once your selection is unique)" -ForegroundColor Yellow
    $cert | Select-Object Thumbprint,Subject,Issuer,NotBefore,NotAfter | Format-Table
    ""
    $script:cert = $cert | Where-Object -Property Thumbprint -Like "$(Read-Host "Enter Thumbprint")"
} while ( ($cert | measure-object ).count -ge 2)



Set-AuthenticodeSignature -FilePath $ScriptFilePath -Certificate $cert -TimestampServer $TimeStampServer
