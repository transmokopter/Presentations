docker build .\db -t adventureworks2014-db:2.0 --build-arg DBNAME=Adventureworks2014 --build-arg PASSWORD="Pa55w.rd" --build-arg DACPAC="adventureworks2014-db/adventureworks2014-db/bin/Debug/adventureworks2014-db.dacpac" 
docker tag adventureworks2014-db:2.0 transmokopterpasssummit.azurecr.io/db/aw2014:1.0
docker login transmokopterpasssummit.azurecr.io -u "transmokopterpasssummit" -p "Pfv4jJh9E/ke/TVC+lD/iXhWQmhtO2t5rmS0ZmTZ04+ACRA5PrwT"
docker push transmokopterpasssummit.azurecr.io/db/aw2014:1.0
