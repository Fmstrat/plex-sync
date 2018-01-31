FROM node
MAINTAINER NOSPAM <nospam@nnn.nnn>

ENV PLEX_TOKEN=''
ENV DRY_RUN=''
ENV MATCH_TYPE=''
ENV RATE_LIMIT=''

ENV SECTION_MAPS=''
ENV CRON_SCHEDULE='0 * * * *'
ENV INITIAL_RUN=''

ADD bin/ /opt/bin/

RUN apt-get update && \
    apt-get -y -qq --force-yes install cron rsyslog host && \
    npm install -g --quiet plex-sync && \
    chmod 0755 /opt/bin/job.sh && \
    chmod 0755 /opt/bin/init.sh && \
    touch /var/log/cron.log

ENTRYPOINT /opt/bin/init.sh

