FROM python:3.10.11-slim-buster


# START ::: vars
ARG GID
ARG UID
ARG ORG_DIR
ARG UTL_PROJ_PATH
ARG APPUSR
ARG APPGRP
ARG HOME_UTL_PROJ_PATH
ARG DOCKER_HOME
ARG APP_PATH
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

ENV MODULE='tpl-gen'
ENV EDITOR="vim"
ENV PS1='`date "+%F %T"` \u@\h  \w \n\n  '

ENV PROJ_PATH=$TPG_PROJ_PATH
ENV HOME_PROJ_PATH=$HOME_TPG_PROJ_PATH
ENV ORG=$ORG
ENV ORG_DIR=$ORG_DIR
ENV UTL_PROJ_PATH=$UTL_PROJ_PATH
ENV APPUSR=$APPUSR
ENV APPGRP=$APPGRP
ENV HOME_UTL_PROJ_PATH=$HOME_UTL_PROJ_PATH
ENV DOCKER_HOME=$DOCKER_HOME
ENV HOME_APP_PATH=/home/$APPUSR/$APP_PATH

# STOP  ::: vars


# START ::: install OS utils

RUN apt-get update && apt-get install -y --no-install-recommends  \
  perl jq vim wget curl sudo zip unzip make bsdmainutils tzdata
# STOP  ::: install  OS utils


# isntall python pip
RUN wget https://bootstrap.pypa.io/get-pip.py ; sudo python3 get-pip.py ; sudo rm -v get-pip.py

RUN pip3 install --upgrade pip
RUN pip3 install wheel


# START ::: add-os-user
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
RUN mkdir -p "/home/$APPUSR" && chown "$APPUSR":"$APPGRP" "${DOCKER_HOME}"


RUN echo "$APPUSR ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN echo "export PS1=\"$PS1\"" >> $DOCKER_HOME/.bashrc && \
  chown -R $APPUSR:$APPGRP $DOCKER_HOME && \
  chmod -R 0775 $DOCKER_HOME


USER $APPUSR

# STOP  ::: add-os-user



# START ::: install-poetry

# Set the Poetry version
ENV POETRY_VERSION=1.5.1

# Check if Poetry is installed and install it if necessary
RUN poetry --version >/dev/null 2>&1 \
  && poetry_version=$(poetry --version | sed -n 's/Poetry version \(.*\)/\1/p') \
  && test "$poetry_version" = "$POETRY_VERSION" \
  || (curl -sSL https://install.python-poetry.org | python - \
  && chmod 775 $HOME/.local/share/pypoetry/venv/bin/poetry )

RUN echo 'export PATH=$PATH:$HOME/.local/bin/' >> $HOME/.bashrc

ENV PATH="${PATH}:/home/${APPUSR}/.local/bin/"


# set the default shell as bash and not sh
SHELL ["/bin/bash", "-c"]

# STOP  ::: install-poetry


# START ::: copy-proj-dir
COPY --chown=$APPUSR:$APPGRP . ${HOME_APP_PATH}
# STOP  ::: copy-proj-dir


# Create the 'run' symlink
WORKDIR $HOME_PROJ_PATH


RUN pip wheel --use-pep517 "pyyaml (==5.3.1)"
# START ::: install poetry modules in the  module
RUN find $HOME_PROJ_PATH/src/python/ -name "pyproject.toml" -print0 | \
  while IFS= read -r -d '' f; do \
  tgt_dir=$(dirname "$f"); \
  echo "Working on tgt_dir: $tgt_dir"; \
  sudo chmod -R ug+w $tgt_dir; \
  cd "$tgt_dir"; \
  if [ ! -z "${MODULE:-}" ] && [[ "$tgt_dir" == *"$MODULE"* ]]; then \
  test -f poetry.lock && rm -vf poetry.lock; \
  test -d .venv && rm -rv .venv; \
  poetry config virtualenvs.create true; \
  poetry install -vvv; \
  sudo chmod -R ug+w poetry.lock; \
  if [ $? -ne 0 ]; then \
  echo "FATAL: failed to install $tgt_dir py modules"; \
  exit 1; \
  fi; \
  fi; \
  cd -; \
  done
#
# STOP  ::: install poetry modules in the  module





#RUN chmod 0775 "$HOME_PROJ_PATH/src/bash/scripts/docker-init-${MODULE}.sh"
WORKDIR $HOME_PROJ_PATH

CMD exec /bin/bash -c "$HOME_PROJ_PATH/src/bash/scripts/docker-init-${MODULE}.sh"
