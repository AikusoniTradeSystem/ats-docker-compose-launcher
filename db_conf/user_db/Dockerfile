# PostgreSQL 기본 이미지 사용
FROM postgres:17

# 빌드 시 환경 변수로 경로 받기
ARG SSL_PATH_IN_CONTAINER=/var/lib/postgresql/ssl
ARG ENTRYPOINT_PATH=./db_conf/user_db/custom_entrypoint.sh

# 필수 패키지 설치
RUN apt-get update && apt-get install -y gettext openssl && rm -rf /var/lib/apt/lists/*

# 임시 인증서 파일 생성
RUN mkdir -p $SSL_PATH_IN_CONTAINER && \
    openssl genrsa -out $SSL_PATH_IN_CONTAINER/server.key 2048 && \
    openssl req -new -key $SSL_PATH_IN_CONTAINER/server.key -out $SSL_PATH_IN_CONTAINER/server.csr -subj "/CN=localhost" && \
    openssl x509 -req -in $SSL_PATH_IN_CONTAINER/server.csr -signkey $SSL_PATH_IN_CONTAINER/server.key -out $SSL_PATH_IN_CONTAINER/server.crt && \
    openssl req -new -x509 -key $SSL_PATH_IN_CONTAINER/server.key -out $SSL_PATH_IN_CONTAINER/ca.crt -days 3650 -subj "/CN=localhost" && \
    rm -f $SSL_PATH_IN_CONTAINER/server.csr

# PostgreSQL에 맞게 파일 권한 설정
RUN chown postgres:postgres $SSL_PATH_IN_CONTAINER/server.crt $SSL_PATH_IN_CONTAINER/server.key $SSL_PATH_IN_CONTAINER/ca.crt && \
    chmod 600 $SSL_PATH_IN_CONTAINER/server.key && \
    chmod 644 $SSL_PATH_IN_CONTAINER/server.crt && \
    chmod 644 $SSL_PATH_IN_CONTAINER/ca.crt

# 환경 변수로 c 파일 경로 설정 (컨테이너 실행 시 사용)
ENV SSL_CERT_FILE=$SSL_PATH_IN_CONTAINER/server.crt
ENV SSL_KEY_FILE=$SSL_PATH_IN_CONTAINER/server.key
ENV SSL_CA_FILE=$SSL_PATH_IN_CONTAINER/ca.crt

# 초기화용 템플릿 파일 복사
ARG USER_DB_INIT_TEMPLATE_PATH=./db_conf/user_db/templates
RUN mkdir -p /etc/postgresql/templates
COPY ${USER_DB_INIT_TEMPLATE_PATH} /etc/postgresql/templates

ARG USER_DB_CUSTOM_ENTRY_POINT=./db_conf/user_db/custom_entrypoint.sh
COPY ${USER_DB_CUSTOM_ENTRY_POINT} /docker-entrypoint-initdb.d/custom_entrypoint.sh
RUN chown -R postgres:postgres docker-entrypoint-initdb.d && \
    chmod -R u+rwX,go-rwx docker-entrypoint-initdb.d && \
    chmod +x /docker-entrypoint-initdb.d/custom_entrypoint.sh

USER postgres
ENTRYPOINT ["/docker-entrypoint-initdb.d/custom_entrypoint.sh"]