# Author: Cuong Tran
# Date: 2017-02-04
#
# Build:
#       docker build -t cuongtransc/nginx:1.10.3 .
#
# Run:
#       docker run -d -p 80:80 -p 443:443 --name nginx cuongtransc/nginx:1.10.3
#

FROM ubuntu:16.04
MAINTAINER Cuong Tran "cuongtransc@gmail.com"

# Using apt-cacher-ng proxy for caching deb package
RUN echo 'Acquire::http::Proxy "http://172.17.0.1:3142/";' >> /etc/apt/apt.conf.d/01proxy

ENV REFRESHED_AT 2017-02-17

RUN apt-get update -qq

COPY build-nginx/build-nginx-ubuntu-16.04_cached.sh /build-nginx.sh
RUN DEBIAN_FRONTEND=noninteractive bash /build-nginx.sh \
    && rm /build-nginx.sh

RUN apt-get install -y letsencrypt

# Make utf-8 enabled by default
ENV LANG en_US.utf8

COPY nginx-config /etc/nginx

# Remove deb proxy
RUN rm /etc/apt/apt.conf.d/01proxy

# Forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

COPY ./docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

# Define working directory
WORKDIR /etc/nginx

# Create mount point
VOLUME ["/etc/nginx", "/etc/letsencrypt"]

# Expose port
EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
