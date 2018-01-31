#!/bin/sh

if [ ! -f /config/servers.cfg ]; then
	echo "Missing /config/servers.cfg"
	exit
fi;

crontab -l | grep plex-sync-job || echo 'Installing cron job' && (crontab -l 2>/dev/null; echo "$CRON_SCHEDULE /usr/local/bin/job.sh >> /var/log/cron.log 2>&1") | crontab -

rm -rf /tmp/DRY_RUN
[ ! -z "$DRY_RUN" ] && echo "$DRY_RUN" > /tmp/DRY_RUN

rm -rf /tmp/MATCH_TYPE
[ ! -z "$MATCH_TYPE" ] && echo "$MATCH_TYPE" > /tmp/MATCH_TYPE

rm -rf /tmp/RATE_LIMIT
[ ! -z "$RATE_LIMIT" ] && echo "$RATE_LIMIT" > /tmp/RATE_LIMIT

[ ! -z "$INITIAL_RUN" ] && /usr/local/bin/job.sh

touch /var/log/cron.log

cron && tail -F /var/log/syslog /var/log/cron.log 2>/dev/null
