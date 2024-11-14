#!/bin/bash
# referece from: https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04
do_ubuntu_check_install_docker() {

  # Install dependencies.
  sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

  echo uninstall old packages - this will probably fail as there might not be any ...
  sudo apt-get remove docker docker-engine docker.io containerd runc

  # Add docker GPG key.
  test -f /etc/apt/keyrings/docker.gpg && sudo rm -fr /etc/apt/keyrings/docker.gpg
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --yes --dearmor -o /etc/apt/keyrings/docker.gpg

  # Install docker.
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

  sudo apt update
  apt-cache policy docker-ce
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

  # Show service status.
  sudo systemctl status --no-pager --full docker

  # Add user to docker group
  sudo groupadd docker
  sudo usermod -aG docker ${USER}
  sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
  sudo chmod g+rwx "$HOME/.docker" -R
  sudo chmod 777 /var/run/docker.sock

  # Test docker with hello-world image.
  sudo docker run --rm hello-world
  sleep 2
  sudo docker rmi hello-world

  # Install docker-compose for current os.
  sudo curl -L "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose

  # Install docker-machine.
  curl -L https://github.com/docker/machine/releases/download/v0.16.2/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine
  chmod +x /tmp/docker-machine
  sudo mv /tmp/docker-machine /usr/local/bin/docker-machine

  # Validate docker-compose installation.
  docker-compose --version
  sleep 2

  export EXIT_CODE=0
}
