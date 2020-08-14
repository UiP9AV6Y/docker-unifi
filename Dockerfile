FROM openjdk:8-jre

ENV UNIFI_HOME=/usr/lib/unifi
RUN set -xe; \
    groupadd --gid 1000 unifi \
    && useradd --uid 1000 --gid unifi --shell /bin/sh --home ${UNIFI_HOME} --create-home unifi

WORKDIR ${UNIFI_HOME}
EXPOSE \
  # Port used for STUN.
  3478/udp \
  # Port used for remote syslog capture.
  5514/udp \
  # Port used for device and controller communication.
  8080 \
  # Port used for controller GUI/API as seen in a web browser
  8443 \
  # Port used for HTTP portal redirection.
  8880 \
  # Port used for HTTPS portal redirection.
  8843 \
  # Port used for UniFi mobile speed test.
  6789 \
  # Ports used by AP-EDU broadcasting.
  5656-5699/udp \
  # Port used for device discovery
  10001/udp \
  # Port used for "Make controller discoverable on L2 network" in controller settings.
  1900/udp

ARG UNIFI_VERSION
ENV UNIFI_VERSION=${UNIFI_VERSION}
RUN set -xe; \
    curl -sSLO http://dl.ubnt.com/unifi/${UNIFI_VERSION}/unifi_sysvinit_all.deb \
    && dpkg-deb -x unifi_sysvinit_all.deb /tmp/unifi \
    && chown -R unifi:unifi /tmp/unifi \
    && cp -r \
        /tmp/unifi/${UNIFI_HOME}/* \
        ${UNIFI_HOME} \
    && rm -rf \
        unifi_sysvinit_all.deb \
        /tmp/unifi
COPY system.properties \
    ${UNIFI_HOME}/data/
COPY unifi.sh \
    /usr/local/bin/unifi

VOLUME [ \
    "${UNIFI_HOME}/data", \
    "${UNIFI_HOME}/logs", \
    "${UNIFI_HOME}/run" \
]
HEALTHCHECK --interval=5m --timeout=3s --start-period=10s \
  CMD /usr/bin/curl -f http://localhost:8080 || exit 1
CMD [ "/usr/local/bin/unifi" ]

ARG BUILD_DATE="1970-01-01T00:00:00Z"
ARG VCS_URL="http://localhost/"
ARG VCS_REF="master"
LABEL org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.title="Unifi Controller" \
      org.opencontainers.image.description="Unifi Access Point controller" \
      org.opencontainers.image.url="https://www.ubnt.com/" \
      org.opencontainers.image.source=$VCS_URL \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.vendor="Ubiquiti Networks, Inc." \
      org.opencontainers.image.version=${UNIFI_VERSION}-1 \
      com.microscaling.docker.dockerfile="/Dockerfile" \
      org.opencontainers.image.licenses="GPL-3.0"
