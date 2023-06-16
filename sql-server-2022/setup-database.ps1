docker create --name sql2022 -e "SA_PASSWORD=Pa55w.rd" -e "ACCEPT_EULA=Y" -p1459:1433 mcr.microsoft.com/mssql/server:latest
docker cp $PSScriptRoot\WideWorldImporters-Full.bak sql2022:/var/opt/mssql/data
