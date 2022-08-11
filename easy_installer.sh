#!/bin/bash

STORE_CREDENTIALS(){
	echo "---REQUESTING CREDENTIALS---"
	echo -n Password:
	read -s PASSWORD
	echo $PASSWORD > ~/.password
	chmod 400 ~/.password
}
CLEANUP(){
	echo "---CLEANING UP---"
	rm -f ~/.password
}
RUN_AS() {
	cat ~/.password | sudo -s 
}
UPDATE() {
	echo  "---UPDATING---"
	cat ~/.password | sudo -s apt update -y
}
INSTALL_REQUIREMENTS() {
	echo "---INSTALLING REQUIREMENTS---"
	cat ~/.password | sudo -s apt-get install -y \
	ca-certificates \
	curl \
	gnupg \
	lsb-release \
	sed \
	socat
}
ADD_DOCKER_REPO() {
	echo "---ADDING DOCKER REPO---"
	curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	echo \
	  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
	  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
}
CORRECT_REPO() {
	echo "---CORRECTING ARCH BUG---"
	cat ~/.password | sudo -s sed -i 's/debian/ubuntu/g' /etc/apt/sources.list.d/docker.list
}
INSTALL_DOCKER() {
	echo "---INSTALLING DOCKER---"
	cat ~/.password | sudo -s apt update -y
	cat ~/.password | sudo -s apt install -y \
	docker-ce \
	docker-ce-cli \
	containerd.io \
	docker-compose-plugin
	cat ~/.password | sudo -s curl -SL https://github.com/docker/compose/releases/download/v2.4.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
	cat ~/.password | sudo -s chmod +x /usr/local/bin/docker-compose
	cat ~/.password | sudo -s /usr/local/bin/docker-compose
}
START_DOCKER_ON_BOOT() {
	echo "---SETTING DOCKER TO START ON BOOT---"
	cat ~/.password | sudo -s systemctl start docker
	cat ~/.password | sudo -s systemctl enable docker.service
	cat ~/.password | sudo -s systemctl enable containerd.service
}
BUILD_CRAPI() {
	echo "---BUILDING CONTAINERS---"
	cat ~/.password | sudo -s deploy/docker/build-all.sh
}
CRAPI_SCRIPT(){
	echo "---CREATING  STARUP SCRIPT---"
	REPLACEMENT=pwd
	sed -i "s/REPLACE/$REPLACEMENT/g" parked
	cat ~/.password | sudo -s mv parked /usr/local/bin/start_crapi
	cat ~/.password | sudo -s chmod  a+x /usr/local/bin/start_crapi
}
SETUP_CRONJOB() {
	echo "---UPDATING CRON---"
	sudo su -
	crontab -l > mycron
	echo "@reboot socat tcp-listen:80,reuseaddr,fork tcp:localhost:8888 &" >> mycron
	echo "@reboot socat tcp-listen:18025,reuseaddr,fork tcp:localhost:8025 &" >> mycron
	echo "@reboot /usr/local/bin/start_crapi" >> mycron
	crontab mycron
}
REBOOT() {
	echo "---SCHEDULING REBOOT---"
	shutdown -r +3
}

STORE_CREDENTIALS
UPDATE
INSTALL_REQUIREMENTS
ADD_DOCKER_REPO
CORRECT_REPO
INSTALL_DOCKER
START_DOCKER_ON_BOOT
BUILD_CRAPI
CRAPI_SCRIPT
CLEANUP
REBOOT
SETUP_CRONJOB
