# 🖥️ 데스크톱 PC 환경 최적화 (Desktop PC Optimization)

이 디렉터리는 데스크톱 PC 환경에서 AI 연산, 로컬 에이전트 실행 및 대용량 컴파일 등 개발 생산성 극대화를 목표로 최적화(Optimization)를 진행하고 환경을 격리 관리하는 공간입니다.

모든 최적화 절차는 `안정성 검증 → 전력/지연 조율 → 적용 결과 수치화 → 복구 방안 확보` 원칙을 철저히 준수합니다.

---

## 📋 대상 시스템 사양 (System Specs)

| 분류 | 세부 항목 | 사양 |
|---|---|---|
| **기본 사양** | 모델 / 메인보드 | Intel H170 조립 PC (Desktop) |
| | CPU | Intel(R) Core(TM) i7-6700K CPU @ 4.00GHz (4C / 8T) |
| | RAM | DDR4 32GB (31.94GB) |
| | GPU | NVIDIA GeForce GTX 1070 8GB |
| | OS | Windows 10 Pro 64-bit (10.0.19045) |
| **저장 장치** | SSD (C:) | SSD (NTFS DisableDeleteNotify = 0, TRIM 활성 상태) |
| **네트워크** | NIC | Killer E2400 Gigabit Ethernet |

---

## 🛠️ 최적화 추진 계획 및 상태

### 1. 전력 및 발열 튜닝 (Power & Thermal)
- [x] 윈도우 고성능 프로필 세부 튜닝: 최소 프로세서 상태 `10%`로 완화 (Idle 시 발열/소음 획기적 개선, 로드 시 즉시 100% 가속)

### 2. 메모리 및 지연 시간 최적화 (Memory & Latency)
- [x] 백그라운드 네트워크 대역 제한 해제 (`NetworkThrottlingIndex` = `0xffffffff` 적용)
- [x] 어댑터(Killer E2400) 레이턴시 단축 레지스트리 (`TcpAckFrequency`=1, `TCPNoDelay`=1) 주입 완료

### 3. AI 및 개발 환경 최적화 (AI & Dev Stack)
- [x] 디스크 I/O 최적화를 위한 SSD TRIM 강제 구동 (`defrag.exe /C /O` 완료)
- [x] Antigravity IDE 경량화 (불필요한 타 언어 LSP 및 중복 포맷터 등 22개 확장 프로그램 삭제 완료)
- [x] Claude Code CLI 스킬 최적화 (불필요한 3개 플러그인 삭제 완료)

---

## 📂 파일 구성
- [implementation_plan.md](implementation_plan.md): 최적화 설계 및 추진 계획서
- [optimization_result.md](optimization_result.md): 전원, 네트워크 튜닝 검증 수치 및 벤치마크 결과 리포트
- [antigravity-agent-environment.md](antigravity-agent-environment.md): Antigravity IDE 슬리밍 내역 및 최적의 확장 프로그램 상태 기록
- [claude-agent-environment.md](claude-agent-environment.md): Claude Code의 로컬 스킬 및 권한 설정 상세 가이드
- `scratch/`: 최적화 관련 로컬 실행 스크립트 및 복구(Rollback) 스크립트 저장소 (아래 복구 경로 참조)

---

## ↩️ 롤백 (Rollback) 및 복구 경로

시스템 설정 튜닝(전원, 네트워크)을 최적화 적용 전 순정 상태로 안전하게 복구하고 싶으신 경우, 아래 경로에 있는 배치 스크립트를 관리자 권한으로 실행하시기 바랍니다.

- **복구 스크립트**: [desktop/scratch/rollback_optimization.bat](scratch/rollback_optimization.bat)
