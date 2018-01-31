#!/bin/bash

die() {
	printf >&2 "%s\n" "$@"
	exit 1
}

getTrueHost() {
	IP=$(host $1 |tail -n 1 |awk '/has address/ { print $4 }')
	CERTDOMAIN=$(curl -vI https://$1:$2 2>&1 |grep CN= |sed s/[^\\*]*CN=\\*//g |sed s/\*//g)
	NEWROOT=$(echo $IP |sed 's/\./-/g')
	echo ${NEWROOT}${CERTDOMAIN}
}

export PATH=/usr/local/bin:$PATH

aryname=''
linenb=0
arraylist=''
while read line; do
	((++linenb))
	if [[ $line =~ ^[[:space:]]*$ ]]; then
		continue
	elif [[ $line =~ ^\[([[:alpha:]][[:alnum:]]*)\]$ ]]; then
		aryname=${BASH_REMATCH[1]}
		arraylist="$arraylist $aryname"
		declare -A $aryname
	elif [[ $line =~ ^([^=]+)=(.*)$ ]]; then
		[[ -n aryname ]] || die "*** Error line $linenb: no array name defined"
		printf -v ${aryname}["${BASH_REMATCH[1]}"] "%s" "${BASH_REMATCH[2]}"
	else
		die "*** Error line $linenb: $line"
	fi
done < /config/servers.cfg

CMDLINE=''
if [ -f /tmp/DRY_RUN ]; then
	DRY_RUN=$(cat /tmp/DRY_RUN)
	DRY_RUN=$(echo $DRY_RUN)
	CMDLINE="${CMDLINE} DRY_RUN=$DRY_RUN"
fi
if [ -f /tmp/MATCH_TYPE ]; then
	MATCH_TYPE=$(cat /tmp/MATCH_TYPE)
	MATCH_TYPE=$(echo $MATCH_TYPE)
	CMDLINE="${CMDLINE} MATCH_TYPE=$MATCH_TYPE"
fi
if [ -f /tmp/RATE_LIMIT ]; then
	RATE_LIMIT=$(cat /tmp/RATE_LIMIT)
	RATE_LIMIT=$(echo $RATE_LIMIT)
	CMDLINE="${CMDLINE} RATE_LIMIT=$RATE_LIMIT"
fi
CMDLINE=$(echo $CMDLINE)

for SERVER in $arraylist; do
	eval 'PLEXHOST1=${'$SERVER'[''HOST1'']}'
	eval 'PLEXPORT1=${'$SERVER'[''PORT1'']}'
	eval 'PLEXTOKEN1=${'$SERVER'[''TOKEN1'']}'
	eval 'PLEXHOST2=${'$SERVER'[''HOST2'']}'
	eval 'PLEXPORT2=${'$SERVER'[''PORT2'']}'
	eval 'PLEXTOKEN2=${'$SERVER'[''TOKEN2'']}'
	eval 'PLEXSECTIONS=${'$SERVER'[''SECTIONS'']}'
	PLEXTRUEHOST1=$(getTrueHost $PLEXHOST1 $PLEXPORT1)
	PLEXTRUEHOST2=$(getTrueHost $PLEXHOST2 $PLEXPORT2)
	IFS='|'
	for SECTIONMAP in $PLEXSECTIONS; do
		PLEXSECTION1=${SECTIONMAP%%:*}
		PLEXSECTION2=${SECTIONMAP##*:}
		echo "Syncing $SERVER - ${PLEXTRUEHOST1}(${PLEXHOST1}):${PLEXPORT1}/${PLEXSECTION1} -> ${PLEXTRUEHOST2}(${PLEXHOST2}):${PLEXPORT2}/${PLEXSECTION2}..."
		FULLCMD="$CMDLINE plex-sync https://${PLEXTOKEN1}@${PLEXTRUEHOST1}:${PLEXPORT1}/${PLEXSECTION1} https://${PLEXTOKEN2}@${PLEXTRUEHOST2}:${PLEXPORT2}/${PLEXSECTION2}"
		FULLCMD=$(echo $FULLCMD)
		eval $FULLCMD

	done
	unset IFS
done
