docker volume create tddvolume
docker create -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=Pa55w.rd" -e "MSSQL_AGENT_ENABLED=True" --name tddsql -v tddvolume:/var/opt/mssql -p1405:1433 -i mcr.microsoft.com/mssql/server:latest
docker start tddsql
$log = (docker logs tddsql) -like "*Service Broker manager has started*"
$ctr = 0
while( $log.Length -eq 0 ) {
    $ctr++
    if($ctr -ge 10){
        Write-Host "Instance not ready after 20 seconds. Giving up. Manually check if instance is ready before continuing." -ForegroundColor DarkRed
        break
    }
    Write-Host "Instance not ready, sleeping for two seconds" -ForegroundColor Cyan
    Start-Sleep -Seconds 2
    $log = (docker logs tddsql) -like "*Service Broker manager has started*"
    if( $log.Length -gt 0 ){
        Write-Host "Instance ready." -ForegroundColor Green
#	Invoke-WebRequest https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2016.bak -OutFile .\AdventureWorks2016.bak
#	docker cp .\AdventureWorks2016.bak tddsql:/var/opt/mssql/data
	$cred = New-Object System.Management.Automation.PSCredential("sa",(ConvertTo-SecureString -AsPlainText "Pa55w.rd" -Force))
#	Restore-DbaDatabase -SqlInstance "localhost,1405" -SqlCredential $cred -Path /var/opt/mssql/data/AdventureWorks2016.bak
#	Remove-Item .\AdventureWorks2016.bak
#	Invoke-WebRequest https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2014.bak -OutFile .\AdventureWorks2014.bak
	docker cp .\AdventureWorks2014.bak tddsql:/var/opt/mssql/data
	$cred = New-Object System.Management.Automation.PSCredential("sa",(ConvertTo-SecureString -AsPlainText "Pa55w.rd" -Force))
#	Restore-DbaDatabase -SqlInstance "localhost,1405" -SqlCredential $cred -Path /var/opt/mssql/data/AdventureWorks2014.bak -WithReplace
SQLCMD.EXE -S "localhost,1405" -Usa -P "Pa55w.rd" -Q "RESTORE DATABASE AdventureWorks2014 FROM DISK='/var/opt/mssql/data/Adventureworks2014.bak' WITH MOVE 'Adventureworks2014_Data' to '/var/opt/mssql/data/Adventureworks2014.mdf', MOVE 'Adventureworks2014_log' TO '/var/opt/mssql/data/Adventureworks2014_log.ldf',REPLACE;"
	Remove-Item .\AdventureWorks2014.bak
  
}
}


