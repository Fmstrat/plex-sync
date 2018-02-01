#!/bin/bash

LOGPATH=${1:-"/data/docker/containers/plex/config/Library/Application Support/Plex Media Server/Logs"}

if [ ! -d "$LOGPATH" ]; then
	echo "Not a log directory."
	exit
fi

cd "$LOGPATH"
touch /tmp/plex-tokens
find . -type f -name Plex\ Media\ Server\*.log -print0 | while IFS= read -r -d '' LOGFILE; do
	LOGS=$(egrep "X-Plex-Username|X-Plex-Token" "$LOGFILE" |awk '{print $9} {print $11}')
	USER_IS_NEXT=0
	TOKEN_IS_NEXT=0
	USER=''
	TOKEN=''
	for LINE in $LOGS; do
		if [ "$LINE" == "X-Plex-Username" ]; then
			USER_IS_NEXT=1
		elif [ $USER_IS_NEXT -eq 1 ]; then
			USER=$LINE
			USER_IS_NEXT=0
			TOKEN_IS_NEXT=1
		elif [ $TOKEN_IS_NEXT -eq 1 ]; then
			if [ "$LINE" != "X-Plex-Token" ]; then
				TOKEN=$LINE
				TOKEN_IS_NEXT=0
				echo "Token: $TOKEN - User: $USER" >> /tmp/plex-tokens
			fi
		fi
	done
done
cat /tmp/plex-tokens |sort |uniq
rm /tmp/plex-tokens
