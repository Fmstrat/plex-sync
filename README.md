# plex-sync
Docker container for plex-sync that allows you to synchronize remote servers across the internet via SSL with dynamic DNS hostnames.

Based on plex-sync from https://github.com/jacobwgillespie/plex-sync

## Prerequisites
* You will need dynamic DNS hostnames (or static) for each of your Plex servers
* SSL must be enabled in Plex
* You must have tokens for each user (pull from logs)

## Configuration
You will need a `servers.cfg` file that maps to `/config/servers.cfg` in the container. The format is as follows, no spaces are allowed.

`./plex-sync/config/servers.cfg`:
```
[myfirstuser]
HOST1=dynamicDNSHost1.domain.com
PORT1=33400
TOKEN1=XXXXXXXXXXXXXXXXXXXX
HOST2=dynamicDNSHost2.domain.com
PORT2=33400
TOKEN2=XXXXXXXXXXXXXXXXXXXX
SECTIONS=1:3|2:1

[myseconduser]
HOST1=dynamicDNSHost1.domain.com
PORT1=33400
TOKEN1=XXXXXXXXXXXXXXXXXXXX
HOST2=dynamicDNSHost2.domain.com
PORT2=33400
TOKEN2=XXXXXXXXXXXXXXXXXXXX
SECTIONS=1:3|2:1
```

This would synchronize `dynamicDNSHost1` section `1` with `dynamicDNSHost2` section `3` and `dynamicDNSHost1` section `2` with `dynamicDNSHost2` section `1` for both `myfirstuser` and `myseconduser`.

## Usage
The following example is for docker-compose.

```
version: '2'

services:

  plex-sync:
    image: nowsci/plex-sync
    container_name: plex-sync
    volumes:
      - ./plex-sync/config:/config
    environment:
      - INITIAL_RUN=1
      - DRY_RUN=1
      - CRON_SCHEDULE=*/30 * * * *
    restart: always
```

Variable | Description 
-------- | -----------
`INITIAL_RUN` | Set this to 1 to run plex-sync as soon as the container starts before executing cron.
`CRON_SCHEDULE` | The default is every hour, however a custom schedule can be used with this variable.
`DRY_RUN` | Set this environment variable to 1 make `plex-sync` print out what it was planning to do rather than actually perform the synchronization.
`MATCH_TYPE` | Can be either `fuzzy` (default) or `precise`.  When the matching is fuzzy, the script will match items by their year and title.  When the matching is precise, the script matches items by their internal Plex GUID, which is usually the IMDb or TMDb ID.  This requires an individual API request to be performed for each item (each movie, each TV episode, etc.) and thus is very slow and can potentially overwhelm and crash the Plex server.  Use at your own risk.
`RATE_LIMIT` | Default `5`.  If the `MATCH_TYPE` is set to `precise`, this is the maximum number of concurrent API requests `plex-sync` will make to your server to fetch GUIDs.  Use this to (potentially) alleviate performance issues with precise matching.

