docker volume create areyoudrunkvolume
docker create -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=Pa55w.rd" -e "MSSQL_AGENT_ENABLED=True" -e "MSSQL_PID=Standard" --name areyoudrunksql -v areyoudrunkvolume:/var/opt/mssql -p1401:1433 -i mcr.microsoft.com/mssql/server:latest
docker start areyoudrunksql