![otus checks ](https://github.com/Otus-DevOps-2022-02/saaverdo_microservices/actions/workflows/run-tests-2022-02.yml/badge.svg)


# saaverdo_microservices
saaverdo microservices repository

## Task 14 Docker - 3

#### basic play

Собираем образы (по образу и подобию из методички) ((pip тоже надо апдейтить ;))

> docker build -t saaverdo/post:1.0 ./post-py
> docker build -t saaverdo/comment:1.0 ./comment
> docker build -t saaverdo/ui:1.0 ./ui

Последний использовал уже готовые слои из кэша, поэтому сборка фактически началась с 7-го шага:

> 00:12 $ docker build -t saaverdo/ui:1.0 ./ui
> Sending build context to Docker daemon  30.72kB
> Step 1/13 : FROM ruby:2.2
>  ---> 6c8e6f9667b2
> Step 2/13 : RUN apt-get update -qq && apt-get install -y build-essential
>  ---> Using cache
>  ---> 8b419bfd5b0d
> Step 3/13 : ENV APP_HOME /app
>  ---> Using cache
>  ---> cfff55570422
> Step 4/13 : RUN mkdir $APP_HOME
>  ---> Using cache
>  ---> cbe6ec7e015a
> Step 5/13 : WORKDIR $APP_HOME
>  ---> Using cache
>  ---> a5c9ee294c45
> Step 6/13 : ADD Gemfile* $APP_HOME/
>  ---> 43e991c61076
> Step 7/13 : RUN bundle install
>  ---> Running in d45ffdb1c877
> ...

создадим сеть для наших контейнеров:

> docker network create reddit

И запустим контейнеры.

> docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
> docker run -d --network=reddit --network-alias=post saaverdo/post:1.0
> docker run -d --network=reddit --network-alias=comment saaverdo/comment:1.0
> docker run -d --network=reddit -p 9292:9292 saaverdo/ui:1.0

#### custom network aliases (дз*)

В образах имена хостов (алиасы), к которым должны обращаться сервисы, забиты в переменныех окружения, поэтому при изменениее алиасов, нам надо переопределить эти переменные.
Для `post` это `ENV POST_DATABASE_HOST post_db`
Для `comment` это `ENV COMMENT_DATABASE_HOST comment_db`
Для `ui` это `ENV POST_SERVICE_HOST post` и `ENV COMMENT_SERVICE_HOST comment`

Тут есть два варианта:
1) можно задать эти переменные окружения на хосте и затем указать их параметром `-e`, `--env` команде `docker run`:

```
export ENV POST_DATABASE_HOST db_service
docker run -d -e ENV POST_DATABASE_HOST --network=reddit --network-alias=post_srv saaverdo/post:1.0
```

2) можно определить эти переменные в параметре `-e`, `--env` команде `docker run`. Так и поступим.


> docker run -d --network=reddit --network-alias=wtf_posts --network-alias=wtf_comments mongo:latest
> docker run -d --env POST_DATABASE_HOST=wtf_posts --network=reddit --network-alias=omg_post_srv saaverdo/post:1.0
> docker run -d --env COMMENT_DATABASE_HOST=wtf_comments --network=reddit --network-alias=lol_comments_srv saaverdo/comment:1.0
> docker run -d --env POST_SERVICE_HOST=omg_post_srv --env COMMENT_SERVICE_HOST=lol_comments_srv --network=reddit -p 9292:9292 saaverdo/ui:1.0

### Оптимизируем образ `ui`

До

> 01:01 $ docker images
> REPOSITORY         TAG            IMAGE ID       CREATED          SIZE
> saaverdo/post      1.0            273de64848e3   31 minutes ago   121MB
> saaverdo/ui        1.0            73c28f6e6a76   50 minutes ago   772MB
> saaverdo/comment   1.0            47632ff4934a   50 minutes ago   770MB
> mongo              latest         c8b57c4bf7e3   8 days ago       701MB
> ruby               2.2            6c8e6f9667b2   4 years ago      715MB
> python             3.6.0-alpine   cb178ebbf0f2   5 years ago      88.6MB

#### FROM ubuntu:16.04

На этот раз сборка началась с 1-го шага:

> 01:03 $ docker build -t saaverdo/ui:2.0 ./ui
> Sending build context to Docker daemon  30.72kB
> Step 1/13 : FROM ubuntu:16.04
> 16.04: Pulling from library/ubuntu
> 58690f9b18fc: Pull complete
> ...

После:

> 01:33 $ docker images
> REPOSITORY             TAG       IMAGE ID       CREATED         SIZE
> saaverdo/ui            2.0       dc40e9a70cfc   2 minutes ago   463MB

Образ занимает ощутимо меньше места.

We can go deeper!

#### FROM alpine:3.16

На этот раз соберём образ на базе `alpine:3.16` - 2.1
И  на очень лёгком образе `frolvlad/alpine-ruby` - 2.2 (TLDR: эффект практически нулевой)

> 02:01 $ docker images
> REPOSITORY             TAG       IMAGE ID       CREATED          SIZE
> saaverdo/ui            2.2       ea9a9c4a9028   9 seconds ago    252MB
> saaverdo/ui            2.1       b099339762b7   4 minutes ago    253MB
> saaverdo/ui            2.0       dc40e9a70cfc   28 minutes ago   463MB

#### Где ~~моя тачка~~ мои посты, чувак?

Add more volume, it's my favorite song!
Добавим volume для нашей базы:

> docker volume create reddit_db

теперь запустим контейнеры с данным volume

> docker kill $(docker ps -q)
> docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
> docker run -d --network=reddit --network-alias=post saaverdo/post:1.0
> docker run -d --network=reddit --network-alias=comment saaverdo/comment:1.0
> docker run -d --network=reddit -p 9292:9292 saaverdo/ui:2.0

Уря! Всё работает!


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

NB - для деактивации окружения:
`eval $(docker-machine env -u)`


Теперь мы работаем с docker на удалённой машине.
Соберем контейнер
`docker build -t reddit:latest .`

и запустим его
`docker run --name reddit -d --network=host reddit:latest`

Затегаем наш образ
`docker tag reddit:latest saaverdo/otus-reddit:1.0`

и запушим на docker hub
`docker push saaverdo/otus-reddit:1.0`
