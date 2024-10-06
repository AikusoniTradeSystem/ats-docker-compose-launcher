FROM hashicorp/vault:1.17

# 빌드 시점에 인증서 경로를 외부에서 전달받음
ARG VAULT_SERVER_CERT_PATH=./credentials/certs/server/vault/server.crt
ARG VAULT_SERVER_KEY_PATH=./credentials/certs/server/vault/server.key
ARG VAULT_CA_CERT_PATH=./credentials/certs/ca/vault/ca.crt

# 인증서 파일 복사
COPY ${VAULT_SERVER_CERT_PATH} /etc/ssl/certs/server.crt
COPY ${VAULT_SERVER_KEY_PATH} /etc/ssl/private/server.key
COPY ${VAULT_CA_CERT_PATH} /etc/ssl/certs/ca.crt

# vault 계정이 인증서 파일에 접근할 수 있도록 권한 설정
RUN chown vault:vault /etc/ssl/certs/server.crt /etc/ssl/private/server.key /etc/ssl/certs/ca.crt && \
    chmod 640 /etc/ssl/private/server.key && \
    chmod 644 /etc/ssl/certs/server.crt && \
    chmod 644 /etc/ssl/certs/ca.crt

# entrypoint.sh 파일을 컨테이너에 복사하고 실행 권한 부여
COPY ./vault/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 실행 시점에 소유자 변경 후 Vault 서버 시작
ENTRYPOINT ["/entrypoint.sh"]
