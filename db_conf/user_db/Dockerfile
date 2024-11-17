# PostgreSQL 기본 이미지 사용
FROM postgres:17

# 빌드 시 환경 변수로 경로 받기
ARG SSL_CERT_DIR=/etc/ssl/certs

# 필수 패키지 설치
RUN apt-get update && apt-get install -y gettext openssl && rm -rf /var/lib/apt/lists/*

# 임시 인증서 파일 생성
RUN mkdir -p $SSL_CERT_DIR && \
    openssl genrsa -out $SSL_CERT_DIR/server.key 2048 && \
    openssl req -new -key $SSL_CERT_DIR/server.key -out $SSL_CERT_DIR/server.csr -subj "/CN=localhost" && \
    openssl x509 -req -in $SSL_CERT_DIR/server.csr -signkey $SSL_CERT_DIR/server.key -out $SSL_CERT_DIR/server.crt && \
    openssl req -new -x509 -key $SSL_CERT_DIR/server.key -out $SSL_CERT_DIR/ca.crt -days 3650 -subj "/CN=localhost" && \
    rm -f $SSL_CERT_DIR/server.csr

# PostgreSQL에 맞게 파일 권한 설정
RUN chown postgres:postgres $SSL_CERT_DIR/server.crt $SSL_CERT_DIR/server.key $SSL_CERT_DIR/ca.crt && \
    chmod 600 $SSL_CERT_DIR/server.key && \
    chmod 644 $SSL_CERT_DIR/server.crt && \
    chmod 644 $SSL_CERT_DIR/ca.crt

# 환경 변수로 SSL 파일 경로 설정 (컨테이너 실행 시 사용)
ENV SSL_CERT_FILE=$SSL_CERT_DIR/server.crt
ENV SSL_KEY_FILE=$SSL_CERT_DIR/server.key
ENV SSL_CA_FILE=$SSL_CERT_DIR/ca.crt

# 템플릿 파일을 복사하고 환경 변수를 치환하여 초기화 스크립트로 사용
ARG USER_DB_INIT_TEMPLATE_PATH=./db_conf/user_db/templates

RUN mkdir -p /etc/postgresql/templates
COPY ${USER_DB_INIT_TEMPLATE_PATH} /etc/postgresql/templates

RUN mkdir -p /docker-entrypoint-initdb.d /etc/postgresql && \
    for file in /etc/postgresql/templates/*.sql.template; do \
        echo "Found: $file" && \
        [ -e "$file" ] || continue; \
        envsubst < "$file" > "/docker-entrypoint-initdb.d/$(basename "${file%.template}")"; \
    done && \
    for file in /etc/postgresql/templates/*.conf.template; do \
        echo "Found: $file" && \
        [ -e "$file" ] || continue; \
        envsubst < "$file" > "/docker-entrypoint-initdb.d/$(basename "${file%.template}")"; \
    done

# PostgreSQL을 실행할 때 SSL 파일 경로를 환경변수로 참조
CMD ["postgres", "-c", "ssl=on", \
     "-c", "ssl_cert_file=$SSL_CERT_FILE", \
     "-c", "ssl_key_file=$SSL_KEY_FILE", \
     "-c", "ssl_ca_file=$SSL_CA_FILE"]