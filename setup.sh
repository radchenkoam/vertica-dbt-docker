#!/bin/sh
# This script setups dockerized Vertica on Ubuntu 18.04 & DBT
set -eu

# Set environment variables from .env file
export $(cat .env | egrep -v "(^#.*|^$)" | xargs)

sudo -E apt -qqy -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
sudo apt-get -qqy update
sudo sh ./scripts/docker_install.sh
sudo sh ./scripts/docker_compose_install.sh
sudo apt-get -qqy install wget pwgen

create_network() {
  if [ -n "$(docker network ls | grep dbt-net)" ]; then
    docker network rm dbt-net
  fi
  docker network create dbt-net
}

create_directories() {
  if [ -e $VERTICA_LOCAL_PATH/data ]; then
      sudo rm -r $VERTICA_LOCAL_PATH/data
  fi

  sudo mkdir -p $VERTICA_LOCAL_PATH/data
  sudo chown $USER:$USER $VERTICA_LOCAL_PATH/data
}

create_configs() {
  # Create Vertica config
  if [ -e $VERTICA_LOCAL_PATH/.env ]; then
      sudo rm $VERTICA_LOCAL_PATH/.env
  fi
  sudo touch $VERTICA_LOCAL_PATH/.env

  echo "VERTICA_PACKAGE="$VERTICA_PACKAGE >> $VERTICA_LOCAL_PATH/.env
  echo "VERTICA_DATA="$VERTICA_DATA >> $VERTICA_LOCAL_PATH/.env
  echo "VERTICA_DBA_USER="$VERTICA_DBA_USER >> $VERTICA_LOCAL_PATH/.env
  export VERTICA_DBA_PASSWORD=$(pwgen -1s 32)
  echo "VERTICA_DBA_PASSWORD="$VERTICA_DBA_PASSWORD >> $VERTICA_LOCAL_PATH/.env
  echo "VERTICA_DATABASE_NAME="$VERTICA_DATABASE_NAME >> $VERTICA_LOCAL_PATH/.env

  # Create dbt config
  if [ -e $DBT_LOCAL_PATH/.env ]; then
      sudo rm $DBT_LOCAL_PATH/.env
  fi
  sudo touch $DBT_LOCAL_PATH/.env

  echo "DBT_USER="${DBT_USER:-dbt_user} >> $DBT_LOCAL_PATH/.env
  echo "DBT_PROFILES_DIR="${DBT_PROFILES_DIR:-/home/$DBT_USER/.dbt} >> $DBT_LOCAL_PATH/.env

  # Create dbt profile
  if [ -e ./dbt/crimes_in_boston/profiles.yml ]; then
      sudo rm ./dbt/crimes_in_boston/profiles.yml
  fi
  sudo touch ./dbt/crimes_in_boston/profiles.yml

  echo "crimes_in_boston_vertica:" >> ./dbt/crimes_in_boston/profiles.yml
  echo "  outputs:" >> ./dbt/crimes_in_boston/profiles.yml
  echo "    dev:" >> ./dbt/crimes_in_boston/profiles.yml
  echo "      type: vertica" >> ./dbt/crimes_in_boston/profiles.yml
  echo "      host: vertica" >> ./dbt/crimes_in_boston/profiles.yml
  echo "      port: 5433" >> ./dbt/crimes_in_boston/profiles.yml
  echo "      username: "$VERTICA_DBA_USER >> ./dbt/crimes_in_boston/profiles.yml
  echo "      password: "$VERTICA_DBA_PASSWORD >> ./dbt/crimes_in_boston/profiles.yml
  echo "      database: "$VERTICA_DATABASE_NAME >> ./dbt/crimes_in_boston/profiles.yml
  echo "      schema: dbt" >> ./dbt/crimes_in_boston/profiles.yml
  echo "  target: dev" >> ./dbt/crimes_in_boston/profiles.yml
}

unpack_seeds() {
  # tar bz2
  tar -C $DBT_LOCAL_PATH/crimes_in_boston/data/seeds \
    -xvjf $DBT_LOCAL_PATH/crimes_in_boston/pack/crimes-in-boston.tar.bz2
}

create_network
create_directories
create_configs
unpack_seeds

# Set environment variables from vertica .env file
export $(cat $VERTICA_LOCAL_PATH/.env | egrep -v "(^#.*|^$)" | xargs)

docker build -t radchenkoam/vertica \
  --build-arg VERTICA_PACKAGE \
  --build-arg VERTICA_DATA \
  --build-arg VERTICA_DBA_USER \
  --build-arg VERTICA_DBA_PASSWORD \
  --build-arg VERTICA_DATABASE_NAME \
  --network dbt-net $VERTICA_LOCAL_PATH

# Set environment variables from dbt .env file
export $(cat $DBT_LOCAL_PATH/.env | egrep -v "(^#.*|^$)" | xargs)

docker build -t radchenkoam/dbt \
  --build-arg DBT_USER \
  --build-arg DBT_PROFILES_DIR \
  --network dbt-net $DBT_LOCAL_PATH
