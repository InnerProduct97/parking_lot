## Guidance
1. Please make sure you have configured aws cli before running "setup.sh"
2. Download the scripts:"setup.sh","deploy.sh" to the same directory and run setup.sh (alternatively you can clone this repository and run "setup.sh"). You should get the same output as "setup.out".

## Tests
1. I provided sample images in "plates_images". You can use them while testing the web application.
2. You can use the "curl" utility.
### GET
```
curl --location 'http://<host_ip>/entry?plate=SHC1231&parkingLot=314'
```
```
curl --location 'http://<host_ip>/exit?ticketId=9'
```
### POST
```
curl --location 'http://<host_ip>/entry' \
--form 'image=@"/Users/InnerProduct97/Downloads/images.jpeg"' \
--form 'parkingLot="314";type=application/json'
```
```
curl --location 'http://<host_ip>/exit' --form 'ticketId="10";type=application/json'
```
