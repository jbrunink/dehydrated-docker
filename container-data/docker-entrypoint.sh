#!/usr/bin/env bash
set -Eeo pipefail

umask 0077

cp -an /skel/* / 

[ -d "/etc/dehydrated" ] && chown -R dehydrated.dehydrated /etc/dehydrated
[ -d "/www" ] && chown -R dehydrated.dehydrated /www


if [ "${1}" = 'sh' ] || [ "${1}" = 'bash' ]; then
	echo "Running shell."
	exec "${@}"
fi

if [[ ! -z "$@" ]]; then 
	exec /sbin/su-exec dehydrated "/opt/dehydrated/dehydrated" "${@}"
fi

exec /sbin/su-exec dehydrated "/bin/sh" -c 'trap "exit" TERM;  while :; do /opt/dehydrated/dehydrated --cron; sleep 300 & wait ${!}; done;'
