#!/bin/sh
# This script setups dockerized Vertica on Ubuntu 18.04 & DBT.
set -eu

export VERTICA_PATH=./vertica
export COMPOSE_VERSION=`git ls-remote https://github.com/docker/compose | grep refs/tags | grep -oP "[0-9]+\.[0-9][0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1`
export LOCAL_COMPOSE_VERSION=`docker-compose --version | grep -oP "[0-9]+\.[0-9][0-9]+\.[0-9]+"`

install_docker() {
    # Install Docker
    export DEBIAN_FRONTEND=noninteractive
    sudo apt -qqy update
    # DEBIAN_FRONTEND=noninteractive
    sudo -E apt -qqy -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
    sudo apt -yy install apt-transport-https ca-certificates curl software-properties-common wget pwgen
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository -r "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update && sudo apt-get -y install docker-ce

    # Allow current user to run Docker commands
    sudo usermod -aG docker $USER

    # Install Docker Compose & bash_completion
    if [ $COMPOSE_VERSION != $LOCAL_COMPOSE_VERSION ]; then
      sudo curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
      sudo curl -L https://raw.githubusercontent.com/docker/compose/${COMPOSE_VERSION}/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
      sudo chmod +x /usr/local/bin/docker-compose
    fi
}

create_directories() {
    if [ ! -e $VERTICA_PATH/data ]; then
        sudo mkdir -p $VERTICA_PATH/data
        sudo chown $USER:$USER $VERTICA_PATH/data
    fi

    if [ ! -e $VERTICA_PATH/data ]; then
        mkdir $VERTICA_PATH/data
    fi
}

create_config() {
    if [ -e $VERTICA_PATH/.env ]; then
        sudo rm $VERTICA_PATH/.env
        sudo touch $VERTICA_PATH/.env
    fi

    # Set environment variables from .env ("$ export -p" -> check)
    export $(cat .env | egrep -v "(^#.*|^$)" | xargs)

    VERTICA_PACKAGE=$VERTICA_PKG
    VERTICA_DBA_USER=$DBA_USER
    VERTICA_DBA_PASSWORD=$(pwgen -1s 32)
    VERTICA_DATABASE_NAME=$DB_NAME

    echo "VERTICA_PACKAGE"=$VERTICA_PACKAGE >> ./vertica/.env
    echo "VERTICA_DBA_USER="$VERTICA_DBA_USER >> ./vertica/.env
    echo "VERTICA_DBA_PASSWORD="$VERTICA_DBA_PASSWORD >> ./vertica/.env
    echo "VERTICA_DATABASE_NAME"=$VERTICA_DATABASE_NAME >> ./vertica/.env
}

install_docker
create_directories
create_config

# Set environment variables from $VERTICA_PATH/.env ("$ export -p" -> check)
export $(cat $VERTICA_PATH/.env | egrep -v "(^#.*|^$)" | xargs)

docker build -t radchenkoam/vertica \
  --build-arg VERTICA_PACKAGE \
  --build-arg VERTICA_DBA_USER \
  --build-arg VERTICA_DBA_PASSWORD \
  --build-arg VERTICA_DATABASE_NAME $VERTICA_PATH

docker build -t radchenkoam/dbt-vertica ./dbt-vertica
