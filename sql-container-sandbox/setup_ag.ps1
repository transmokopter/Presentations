docker compose up -d
Write-Host "Sleeping 5 seconds" -ForegroundColor Cyan
Start-Sleep -Seconds 5

Write-Host "Please key in sa credentials"
$cred = Get-Credential -UserName sa
Invoke-Sqlcmd -ServerInstance "localhost,1498" -InputFile $PSScriptRoot\ag_db1.sql -Credential $cred -TrustServerCertificate

docker cp db1:/var/opt/mssql/data/db1cert.cer .
docker cp db1:/var/opt/mssql/data/db1cert.pvk . 

docker cp .\db1cert.cer db2:/var/opt/mssql/data
docker cp .\db1cert.pvk db2:/var/opt/mssql/data

Remove-Item db1cert.*

Invoke-Sqlcmd -ServerInstance "localhost,1499" -InputFile $PSScriptRoot\ag_db2.sql -Credential $cred -TrustServerCertificate

