docker build .\db -t adventureworks2014-db:2.0 --build-arg DBNAME=Adventureworks2014 --build-arg PASSWORD="Pa55w.rd" --build-arg DACPAC="adventureworks2014-db/adventureworks2014-db/bin/Debug/adventureworks2014-db.dacpac" 
docker tag adventureworks2014-db:2.0 transmokopterdemos.azurecr.io/db/aw2014:1.0
docker login transmokopterdemos.azurecr.io -u "transmokopterdemos" -p "293o4HdprgrDT3jV8DlMesYNpi9TNw0AWzgZ0VCqjr+ACRA576hW"
docker push transmokopterdemos.azurecr.io/db/aw2014:1.0
