# ats-quick-launcher
한큐에 AikusoniTradeSystem 앱을 배포할 때 사용

### 개요
- Docker Compose를 사용해 한번에 앱을 배포 할 수 있다.

### 사용법
1. 이 레포지토리를 클론한다.
```sh
$ git clone https://github.com/AikusoniTradeSystem/ats-quick-launcher.git
```

2. 프로젝트 루트에 쉘 스크립트를 만든다. \
이 쉘 스크립트는 필요한 환경변수를 설정하고 도커 컴포즈를 올리는 역할을 한다.
> 다음은 예시 스크립트
```sh
$ vi ats_start.sh

#!/bin/bash
(
  # subshell
  # environment variables
  export AUTH_DB_USER=sa
  export AUTH_DB_PASSWORD=password
  export AUTH_DB_DRIVER_CLASS_NAME=org.h2.Driver
  export AUTH_DB_URL=jdbc::h2::mem:testdb
  export TEST_SERVER_SPRING_LOG_HOME=~/ats/logs/TestServer
  export SESSION_AUTH_SERVER_LOG_HOME=~/ats/logs/SessionAuthServer
  export NGINX_LOG_HOME=~/ats/logs/nginx

  nohup docker compose up -d &
)
```

3. 작성한 쉘 스크립트를 실행한다.
```sh
# 권한 문제가 있으니 sudo 명령을 사용해야 할 수 도 있습니다.
$ chmod +x ats_start.sh
$ ./ats_stop.sh
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
$ vi ats_stop.sh

#!/bin/bash
(
  # subshell
  # environment variables
  export AUTH_DB_USER=sa
  export AUTH_DB_PASSWORD=password
  export AUTH_DB_DRIVER_CLASS_NAME=org.h2.Driver
  export AUTH_DB_URL=jdbc::h2::mem:testdb
  export TEST_SERVER_SPRING_LOG_HOME=~/ats/logs/TestServer
  export SESSION_AUTH_SERVER_LOG_HOME=~/ats/logs/SessionAuthServer
  export NGINX_LOG_HOME=~/ats/logs/nginx

  docker compose down
)
```

2. 작성한 쉘 스크립트를 실행한다.
```sh
# 권한 문제가 있을 수 있으니, sudo를 사용해야 할 수도 있습니다.
$ chmod +x ats_stop.sh
$ ./ats_stop.sh
```
