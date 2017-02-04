#!/bin/bash
set -e

if [ ! -f /etc/nginx/certs/dhparam.pem ]; then
    openssl dhparam -out /etc/nginx/certs/dhparam.pem 2048
fi

if [ "$1" = 'nginx' ]; then

    # fix permissions and ownership of /var/cache/pagespeed
    mkdir -p -m 755 /var/cache/pagespeed
    chown -R nginx:nginx /var/cache/pagespeed

    exec "$@"
fi

exec "$@"

