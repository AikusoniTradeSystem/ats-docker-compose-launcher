# pki 엔진에 대한 접근을 허용하는 정책 예시
path "pki/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}