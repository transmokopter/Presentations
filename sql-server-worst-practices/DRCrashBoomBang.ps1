docker exec -u root sql1 bash -c "rm /var/opt/mssql/data/dr -f -r"
docker exec -u root sql1 bash -c "rm /var/opt/mssql/data/backups -f -r"
docker stop sql1
docker start sql1