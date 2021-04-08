#!/bin/sh
# This script install or upgrade docker-compose & bash_completion
set -eu

export COMPOSE_VERSION=`git ls-remote https://github.com/docker/compose | grep refs/tags | grep -oP "[0-9]+\.[0-9][0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1`
export COMPOSE_LOCAL_VERSION=`docker-compose version --short`

if [ $COMPOSE_VERSION != $COMPOSE_LOCAL_VERSION ]; then
  sudo curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
  sudo curl -L https://raw.githubusercontent.com/docker/compose/${COMPOSE_VERSION}/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
else
  echo "INFO: docker-compose ($COMPOSE_LOCAL_VERSION) -> no upgrade required"
fi
