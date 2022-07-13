![otus checks ](https://github.com/Otus-DevOps-2022-02/saaverdo_microservices/actions/workflows/run-tests-2022-02.yml/badge.svg)


# saaverdo_microservices
saaverdo microservices repository


## Task 17 Monitoring. Prometheus

Соберём свой образ, включив в него конфигурационный файл:

```
01:20 $ cat monitoring/prometheus/Dockerfile
FROM prom/prometheus:v2.1.0
ADD prometheus.yml /etc/prometheus/
```

Также соберём образы микросервисов:

```
export USER_NAME=saaverdo
for i in ui post-py comment; do cd src/$i; bash docker_build.sh; cd -; done
```

И запушим их на docker hub:

```
docker tag saaverdo/comment saaverdo/comment:1.0
docker tag saaverdo/post saaverdo/post:1.0
docker tag saaverdo/ui saaverdo/ui:1.0
docker push saaverdo/ui:1.0
docker push saaverdo/post:1.0
docker push saaverdo/comment:1.0
docker push saaverdo/prometheus
```

#### * mongodb exporter

Для мониторинга mongoDB воспользуемся экспортером percona/mongodb_exporter
Они предлагают запускать его командой:

```
docker run -d -p 9216:9216 -p 17001:17001 percona/mongodb_exporter:0.20 --mongodb.uri=mongodb://127.0.0.1:17001
```

но мы добавим в `docker-conmpose.yml` необходимый фрагмент:

```
  mongo-exporter:
    image: percona/mongodb_exporter:0.20
    ports:
        - '9216:9216'
        - '17001:17001'
    environment:
      - MONGODB_URI=mongodb://post_db:27017
    networks:
      - back_net
```

И в конфигурацию prometheus'а:

```
  - job_name: 'mongo'
    static_configs:
      - targets:
        - 'mongo-exporter:9216'
```


#### Links 2-3-4  Kann man Herzen brechen?

mongo exporter от перконы
https://github.com/percona/mongodb_exporter


## Task 16 Gitlab CI

Создание окружения для задания реализуем через `terraform` а установку `docker'а` - посредством `ansible`
Необходимые для этого скрипты и плейбуки разместим в директории `gitlab-ci`.

```
terraform apply

cd ../ansible
ansible-playbook playbooks/docker.yml -i environments/gitlsb/inventory
```

Когда ВМ готова, запустим контейнер с Gitlab с помощью файла `gitlab-ci/docker-compose.yml`

```
ansible-playbook playbooks/gitlab-omni.yml -i environments/gitlsb/inventory
```

Добавляем раннер - запустим контейнер на том же хосте:

```
docker run -d --name gitlab-runner --restart always -v /srv/gitlab-runner/config:/etc/gitlab-runner -v /var/run/docker.sock:/var/run/docker.sock
gitlab/gitlab-runner:latest
```

И регистрируем его а Gitlab, подставив свои IP и токен

```
docker exec -it gitlab-runner gitlab-runner register \
 --url http://<my-gitlab-ip>/ \
 --non-interactive \
 --locked=false \
 --name DockerRunner \
 --executor docker \
 --docker-image alpine:latest \
 --registration-token <my-gitlab-token> \
 --tag-list "linux,xenial,ubuntu,docker" \
 --run-untagged
 ```

Для удобства эти действия опишем в плейбуке `gitlab-runner.yml` который скопирует на хост `docker-compose` файл для раннера, запустит его и зарегистрирует

```
ansible-playbook playbooks/gitlab-runner.yml -i environments/gitlsb/inventory
```


## Task 15 Docker - 4

Docker при инициализации контейнера может подключить к нему только 1
сеть.
Дополнительные сети подключаются командой:

> docker network connect <network> <container>

При запуске создаваемые docker-compose контейнеры получают имя в формате <имя проекта>_<имя контейнера>_<инкремент>
По-умолчанию в качестве <имя проекта> берётся имя директории.

```
$ docker ps
CONTAINER ID   IMAGE                  COMMAND                   CREATED              STATUS          PORTS                    NAMES
281bb5b42aab   saaverdo/post:1.0      "python3 post_app.py"    About a  minute ago   Up 42 seconds                            src_post_1
4d9e02a9d1ae   mongo:3.2              "docker-entrypoint.s…"   About a  minute ago   Up 42 seconds   27017/tcp                src_post_db_1
c70f4b4cb2ed   saaverdo/comment:1.0   "puma"                   About a  minute ago   Up 41 seconds                            src_comment_1
417a3646e95e   saaverdo/ui:1.0        "puma"                   About a  minute ago   Up 41 seconds   0.0.0.0:9292->9292/tcp   src_ui_1
```

Изменить его можно:
задав переменную окружения `COMPOSE_PROJECT_NAME` в файле `.env` либо экспортировав её

```
$ export COMPOSE_PROJECT_NAME=shmuzik
$ docker-compose up -d
$ docker ps
CONTAINER ID   IMAGE                  COMMAND                   CREATED          STATUS          PORTS                    NAMES
453045206cc4   mongo:3.2              "docker-entrypoint.s…"   54  seconds ago   Up 49 seconds   27017/tcp                shmuzik_post_db_1
1b0e37821d1f   saaverdo/comment:1.0   "puma"                   54  seconds ago   Up 50 seconds                            shmuzik_comment_1
fdc1a8613e4e   saaverdo/post:1.0      "python3 post_app.py"    54  seconds ago   Up 50 seconds                            shmuzik_post_1
bbf79f250990   saaverdo/ui:1.0        "puma"                   54  seconds ago   Up 49 seconds   0.0.0.0:9292->9292/tcp   shmuzik_ui_1
```

указав его в строке запуска через ключ `-p`

```
$ docker-compose -p tuzik up -d
$ docker ps
CONTAINER ID   IMAGE                  COMMAND                   CREATED          STATUS          PORTS                    NAMES
9597baea0b53   mongo:3.2              "docker-entrypoint.s…"   21  minutes ago   Up 21 minutes   27017/tcp                tuzik_post_db_1
95c2eb7cd78f   saaverdo/post:1.0      "python3 post_app.py"    21  minutes ago   Up 21 minutes                            tuzik_post_1
ded8cc33b8d0   saaverdo/comment:1.0   "puma"                   21  minutes ago   Up 21 minutes                            tuzik_comment_1
d3f8e8e6c178   saaverdo/ui:1.0        "puma"                   21  minutes ago   Up 21 minutes   0.0.0.0:9292->9292/tcp   tuzik_ui_1
```

Кроме того, имя контейнера можно задать директивой `container_name:` - оно в результате будет без префиксов и суффиксов.

### Bonus level!

Задача:
Создайте docker-compose.override.yml для reddit проекта, который позволит:
1 - изменять код каждого из приложений, не выполняя сборку образа
2 - изменять код каждого из приложений, не выполняя сборку образа

#### I
Для этой задачи мы укажем монтировать директорию с файлами сервиса в директорию `/app/` внутри контейнера.

```
  ui:
    build: ./ui
    image: ${USERNAME}/ui:${UI_VER}
    volumes:
      - ./ui:/app/
```
теперь, если мы добавим, к примеру, строку `# test line` в файл `post_app.py` и запустим наш проект, то эта строка появится в данном файле внутри контейнера `post`


#### II

Чтобы переопределить команду запуска контейнера добавим пункт `command:` и укажем новую строку запуска: `["puma", "--debug", "-w", "2"]`

```
  ui:
    build: ./ui
    image: ${USERNAME}/ui:${UI_VER}
    volumes:
      - ./ui:/app/
    command: ["puma", "--debug", "-w", "2"]
    ports:
      - ${UI_PORT}:9292/tcp
    networks:
      - front_net
```




#### Links 2-3-4

https://superuser.com/questions/1269159/how-to-override-docker-compose-project-name-and-network-name

https://habr.com/ru/post/454552/
https://www.wake-up-neo.com/ru/docker-compose/kak-peredat-argumenty-v-tochku-vhoda-v-docker-compose.yml/826203749/
https://habr.com/ru/company/southbridge/blog/329138/


## Task 14 Docker - 3

#### basic play

Собираем образы (по образу и подобию из методички) ((pip тоже надо апдейтить ;))

```
docker build -t saaverdo/post:1.0 ./post-py
docker build -t saaverdo/comment:1.0 ./comment
docker build -t saaverdo/ui:1.0 ./ui
```

Последний использовал уже готовые слои из кэша, поэтому сборка фактически началась с 7-го шага:

```
00:12 $ docker build -t saaverdo/ui:1.0 ./ui
Sending build context to Docker daemon  30.72kB
Step 1/13 : FROM ruby:2.2
 ---> 6c8e6f9667b2
Step 2/13 : RUN apt-get update -qq && apt-get install -y build-essential
 ---> Using cache
 ---> 8b419bfd5b0d
Step 3/13 : ENV APP_HOME /app
 ---> Using cache
 ---> cfff55570422
Step 4/13 : RUN mkdir $APP_HOME
 ---> Using cache
 ---> cbe6ec7e015a
Step 5/13 : WORKDIR $APP_HOME
 ---> Using cache
 ---> a5c9ee294c45
Step 6/13 : ADD Gemfile* $APP_HOME/
 ---> 43e991c61076
Step 7/13 : RUN bundle install
 ---> Running in d45ffdb1c877
...
```

создадим сеть для наших контейнеров:

> docker network create reddit

И запустим контейнеры.

```
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post saaverdo/post:1.0
docker run -d --network=reddit --network-alias=comment saaverdo/comment:1.0
docker run -d --network=reddit -p 9292:9292 saaverdo/ui:1.0
```

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

```
docker run -d --network=reddit --network-alias=wtf_posts --network-alias=wtf_comments mongo:latest
docker run -d --env POST_DATABASE_HOST=wtf_posts --network=reddit --network-alias=omg_post_srv saaverdo/post:1.0
docker run -d --env COMMENT_DATABASE_HOST=wtf_comments --network=reddit --network-alias=lol_comments_srv saaverdo/comment:1.0
docker run -d --env POST_SERVICE_HOST=omg_post_srv --env COMMENT_SERVICE_HOST=lol_comments_srv --network=reddit -p 9292:9292 saaverdo/ui:1.0
```

### Оптимизируем образ `ui`

До

```
01:01 $ docker images
REPOSITORY         TAG            IMAGE ID       CREATED          SIZE
saaverdo/post      1.0            273de64848e3   31 minutes ago   121MB
saaverdo/ui        1.0            73c28f6e6a76   50 minutes ago   772MB
saaverdo/comment   1.0            47632ff4934a   50 minutes ago   770MB
mongo              latest         c8b57c4bf7e3   8 days ago       701MB
ruby               2.2            6c8e6f9667b2   4 years ago      715MB
python             3.6.0-alpine   cb178ebbf0f2   5 years ago      88.6MB
```

#### FROM ubuntu:16.04

На этот раз сборка началась с 1-го шага:

> 01:03 $ docker build -t saaverdo/ui:2.0 ./ui
> Sending build context to Docker daemon  30.72kB
> Step 1/13 : FROM ubuntu:16.04
> 16.04: Pulling from library/ubuntu
> 58690f9b18fc: Pull complete
> ...

После:

```
01:33 $ docker images
REPOSITORY             TAG       IMAGE ID       CREATED         SIZE
saaverdo/ui            2.0       dc40e9a70cfc   2 minutes ago   463MB
```

Образ занимает ощутимо меньше места.

We can go deeper!

#### FROM alpine:3.16

На этот раз соберём образ на базе `alpine:3.16` - 2.1
И  на очень лёгком образе `frolvlad/alpine-ruby` - 2.2 (TLDR: эффект практически нулевой)

```
02:01 $ docker images
REPOSITORY             TAG       IMAGE ID       CREATED          SIZE
saaverdo/ui            2.2       ea9a9c4a9028   9 seconds ago    252MB
saaverdo/ui            2.1       b099339762b7   4 minutes ago    253MB
saaverdo/ui            2.0       dc40e9a70cfc   28 minutes ago   463MB
```


#### Где ~~моя тачка~~ мои посты, чувак?

Add more volume, it's my favorite song!
Добавим volume для нашей базы:

> docker volume create reddit_db

теперь запустим контейнеры с данным volume

```
docker kill $(docker ps -q)
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=post saaverdo/post:1.0
docker run -d --network=reddit --network-alias=comment saaverdo/comment:1.0
docker run -d --network=reddit -p 9292:9292 saaverdo/ui:2.0
```

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

### Gcloud commands


gcloud compute instances list

gcloud compute images list | grep ubuntu
