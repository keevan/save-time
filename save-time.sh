#/usr/bin/env bash

# CLI ARGS
	CLEAR='\033[0m'
	RED='\033[0;31m'

	function usage() {
		if [ -n "$1" ]; then
			echo -e "${RED}👉 $1${CLEAR}\n";
		fi
		echo "Usage: $0 [-s] [-r email(s)]"
		echo "  -d, --dry-run        If you do not want to actually create any events"
		echo "  -s, --summary        Instead of creating events for everything, just create the summary event"
		echo "  -r, --recipients     Specify a list of recipients to share event with (NOT WORKING YET)"
		echo "  -v, --verbose        Output debugging information"
		echo ""
		echo "Example: $0 --summary --recipients \"destination@example.com\""
		exit 1
	}

	# parse params
	while [[ "$#" > 0 ]]; do case $1 in
		-d|--dry-run) DRY_RUN=1; shift;shift;;
		-r|--recipients) RECIPIENTS="$2";shift;shift;;
		-h|--help) usage;shift;shift;;
		-v|--verbose) VERBOSE=1;shift;;
		*) usage "Unknown parameter passed: $1"; shift; shift;;
	esac; done

	# verify params
	# if [ -z "$SOMETHING" ]; then usage "My error"; fi;

# END CLI ARGS CHECK


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

for encoded in $(timew export | jq -c '.[] | @base64'); do

	row=$( echo $encoded | base64 --decode -i )

	# echo $row
	# Try the call with the first stored event
	START=$( echo $row | jq -r '.start' | sed -E 's/^(.{13})/\1:/;s/^(.{11})/\1:/;s/^(.{6})/\1-/;s/^(.{4})/\1-/;s/Z//' )

	END=$( echo $row | jq -r '.end' | sed -E 's/^(.{13})/\1:/;s/^(.{11})/\1:/;s/^(.{6})/\1-/;s/^(.{4})/\1-/;s/Z//' )

	SUMMARY="$( echo $row | jq -r '.tags | join(", ")' )"
	# SUMMARY="test"

	# Prepare each section separately
	start_datetime_object="\"start\":{\"dateTime\":\"$START\",\"timeZone\":\"UTC\"}"
	end_datetime_object="\"end\":{\"dateTime\":\"$END\",\"timeZone\":\"UTC\"}"
	summary_object="\"summary\":\"$SUMMARY\""

	# echo "{$start_datetime_object, $end_datetime_object, $summary_object}"
	echo "... Adding [$SUMMARY]"

	if [ "$DRY_RUN" != 1 ] ; then

		# If not a dry-run, call the api
		curl -s "https://content.googleapis.com/calendar/v3/calendars/primary/events?sendNotifications=true&alt=json&key=$API_KEY" \
			-H "authorization: Bearer $OAUTH_TOKEN" \
			-H 'content-type: application/json' \
			--data-binary "{$start_datetime_object,$end_datetime_object,$summary_object}" \
			--compressed |
			jq -r '.status'

	fi



done

