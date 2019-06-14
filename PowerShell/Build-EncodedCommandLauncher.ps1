# This script will encode a powershell script into a base64 string and create a .bat file that will launch the command.
# The script will also write the content of the encoded script as a comment in the .bat.
#
# NOTE!: Be careful with this, make sure you either track the finished file with a SCM or lock down write access to the file.
# The only way to verify that the encoded command does as described is to decode it to a string again.

#File selection window
Add-Type -AssemblyName System.Windows.Forms
$f = new-object Windows.Forms.OpenFileDialog
$f.InitialDirectory = $PSScriptRoot
$f.Filter = "All Files (*.*)|*.*"
$f.ShowHelp = $true
$f.Multiselect = $false
[void]$f.ShowDialog()

if ([string]::IsNullOrWhiteSpace($f.FileName)){
    break
    }
else {
    $ScriptFilePath = $f.FileName
    }

#Place the resulting file at same location but with .bat ending
$OutFile = $ScriptFilePath -replace ".ps1",".bat"


#Get script content
$ScriptContent = Get-Content $ScriptFilePath -Raw

#Encode payload script in a base64 string
$Base64EncodedCommand = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($ScriptContent))

#Create content of batch file
$BatchFileContent = "
@Echo off

 
rem^ ||(
This is the content of the base64 encoded command that PowerShell is launching
#####

$ScriptContent

#####
)

powershell.exe -noprofile -encodedcommand $Base64EncodedCommand

"

#Write batch file
$BatchFileContent | Out-File $OutFile -Encoding ascii