<#
.SYNOPSIS
    Sends JSON data to specified URI
.NOTES
    Author: Jens-Kristian Myklebust
.LINK 
    https://github.com/JMyklebust/Scripts
#>


function Send-JSONToWebhook {
    param(
    
    # Webook URI
    [Parameter(Mandatory=$true)]
    [string]$webhookURI,

    # Message body to send, must be JSON formatted
    [Parameter(Mandatory=$true,ValueFromRemainingArguments=$true)]
    [String]$Body

    )

    Invoke-RestMethod -Uri $webhookURI -Body $Body -Headers @{'accept'='application/json'} -Method Post
}

Export-ModuleMember Send-JSONToWebhook



