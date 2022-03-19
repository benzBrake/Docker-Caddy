#!/bin/sh
VERSION=${VERSION:-"2.2.0"}
IMPORT="github.com/caddyserver/caddy"

# add `v` prefix for version numbers
[ "$(echo $VERSION | cut -c1)" -ge 0 ] 2>/dev/null && VERSION="v$VERSION"

stage() {
    STAGE="$1"
    echo
    echo starting stage: ${STAGE}
}

end_stage() {
    if [ $? -ne 0 ]; then
        >&2 echo error at \'$STAGE\'
        exit 1
    fi
    echo finished stage: $STAGE ✓
    echo
}
stage "prepare environment"
apk add git
end_stage

stage "building xcaddy"
go get -u github.com/caddyserver/xcaddy/cmd/xcaddy
end_stage

stage "building caddy using xcaddy"
for plugin in ${CADDY_PLUGINS}; do
    [[ ! -z $plugin ]] && PLUGINS_OPTS="${PLUGINS_OPTS} --with ${plugin}"
done
echo CGO_ENABLED=0 xcaddy build ${VERSION} ${PLUGINS_OPTS}
cd / && CGO_ENABLED=0 xcaddy build ${VERSION} ${PLUGINS_OPTS}
end_stage

echo "installed caddy version ${VERSION} at /caddy"
