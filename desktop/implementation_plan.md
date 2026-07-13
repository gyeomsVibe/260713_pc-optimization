# 데스크톱 PC 최적화 구현 계획서 (Implementation Plan)

본 계획서는 데스크톱 PC 환경에서 AI 연산 속도를 극대화하고, 불필요한 발열과 디스크/네트워크 지연(Latency)을 해소하며, Antigravity IDE 및 Claude CLI의 리소스 낭비를 막기 위해 수립된 통합 튜닝 설계도입니다.

---

## 1. 최적화 대상 및 범위
- **OS**: Windows 10 Pro 64-bit
- **CPU**: Intel(R) Core(TM) i7-6700K (4 Cores / 8 Threads)
- **RAM**: DDR4 32GB
- **GPU**: NVIDIA GeForce GTX 1070 8GB
- **대상 에이전트**: Antigravity IDE, Claude Code (CLI)

---

## 2. 세부 제안 및 변경 조치

### 1) 전력 및 발열 최적화 (Power & Thermal)
- **현상**: 고성능 전원 관리 프로필 선택으로 인해 최소 프로세서 상태가 `100%`로 고정됨. Idle 상태에서도 CPU가 최대 속도를 유지하여 미세 발열 및 팬 소음 발생.
- **해결책**: 고성능 프로필의 AC 최소 프로세서 상태를 `10%`로 안전하게 하향 조정. Idle 상태 온도를 내리되 로드 시 즉각 부스트(Boost)되도록 조율.

### 2) 네트워크 및 API RTT 단축 (Latency)
- **현상**: 기가비트 이더넷 환경에서 기본 TCP 스택이 작은 패킷의 즉시 송신을 버퍼링하는 Nagle 알고리즘 사용 중.
- **해결책**: 활성 어댑터(Killer E2400) IP 레지스트리에 `TcpAckFrequency = 1` 및 `TCPNoDelay = 1` 주입.
- **멀티미디어 네트워크 조율**: `NetworkThrottlingIndex` = `0xffffffff` 적용으로 백그라운드 스로틀링 해제.

### 3) SSD 디스크 I/O 최적화 (Disk I/O)
- **현상**: 가상환경 패키지 로드 및 임시 I/O 생성 시의 지연 요소 방지 필요.
- **해결책**: 백그라운드로 모든 SSD 볼륨에 TRIM 최적화(`defrag.exe /C /O`) 수행.

### 4) IDE 확장 프로그램 슬리밍 (Extension Slimming)
- **현상**: 에이전트와 관계없는 무거운 타 언어 서버(Java, C++, Rust, PHP, Flutter 등) 및 중복 포맷터가 실행되어 대규모 백그라운드 리소스(LSP, JVM 등) 점유.
- **해결책**: 불필요한 22개 확장 프로그램 일괄 제거. 파이썬 환경은 `ms-python.python`, `ms-pyright.pyright`, `charliermarsh.ruff`로 슬림화.

### 5) Claude Code (CLI) 스킬 다이어트
- **현상**: 미사용 데모 플러그인(`example-skills`, `plugin-dev`, `frontend-design`)이 로드되어 시작 속도 및 프롬프트 토큰 점유율 유발.
- **해결책**: 해당 3개 플러그인 제거 및 Canva MCP 연동 상태 원인 분석.

---

## 3. 검증 계획
- 전원 및 레지스트리 설정값 쿼리(Query) 검증.
- `antigravity-ide --list-extensions` 및 `claude plugin list` 교차 리스트 검증.
- 최적화 작업 전 안전한 롤백을 보장하는 `rollback_optimization.bat` 스크립트 작성 및 테스트.
