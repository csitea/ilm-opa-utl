FROM python:3.10.11-slim-buster

# START ::: vars
ARG GID
ARG UID
ARG ORG_DIR
ARG APPUSR
ARG APPGRP
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

ENV PROJ_PATH=$UTL_PROJ_PATH
ENV HOME_PROJ_PATH=$HOME_TPL_PROJ_PATH

ENV MODULE='conf-validator'
ENV BASE_PATH=$BASE_PATH
ENV EDITOR="vim"
ENV PS1='`date "+%F %T"` \u@\h  \w \n\n  '
ENV HOME_APP_PATH=${DOCKER_HOME}${APP_PATH}
# STOP  ::: vars


# START ::: install alpine OS utils
RUN apt-get update && apt-get install -y --no-install-recommends  \
  perl jq vim wget curl sudo zip unzip make bsdmainutils tzdata
# STOP  ::: install alpine OS utils


# isntall python pip
RUN wget https://bootstrap.pypa.io/get-pip.py ; python3 get-pip.py ; sudo rm -v get-pip.py

RUN pip install --upgrade pip
RUN pip install wheel







# set the default shell as bash and not sh
SHELL ["/bin/bash", "-c"]

# STOP  ::: install-poetry

# START ::: add-os-user

# Your existing commands for groupadd and useradd
RUN if getent group $GID ; then groupmod -g $((GID+3333)) $(getent group $GID  | cut -d: -f1); fi

RUN set -x ; groupadd -g "$GID" "${APPGRP}" && \
  useradd \
  --gid "$GID" \
  --non-unique \
  --shell "/bin/bash" \
  --home-dir "${DOCKER_HOME}" \
  --uid "$UID" \
  --groups "${APPGRP}" "${APPUSR}" && exit 0 ; exit 1



# create home directory and change its ownership to ${APPUSR}:${APPGRP}
RUN mkdir -p "${DOCKER_HOME}/.local/share" && chown "${APPUSR}":"${APPGRP}" "${DOCKER_HOME}"



RUN echo "${APPUSR} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN echo "export PS1=\"$PS1\"" >> $DOCKER_HOME/.bashrc && \
  chown -R ${APPUSR}:${APPGRP} "${DOCKER_HOME}" && \
  chmod -R 0775 "${DOCKER_HOME}"

RUN echo 'export PATH=$PATH:${DOCKER_HOME}/.local/bin/' >> ${DOCKER_HOME}/.bashrc

ENV PATH="${PATH}:${DOCKER_HOME}/.local/bin/"

# STOP  ::: add-os-user



# START ::: copy-proj-dir
COPY --chown=${APPUSR}:${APPGRP} . ${HOME_APP_PATH}
# STOP  ::: copy-proj-dir

# Create the 'run' symlink
WORKDIR $HOME_UTL_PROJ_PATH
USER ${APPUSR}

# START  ::: install-poetry

# Set the Poetry version
ENV POETRY_VERSION=1.5.0

# Check if Poetry is installed and install it if necessary
RUN poetry --version >/dev/null 2>&1 \
  && poetry_version=$(poetry --version | sed -n 's/Poetry version \(.*\)/\1/p') \
  && test "$poetry_version" = "$POETRY_VERSION" \
  || (curl -sSL https://install.python-poetry.org | python - \
  && chmod 775 $DOCKER_HOME/.local/share/pypoetry/venv/bin/poetry )
# STOP  ::: install-poetry

# RUN ln -sfn src/bash/run/run.sh run


# STOP  ::: copy-proj-dir

# START ::: install poetry modules in the csi module
RUN find $HOME_UTL_PROJ_PATH/src/python/ -name "pyproject.toml" -print0 | \
  while IFS= read -r -d '' f; do \
  tgt_dir=$(dirname "$f"); \
  echo "Working on tgt_dir: $tgt_dir"; \
  cd "$tgt_dir"; \
  if [ ! -z "${MODULE:-}" ] && [[ "$tgt_dir" == *"$MODULE"* ]]; then \
  test -f poetry.lock && rm -vf poetry.lock; \
  test -d .venv && rm -rv .venv; \
  poetry config virtualenvs.create true; \
  poetry install -vvv; \
  if [ $? -ne 0 ]; then \
  echo "FATAL: failed to install $tgt_dir py modules"; \
  exit 1; \
  fi; \
  fi; \
  cd -; \
  done

# STOP  ::: install poetry modules in the csi module



WORKDIR $HOME_UTL_PROJ_PATH

# RUN chmod 0775 "$HOME_UTL_PROJ_PATH/src/bash/scripts/docker-init-${MODULE}.sh"
