# saaverdo_microservices
saaverdo microservices repository

## Task 12 - 13


`docker-machine` может сам создать хост для docker'а на gcp

```
 docker-machine create --driver google \
--google-project black-machine-349109  \
--google-zone europe-west4-a \
--google-machine-type f1-micro \
--google-machine-image $(gcloud compute images list --filter ubuntu-minimal-1804-lts --uri) \
docker-host
```

docker-machine env docker-host

eval $(docker-machine env docker-host)

Соберем контейнер
`docker build -t reddit:latest .`

Затегаем его
`docker tag reddit:latest saaverdo/otus-reddit:1.0`

и запушим на docker hub
`docker push saaverdo/otus-reddit:1.0`

 


