# vertica-dbt-docker

$ git clone git@github.com:radchenkoam/vertica-dbt-docker.git
скачать package vertica в ./vertica/packages | wget
скачать boston_crimes (make)
установить vsql

описать параметры в .env
  из строки profile: crimes_in_boston_vertica в dbt_project.yml заполняем имя профиля в .env

$ cd vertica-dbt-docker
$ sudo chmod ugo+x setup.sh && sudo ./setup.sh
$ docker-compose up -d

$ export DBT_PROFILES_DIR=/usr/app/.dbt
dbt run --profiles-dir path/to/directory
