docker build .\app -t stateprovinceapp:1.0 
docker tag stateprovinceapp:1.0 transmokopterpasssummit.azurecr.io/app/stateprovinceapp:1.0
docker login transmokopterpasssummit.azurecr.io -u "transmokopterpasssummit" -p "JtV33GSfPrQidweQ0=LHIy3sMWgGNplq"
docker push transmokopterpasssummit.azurecr.io/app/stateprovinceapp:1.0