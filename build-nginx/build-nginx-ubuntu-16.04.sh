#!/bin/bash

apt-get update

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

# wget http://172.17.0.1:8000/nginx/nginx-${NGINX_STABLE_VERSION}.tar.gz
wget http://nginx.org/download/nginx-${NGINX_STABLE_VERSION}.tar.gz \
    -O nginx-${NGINX_STABLE_VERSION}.tar.gz \
    && tar -xzvf nginx-${NGINX_STABLE_VERSION}.tar.gz \
    && rm nginx-${NGINX_STABLE_VERSION}.tar.gz

#dir nginx-1.7.7


##### Download module ngx_echo #####
ECHO_NGINX_MODULE_VERSION=v0.56

# wget http://172.17.0.1:8000/nginx/echo-nginx-module_${ECHO_NGINX_MODULE_VERSION}.tar.gz
wget https://github.com/openresty/echo-nginx-module/archive/${ECHO_NGINX_MODULE_VERSION}.tar.gz \
    -O echo-nginx-module_${ECHO_NGINX_MODULE_VERSION}.tar.gz \
    && tar -xzvf echo-nginx-module_${ECHO_NGINX_MODULE_VERSION}.tar.gz \
    && rm echo-nginx-module_${ECHO_NGINX_MODULE_VERSION}.tar.gz

#dir echo-nginx-module-0.56


##### Download module nginx-sticky #####
# Source: https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng/overview
NGINX_STICKY_MODULE_NG_VERSION=1.2.5

# wget http://172.17.0.1:8000/nginx/ nginx-sticky-module-ng-${NGINX_STICKY_MODULE_NG_VERSION}.tar.gz
wget https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng/get/${NGINX_STICKY_MODULE_NG_VERSION}.tar.gz \
    -O nginx-sticky-module-ng-${NGINX_STICKY_MODULE_NG_VERSION}.tar.gz \
    && tar -xzvf nginx-sticky-module-ng-${NGINX_STICKY_MODULE_NG_VERSION}.tar.gz \
    && rm nginx-sticky-module-ng-${NGINX_STICKY_MODULE_NG_VERSION}.tar.gz \
    && mv nginx-goodies-nginx-sticky-module-ng-* nginx-sticky-module-ng-${NGINX_STICKY_MODULE_NG_VERSION}

##### Download module pagespeed #####
#
# Source: https://modpagespeed.com/doc/build_ngx_pagespeed_from_source
# Tutorial: https://www.howtoforge.com/tutorial/how-to-install-nginx-and-google-pagespeed-on-ubuntu-16-04/
#
NPS_VERSION=1.11.33.3

# wget http://172.17.0.1:8000/nginx/ngx_pagespeed_${NPS_VERSION}.tar.gz
wget https://github.com/pagespeed/ngx_pagespeed/archive/v${NPS_VERSION}-beta.tar.gz \
    -O ngx_pagespeed_v${NPS_VERSION}-beta.tar.gz \
    && tar -xzvf ngx_pagespeed_v${NPS_VERSION}-beta.tar.gz \
    && rm ngx_pagespeed_v${NPS_VERSION}-beta.tar.gz \
    && mv ngx_pagespeed_* ngx_pagespeed-${NPS_VERSION}-beta/ \
    && cd ngx_pagespeed-${NPS_VERSION}-beta/ \
    && wget https://dl.google.com/dl/page-speed/psol/${PSOL_VERSION}.tar.gz \
        -O pagespeed-psol_${PSOL_VERSION}.gz \
    && tar -xzvf pagespeed-psol_${PSOL_VERSION}.tar.gz \
    && cd ..

# wget http://172.17.0.1:8000/nginx/pagespeed-psol_${PSOL_VERSION}.tar.gz
#dir ngx_pagespeed-1.9.32.2-beta

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
    --with-http_spdy_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_xslt_module \
    --with-ipv6 \
    --with-pcre \
    --with-debug \
    --add-module=../echo-nginx-module-${ECHO_NGINX_MODULE_VERSION}/ \
    --add-module=../nginx-sticky-module-ng-${NGINX_STICKY_MODULE_NG_VERSION}/ \
    --add-module=../ngx_pagespeed-${NPS_VERSION}-beta/

make && make install

# configure nginx
useradd -r nginx

rm -rf /etc/nginx
tar xzf /tmp/build-nginx/nginx-config.tgz -C /etc/

# cleaning
DEBIAN_FRONTEND=noninteractive \
apt-get purge --auto-remove -y wget \
    gcc g++ make \
    zlib1g-dev  \
    libpcre3-dev \
    libssl-dev \
    libxslt1-dev \
    libxml2-dev \
    libgd-dev \
    libgd2-xpm-dev \
    libgeoip-dev

rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
