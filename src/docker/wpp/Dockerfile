FROM debian:bullseye

# START ::: Arguments and Environment Variables =============================

# To keep it easier to spot whenever we miss a variable lets keep args and
# envs in sync. Add variables here in the same order as they appear in the
# .env file, for simplicity
# https://vsupalov.com/docker-arg-vs-env/

ARG GID
ARG UID
ARG ORG_DIR
ARG APPUSR
ARG APPGRP
ARG WUI_PROJ_PATH

# DB args
ARG DB_NAME
ARG DB_USER
ARG DB_PASSWORD
ARG DB_HOST
ARG DB_PORT

EXPOSE 8080

# STOP ::: Arguments and Environment Variables =============================

#VOLUME ${ORG_DIR}

# START ::: install bin utils
RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y bash binutils git vim perl jq wget openssh-client \
  curl zip unzip busybox sudo net-tools \
  build-essential gcc openssl libssl-dev git \
  file make jq zlib1g-dev \
  util-linux rsync
SHELL ["/bin/bash", "-c"]

# Install required packages for WordPress and Nginx
RUN apt-get install -y vim mlocate perl unzip nginx python3-pip \
  php-fpm php-mysql php-curl php-gd php-intl php-mbstring \
  php-soap php-xml php-xmlrpc php-zip tar

RUN mkdir -p /var/log/nginx /var/lib/nginx/body /var/lib/nginx/fastcgi /var/cache/nginx \
  && touch /var/log/nginx/error.log \
  && chown -R www-data:www-data /var/log/nginx /var/lib/nginx /var/cache/nginx \
  && chmod -R 755 /var/log/nginx /var/lib/nginx /var/cache/nginx

# Cleanup the cache to reduce the image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy the Nginx configuration file into the container
COPY /ilm-opa/ilm-opa-utl/dat/nginx/default.conf /etc/nginx/sites-available/default
COPY /ilm-opa/ilm-opa-utl/dat/nginx/nginx.conf /etc/nginx/nginx.conf

RUN chmod 0644 /etc/nginx/sites-available/default

# Download WordPress
RUN curl -o /tmp/wordpress.tar.gz https://wordpress.org/wordpress-6.3.1.tar.gz

# Extract WordPress archive
RUN tar -xzf /tmp/wordpress.tar.gz -C /var/www/ \
  && rm /tmp/wordpress.tar.gz

# Create the WordPress directory
#RUN mkdir /var/www/wordpress

# Clear /var/www/html/ directory
RUN rm -rf /var/www/html

# Move WordPress files to Nginx root directory (/var/www/html/)
RUN mv /var/www/wordpress /var/www/html/

# Correct permissions for the /var/www/html directory
RUN chown -R www-data:www-data /var/www/html

# Copy sample WordPress config file
RUN cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

RUN sed -i "s/database_name_here/${DB_NAME}/" /var/www/html/wp-config.php \
  && sed -i "s/username_here/${DB_USER}/" /var/www/html/wp-config.php \
  && sed -i "s/password_here/${DB_PASSWORD}/" /var/www/html/wp-config.php \
  && sed -i "s/localhost/${DB_HOST}:${DB_PORT}/" /var/www/html/wp-config.php

# START ::: add-os-user
RUN if getent group ${GID}; then groupmod -g $((GID+3333)) $(getent group ${GID} | cut -d: -f1); fi
RUN if getent passwd ${UID}; then usermod -u $((UID+3333)) $(getent passwd ${UID} | cut -d: -f1); fi

# START ::: add-os-user
RUN set -x ; groupadd -g ${GID} ${APPGRP} && \
  useradd \
  --gid ${GID} \
  --non-unique \
  --shell "/bin/bash" \
  --home-dir "/home/${APPUSR}" \
  --uid "${UID}" \
  --groups ${APPGRP} ${APPUSR} && exit 0 ; exit 1


RUN mkdir -p "/home/${APPUSR}" && chown ${APPUSR}:${APPGRP} "/home/${APPUSR}"

RUN echo "${APPUSR} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN echo "${APPGRP} ALL=(ALL) NOPASSWD: /usr/bin/npm" >> /etc/sudoers

RUN echo "export PS1='\$(date +\"%F %T\") \u@\h  \w \n\n  '" >> /home/${APPUSR}/.bashrc && \
  echo "cd ${WUI_PROJ_PATH}" >> /home/${APPUSR}/.bashrc && \
  chown -R ${APPUSR}:${APPGRP} /home/${APPUSR}/ && \
  chmod -R 0775 /home/${APPUSR}

# STOP  ::: add-os-user

ADD --chown=${APPUSR}:${APPGRP} "." /opt/ilm/ilm-opa/


CMD exec /bin/bash -c "${ORG_DIR}/src/bash/scripts/start-wpp-dev.sh"
