FROM benzbrake/alpine
LABEL maintainer "Ryan Lieu <github-benzBrake@woai.ru>"

# CADDY PLUGINS
ARG CADDY_PLUGINS="git,cors,realip,filter,expires,cache,cloudflare"
ARG TELEMETRY="off"

# Install Caddy & PHP
RUN env && \
	set -x && \
	curl --silent --show-error --fail --location --header "Accept: application/tar+gzip, application/x-gzip, application/octet-stream" -o - "https://caddyserver.com/download/linux/amd64?plugins=${CADDY_PLUGINS}&license=personal&telemetry=${TELEMETRY}" | tar --no-same-owner -C /usr/bin/ -xz caddy && \
	chmod +x /bin/entrypoint.sh && \
	rm -rf /var/cache/apk/* /tmp/*

# Configure 
RUN mkdir -pv /www/wwwroot/default /www/wwwlogs/
COPY html/index.html /www/wwwroot/default/
COPY html/404.html /www/wwwroot/default/
COPY html/phpinfo.php /www/wwwroot/default/
COPY Caddyfile /etc/
COPY entrypoint.sh /bin/

# validate install
RUN /usr/bin/caddy -version
RUN /usr/bin/caddy -plugins

# Let's Encrypt Agreement
ENV ACME_AGREE="false"

# Ports, volumes, workdir
EXPOSE 80 443 2015
VOLUME /root/.caddy /www
WORKDIR /www

ENTRYPOINT ["/usr/bin/caddy"]
CMD ["--conf", "/etc/Caddyfile", "--log", "stdout", "--agree=true"]
