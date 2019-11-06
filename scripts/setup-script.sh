#!/bin/bash

# HLF Fabric Pre-requisites setup script
# Tested for Ubuntu 18.04 
# Installs fabric-samples as well

NODE_VERSION=v8.16.2
NODE_DIST_NAME=node-$NODE_VERSION-linux-x64
NODE_DOWNLOAD_URL=https://nodejs.org/download/release/latest-v8.x/$NODE_DIST_NAME.tar.gz

GOLANG_VERSION=go1.12.13
GOLANG_DIST_NAME=$GOLANG_VERSION.linux-amd64.tar.gz
GOLANG_DOWNLOAD_URL=https://dl.google.com/go/$GOLANG_DIST_NAME
GOPATH=~/go

begin_setup() {
	SAVED_MSG=$1
	echo -e "\e[93m$1\e[0m"
	set -x
}

end_setup() {
	set +x
	if [[ -z "$1" || -z "$2" ]]; then
		echo -e "\e[32mSUCESS\e[0m"  $SAVED_MSG
		return 0
	fi

	if [ "$1" == "$2" ]; then
  		echo -e "\e[32mSUCESS\e[0m"  $SAVED_MSG
	else
  		echo -e "\e[31mFAILED\e[0m"  $SAVED_MSG
		exit 1
	fi
}

# Setup NodeJS
begin_setup 'Installing NodeJS'
wget $NODE_DOWNLOAD_URL
sudo tar -C /usr/local -xzf $NODE_DIST_NAME.tar.gz
echo "PATH=\$PATH:/usr/local/$NODE_DIST_NAME/bin" >> ~/.profile
end_setup "$(/usr/local/$NODE_DIST_NAME/bin -v)" "$NODE_VERSION"

# Setup Docker
begin_setup 'Setting up Docker'
sudo apt-get remove docker docker-engine docker.io containerd runc && \
sudo apt-get update && \
sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common && \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && \
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
sudo apt-get update && \
sudo apt-get -y install docker-ce docker-ce-cli containerd.io && \
sudo usermod -aG docker $USER

sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" \
		  -o /usr/local/bin/docker-compose
sudo chmod a+x /usr/local/bin/docker-compose
end_setup

# Setup python
begin_setup "Setting up python"
sudo apt-get -y install python
end_setup

# Setup golang
begin_setup 'Setting up golang'
wget $GOLANG_DOWNLOAD_URL
sudo tar -C /usr/local -xzf $GOLANG_DIST_NAME
mv $GOLANG_DIST_NAME $_DIR
mkdir -p $GOPATH/src $GOPATH/bin
echo "GOPATH=$GOPATH" >> ~/.profile
echo "PATH=\$PATH:/usr/local/go/bin:$GOPATH/bin" >> ~/.profile
end_setup "$(/usr/local/go/bin/go version)" "go version $GOLANG_VERSION linux/amd64"

#Setup samples
begin_setup 'Setting up fabric-samples'
mkdir -p $GOPATH/src/github.com/hyperledger/ && \
cd $GOPATH/src/github.com/hyperledger/ && \
git clone https://github.com/hyperledger/fabric-samples.git && \
end_setup

#Setup misc if not already present
sudo apt-get -y install make g++

echo -e "\e[93mLogout and login back in for all changes to load\e[0m"