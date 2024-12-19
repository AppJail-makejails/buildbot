#!/bin/sh

set -e

config="${BUILDBOT_CONFIG:-master.cfg}"
db="${BUILDBOT_DB:-sqlite:///state.sqlite}"
log_count="${BUILDBOT_LOG_COUNT:-10}"
log_size="${BUILDBOT_LOG_SIZE:-10000000}"
nologrotate="${BUILDBOT_NOLOGROTATE}"

if [ -n "${BUILDBOT_FORCE}" ] || [ `ls -1 /var/db/buildbot | wc -l` -eq 0 ]; then
    set --

    if [ -n "${nologrotate}" ]; then
        set -- --no-logrotate
    else
        set -- --log-count="${log_count}" --log-size="${log_size}"
    fi

    buildbot create-master --config="${config}" --db="${db}" "$@" /var/db/buildbot
fi
