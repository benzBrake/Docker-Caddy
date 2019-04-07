FROM alpine
MAINTAINER Ryan Lieu <github-benzBrake@woai.ru>
ARG CADDY_ARCH="amd64"
ARG CADDY_PLUGIN="http.cache,http.filebrowser,http.filter,http.ratelimit"
ARG CADDY_LICENSE="personal"
ARG CADDY_ACCOUNT_ID=""
ARG CADDY_API_KEY=""
ADD html /html
RUN apk add --update --no-cache openssl curl && \
    curl -fsSL "https://caddyserver.com/download/linux/${CADDY_ARCH}?plugins=${CADDY_PLUGIN}&license=${CADDY_LICENSE}&telemetry=off" -u "${CADDY_ACCOUNT_ID}:${CADDY_API_KEY}" -o "/tmp/caddy.tgz" && \
    cd /tmp && \
    tar xvf caddy.tgz && \
    mv caddy /bin/caddy && \
    chmod +x /bin/caddy && \
    rm -rf /tmp/*
CMD ["--conf=/data/caddy/caddy.conf", "--log=stdout", "--agree=true"]
ENTRYPOINT ["caddy"]