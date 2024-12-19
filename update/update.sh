#!/bin/sh

BASEDIR=`dirname -- "$0"` || exit $?
BASEDIR=`realpath -- "${BASEDIR}"` || exit $?

. "${BASEDIR}/update.conf"

set -xe
set -o pipefail

cat -- "${BASEDIR}/master.makejail.template" |\
    sed -Ee "s/%%TAG1%%/${TAG1}/g" > "${BASEDIR}/../master.makejail"

cat -- "${BASEDIR}/worker.makejail.template" |\
    sed -Ee "s/%%TAG1%%/${TAG1}/g" > "${BASEDIR}/../worker.makejail"

cat -- "${BASEDIR}/build-master.makejail.template" |\
    sed -Ee "s/%%PYVER%%/${PYVER}/g" > "${BASEDIR}/../build-master.makejail"

cat -- "${BASEDIR}/build-worker.makejail.template" |\
    sed -Ee "s/%%PYVER%%/${PYVER}/g" > "${BASEDIR}/../build-worker.makejail"

cat -- "${BASEDIR}/README.md.template" |\
    sed -E \
        -e "s/%%TAG1%%/${TAG1}/g" \
        -e "s/%%TAG2%%/${TAG2}/g"  > "${BASEDIR}/../README.md"
