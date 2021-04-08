#!/bin/sh
# This script install docker-ce
set -eu

# Check docker-version
# export DOCKER_LOCAL_VERSION=`docker version --format '{{.Server.Version}}'`

# Old version remove
sudo apt-get -qqy remove docker docker-engine docker.io containerd runc
sudo add-apt-repository -r "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt-get -qqy install \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release

if [ ! -f /usr/share/keyrings/docker-archive-keyring.gpg ]; then
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
fi

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get -qqy update && sudo apt-get -qqy install docker-ce docker-ce-cli containerd.io

# Allow current user to run Docker commands
sudo usermod -aG docker $USER
