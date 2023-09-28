docker build .\app -t stateprovinceapp:1.1 
docker tag stateprovinceapp:1.1 transmokopterdemos.azurecr.io/app/stateprovinceapp:1.1
docker login transmokopterdemos.azurecr.io -u "transmokopterdemos" -p "293o4HdprgrDT3jV8DlMesYNpi9TNw0AWzgZ0VCqjr+ACRA576hW"
docker push transmokopterdemos.azurecr.io/app/stateprovinceapp:1.1