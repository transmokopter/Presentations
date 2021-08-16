docker volume create tddvolume
docker create -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=Pa55w.rd" -e "MSSQL_AGENT_ENABLED=True" --name tddsql -v tddvolume:/var/opt/mssql -p1405:1433 -i mcr.microsoft.com/mssql/server:latest
docker start tddsql
$log = (docker logs tddsql) -like "*Service Broker manager has started*"
$ctr = 0
while( $log.Length -eq 0 ) {
    $ctr++
    if($ctr -ge 5){
        Write-Host "Instance not ready after 20 seconds. Giving up. Manually check if instance is ready before continuing." -ForegroundColor DarkRed
        break
    }
    Write-Host "Instance not ready, sleeping for two seconds" -ForegroundColor Cyan
    Start-Sleep -Seconds 2
    $log = (docker logs tddsql) -like "*Service Broker manager has started*"
    if( $log.Length -gt 0 ){
        Write-Host "Instance ready." -ForegroundColor Green
    }
}

