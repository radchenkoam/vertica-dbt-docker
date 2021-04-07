build:
	docker build -t radchenkoam/dbt-vertica .

run:
	docker run --rm -it --name dbt-vertica radchenkoam/dbt-vertica

connect_vertica:
	/opt/vertica/bin/vsql -h 127.0.0.1 -p 5433 -U dbadmin
