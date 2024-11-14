#!/bin/bash
# This script is designed to fully uninstall and then reinstall Docker on Debian systems.
# Reference: Docker Official Installation Guide for Debian

do_debian_check_install_docker() {

  do_log "INFO Adding current user to the Docker group..."
  sudo groupadd docker 2>/dev/null
  sudo usermod -aG docker ${USER}

  do_log "INFO Correct Docker socket permissions"
  sudo chown root:docker /var/run/docker.sock
  sudo chmod 0770 /var/run/docker.sock

  do_log "INFO Setting permissions for Docker socket..."
  sudo chown "$USER":"$USER" /home/"$USER"/.docker -R 2>/dev/null
  sudo chmod g+rwx "$HOME/.docker" -R
  sudo chmod 777 /var/run/docker.sock

  do_log "INFO kill & rm containers, rm images, clear lib/docker"
  docker rm $(docker ps -aq)
  docker image prune -a -f
  docker builder prune -f -a
  docker volume rm $(docker volume ls -q)
  docker system prune --volumes -f
  sudo rm -rf /var/lib/docker/*

  do_log "INFO Removing any existing Docker installations..."
  sudo apt-get -y purge docker-ce docker-ce-cli containerd.io docker-compose-plugin
  sudo rm -rf /var/lib/docker /etc/docker
  sudo rm /etc/apparmor.d/docker 2>/dev/null
  sudo groupdel docker 2>/dev/null
  sudo rm -rf /var/run/docker.sock

  do_log "INFO Installing dependencies..."
  sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

  do_log "INFO Cleaning up old Docker sources..."
  sudo apt-get remove -y docker docker-engine docker.io containerd runc

  do_log "INFO Adding Docker's official GPG key..."
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg

  do_log "INFO Setting up the stable Docker repository..."
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

  do_log "INFO Updating apt and installing Docker..."
  sudo apt update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

  # Define the content of the JSON file
  json_content='{
    "dns": ["8.8.8.8", "8.8.4.4"]
  }'

  # Create the file and write the content to it
  echo "$json_content" | sudo tee "/etc/docker/daemon.json" >/dev/null

  # Restart the Docker service to apply the changes
  sudo systemctl restart docker

  do_log "INFO Restarting Docker service..."
  sudo systemctl restart docker

  do_log "INFO Adding current user to the Docker group..."
  sudo groupadd docker 2>/dev/null
  sudo usermod -aG docker ${USER}

  do_log "INFO Correct Docker socket permissions"
  sudo chown root:docker /var/run/docker.sock
  sudo chmod 0770 /var/run/docker.sock

  do_log "INFO Setting permissions for Docker socket..."
  sudo chown "$USER":"$USER" /home/"$USER"/.docker -R 2>/dev/null
  sudo chmod g+rwx "$HOME/.docker" -R
  sudo chmod 777 /var/run/docker.sock

  do_log "INFO Reloading shell to apply group membership changes..."
  exec sg docker newgrp $(id -gn)

  do_log "INFO enable swam mode, to enable secrets"
  docker swarm init

  if ! docker info 2>/dev/null | grep -q 'Swarm: active'; then
    docker swarm init
  else
    do_log "INFO Swarm already initialized."
  fi
  if [ $? -ne 0 ]; then
    do_log "FATAL Failed to initialize Docker Swarm."
    exit 1
  fi
  do_log "INFO Checking Docker service status..."
  sudo systemctl status --no-pager --full docker

  do_log "INFO Testing Docker installation with hello-world image..."
  sudo docker run --rm hello-world
  sudo docker rmi hello-world

  do_log "INFO Installing docker-compose..."
  sudo curl -L "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose

  do_log "INFO Installing docker-machine..."
  curl -L https://github.com/docker/machine/releases/download/v0.16.2/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine
  chmod +x /tmp/docker-machine
  sudo mv /tmp/docker-machine /usr/local/bin/docker-machine

  do_log "INFO Validating docker-compose installation..."
  docker-compose --version
  if [ $? -eq 0 ]; then
    do_log "INFO Docker Compose installed successfully."
  else
    do_log "INFO Docker Compose installation failed."
    exit 1
  fi

  do_log "INFO Docker installation completed successfully."
  export EXIT_CODE="0"
}
