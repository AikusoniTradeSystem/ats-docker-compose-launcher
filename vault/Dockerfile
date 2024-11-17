FROM hashicorp/vault:1.17

ARG ENTRYPOINT_PATH=./vault/entrypoint.sh

# entrypoint.sh 파일을 컨테이너에 복사하고 실행 권한 부여
COPY ${ENTRYPOINT_PATH} /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 실행 시점에 소유자 변경 후 Vault 서버 시작
ENTRYPOINT ["/entrypoint.sh"]
