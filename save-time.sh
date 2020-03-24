#/usr/bin/env bash

# Setup config directory (creates if it doesn't exist)
CONFIG_PATH=~/.config/save-time
mkdir -p $CONFIG_PATH

# Set your crentials file path via ENV variable (GOOGLE_APPLICATION_CREDENTIALS)
export GOOGLE_APPLICATION_CREDENTIALS=$CONFIG_PATH/credentials.json

# Export events
oauth2l fetch --scope userinfo.email,calendar.events --cache $CONFIG_PATH/oauth2l

# Count the number of events
#timew export | grep -i "start" | wc -l
