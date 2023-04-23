docker build .\app -t stateprovinceapp:1.1 
docker tag stateprovinceapp:1.1 transmokopterpasssummit.azurecr.io/app/stateprovinceapp:1.1
docker login transmokopterpasssummit.azurecr.io -u "transmokopterpasssummit" -p "Pfv4jJh9E/ke/TVC+lD/iXhWQmhtO2t5rmS0ZmTZ04+ACRA5PrwT"
docker push transmokopterpasssummit.azurecr.io/app/stateprovinceapp:1.1