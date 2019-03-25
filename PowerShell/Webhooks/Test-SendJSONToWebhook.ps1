# Example script on how to use webhook module

Import-Module "$PSScriptRoot\Send-JsonToWebhook.psm1"

$webhook = 'https://example.com/token'

$Body = '{
  "username": "Mynotes",
  "content": "#CONTENT#"
}'

Send-JSONToWebhook -webhookURI $webhook -Body $Body