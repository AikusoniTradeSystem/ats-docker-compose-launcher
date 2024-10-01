# ats-quick-launcher
한큐에 AikusoniTradeSystem 앱을 배포할 때 사용

### 목록
- [개요](#개요)
- [사용법](#사용법)
- [끄는 법](#끄는-법)

### 개요
- Docker Compose를 사용해 손쉽게 앱을 배포 할 수 있다.

### 사용법 (예시)
> 요약 :
> 의존성대로 도커 컴포즈를 실행한다.
> 1. 00_docekr-compose.network.yml
> 1. 10_docekr-compose.db.yml 
> 2. 20_docker-compose.vault.yml
> 3. 30_docker-compose.monitoring.yml
> 4. 40_docker-compose.yml (혹은 40_docker-compose.dev.yml)

1. 이 레포지토리를 클론한다.
```sh
$ git clone https://github.com/AikusoniTradeSystem/ats-quick-launcher.git
```

2. 프로젝트 루트에 쉘 스크립트를 만든다. \
이 쉘 스크립트는 필요한 환경변수를 설정하고 도커 컴포즈를 올리는 역할을 한다.
> 다음은 예시 스크립트
```sh
# 네트워크 시작 스크립트
$ vi network_start.sh
#!/bin/bash

(
  docker compose -f 00_docker-compose.network.yml pull
  docker compose -f 00_docker-compose.network.yml build --no-cache
  docker compose -f 00_docker-compose.network.yml up -d
)
```

```sh
# DB 시작 스크립트
$ vi db_start.sh
#!/bin/bash

(
  export PG_DATA=/home/ats/pg_data

  docker compose -f 10_docker-compose.db.yml pull
  docker compose -f 10_docker-compose.db.yml build --no-cache
  docker compose -f 10_docker-compose.db.yml up -d
)
```

```sh
# Vault 시작 스크립트  
$ vi vault_start.sh
#!/bin/bash

(
  docker compose -f 20_docker-compose.vault.yml pull
  docker compose -f 20_docker-compose.vault.yml build --no-cache
  docker compose -f 20_docker-compose.vault.yml up -d
)
```

```sh
# Monitoring 시작 스크립트
$ vi monitoring_start.sh
#!/bin/bash

(
    # determine the architecture to build cadvisor image
    ARCH=$(uname -m)
    case "$ARCH" in
      x86_64)
        GOARCH="amd64"
        ;;
      aarch64)
        GOARCH="arm64"
        ;;
      *)
        echo "Unknown server architecture: $ARCH"
        exit 1
        ;;
    esac
    
    export GOARCH=$GOARCH
    
    docker compose -f 30_docker-compose.monitoring.yml pull
    docker compose -f 30_docker-compose.monitoring.yml up -d
)
```

```sh
# App 시작 스크립트
$ vi ats_start.sh
#!/bin/bash

(
  # host environment variables
  export NGINX_LOG_HOME=/home/ats/logs/nginx
  export TEST_SERVER_SPRING_LOG_HOME=/home/ats/logs/test-server-spring
  export SESSION_AUTH_SERVER_LOG_HOME=/home/ats/logs/session-auth-server
  
  # You can add more environment variables here (See 40_docker-compose.yml)

  # run docker compose
  docker compose -f 40_docker-compose.yml pull
  docker compose -f 40_docker-compose.yml build --no-cache
  docker compose -f 40_docker-compose.yml up -d
  
  # If you want to use dev image, use the following command
  # docker compose -f 40_docker-compose.dev.yml pull 
  # docker compose -f 40_docker-compose.dev.yml build --no-cache
  # docker compose -f 40_docker-compose.dev.yml up -d
)
```

3. 작성한 쉘 스크립트를 순서대로 실행한다.
```sh
# If you have permission issues, you may need to use sudo.
$ chmod +x ats_start.sh
$ ./ats_start.sh
```

### 확인
- 다음과 같이 curl로 페이지를 호출해보거나, 웹 브라우저로 페이지를 열면 서버가 정상 작동 중인 것을 확인 할 수 있습니다. 
```sh
$ curl http://localhost:8080/api/session/swagger-ui/index.html
$ curl http://localhost:8080/api/test-server-spring/swagger-ui/index.html
````

![server-running](./documents/imgs/server-running-test.png)

### 끄는 법
1. 프로젝트 루트에 쉘 스크립트를 만든다. \
이 스크립트는 환경변수를 설정하고 도커 컴포즈를 내리는 역할을 한다.
> 다음은 예시 스크립트
```sh
$ vi all_stop.sh
#!/bin/bash
(
  docker compose -f 40_docker-compose.yml down
  docker compose -f 30_docker-compose.monitoring.yml down
  docker compose -f 20_docker-compose.vault.yml down
  docker compose -f 10_docker-compose.db.yml down
  docker compose -f 00_docker-compose.network.yml down
)
```

2. 작성한 쉘 스크립트를 실행한다.
```sh
# If you have permission issues, you may need to use sudo.
$ chmod +x all_stop.sh
$ ./all_stop.sh
```