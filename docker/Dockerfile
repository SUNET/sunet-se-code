FROM debian:bookworm

ENV DEBIAN_FRONTEND noninteractive
ENV NGINX_VERSION 1.25.3.1

# required
ENV REFRESH_PASSWORD="dummy"
ENV SUNET_JIRA_PASSWORD="dummy"

# optional
ENV SERVER_NAME="sunet.se"
ENV GITHUB_CODE_REPO="https://github.com/SUNET/sunet-se-code"
ENV GIT_BRANCH="staging"
ENV REFRESH_USERNAME="editor"
ENV JIRA_BASEURL="https://jira-test.sunet.se/rest/api/2"
ENV JIRA_USERNAME="restsunetweb"
ENV JIRA_TICKETS_OUTPUT="/tmp"
ENV JIRA_PROJECT="TIC"
ENV MAX_CLOSED_AGE="30d"

# Install needed software

RUN apt-get -y update && apt-get -y upgrade && \
    apt-get install -y curl wget gnupg ca-certificates git nodejs \
    python3 python3-venv python3-pip npm openssl gettext-base && \
    rm -rf /var/lib/apt/lists/*

RUN wget -O - https://openresty.org/package/pubkey.gpg | apt-key add -
RUN echo "deb http://openresty.org/package/debian bookworm openresty" \
    | tee /etc/apt/sources.list.d/openresty.list

RUN apt-get -y update && \
    apt-get -y install --no-install-recommends openresty && \
    rm -rf /var/lib/apt/lists/*

RUN git clone --branch $GIT_BRANCH $GITHUB_CODE_REPO /opt/sunet-se-code

WORKDIR /opt/sunet-se-code

RUN git submodule init
RUN git submodule update

RUN python3 -m venv venv

RUN . venv/bin/activate && pip install -r requirements.txt
RUN npm install

RUN . venv/bin/activate && make pristine

RUN git config --global --add safe.directory /opt/sunet-se-code
RUN git config --global --add safe.directory /opt/sunet-se-code/sunet-se-content

RUN mkdir /opt/templates

COPY ./nginx.conf /opt/templates/nginx.conf
COPY ./htpasswd /opt/templates/htpasswd
COPY ./update_site.sh /opt/templates/update_site.sh
COPY ./get-jira-issues.sh /opt/templates/get-jira-issues.sh
COPY ./update_issues.sh /usr/local/bin/update_issues.sh
RUN chmod 755 /usr/local/bin/update_issues.sh

COPY ./start.sh /start.sh

EXPOSE 80

CMD ["bash", "/start.sh"]
