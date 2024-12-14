# Mount secrets engines
path "sys/mounts/*" {
  capabilities = [ "create", "read", "list" ]
}

# AppRole 인증 엔진 관리 권한 (삭제나 수정은 불가)
path "sys/auth/approle" {
  capabilities = ["create", "update", "delete", "read", "list"]
}

# 다른 인증 엔진 조회 가능 (삭제나 수정은 불가)
path "sys/auth/*" {
  capabilities = ["read", "list"]
}

# AppRole을 생성하고 관리할 수 있는 권한
path "auth/approle/role/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# AppRole Secret ID 생성 및 관리 권한
path "auth/approle/role/*/secret-id" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# AppRole의 Secret ID Accessor 관리 권한
path "auth/approle/role/*/secret-id-accessor" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# AppRole을 통해 인증할 수 있는 권한
path "auth/approle/login" {
  capabilities = ["create", "read"]
}

# 하위 정책 생성 가능
path "sys/policies/acl/sub/approle/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "database/creds/*" {
  capabilities = ["read"]
}