# Author: Tran Huu Cuong
# Date: 2014-12-12
#
# Build:
#       docker build -t cocd/nginx:1.7 .
#
# Run:
#       docker run -d -p 80:80 -p 443:443 --name nginx cocd/nginx:1.7
#

# FROM debian:wheezy
# FROM debian:jessie

FROM ubuntu:14.04
MAINTAINER Tran Huu Cuong "tranhuucuong91@gmail.com"

# using apt-cacher-ng proxy for caching deb package
RUN echo 'Acquire::http::Proxy "http://172.17.0.1:3142/";' >> /etc/apt/apt.conf.d/01proxy

COPY build-nginx /tmp/build-nginx
RUN DEBIAN_FRONTEND=noninteractive bash /tmp/build-nginx/build-nginx-ubuntu-14.04.sh

# make utf-8 enabled by default
ENV LANG en_US.utf8

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

COPY ./docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

# Define working directory
WORKDIR /etc/nginx

# Create mount point
VOLUME ["/etc/nginx/"]

# Expose port
EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]

