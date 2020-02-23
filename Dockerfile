#
# Builder 
# Copy from Abiosoft/caddy-docker
#
FROM benzbrake/caddy:builder as builder

ARG version="1.0.4"
ARG caddy_plugins="git,cors,realip,filter,expires,cache,cloudflare"
ARG enable_telemetry="false"

# process wrapper
RUN go get -v github.com/abiosoft/parent

RUN VERSION=${version} PLUGINS=${caddy_plugins} ENABLE_TELEMETRY=${enable_telemetry} /bin/sh /usr/bin/builder.sh

#
# Final stage
#
FROM benzbrake/alpine
LABEL maintainer "Ryan Lieu <github-benzBrake@woai.ru>"

ARG version="1.0.4"
LABEL caddy_version="$version"

# Let's Encrypt Agreement
ENV ACME_AGREE="false"

# Telemetry Stats
ENV ENABLE_TELEMETRY="$enable_telemetry"

# Caddy PATH
ENV CADDYPATH=/data/caddy

RUN mkdir -pv /www/wwwroot/default
COPY html/index.html /www/wwwroot/default/
COPY html/404.html /www/wwwroot/default/
ADD Caddyfile /etc/

RUN apk add --update --no-cache openssl curl git && \
	mkdir -pv /www/{config,wwwlogs} &&\
	rm -rf /var/cache/apk/* /tmp/*

# install caddy
COPY --from=builder /install/caddy /usr/bin/caddy

# install process wrapper
COPY --from=builder /go/bin/parent /bin/parent

# validate install
RUN /usr/bin/caddy -version
RUN /usr/bin/caddy -plugins

EXPOSE 80 443 2015
VOLUME /root/.caddy /www
WORKDIR /www

ENTRYPOINT ["/bin/parent", "caddy"]
CMD ["--conf", "/etc/Caddyfile", "--log", "stdout", "--agree=$ACME_AGREE"]
