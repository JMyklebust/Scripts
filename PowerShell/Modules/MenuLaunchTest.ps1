#Dot source the Menu module script
. $PSScriptRoot\Menu.ps1


#This is the information text that will be displayed
#You can use variables and even functions here for getting you data.
#The Get-DayYear function is an example of calling a function created in the script
$MainMenuInformationText = {
#Name
"Start tools"
""
#Infotext
"Script to start various tools

Launching tools as user:
$env:username

Current script location:
$PSScriptRoot

WinPE Architecture:
$ENV:PROCESSOR_ARCHITECTURE

Current year, month and day:"
Get-DayYear
""

}

#Example function used for the menu information text
function Get-DayYear {
    Get-Date -Format yyyy-MM-dd
}

#Add software here
#Applications

function Start-PowerShellInstance {Start-Process "Powershell.exe"}

#Add to menu here
$MainMenuItemsTable = @(

#Applications
("Separator","***Applications***"),
("Start-PowerShellInstance","Start a PowerShell instance"),
("Start-Menu @SubMenuHashTable","Go to submenu")

)

#Store menu in a variable for splatting with the menu function
#This is reused by the Menu function itself so MenuIntenalName must match the the variable name
$script:MainMenuHashTable = @{
    MenuItemsHashTable = $MainMenuItemsTable
    MenuInformationText = $MainMenuInformationText
    MenuInternalName = "MainMenuHashTable"
}

##Submenu example
$SubMenuInfromationText = {
    "SUBMENU"
}
$SubMenuItemsTable = @(
    ("Start-Menu @MainMenuHashTable","Go to main menu"),
    ("Start-PowerShellInstance","Start a PowerShell instance")
)
$script:SubMenuHashTable  = @{
    MenuInformationText = $SubMenuInfromationText
    MenuItemsHashTable = $SubMenuItemsTable
    MenuInternalName = "SubMenuHashTable"
}

#Run menu
Start-Menu @MainMenuHashTable