#!/bin/sh -x


if [ -z "$REFRESH_PASSWORD" ]; then
  echo "Environment variable REFRESH_PASSWORD is needed to run container"
  exit 1
fi

if [ -z "$JIRA_PASSWORD" ]; then
  echo "Environment variable JIRA_PASSWORD is needed to run container"
  exit 1
fi

if [ -z "$SERVER_NAME" ]; then
   export SERVER_NAME="sunet.se"
fi

if [ -z "$SSH_PRIVATE_KEY_LOCATION" ]; then
  export SSH_PRIVATE_KEY_LOCATION="/root/.ssh/server_key"
fi

if [ -z "$GIT_SSH_COMMAND" ]; then
  export GIT_SSH_COMMAND="ssh -i $SSH_PRIVATE_KEY_LOCATION -o IdentitiesOnly=yes"
fi

if [ -z "$GITHUB_CONTENT_REPO" ]; then
  export GITHUB_CONTENT_REPO="https://github.com/SUNET/sunet-se-content.git"
fi

if [ -z "$GIT_BRANCH" ]; then
  export GIT_BRANCH="staging"
fi

if [ -z "$REFRESH_USERNAME" ]; then
  export REFRESH_USERNAME="editor"
fi

if [ -z "$JIRA_BASEURL" ]; then
  export JIRA_BASEURL="https://jira-test.sunet.se/rest/api/2"
fi

if [ -z "$JIRA_USERNAME" ]; then
  export JIRA_USERNAME="restsunetweb"
fi

if [ -z "$JIRA_TICKETS_OUTPUT" ]; then
  export JIRA_TICKETS_OUTPUT="/tmp"
fi

if [ -z "$JIRA_PROJECT" ]; then
  export JIRA_PROJECT="TIC"
fi

if [ -z "$MAX_CLOSED_AGE" ]; then
  export MAX_CLOSED_AGE="30d"
fi

ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts

git clone --branch $GIT_BRANCH $GITHUB_CONTENT_REPO /opt/sunet-se/sunet-se-content

git config --global --add safe.directory /opt/sunet-se/sunet-se-content

cd /opt/sunet-se && source venv/bin/activate && make pristine

envsubst '$SERVER_NAME' < /opt/templates/nginx.conf > /usr/local/openresty/nginx/conf/nginx.conf

envsubst '$GIT_BRANCH $SSH_PRIVATE_KEY_LOCATION' < /opt/templates/update_site.sh > /usr/local/bin/update_site.sh
chmod 755 /usr/local/bin/update_site.sh

JIRA_VARS='$JIRA_BASEURL $JIRA_USERNAME $JIRA_PASSWORD $JIRA_TICKETS_OUTPUT $JIRA_PROJECT $MAX_CLOSED_AGE'
envsubst "$JIRA_VARS" < /opt/templates/get-jira-issues.sh > /usr/local/bin/get-jira-issues.sh
chmod 755 /usr/local/bin/get-jira-issues.sh

HASHED_REFRESH_PASSWORD="$(openssl passwd -apr1 "$REFRESH_PASSWORD")"
export HASHED_REFRESH_PASSWORD

envsubst < /opt/templates/htpasswd > /usr/local/openresty/nginx/conf/.htpasswd
	 
# Start OpenResty
exec start-stop-daemon --start --exec \
  /usr/local/openresty/nginx/sbin/nginx \
  --  -c /usr/local/openresty/nginx/conf/nginx.conf -g 'daemon off;'
