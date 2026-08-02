#!/bin/sh

. /lib.subr

set -e

if [ "$1" = "twistd" ]; then
    create_user

    if [ ! -s /buildbot/buildbot.tac ]; then
        cp /src/buildbot.tac /buildbot
    fi

    chown -R noroot:noroot /buildbot

    set -- su-exec noroot "$@"
fi

exec "$@"
