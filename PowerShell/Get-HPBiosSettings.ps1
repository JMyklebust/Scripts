param (
    [Parameter(Mandatory=$True)]
    [String]$Computer,

    $LogFolder = "$env:USERPROFILE\Documents"

)

#Create Session with basic error checking
Try {
    
    $Session = New-CimSession -ComputerName $Computer -ErrorAction Stop
}
catch {
    Write-Warning "Unable to create CIM session to $Computer!"
    Write-Warning "Stopping script!..."
    break
}

#Gather Computer Info 
$ComputerInfo = Get-CimInstance -ClassName CIM_ComputerSystem -CimSession $Session
#Gather HP BIOS info from CIM class
$HPBIOS = Get-CimInstance -Namespace root/HP/InstrumentedBIOS -ClassName HPBIOS_BIOSEnumeration -CimSession $Session

#Output file is a csv with the hostname and computer model, all spaces replaced with underscore
$OutFile = "$LogFolder\$($ComputerInfo.Name)_$($ComputerInfo.Model).csv" -replace ' ','_'

#Clear entries with no name by filtering if the name property contains any character that is not space, tab or newline
$HPBIOS = $HPBIOS | Where-Object -FilterScript {$_.name -match '\S'} | Sort-Object Path

#Filter and add export list to csv
$HPBIOS | Select-Object Path,Name,CurrentValue,@{n="PossibleValues";e={($_ | Select -ExpandProperty PossibleValues) -join ','}} | Export-Csv -Path $OutFile -NoTypeInformation -Encoding ASCII

#Add computer info on top of output file
@("#Hostname: $($ComputerInfo.Name)", "#Model: $($ComputerInfo.Model)","#Date: $(Get-Date -Format s)") +  (Get-Content $OutFile -Encoding Ascii) | Set-Content $OutFile -Encoding Ascii

#Clean up session connection
Remove-CimSession $Computer

