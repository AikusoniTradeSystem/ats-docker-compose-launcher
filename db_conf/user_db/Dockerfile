# PostgreSQL 기본 이미지 사용
FROM postgres:17

# 인증서 파일 복사
COPY ./certs/vault/server.crt /etc/ssl/certs/server.crt
COPY ./certs/vault/server.key /etc/ssl/certs/server.key
COPY ./certs/vault/ca.crt /etc/ssl/certs/ca.crt

# PostgreSQL에 맞게 인증서 파일 권한 설정
# PostgreSQL은 개인 키 파일의 권한이 600이어야 함
RUN chown postgres:postgres /etc/ssl/certs/server.crt /etc/ssl/certs/server.key /etc/ssl/certs/ca.crt && \
    chmod 600 /etc/ssl/certs/server.key && \
    chmod 644 /etc/ssl/certs/server.crt && \
    chmod 644 /etc/ssl/certs/ca.crt

# 기본 PostgreSQL 설정을 SSL을 사용하도록 명령어 전달
CMD ["postgres", "-c", "ssl=on", \
     "-c", "ssl_cert_file=/etc/ssl/certs/server.crt", \
     "-c", "ssl_key_file=/etc/ssl/certs/server.key", \
     "-c", "ssl_ca_file=/etc/ssl/certs/ca.crt"]

