# PKI 엔진에서 인증서 발급 권한만 부여
path "pki/issue/database-server-role" {
  capabilities = ["create"]
}

# 서버 인증서 발급에 필요한 역할(role) 정보 읽기 권한
path "pki/roles/database-server-role" {
  capabilities = ["read"]
}