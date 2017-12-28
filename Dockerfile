FROM alpine:latest
MAINTAINER Timothy Clarke <ghtimothy@timothy.fromnz.net>

COPY templates/* /awscron/templates/
COPY cronscripts/* /awscron/bin/
COPY pipe-dev-null.sh /usr/local/bin/pipe-dev-null.sh
COPY app-entry.sh /app-entry.sh

RUN apk -Uuv add bash dcron python py-pip gettext && \
    pip install awscli && \
    apk --purge -v del py-pip && rm -rf /var/cache/apk/* && \
    mkdir -p /root/.aws && \
    chmod +x /awscron/bin/* && \
    chmod +x /usr/local/bin/pipe-dev-null.sh && \
    touch /var/log/cron.log && \
    touch /awscron/crons && \
    chmod +x /app-entry.sh

ENTRYPOINT ["/app-entry.sh"]
