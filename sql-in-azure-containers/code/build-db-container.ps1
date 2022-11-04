docker build .\db -t adventureworks2014-db:2.0 --build-arg DBNAME=Adventureworks2014 --build-arg PASSWORD="Pa55w.rd" --build-arg DACPAC="adventureworks2014-db/adventureworks2014-db/bin/Debug/adventureworks2014-db.dacpac" 
docker tag adventureworks2014-db:2.0 transmokopterpasssummit.azurecr.io/db/aw2014:1.0
docker login transmokopterpasssummit.azurecr.io -u "transmokopterpasssummit" -p "JtV33GSfPrQidweQ0=LHIy3sMWgGNplq"
docker push transmokopterpasssummit.azurecr.io/db/aw2014:1.0