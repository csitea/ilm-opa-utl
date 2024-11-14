# ilm-opa-local-dev-setup

## PREREQUISTES

### Directory Structure

You MUST have the following relative directory structure:

```sh
# this could be also ~/opt or any dir your OS usr has rwx
BASE_PATH=/opt;
ORG=ilm
APPLICATION=ilm-opa

find $BASE_PATH/$ORG/$APPLICATION -maxdepth 1|sort

# the APPLICTION_PATH
/opt/str/ilm-opa

# the configuration project for the ilm-opa application
/opt/str/ilm-opa/ilm-opa-cnf

# the infrastucture project
/opt/str/ilm-opa/ilm-opa-inf

# the utils project - where the local dev env utilities residue
/opt/str/ilm-opa/ilm-opa-utl

# the web ui project - the web ui src
/opt/str/ilm-opa/ilm-opa-wui

# the GLOBAL csi infra-core
/opt/str/ilm-opa/infra-core

# the GLOBAL template generator project
/opt/str/ilm-opa/tpl-gen
```

Of course your BASE_PATH COULD be ( but probably shouldn't ) also anything like /var, ~/opt , ~/var etc...
You MUST have docker and make natively, docker MUST be able to share as volume your `<<BASE_PATH>>/<<ORG>>/<<APPLICATION>>`.

### BINARIES

You must have `make`, `bash` and `docker` on your host.

### OS user permissions

Your host OS user MUST have full ownership of the `<<BASE_PATH>>` dir on your host - if it does not, or you are not sure, use the `~/opt` dir.

### UID & GID

If those are not set volume sharing between the host and the containers WILL NOT WORK. You have been warned. This is not an opinion, this IS how docker works by design.

```sh
# Export UID and GID and set them in the current shell session
export UID=$(id -u) ; export GID=$(id -g);

# Permanently set UID and GID in .bashrc or .bash_profile
# Append them if they are not yet set
grep -q 'export UID=$(id -u)' ~/.bashrc || echo 'export UID=$(id -u)' >> ~/.bashrc ;
grep -q 'export GID=$(id -g)' ~/.bashrc || echo 'export GID=$(id -g)' >> ~/.bashrc ;
grep -q 'export DOCKER_BUILDKIT=1' ~/.bashrc || echo 'export DOCKER_BUILDKIT=1' >> ~/.bashrc
source ~/.bashrc ; # apply changes immediately

```

### Docker daemon permissions for volumes

On mac and Windows in the UI ensure that the docker daemon does have full capability to map volumes under the `<<BASE_PATH>>`

### YOU MUST enable DockerBuildKit as well

https://docs.docker.com/build/buildkit/#getting-started

#### On Linux

```sh
  sudo cat /etc/docker/daemon.json
{ "features": { "buildkit": true } }
```

## USAGE & HELP

type `make` in the project's root dir:

```sh
make
```

## SETUP

```sh
# build all the docker images and kick-in containers
export GITHUB_TOKEN="<<your-personal-gitlab-token-here>>"
make do-setup-ilm-opa-all

```

If you cannot, something is wrong, inspect the docker compose logs

## BUILD

Build in this context means "syntax check, autoformat and build ( if applicable)"


## CONFIGURATION GENERATION

```bash
# override if needed 
# SRC=/opt/str/ilm-opa/ilm-opa-cnf/ TGT=/opt/str/ilm-opa/ilm-opa-cnf
export STEP=012-static-sites; ORG=ilm APP=opa ENV=dev TPL_SRC=/opt/str/ilm-opa/ilm-opa-inf  make do-generate-config-for-step

```

## PROVISION & DIVEST 

```bash
export STEP=012-static-sites; ORG=ilm APP=opa ENV=dev make do-provision
ORG=ilm APP=opa ENV=dev STEP=008-csi-gcp-aws-subzone make do-divest
```



### Post-Setup

After executing the setup command, verify if the following 3 containers are running:

```plaintext
CONTAINER ID   IMAGE                          COMMAND                  CREATED          STATUS                    PORTS                            NAMES
e194b2f12550   wpp-dev-wpp                    "/bin/bash -c 'exec …"   10 minutes ago   Up 10 minutes             8080/tcp, 0.0.0.0:8080->80/tcp   docker-wpp-1
5339f6fe542e   phpmyadmin/phpmyadmin:latest   "/docker-entrypoint.…"   10 minutes ago   Up 10 minutes             0.0.0.0:8000->80/tcp             docker-phpmyadmin-1
f008d89d5e62   maria-db                       "docker-entrypoint.s…"   10 minutes ago   Up 10 minutes (healthy)   0.0.0.0:3306->3306/tcp           docker-db-1
```

### Accessing the Applications

- **PHP Admin:** [http://localhost:8000](http://localhost:8000)
- **WordPress:** [http://localhost:8080](http://localhost:8080)

## Prerequisites

- **Docker:** Must be installed and able to share `<<BASE_PATH>>` as a volume.
- **Make:** Must be installed natively on your system.

Simply run `make` to start the setup.

## REPLICATION AND PROPAGATION FROM AND TO BASE PROJECT 

to replicate 
```bash
SRC_PATH=/opt/str/ilm-opa/ilm-opa-utl/src/bash/ bash /opt/str/ilm-opa/ilm-opa-utl/run -a do_replicate_dir_to_bas
SRC_PATH=/opt/str/ilm-opa/ilm-opa-wui/.github/ bash /opt/str/ilm-opa/ilm-opa-utl/run -a do_replicate_dir_to_bas
SRC_PATH=/opt/str/ilm-opa/ilm-opa-utl/src/bash/run/run.sh bash /opt/str/ilm-opa/ilm-opa-utl/run -a do_replicate_file_to_bas
```

```bash
TGT_PATH=/opt/str/ilm-opa/ilm-opa-utl/src/bash/run bash /opt/str/ilm-opa/ilm-opa-utl/run -a do_replicate_dir_from_bas
TGT_PATH=/opt/str/ilm-opa/ilm-opa-utl/src/bash/run/run.sh bash /opt/str/ilm-opa/ilm-opa-utl/run -a do_replicate_file_from_bas
```

```bash
SRC_PATH=/opt/str/ilm-opa/ilm-opa-utl/src/bash/run bash /opt/str/ilm-opa/ilm-opa-utl/run -a do_broadcast_dir_from_bas
``` 
