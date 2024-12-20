#!/bin/sh

set -e

dbdir="/var/db/buildbot"
admin="${BUILDBOT_INFO_ADMIN}"
host="${BUILDBOT_INFO_HOST}"
keepalive="${BUILDBOT_KEEPALIVE:-600}"
log_count="${BUILDBOT_LOG_COUNT:-10}"
maxdelay="${BUILDBOT_MAXDELAY:-300}"
maxretries="${BUILDBOT_MAXRETRIES}"
nologrotate="${BUILDBOT_NOLOGROTATE}"
numcpus="${BUILDBOT_NUMCPUS}"
protocol="${BUILDBOT_PROTOCOL}"
proxy_connection_string="${BUILDBOT_PROXY_CONNECTION}"
log_size="${BUILDBOT_LOG_SIZE:-10000000}"
umask="${BUILDBOT_UMASK}"
use_tls="${BUILDBOT_USE_TLS}"
master="${BUILDBOT_MASTER}"
name="${BUILDBOT_WORKER_NAME}"
pass="${BUILDBOT_WORKER_PASS}"

if [ -n "${BUILDBOT_FORCE}" ] || [ `ls -1 "${dbdir}" | wc -l` -eq 0 ]; then
    set --

    if [ -n "${keepalive}" ]; then
        set -- --keepalive="${keepalive}"
    fi
    
    if [ -n "${nologrotate}" ]; then
        set -- "$@" --no-logrotate
    else
        set -- "$@" --log-count="${log_count}" --log-size="${log_size}"
    fi

    if [ -n "${maxdelay}" ]; then
        set -- "$@" --maxdelay="${maxdelay}"
    fi

    if [ -n "${maxretries}" ]; then
        set -- "$@" --maxretries="${maxretries}"
    fi

    if [ -n "${numcpus}" ]; then
        set -- "$@" --numcpus="${numcpus}"
    fi

    if [ -n "${protocol}" ]; then
        set -- "$@" --protocol="${protocol}"
    fi

    if [ -n "${proxy_connection_string}" ]; then
        set -- "$@" --proxy-connection-string="${proxy_connection_string}"
    fi

    if [ -n "${umask}" ]; then
        set -- "$@" --umask="${umask}"
    fi

    if [ -n "${use_tls}" ]; then
        set -- "$@" --use-tls
    fi

    if [ -z "${master}" ]; then
        err "BUILDBOT_MASTER environment variable is not set but is required."
        exit 1
    fi

    if [ -z "${name}" ]; then
        err "BUILDBOT_WORKER_NAME environment variable is not set but is required."
        exit 1
    fi

    if [ -z "${pass}" ]; then
        err "BUILDBOT_WORKER_PASS environment variable is not set but is required."
        exit 1
    fi

    buildbot-worker create-worker "$@" "${dbdir}" "${master}" "${name}" "${pass}"

    if [ -n "${admin}" ] && [ -d "${dbdir}/info" ]; then
        echo "${admin}" > "${dbdir}/info/admin"
    fi

    if [ -n "${host}" ] && [ -d "${dbdir}/info" ]; then
        echo "${host}" > "${dbdir}/info/host"
    fi
fi
