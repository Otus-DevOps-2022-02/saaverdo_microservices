# saaverdo_microservices
saaverdo microservices repository

## Task 12/13 Docker - 2


`docker-machine` может сам создать хост для docker'а на gcp

```
 docker-machine create --driver google \
--google-project black-machine-349109  \
--google-zone europe-west4-a \
--google-machine-type f1-micro \
--google-machine-image $(gcloud compute images list --filter ubuntu-minimal-1804-lts --uri) \
docker-host
```
Создадим окружение docker-machine
`docker-machine env docker-host`
И активируем его
`eval $(docker-machine env docker-host)`
Теперь мы работаем с docker на удалённой машине.
Соберем контейнер
`docker build -t reddit:latest .`

и запустим его
`docker run --name reddit -d --network=host reddit:latest`

Затегаем наш образ
`docker tag reddit:latest saaverdo/otus-reddit:1.0`

и запушим на docker hub
`docker push saaverdo/otus-reddit:1.0`
