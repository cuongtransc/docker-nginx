#!/bin/bash
set -e

if [ "$1" = 'nginx' ]; then

    # fix permissions and ownership of /var/cache/pagespeed
    mkdir -p -m 755 /var/cache/pagespeed
    chown -R nginx:nginx /var/cache/pagespeed

    exec "$@"
fi

exec "$@"

