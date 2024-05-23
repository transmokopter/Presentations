docker exec sql1 bash -c "rm /var/opt/mssql/data/dr -f -r"
docker exec sql1 bash -c "mkdir /var/opt/mssql/data/dr"
docker exec sql1 bash -c "rm /var/opt/mssql/data/backups -f -r"
docker exec sql1 bash -c "mkdir /var/opt/mssql/data/backups"
