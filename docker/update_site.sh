#!/bin/bash

log_file="/tmp/update_site.log"

# Function to log with timestamp
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$log_file"
}

# Base repository directory
base_dir="/opt/sunet-se"
bin_dir="/usr/local/bin"

# Start logging
log "Update started."

# Ensure the script exits if any commands fail
set -e

export GIT_SSH_COMMAND="ssh -i $SSH_PRIVATE_KEY_LOCATION -o IdentitiesOnly=yes"

# Switch to content directory
cd "${base_dir}/sunet-se-content" || exit 1

# Stash any local changes (optional, uncomment if needed)
# git stash push --include-untracked &>> "$log_file"

git fetch --all &>> "$log_file"
git reset --hard "origin/$GIT_BRANCH" &>> "$log_file"
git checkout "$GIT_BRANCH" &>> "$log_file"
git pull &>> "$log_file"
log "Updated content repository."

cd "$base_dir" || exit 1

# Activate virtual environment and build the site
source venv/bin/activate
make pristine &>> "$log_file"
log "Built the site."

log "Update completed successfully."

# Exit without error
exit 0
