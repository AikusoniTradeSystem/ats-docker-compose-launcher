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
    git \
    && rm -rf /var/lib/apt/lists/*

# Set environment variable for NGINX version


# Run a command and set the environment variable
RUN export NGINX_VERSION=$(nginx -v 2>&1 | cut -d '/' -f 2) && \
    echo "Environment variable $NGINX_VERSION is set to: $NGINX_VERSION"

# Use ENV to persist the environment variable
ENV NGINX_VERSION=$NGINX_VERSION

# Download NGINX source and headers-more module source
RUN wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz && \
    tar zxvf nginx-$NGINX_VERSION.tar.gz && \
    git checkout tags/v0.37 -b v0.37

# Compile NGINX with the headers-more module
RUN cd nginx-$NGINX_VERSION && \
    ./configure \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_auth_request_module \
    make && \
    make install

# Clean up the source files to reduce image size
RUN rm -rf /nginx-$NGINX_VERSION && rm nginx-$NGINX_VERSION.tar.gz

# Copy the NGINX configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Expose the necessary ports
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
