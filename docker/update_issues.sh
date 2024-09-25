#!/bin/bash

log_file="/tmp/update_site.log"

# Function to log with timestamp
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$log_file"
}

# Base repository directory
repo_dir="/opt/sunet-se-code"
bin_dir="/usr/local/bin"

# Start logging
log "Issue update started."

# Ensure the script exits if any commands fail
set -e

# Retrieve JIRA tickets
"${bin_dir}/get-jira-issues.sh" -c get-jira-issues.conf -p "SUNET_JIRA_PASSWORD" &>> "$log_file"
log "Retrieved JIRA tickets."

cd "$repo_dir" || exit 1

# Activate virtual environment and build the site
source venv/bin/activate
make pristine &>> "$log_file"
log "Built the site."

log "Update completed successfully."

# Exit without error
exit 0
