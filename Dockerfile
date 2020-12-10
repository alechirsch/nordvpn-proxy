FROM vimagick/tinyproxy
LABEL MAINTAINER "Alec Hirsch"

ENV OVPN_FILES="https://downloads.nordcdn.com/configs/archives/servers/ovpn.zip" \
    OVPN_CONFIG_DIR="/app/ovpn/config" \
    SERVER_RECOMMENDATIONS_URL="https://nordvpn.com/wp-admin/admin-ajax.php?action=servers_recommendations" \
    SERVER_STATS_URL="https://nordvpn.com/api/server/stats/" \
    CRON="*/15 * * * *" \
    CRON_OVPN_FILES="@daily"\
    PROTOCOL="tcp"\
    USERNAME="" \
    PASSWORD="" \
    COUNTRY="" \
    LOAD=75

COPY app /app

RUN \
    echo "####### Changing permissions #######" && \
      chmod u+x /app/**/run && \
      chmod u+x /app/**/*.sh \
      && \
    echo "####### Installing packages #######" && \
    apk --update --no-cache add \
      openvpn \
      runit \
      bash \
      jq \
      ncurses \
      curl \
      unzip \
      && \
    echo "####### Removing cache #######" && \
      rm -rf /var/cache/apk/*

ENTRYPOINT []
CMD ["runsvdir", "/app"]

HEALTHCHECK --interval=1m --timeout=10s \
  CMD if [[ $( curl -s https://api.nordvpn.com/vpn/check/full | jq -r '.["status"]' ) = "Protected" ]] ; then exit 0; else exit 1; fi