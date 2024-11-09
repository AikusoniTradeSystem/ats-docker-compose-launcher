# ats-quick-launcher

AikusoniTradeSystem 앱을 도커를 사용해 배포할 때 사용

### 개요
- Docker Compose를 사용해 손쉽게 앱을 배포 할 수 있습니다.

### 기본사항
- 프로젝트 루트에 예시로 작성된 배치 스크립트를 정렬된 순서대로 실행합니다.
- *_BASE_* 형태의 스크립트는 공용 스크립트로 05_0000_generate_vault_certs.sh 같은 다른 스크립트가 실행합니다.
- 스크립트는 의존성 순서대로 작성되어 있습니다.
- 관련 서비스를 실행하는 스크립트는 R로 시작합니다. (예: R00_start_network.sh)
- 관련 서비스를 종료하는 스크립트는 D로 시작합니다. (예: D00_stop_network.sh)
- D99_stop_all.sh 스크립트를 실행하면 모든 서비스를 종료합니다.
- 기타 스크립트는 X또는 ETC로 시작합니다. (예: X21_seal_vault.sh, X21_unseal_vault.sh, ETC_load_env.sh)
- 각 스크립트는 load_env.sh를 통해 환경변수를 로딩하며, load_env.sh는 sample_configs 폴더 내의 .envconfig 파일을 로딩합니다.
- load_function.sh에는 로깅 함수가 있습니다. 쉘 스크립트에서 log d "message" 또는 log i "message"와 같이 사용할 수 있습니다.

### 스크립트 설명
같은 유형의 모든 스크립트는 숫자 순서대로 실행되어야 합니다. \
(예: R00 -> R01 -> R10 -> R20 -> R21) \
(스크립트 헤더에 붙는 숫자는 개발진행에 따라 변경될 수 있어서 생략했습니다.)
1. 먼저 네트워크와 볼륨 초기화가 필요합니다. (start_network.sh / start_volumes.sh) )
1. 루트 CA와 중간CA를 생성합니다. (generate_root_ca)
1. Vault를 실행합니다. (start_vault.sh)
1. Vault를 초기화합니다. (init_vault.sh)
1. Vault Engine들을 설치합니다.(secrets_engine_database_enable.sh 등)
1. (옵션) 모니터링 서비스들을 실행합니다. (start_monitoring.sh)
1. DB를 실행하고 초기화합니다. (start_db.sh)
1. 볼트와 DB를 연결합니다. (connect_vault_to_db.sh)
1. 볼트를 통해 서비스용 키들을 생성합니다. (generate_service_credentials.sh)
1서비스를 실행합니다. (start_services.sh)