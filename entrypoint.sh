#!/bin/sh
mkdir -pv ${CADDYPATH:-/data/caddy}/logs ${CADDYPATH:-/data/caddy}/vhosts
if [[ ! -f ${CADDYPATH:-/data/caddy}/caddy.conf ]]; then
    cat > ${CADDYPATH:-/data/caddy}/caddy.conf <<EOF
:80 {
        gzip
        timeouts 0
        root ${CADDYPATH:-/data/caddy}/html
        index index.html index.htm default.html default.htm index.php
        log ${CADDYPATH:-/data/caddy}/logs/default.log
}
import vhosts/*.conf
EOF
fi
exec caddy -conf=${CADDYPATH:-/data/caddy}/caddy.conf --log=stdout --agree=true