FROM --platform=amd64 python:slim-bookworm

# START ::: vars
ARG GID
ARG UID
ARG ORG_DIR
ARG UTL_PROJ_PATH
ARG APPUSR
ARG APPGRP
ARG DOCKER_HOME
ARG APP_PATH
ARG TF_VERSION
ARG TF_SWITCH_VERSION

ARG TPG_PROJ_PATH
ARG UTL_PROJ_PATH
ARG INF_PROJ_PATH
ARG CNF_PROJ_PATH
ARG HOME_UTL_PROJ_PATH
ARG HOME_CNF_PROJ_PATH
ARG HOME_INF_PROJ_PATH
ARG HOME_TPG_PROJ_PATH

ENV UTL_PROJ_PATH=$UTL_PROJ_PATH
ENV TPG_PROJ_PATH=$TPG_PROJ_PATH
ENV CNF_PROJ_PATH=$CNF_PROJ_PATH
ENV INF_PROJ_PATH=$INF_PROJ_PATH
ENV HOME_UTL_PROJ_PATH=$HOME_UTL_PROJ_PATH
ENV HOME_TPG_PROJ_PATH=$HOME_TPG_PROJ_PATH
ENV HOME_CNF_PROJ_PATH=$HOME_CNF_PROJ_PATH
ENV HOME_INF_PROJ_PATH=$HOME_INF_PROJ_PATH

ENV PROJ_PATH=$INF_PROJ_PATH
ENV HOME_PROJ_PATH=$HOME_INF_PROJ_PATH

ENV MODULE='tf-runner'
ENV BASE_PATH=$BASE_PATH
ENV ORG=$ORG
ENV ORG_DIR=$ORG_DIR

ENV EDITOR="vim"
ENV APPUSR=$APPUSR
ENV APPGRP=$APPGRP
ENV PS1='`date "+%F %T"` \u@\h  \w \n\n  '
ENV HOME_UTL_PROJ_PATH=$HOME_UTL_PROJ_PATH

ENV DOCKER_HOME=$DOCKER_HOME
ENV HOME_APP_PATH=/home/$APPUSR/$APP_PATH
ENV TF_VERSION=$TF_VERSION
ENV TF_SWITCH_VERSION=$TF_SWITCH_VERSION
# STOP  ::: vars

# START ::: install OS utils
RUN apt-get update && apt-get install -y --no-install-recommends  \
  perl jq vim wget curl sudo zip unzip make bsdmainutils tzdata git openssh-server openssh-client rsync dnsutils keepassxc
# STOP  ::: install  OS utils

# START ::: install alpine OS utils

RUN apt-get update && apt-get install -y --no-install-recommends  \
  apt-utils perl-base jq vim wget curl sudo zip unzip make bsdmainutils tzdata \
  git openssh-server ansible gnupg
# STOP  ::: install alpine OS utils

# # START ::: install yq
RUN sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
  && sudo chmod a+x /usr/local/bin/yq
# STOP  ::: install yq


# # START ::: python build utils
# RUN RUN apt-get update && apt-get install -y  \
#     build-base gcc openssl-dev python3-dev libmagic  \
#     python3-dev jpeg-dev zlib-dev coreutils libffi-dev util-linux

# # STOP  ::: python build utils


# START ::: install aws cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
  && unzip awscliv2.zip \
  && sudo ./aws/install \
  && rm -rf ./aws awscliv2.zip
# STOP  ::: install aws cli

# START ::: install gcloud cli
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN sudo apt-get update && sudo apt-get install -y google-cloud-cli
# STOP ::: install gcloud cli

# START ::: install terraform and tfswitch
# install tfswitch to handle multiple terraform versions
# RUN set -eux; \
#   curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh | bash

# RUN curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh -o /opt/install.sh
# RUN chmod 777 /opt/install.sh
# RUN /opt/install.sh | bash
# RUN rm -v /opt/install.sh

# Download and install terraform-switcher
RUN curl -L "https://github.com/warrensbox/terraform-switcher/releases/download/$TF_SWITCH_VERSION/terraform-switcher_${TF_SWITCH_VERSION}_linux_amd64.tar.gz" -o tfswitch.tar.gz \
  && tar -xzf tfswitch.tar.gz -C /usr/local/bin \
  && rm tfswitch.tar.gz

# Verify the installation
RUN tfswitch --version

# RUN curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/0.13.1308/install.sh | bash
# STOP  ::: install terraform and tfswitch

# START ::: Enable host to container edit of proj code on ubuntu and mac.
RUN test -z $(getent group $GID | cut -d: -f1) || \
  groupmod -g $((GID+1000)) $(getent group $GID | cut -d: -f1)

# isntall python pip
RUN wget https://bootstrap.pypa.io/get-pip.py ; sudo python3 get-pip.py ; sudo rm -v get-pip.py

RUN pip3 install --upgrade pip wheel



# START ::: add-os-user

# START ::: Enable host to container edit of proj code on ubuntu and mac.
RUN test -z $(getent group $GID | cut -d: -f1) || \
  groupmod -g $((GID+1000)) $(getent group $GID | cut -d: -f1)
RUN if getent group $GID; then groupmod -g $((GID+2000)) $(getent group $GID | cut -d: -f1); fi

# create a APPGRP and APPUSR
# START ::: add-os-user
RUN set -x ; groupadd -g "$GID" "$APPGRP" && \
  useradd \
  --gid "$GID" \
  --non-unique \
  --shell "$DOCKER_SHELL" \
  --home-dir "${DOCKER_HOME}" \
  --uid "$UID" \
  --groups "$APPGRP" "$APPUSR" && exit 0 ; exit 1

# create home directory and change its ownership to APPUSR:APPGRP
RUN mkdir -p "/home/$APPUSR" && chown "$APPUSR":"$APPGRP" "/home/$APPUSR"


RUN echo "$APPUSR ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN echo "export PS1=\"$PS1\"" >> $DOCKER_HOME/.bashrc && \
  echo "export EDITOR=\"$EDITOR\"" >> $DOCKER_HOME/.bashrc && \
  echo "cd ${INF_PROJ_PATH}" >> $DOCKER_HOME/.bashrc && \
  echo "export PATH=$DOCKER_HOME/bin:\$PATH" >>$DOCKER_HOME/.bashrc && \
  chown -R $APPUSR:$APPGRP $DOCKER_HOME && \
  chmod -R 0775 $DOCKER_HOME

# START ::: copy-proj-dir
COPY --chown=$APPUSR:$APPGRP . ${HOME_APP_PATH}
# STOP  ::: copy-proj-dir

# set the default shell as bash and not sh
SHELL ["/bin/bash", "-c"]


USER $APPUSR

# STOP  ::: add-os-user

#install anbible plugin
RUN ansible-galaxy collection install cloud.terraform


# START ::: copy-proj-dir


# Create the 'run' symlink
WORKDIR $HOME_PROJ_PATH
RUN ln -sfn src/bash/run/run.sh run


# STOP  ::: copy-proj-dir



# Workdir is /opt/$org/$product/
WORKDIR $PROJ_PATH
ENV PATH=/home/$APPUSR/bin:$PATH
