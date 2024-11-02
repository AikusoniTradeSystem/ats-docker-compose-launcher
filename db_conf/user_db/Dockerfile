# PostgreSQL 기본 이미지 사용
FROM postgres:17

RUN apt-get update && apt-get install -y gettext && rm -rf /var/lib/apt/lists/*

# 빌드 시점에 인증서 경로를 외부에서 전달받음
ARG USER_DB_SERVER_CRT_PATH=./credentials/crypto/server/user_db/server.crt
ARG USER_DB_SERVER_KEY_PATH=./credentials/crypto/server/user_db/server.key
ARG USER_DB_SERVER_SELF_CA_PATH=./credentials/crypto/server/user_db/server_self.crt
ARG USER_DB_INIT_TEMPLATE_PATH=./db_conf/user_db/templates

ARG VAULT_USER_ID
ARG VAULT_USER_PW

# 인증서 파일 복사
RUN mkdir -p /etc/ssl/certs
COPY ${USER_DB_SERVER_CRT_PATH} /etc/ssl/certs/server.crt
COPY ${USER_DB_SERVER_KEY_PATH} /etc/ssl/certs/server.key
COPY ${USER_DB_SERVER_SELF_CA_PATH} /etc/ssl/certs/ca.crt

# PostgreSQL에 맞게 파일 권한 설정
# PostgreSQL은 개인 키 파일의 권한이 600이어야 함
RUN chown postgres:postgres /etc/ssl/certs/server.crt /etc/ssl/certs/server.key /etc/ssl/certs/ca.crt && \
    chmod 600 /etc/ssl/certs/server.key && \
    chmod 644 /etc/ssl/certs/server.crt && \
    chmod 644 /etc/ssl/certs/ca.crt

# 템플릿 파일을 복사하고 환경 변수를 치환하여 초기화 스크립트로 사용
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

CMD ["postgres", "-c", "ssl=on", \
     "-c", "ssl_cert_file=/etc/ssl/certs/server.crt", \
     "-c", "ssl_key_file=/etc/ssl/certs/server.key", \
     "-c", "ssl_ca_file=/etc/ssl/certs/ca.crt" \
     ]