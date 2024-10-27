# PostgreSQL 기본 이미지 사용
FROM postgres:17

# 빌드 시점에 인증서 경로를 외부에서 전달받음
ARG USER_DB_SERVER_CRT_PATH=./credentials/crypto/server/user_db/server.crt
ARG USER_DB_SERVER_KEY_PATH=./credentials/crypto/server/user_db/server.key
ARG USER_DB_SERVER_SELF_CA_PATH=./credentials/crypto/server/user_db/server_self.crt

# 인증서 파일 복사
COPY ${USER_DB_SERVER_CRT_PATH} /etc/ssl/certs/server.crt
COPY ${USER_DB_SERVER_KEY_PATH} /etc/ssl/certs/server.key
COPY ${USER_DB_SERVER_SELF_CA_PATH} /etc/ssl/certs/ca.crt

# PostgreSQL에 맞게 인증서 파일 권한 설정
# PostgreSQL은 개인 키 파일의 권한이 600이어야 함
RUN chown postgres:postgres /etc/ssl/certs/server.crt /etc/ssl/certs/server.key /etc/ssl/certs/ca.crt && \
    chmod 600 /etc/ssl/certs/server.key && \
    chmod 644 /etc/ssl/certs/server.crt && \
    chmod 644 /etc/ssl/certs/ca.crt

RUN chown -R postgres:postgres /var/lib/postgresql/data && \
    chmod -R 700 /var/lib/postgresql/data

# 설정 파일 복사
COPY ./db_conf/user_db/pg_hba.conf /var/lib/postgresql/data/pg_hba.conf

CMD ["postgres", "-c", "ssl=on", \
     "-c", "ssl_cert_file=/etc/ssl/certs/server.crt", \
     "-c", "ssl_key_file=/etc/ssl/certs/server.key", \
     "-c", "ssl_ca_file=/etc/ssl/certs/ca.crt"]

#CMD ["postgres"]