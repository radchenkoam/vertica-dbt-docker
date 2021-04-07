VPWD := $(shell cat .env | sed -n "s/VERTICA_DBA_PASSWORD=//p")

run:
	docker run --rm -it -p 5433:5433 --name vertica radchenkoam/vertica

connect:
	/opt/vertica/bin/vsql -h 127.0.0.1 -p 5433 -U dbadmin -w $(VPWD)
