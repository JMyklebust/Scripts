#Menu module
#This is intendend for dot sourcing, not importing as a PS Module.
#Behaviour of dot sorucing and PS modules are different, using this as a PS module will break it.
#This is done by writing ". .\scriptname.ps1" at the beginning of you script(note that there is a space between the dots).
#Alternatively simply copy the entire function into your script

#See MenuSampleScript.ps1 to see how this is used.

#Creates Menu
function Start-Menu{
    param(
        [Parameter(Mandatory=$True)]
        $MenuItemsHashTable,
        [Parameter(Mandatory=$True)]
        $MenuInformationText,
        [Parameter(Mandatory=$True)]
        $MenuInternalName,
        [Parameter(Mandatory=$False)] 
        [switch]$ClearConsole,
        [Parameter(Mandatory=$False)] 
        [switch]$DebugOn

    )

  #Optional Switch to clear console
  if ($ClearConsole){
    Clear-Host
  } 
  "---------------------------------------------------------"
  #Menu main text is inserted here
  Invoke-Command $MenuInformationText

  #Menu list is generated here
  foreach ($MenuOptionDisplayText in $MenuItemsHashTable)
  {

    #If menu function "Separator" is called, skip assigning it a number and color the text green.
    if($MenuOptionDisplayText[0] -like "Separator"){
      Write-Host ""
      Write-Host $MenuOptionDisplayText[1] -ForegroundColor Green
    }

    #Add each element to list
    else {
      $DescriptionItemNumber += 1
      write-host $DescriptionItemNumber - $MenuOptionDisplayText[1]
    }

  }

  #Menu Quit text
  ""
  "X - Exit"
  "---------------------------------------------------------"  
  
  #Answer promt for menu switch.
  $answer = read-host "Please Make a Selection" 

  #Build switch menu
  #Create fist part of switch variable
  [String]$MenuSwitchStatement = 'switch($answer){'

  #Iterate through hashtable and add entries to the switch variable
  ForEach ($MenuSwitchArray in $MenuItemsHashTable){

    #Skip the seperator element in the function list
    if ($MenuSwitchArray[0] -like "Separator") { 
    }

    #Add element to menu
    #This builds a switch option that runs a command, and then calls the menu again.
    else{
      $MenuNumber += 1 
      [String]$MenuSwitchStatement += "`n`t$MenuNumber {& $($MenuSwitchArray[0]);Start-Menu @$MenuInternalName; break }"

    }

  }

  #Define exit command
  [String]$MenuSwitchStatement +=("
    x {exit;break}
    ")
  
  #Define default statement
  [String]$MenuSwitchStatement +=("
    default {
    write-host -foregroundcolor red 'Please enter a valid selection'
    Sleep 2
    Start-Menu @$MenuInternalName
    }")         
  
  #Close Switch statement
  [String]$MenuSwitchStatement += "`n}"
  
  #If debug flag is used, print content of $MenuSwitchStatement
  if ($DebugOn){
    "DEBUGSWITCH"
    Write-Host $MenuSwitchStatement
    pause
  }

  #Invoke the built switch statement
  Invoke-Expression $MenuSwitchStatement 
}