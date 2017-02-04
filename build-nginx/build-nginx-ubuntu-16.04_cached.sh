#!/bin/bash

# make utf-8 enabled by default
apt-get install -y locales \
&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

DEBIAN_FRONTEND=noninteractive \
apt-get install -y wget \
    gcc g++ make \
    zlib1g zlib1g-dev \
    libpcre3 libpcre3-dev \
    libssl1.0.0 libssl-dev \
    libxslt1.1 libxslt1-dev \
    libxml2 libxml2-dev \
    libgd3 libgd-dev libgd2-xpm-dev \
    libgeoip1 libgeoip-dev
    #libgoogle-perftools-dev

mkdir -pv /tmp/build-nginx/
cd /tmp/build-nginx/

##### Download nginx stable version ######
# NGINX_STABLE_VERSION=1.7.7
NGINX_STABLE_VERSION=1.10.3

wget -q http://172.17.0.1:8000/nginx-${NGINX_STABLE_VERSION}.tar.gz \
    -O nginx-${NGINX_STABLE_VERSION}.tar.gz \
    && tar -xzvf nginx-${NGINX_STABLE_VERSION}.tar.gz \
    && rm nginx-${NGINX_STABLE_VERSION}.tar.gz


##### Download module ngx_echo #####
ECHO_NGINX_MODULE_VERSION=0.56

wget -q http://172.17.0.1:8000/echo-nginx-module_v${ECHO_NGINX_MODULE_VERSION}.tar.gz \
    -O echo-nginx-module_v${ECHO_NGINX_MODULE_VERSION}.tar.gz \
    && tar -xzvf echo-nginx-module_v${ECHO_NGINX_MODULE_VERSION}.tar.gz \
    && rm echo-nginx-module_v${ECHO_NGINX_MODULE_VERSION}.tar.gz


##### Download module nginx-sticky #####
# Source: https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng/overview
# NGINX_STICKY_MODULE_NG_VERSION=1.2.5

# wget -q http://172.17.0.1:8000/nginx-sticky-module-ng-${NGINX_STICKY_MODULE_NG_VERSION}.tar.gz \
#     -O nginx-sticky-module-ng-${NGINX_STICKY_MODULE_NG_VERSION}.tar.gz \
#     && tar -xzvf nginx-sticky-module-ng-${NGINX_STICKY_MODULE_NG_VERSION}.tar.gz \
#     && rm nginx-sticky-module-ng-${NGINX_STICKY_MODULE_NG_VERSION}.tar.gz \
#     && mv nginx-goodies-nginx-sticky-module-ng-* nginx-sticky-module-ng-${NGINX_STICKY_MODULE_NG_VERSION}

##### Download module pagespeed #####
#
# Source: https://modpagespeed.com/doc/build_ngx_pagespeed_from_source
# Tutorial: https://www.howtoforge.com/tutorial/how-to-install-nginx-and-google-pagespeed-on-ubuntu-16-04/
#
NPS_VERSION=1.11.33.3

wget -q http://172.17.0.1:8000/ngx_pagespeed_v${NPS_VERSION}-beta.tar.gz \
    -O ngx_pagespeed_v${NPS_VERSION}-beta.tar.gz \
    && tar -xzvf ngx_pagespeed_v${NPS_VERSION}-beta.tar.gz \
    && rm ngx_pagespeed_v${NPS_VERSION}-beta.tar.gz \
    && cd ngx_pagespeed-${NPS_VERSION}-beta/ \
    && wget -q http://172.17.0.1:8000/pagespeed-psol_${NPS_VERSION}.tar.gz \
        -O pagespeed-psol_${NPS_VERSION}.tar.gz \
    && tar -xzvf pagespeed-psol_${NPS_VERSION}.tar.gz \
    && cd ..

cd /tmp/build-nginx/nginx-${NGINX_STABLE_VERSION}/

./configure \
    --prefix=/usr/share/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/lock/nginx.lock \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/access.log \
    --user=nginx \
    --group=nginx \
    --without-mail_pop3_module \
    --without-mail_imap_module \
    --without-mail_smtp_module \
    --without-http_fastcgi_module \
    --without-http_uwsgi_module \
    --without-http_scgi_module \
    --with-file-aio \
    --with-http_addition_module \
    --with-http_dav_module \
    --with-http_degradation_module \
    --with-http_geoip_module \
    --with-http_gzip_static_module \
    --with-http_image_filter_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_v2_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_xslt_module \
    --with-ipv6 \
    --with-pcre \
    --with-debug \
    --add-module=../echo-nginx-module-${ECHO_NGINX_MODULE_VERSION} \
    --add-module=../ngx_pagespeed-${NPS_VERSION}-beta
    # --add-module=../nginx-sticky-module-ng-${NGINX_STICKY_MODULE_NG_VERSION} \

make && make install

# configure nginx
useradd -r nginx

rm -rf /etc/nginx
# tar xzf /tmp/build-nginx/nginx-config.tgz -C /etc/

mkdir -pv /var/www/html

# cleaning
DEBIAN_FRONTEND=noninteractive \
apt-get purge --auto-remove -y wget -q \
    gcc g++ make \
    zlib1g-dev  \
    libpcre3-dev \
    libssl-dev \
    libxslt1-dev \
    libxml2-dev \
    libgd-dev \
    libgd2-xpm-dev \
    libgeoip-dev

rm -rf /tmp/* /var/tmp/*
