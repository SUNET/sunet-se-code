FROM debian:bookworm

ENV DEBIAN_FRONTEND noninteractive
ENV NGINX_VERSION 1.25.3.1

# required
ENV REFRESH_PASSWORD="dummy"
ENV JIRA_PASSWORD="dummy"

# optional
ENV SERVER_NAME="sunet.se"
ENV GITHUB_CONTENT_REPO="git@github.com:SUNET/sunet-se-content.git"
ENV GIT_BRANCH="staging"
ENV REFRESH_USERNAME="editor"
ENV JIRA_BASEURL="https://jira-test.sunet.se/rest/api/2"
ENV JIRA_USERNAME="restsunetweb"
ENV JIRA_TICKETS_OUTPUT="/tmp"
ENV JIRA_PROJECT="TIC"
ENV MAX_CLOSED_AGE="30d"
ENV SSH_PRIVATE_KEY_LOCATION="/root/.ssh/server_key"
ENV GIT_SSH_COMMAND="ssh -i $SSH_PRIVATE_KEY_LOCATION -o IdentitiesOnly=yes"

# Install needed software

RUN apt-get -y update && apt-get -y upgrade && \
    apt-get install -y curl wget gnupg ca-certificates git nodejs ssh \
    python3 python3-venv python3-pip npm openssl gettext-base && \
    rm -rf /var/lib/apt/lists/*

RUN wget -O - https://openresty.org/package/pubkey.gpg | apt-key add -
RUN echo "deb http://openresty.org/package/debian bookworm openresty" \
    | tee /etc/apt/sources.list.d/openresty.list

RUN apt-get -y update && \
    apt-get -y install --no-install-recommends openresty && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /opt/sunet-se

WORKDIR /opt/sunet-se

COPY ./jinja2_filters /opt/sunet-se/jinja2_filters
COPY ./plugins /opt/sunet-se/plugins
COPY ./theme /opt/sunet-se/theme
COPY ./Makefile /opt/sunet-se/Makefile
COPY ./babel.cfg /opt/sunet-se/babel.cfg
COPY ./package-lock.json /opt/sunet-se/package-lock.json
COPY ./package.json /opt/sunet-se/package.json
COPY ./pelicanconf.py /opt/sunet-se/pelicanconf.py
COPY ./postcss.config.js /opt/sunet-se/postcss.config.js
COPY ./publishconf.py /opt/sunet-se/publishconf.py
COPY ./requirements.txt /opt/sunet-se/requirements.txt
COPY ./tasks.py /opt/sunet-se/tasks.py

RUN python3 -m venv venv

RUN . venv/bin/activate && pip install -r requirements.txt
RUN npm install

RUN mkdir /opt/templates

COPY ./docker/nginx.conf /opt/templates/nginx.conf
COPY ./docker/htpasswd /opt/templates/htpasswd
COPY ./docker/update_site.sh /opt/templates/update_site.sh
COPY ./docker/get-jira-issues.sh /opt/templates/get-jira-issues.sh
COPY ./docker/update_issues.sh /usr/local/bin/update_issues.sh
RUN chmod 755 /usr/local/bin/update_issues.sh

COPY ./docker/refresh.lua /usr/local/openresty/nginx/conf/refresh.lua
RUN chmod 755 /usr/local/openresty/nginx/conf/refresh.lua

COPY ./docker/start.sh /start.sh

EXPOSE 80

CMD ["bash", "/start.sh"]
