# Setting up Adminer with SSH Port Forwarding

This guide provides steps for setting up Adminer with SSH port forwarding using Docker and Makefile targets.

## SSH Port Forwarding Command

Use the following command to set up SSH port forwarding:

```bash

ssh -o IdentitiesOnly=yes -i ~/.ssh/.str/ilm-opa-dev-wpb.pk -L 0.0.0.0:9091:localhost:3306 -N -v debian@csi.wpb.dev.ilmatarbrain.com

```

## Docker Compose Configuration

Here is the Docker Compose configuration for the Adminer service:

```yaml
version: "3.9"

services:
  db-adminer:
    image: adminer
    container_name: ${ADM_CONTAINER}
    environment:
      ADMINER_DESIGN: "pepa-linha"
      PS1: ' \u@\h on \w\n\n  '
    volumes:
      - "${APP_PATH}:${APP_PATH}"
    network_mode: host

```

## Makefile Targets

The following Makefile targets are used for setting up and managing the Adminer service:

### Attach to Containers

```make
.PHONY: do-echo-attach-exec-adminer
do-echo-attach-exec-adminer:
	@echo to attach to the containers do:
	@echo docker exec -it foobar-1 /bin/bash
```

### Setup Adminer

```make
.PHONY: do-setup-adminer
do-setup-adminer: demand_var-GITHUB_TOKEN
	@export DOCKER_BUILDKIT=1; ${DOCKER_COMPOSE_CMD} -f ${DOCKER_COMPOSE_ADMINER} down --rmi all \
	&& ${DOCKER_COMPOSE_CMD} -f ${DOCKER_COMPOSE_ADMINER} --verbose build \
	&& ${DOCKER_COMPOSE_CMD} -f ${DOCKER_COMPOSE_ADMINER} --verbose up -d
	@$(MAKE) do-echo-attach-exec-adminer
```

### Setup Adminer without Cache

```make
.PHONY: do-setup-adminer-no-cache
do-setup-adminer-no-cache: demand_var-GITHUB_TOKEN
	@export DOCKER_BUILDKIT=1; ${DOCKER_COMPOSE_CMD} -f ${DOCKER_COMPOSE_ADMINER} down --rmi all \
	&& ${DOCKER_COMPOSE_CMD} -f ${DOCKER_COMPOSE_ADMINER} --verbose build --no-cache \
	&& ${DOCKER_COMPOSE_CMD} -f ${DOCKER_COMPOSE_ADMINER} --verbose up -d
	@$(MAKE) do-echo-attach-exec-adminer
```
## ATTACH TO CONTAINER 
Install the net-tools, and run the infconfig -a cmd
```sh
docker  exec -u root -it con-adminer /bin/bash -c "apt update && apt install -y net-tools && ifconfig -a"

# cp the inet ip
# 
#wlo1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
#       inet 10.110.51.27  netmask 255.255.254.0  broadcast 10.110.51.255
# aka
# 10.110.51.27
```


## MySQL Configuration
Go to the serverr
```sh
ssh -o IdentitiesOnly=yes -i ~/.ssh/.str/csi-skk-dev-skk.pk debian@csi.skk.dev.gcp.suomalainenkirjoituskilpailu.fi

```

Ensure MySQL accepts connections on all network interfaces:

```ini
[mysqld]
bind-address = 0.0.0.0
```

Use the ip, which is retrieved from the ifconfig -a cmd in the container.

```sql
GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wordpress'@'192.168.10.62' IDENTIFIED BY 'secret';

```

from the host
```
ssh -o IdentitiesOnly=yes -i ~/.ssh/.str/csi-skk-dev-skk.pk debian@csi.skk.dev.gcp.suomalainenkirjoituskilpailu.fi /bin/bach -c "mysql GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wordpress'@'192.168.10.62' IDENTIFIED BY 'secret';"


## SSH Configuration

Configure SSH to allow port forwarding and gateway ports:

```bash
GatewayPorts yes
AllowTcpForwarding yes
```

**Note:** The `do-echo-attach-exec-adminer` target is used to attach to the containers after setup. The `do-setup-adminer` and `do-setup-adminer-no-cache` targets are used to set up the Adminer service.


## Access the db adminer 

- system : MYSQL
- server: 127.0.0.1:9091 ( note the port is the same as the -L in the port forward)
- username: wordpress
- Password: secret
