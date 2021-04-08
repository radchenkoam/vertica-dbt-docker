#!/bin/sh
# This script setups dockerized Vertica on Ubuntu 18.04 & DBT
set -eu

export VERTICA_LOCAL_PATH=./vertica

sudo -E apt -qqy -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
sudo apt-get -qqy update
sudo sh ./scripts/docker_install.sh
sudo sh ./scripts/docker_compose_install.sh
sudo apt-get -qqy install wget pwgen

create_directories() {
    if [ ! -e $VERTICA_LOCAL_PATH/data ]; then
        sudo mkdir -p $VERTICA_LOCAL_PATH/data
        sudo chown $USER:$USER $VERTICA_LOCAL_PATH/data
    fi
}

create_config() {
    if [ -e $VERTICA_LOCAL_PATH/.env ]; then
        sudo rm $VERTICA_LOCAL_PATH/.env
    fi
    sudo touch $VERTICA_LOCAL_PATH/.env

    # Set environment variables from .env
    export $(cat .env | egrep -v "(^#.*|^$)" | xargs)
    echo "VERTICA_PACKAGE"=$VERTICA_PACKAGE >> $VERTICA_LOCAL_PATH/.env
    echo "VERTICA_DATA"=$VERTICA_DATA >> $VERTICA_LOCAL_PATH/.env
    echo "VERTICA_DBA_USER="$VERTICA_DBA_USER >> $VERTICA_LOCAL_PATH/.env
    export VERTICA_DBA_PASSWORD=$(pwgen -1s 32)
    echo "VERTICA_DBA_PASSWORD="$VERTICA_DBA_PASSWORD >> $VERTICA_LOCAL_PATH/.env
    echo "VERTICA_DATABASE_NAME"=$VERTICA_DATABASE_NAME >> $VERTICA_LOCAL_PATH/.env
}

# create_directories
# create_config

# Set environment variables from .env file
# export $(cat $VERTICA_LOCAL_PATH/.env | egrep -v "(^#.*|^$)" | xargs)
#
# docker build -t radchenkoam/vertica \
#   --build-arg VERTICA_PACKAGE \
#   --build-arg VERTICA_DATA \
#   --build-arg VERTICA_DBA_USER \
#   --build-arg VERTICA_DBA_PASSWORD \
#   --build-arg VERTICA_DATABASE_NAME $VERTICA_LOCAL_PATH

# docker build -t radchenkoam/dbt-vertica ./dbt-vertica
