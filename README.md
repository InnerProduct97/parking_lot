## Guidance
1. Please make sure you have configured aws cli before running "setup.sh"
2. Run "setup.sh"

## Tests
1. I provided sample images in "parking_lot/images". You can use them while testing the web application.
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
--form 'parkingLot="527h7h";type=application/json'
```
```
curl --location 'http://<host_ip>/exit' \
--form 'ticketId="10";type=application/json'
```
