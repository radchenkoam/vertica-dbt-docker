## vertica-dbt-docker

❕предназначено только для демонстрационных целей и тестирования❕

* * *

#### Установка:

-   клонировать репозиторий
    ```bash
    $ git clone git@github.com:radchenkoam/vertica-dbt-docker.git
    ```
-   скачать образ [Vertica Free Community Edition Trial](https://www.vertica.com/try/)
-   поместить скачанный образ в `./vertica/packages`
-   если необходимо - в файле `.env` изменить значение `VERTICA_PACKAGE` по имени скачанного образа
-   установить по желанию [vsql Client](https://www.vertica.com/docs/10.1.x/HTML/Content/Authoring/ConnectingToVertica/vsql/Install/InstallingTheVsqlClient.htm)
-   запустить установку проекта
    ```bash
    $ cd vertica-dbt-docker
    $ make setup
    ```
-   запустить контейнер с `Vertica`: `$ make vertica-run`
-   запустить контейнер с `dbt`: `$ make dbt-start`
-   в терминале контейнера `dbt` загрузить датасет: `$ dbt seed`
-   развернуть модели: `$ dbt run`
-   для подключения к `Vertica` (при установленном `vsql Client`): `$ make vertica-connect`

    ```bash
    dbadmin=> \c boston_crimes
    You are now connected to database "boston_crimes" as user "dbadmin".
    boston_crimes=> \dtv+
                                List of tables
     Schema |              Name               | Kind  |  Owner  | Comment
    --------+---------------------------------+-------+---------+---------
     dbt    | crime                           | table | dbadmin |
     dbt    | crimes                          | table | dbadmin |
     dbt    | mrt_offense_all_count           | table | dbadmin |
     dbt    | mrt_offense_by_year_count       | table | dbadmin |
     dbt    | mrt_offense_by_year_month_count | table | dbadmin |
     dbt    | offense_codes                   | table | dbadmin |
     dbt    | seed_rejects                    | table | dbadmin |
     dbt    | stg_crime                       | view  | dbadmin |
     dbt    | stg_offense_codes               | view  | dbadmin |
    (9 rows)

    boston_crimes=> select count(*) from dbt.crime;
     count
    --------
     319073
    (1 row)

    boston_crimes=> \q
    ```

-   удалить проект: `$ make project-remove`
    останутся образы `python:3.8-slim-buster`, `ubuntu:18.04`
    (если необходимо - удалить вручную)

***

#### Ссылки:

🔗 [Vertica docs](https://www.vertica.com/docs/10.1.x/HTML/Content/Home.htm)
🔗 [dbt docs](https://docs.getdbt.com/docs/introduction)
🔗 [docker docs](https://docs.docker.com/engine/)
🔗 [portainer docs](https://documentation.portainer.io/)

* * *

💡 для визуализации установки проекта удобно иcпользовать [Portainer CE](https://documentation.portainer.io/v2.0/deploy/ceinstalldocker/)
💡 для подсказки по `make`-командам - просто набрать в терминале `make`

* * *

❗ не надо менять значения в файле `.env` в текущей версии, с другими параметрами тестирование не производилось
❗ не надо использовать датасет с Kaggle, пользуйтесь тем, что будет распакован с проектом
