#!/bin/bash
do_arch_check_install_docker() {

  sudo pacman-key --init
  sudo pacman -Syu --noconfirm

  # Add user to docker group
  sudo groupadd docker
  sudo usermod -aG docker ${USER}
  mkdir -p $HOME/.docker || echo "FATAL failed to create the ~/.docker dir !!!"
  sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
  sudo chmod g+rwx "$HOME/.docker" -R

  # install docker
  sudo pacman --noconfirm -S lib32-glibc
  sudo pacman --noconfirm -S docker

  # Show service status.
  sudo systemctl status --no-pager --full docker
  systemctl enable docker

  sudo reboot

  #this should be manually done after restart
  sudo chmod 0777 /var/run/docker.sock
  #   # Install dependencies.
  #   sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
  #
  #
  #   echo uninstall old packages - this will probably fail as there might not be any ...
  #   sudo apt-get remove docker docker-engine docker.io containerd runc
  #
  #   # Add docker GPG key.
  #   sudo mkdir -p /etc/apt/keyrings
  #   #curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  #   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  #
  #   # Install docker.
  #   echo \
  #   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  #     $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  #
  #
  #curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  #echo \
  #  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  #  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  #sudo apt-get update
  #sudo apt-get --assume-yes install docker-ce docker-ce-cli containerd.io docker-compose-plugin
  #
  #
  #
  #
  #   # Show service status.
  #   sudo systemctl status --no-pager --full docker
  #
  #   # Add user to docker group
  #   sudo groupadd docker
  #   sudo usermod -aG docker ${USER}
  #   sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
  #   sudo chmod g+rwx "$HOME/.docker" -R
  #   sudo chmod 777 /var/run/docker.sock
  #
  #   # Test docker with hello-world image.
  #   sudo docker run --rm hello-world
  #   sleep 2
  #   sudo docker rmi hello-world
  #
  #   # Install docker-compose for current os.
  #   sudo curl -L "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  #   sudo chmod +x /usr/local/bin/docker-compose
  #
  #   # Install docker-machine.
  #   curl -L https://github.com/docker/machine/releases/download/v0.16.2/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine
  #   chmod +x /tmp/docker-machine
  #   sudo mv /tmp/docker-machine /usr/local/bin/docker-machine
  #
  #   # Validate docker-compose installation.
  #   docker-compose --version
  #   sleep 2
  #
  #   export EXIT_CODE=0
  #}
  #
  #
}
