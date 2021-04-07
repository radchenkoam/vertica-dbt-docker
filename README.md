# vertica-dbt-docker

$ git clone git@github.com:radchenkoam/vertica-dbt-docker.git
скачать package vertica в ./vertica/packages | wget
описать параметры в .env

$ cd vertica-dbt-docker
$ sudo chmod ugo+x setup.sh && sudo ./setup.sh
$ docker-compose up -d
