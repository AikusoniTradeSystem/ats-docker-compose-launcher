FROM nginx:latest

# Install dependencies required to build NGINX modules
RUN apt-get update && apt-get install -y \
    build-essential \
    libpcre3 \
    libpcre3-dev \
    zlib1g \
    zlib1g-dev \
    libssl-dev \
    wget \
    gnupg2 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download the source code for the specific version of NGINX
RUN NGINX_VERSION=$(nginx -v 2>&1 | cut -d '/' -f 2) && \
    wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz && \
    tar zxvf nginx-$NGINX_VERSION.tar.gz && \
    cd nginx-$NGINX_VERSION && \
    ./configure --with-http_ssl_module --with-http_v2_module --with-http_auth_request_module && \
    make && \
    make install

# Copy the NGINX configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Expose the necessary ports
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
