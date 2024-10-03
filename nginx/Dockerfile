FROM alpine:latest

# Install dependencies
RUN apk add --no-cache \
    build-base \
    pcre-dev \
    zlib-dev \
    openssl-dev \
    wget \
    git

# Set the environment variable for the NGINX version
ARG NGINX_VERSION=1.27.2

# Download and extract NGINX source
RUN wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz && \
    tar zxvf nginx-$NGINX_VERSION.tar.gz

# Compile NGINX with the desired modules
RUN cd nginx-$NGINX_VERSION && \
    ./configure \
    --prefix=/custom/nginx \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_auth_request_module && \
    make && \
    make install

# Clean up to reduce image size
RUN rm -rf nginx-$NGINX_VERSION nginx-$NGINX_VERSION.tar.gz

# Expose the necessary ports
EXPOSE 8080

# Run NGINX
CMD ["/custom/nginx/sbin/nginx", "-g", "daemon off;"]
