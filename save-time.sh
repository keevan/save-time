#/usr/bin/env bash

# Setup config directory (creates if it doesn't exist)
CONFIG_PATH=~/.config/save-time
mkdir -p $CONFIG_PATH

# Set your crentials file path via ENV variable (GOOGLE_APPLICATION_CREDENTIALS)
export GOOGLE_APPLICATION_CREDENTIALS=$CONFIG_PATH/credentials.json

# Shouldn't need to change once its set
API_KEY=$(cat $CONFIG_PATH/apikey)

# Export events

OAUTH_TOKEN=$( oauth2l fetch --scope userinfo.email,calendar.events --cache $CONFIG_PATH/oauth2l )

# Count the number of events
#timew export | grep -i "start" | wc -l

# Try the call with the first stored event
START=$( timew export | jq -r '.[0].start' | sed -E 's/^(.{13})/\1:/;s/^(.{11})/\1:/;s/^(.{6})/\1-/;s/^(.{4})/\1-/;s/Z//' )

END=$( timew export | jq -r '.[0].end' | sed -E 's/^(.{13})/\1:/;s/^(.{11})/\1:/;s/^(.{6})/\1-/;s/^(.{4})/\1-/;s/Z//' )

SUMMARY=$( timew export | jq -r '.[0].tags | join(", ")' )

# Prepare each section separately
start_datetime_object="\"start\":{\"dateTime\":\"$START\",\"timeZone\":\"UTC\"}"
end_datetime_object="\"end\":{\"dateTime\":\"$END\",\"timeZone\":\"UTC\"}"
summary_object="\"summary\":\"$SUMMARY\""

# echo "{$start_datetime_object, $end_datetime_object, $summary_object}"
echo "... Adding [$SUMMARY]"

# curl -s "https://content.googleapis.com/calendar/v3/calendars/primary/events?sendNotifications=true&alt=json&key=$API_KEY" \
# 	-H "authorization: Bearer $OAUTH_TOKEN" \
# 	-H 'content-type: application/json' \
# 	--data-binary "{$start_datetime_object,$end_datetime_object,$summary_object}" \
# 	--compressed |
# 	jq -r '.status'
