# save-time (WIP, don't use in production?)
Save time warrior events/intervals to Google Calendar

Note: I'm going to probably use events and intervals interchangably, but events are essentially time warrior's 'intervals'

### Flow:
- Get Auth
- Parse timew intervals
- Create event(s) on Google Calendar

Requirements: (TODO: add links to install instructions)
- oauth2l (cli based OAuth2 tool for fetching tokens)
		Linux Install (e.g. ~/bin/ or a path with $PATH pointing to it)
```sh
curl https://storage.googleapis.com/oauth2l/latest/linux_amd64.tgz | tar zxv
mv linux_amd64/oauth2l .
rm -r linux_amd64
```
- timew (to track time)

### Steps

#### Google Cloud API
1 - Set Up console.cloud.google.com account
	- add a project,
	- enable the Calendar API,
	- create credentials:
	- API Keys (options up to you)
	- OAuth 2.0 Client IDs
		- You can set the redirect URL to https://keevan.github.io/save-time (we only need to grab the 'code/verification-code' value when prompted)

#### Gaining Calendar Access
2 - Run the `save-date` command to start the auth process (uses oauth2l to get tokens and stores them in default 'cache' location)
	- It's not the nicest process because of this issue (https://github.com/google/oauth2l/issues/37)
	- Once saved, this tool should now have permissions to add events to your selected account's Google Calendar
	- To test it out, you can run the following commands:

##### You don't have any timew intervals yet
```sh
timew start 'Test first interval'
timew start tag test api new cli
timew stop
```

##### You already have timew intervals you want to save
```sh
save-time
```

# API / Docs / Usage
`save-time` will check if you have the required files for auth, and start the initialization process if required.
When you want to upload your events, just run `save-time`
When you want to include recipients on specific events, you can do so by going in to your calendar manually (which actually saves me development time?)
If you want a compilation of events/intervals, e.g. summary, to be saved as a single event (e.g. to share with a friend, or loved one), you can do the following:
```sh
# Export the events you want (see docs: https://timewarrior.net/docs/timew-export.1.html)
timew export > /tmp/events.json

# Run save-time with a summary specifying the file, and an optional title parameter to specify the Title/Summary of the event (defaults to Summary)
save-time --summary /tmp/events.json --title "Why I couldn't come out today"
```

## Future
- Use timew hooks to trigger events? Such that when an event has an 'end', save in in the calendar?
- Add recipients option to specify recipients you might want to share the created events with

## Motivation
- That would be nice
- Track time spent on projects, work, chores, research without having to worry about specifics (start, end, calendar, sync, etc)
- Save time by not needing to do this, and focus on doing more important things

## Mentions
I noticed there was 'gcalcli'. Probably would have made this much easier to
make, but where is the fun in that? Also it's not meant to be a full fledged
calendar client. This is meant to solve a very specific problem.

## License
This 'tool' is licensed under MIT. Do with it what you will. Full license text is available in [LICENSE][license].
