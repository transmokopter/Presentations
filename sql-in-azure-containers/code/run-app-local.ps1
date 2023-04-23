docker network create transmokopter-net
docker create  --name app -e "ConnectionStrings__aw2014=Data Source=aw2014;Initial Catalog=AdventureWorks2014;Persist Security Info=True;User ID=sa;Password=Pa55w.rd;Encrypt=False" --net transmokopter-net -p8000:80 stateprovinceapp:1.1
docker create --name aw2014 --net transmokopter-net -p1450:1433 adventureworks2014-db:2.0
docker start aw2014
docker start app
