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


##### Download nginx ######
wget http://nginx.org/download/nginx-1.7.7.tar.gz -O nginx-1.7.7.tar.gz
# wget http://172.17.42.1:8000/nginx/nginx-1.7.7.tar.gz
tar -xzvf nginx-1.7.7.tar.gz

#dir nginx-1.7.7


##### Download module ngx_echo #####
wget https://github.com/openresty/echo-nginx-module/archive/v0.56.tar.gz -O echo-nginx-module_v0.56.tar.gz
# wget http://172.17.42.1:8000/nginx/echo-nginx-module_v0.56.tar.gz
tar -xzvf echo-nginx-module_v0.56.tar.gz

#dir echo-nginx-module-0.56


##### Download module nginx-sticky #####
# Source: https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng/overview
wget https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng/get/1.2.5.tar.gz -O nginx-sticky-module-ng-1.2.5.tar.gz
# wget http://172.17.42.1:8000/nginx/ nginx-sticky-module-ng-1.2.5.tar.gz
tar -xzvf nginx-sticky-module-ng-1.2.5.tar.gz
mv nginx-goodies-nginx-sticky-module-ng-bd312d586752 nginx-sticky-module-ng-1.2.5


##### Download module pagespeed #####
wget https://github.com/pagespeed/ngx_pagespeed/archive/v1.9.32.2-beta.tar.gz -O ngx_pagespeed_v1.9.32.2-beta.tar.gz
# wget http://172.17.42.1:8000/nginx/ngx_pagespeed_v1.9.32.2-beta.tar.gz
tar -xzvf ngx_pagespeed_v1.9.32.2-beta.tar.gz

#dir ngx_pagespeed-1.9.32.2-beta

cd ngx_pagespeed-1.9.32.2-beta/

wget https://dl.google.com/dl/page-speed/psol/1.9.32.2.tar.gz -O pagespeed-psol_v1.9.32.2.tar.gz
# wget http://172.17.42.1:8000/nginx/pagespeed-psol_v1.9.32.2.tar.gz
tar -xzvf pagespeed-psol_v1.9.32.2.tar.gz

cd ..


cd /tmp/build-nginx/nginx-1.7.7/

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
    --add-module=../echo-nginx-module-0.56/ \
    --add-module=../nginx-sticky-module-ng-1.2.5/ \
    --add-module=../ngx_pagespeed-1.9.32.2-beta/


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
