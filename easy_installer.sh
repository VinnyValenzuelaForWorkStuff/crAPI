#!/bin/bash

STORE_CREDENTIALS(){
	echo "Please enter your credentials for sudo"
	echo "This will be removed once complete"
	echo -n Password:
	read -s PASSWORD
	echo $PASSWORD > ~/.password
	chmod 400 ~/.password
}

RUN_AS() {
	cat ~/.password | sudo -s 
}
UPDATE() {
		cat ~/.password | sudo -s apt update -y
}
INSTALL_REQUIREMENTS() {
		cat ~/.password | sudo -s  apt-get install -y \
		ca-certificates \
		curl \
		gnupg \
		lsb-release \
		sed \
		socat
}
ADD_DOCKER_REPO() {
	curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	
	echo \
	  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
	  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
}
CORRECT_REPO() {
	sed 's+deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian   bionic stable+deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu   bionic stable+g'
}
INSTALL_DOCKER() {
	cat ~/.password | sudo -s  apt update -y
	cat ~/.password | sudo -s  apt install \
	docker-ce \
	docker-ce-cli \
	containerd.io \
	docker-compose-plugin
	cat ~/.password | sudo -s  curl -SL https://github.com/docker/compose/releases/download/v2.4.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
	cat ~/.password | sudo -s  chmod +x /usr/local/bin/docker-compose
	cat ~/.password | sudo -s  /usr/local/bin/docker-compose
}
START_DOCKER_ON_BOOT() {
	cat ~/.password | sudo -s  systemctl start docker
	cat ~/.password | sudo -s  systemctl enable docker.service
	cat ~/.password | sudo -s  systemctl enable containerd.service
}
BUILD_CRAPI() {
	git clone https://github.com/VinnyValenzuelaForWorkStuff/crAPI.git
	cd crAPI
	cat ~/.password | sudo -s  deploy/docker/build-all.sh
}
SETUP_CRONJOB() {
	sudo su -
	crontab -l > mycron
	echo "@reboot socat tcp-listen:80,reuseaddr,fork tcp:localhost:8888 &" >> mycron
	echo "@reboot socat tcp-listen:18025,reuseaddr,fork tcp:localhost:8025 &" >> mycron
	echo "@reboot /usr/local/bin/start_crapi" >> mycron
	crontab mycron
}

UPDATE
INSTALL_REQUIREMENTS
ADD_DOCKER_REPO
CORRECT_REPO
INSTALL_DOCKER
START_DOCKER_ON_BOOT
BUILD_CRAPI
SETUP_CRONJOB
