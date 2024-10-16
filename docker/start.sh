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

if [ -z "$GITHUB_CODE_REPO" ]; then
  export GITHUB_CODE_REPO="https://github.com/SUNET/sunet-se-code"
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


envsubst < /opt/templates/nginx.conf > /usr/local/openresty/nginx/conf/nginx.conf

envsubst < /opt/templates/update_site.sh > /usr/local/bin/update_site.sh
chmod 755 /usr/local/bin/update_site.sh

envsubst < /opt/templates/get-jira-issues.sh > /usr/local/bin/get-jira-issues.sh
chmod 755 /usr/local/bin/get-jira-issues.sh

HASHED_REFRESH_PASSWORD="$(openssl passwd -apr1 "$REFRESH_PASSWORD")"
export HASHED_REFRESH_PASSWORD

envsubst < /opt/templates/htpasswd > /usr/local/openresty/nginx/conf/.htpasswd
	 
# Start OpenResty
exec start-stop-daemon --start --exec \
  /usr/local/openresty/nginx/sbin/nginx \
  --  -c /usr/local/openresty/nginx/conf/nginx.conf -g 'daemon off;'
