# 🖥️ 데스크톱 PC 환경 최적화 (Desktop PC Optimization)

이 디렉터리는 데스크톱 PC 환경에서 AI 연산, 로컬 에이전트 실행 및 대용량 컴파일 등 개발 생산성 극대화를 목표로 최적화(Optimization)를 진행하는 공간입니다.

모든 최적화 절차는 `안정성 검증 → 전력/지연 조율 → 적용 결과 수치화 → 복구 방안 확보` 원칙을 철저히 준수합니다.

---

## 📋 대상 시스템 사양 (System Specs)
*최적화 작업을 시작하기 전, 대상 데스크톱의 상세 스펙을 기입해 주시기 바랍니다.*

| 분류 | 세부 항목 | 사양 |
|---|---|---|
| **기본 사양** | 모델 / 메인보드 | (예: ASUS ROG STRIX B650 / 조립 PC) |
| | CPU | (예: AMD Ryzen 9 7900X / Intel Core i9-14900K) |
| | RAM | (예: DDR5 64GB) |
| | GPU | (예: NVIDIA GeForce RTX 4080 16GB) |
| | OS | (예: Windows 11 Pro 24H2) |
| **저장 장치** | NVMe SSD (C:) | (예: Samsung 990 Pro 2TB) |
| | NVMe/SATA (D:) | (예: SK Hynix P41 2TB) |
| **냉각 장치** | CPU Cooler | (예: 3열 수냉 쿨러 / 대장급 공랭 쿨러) |

---

## 🛠️ 최적화 추진 계획

### 1. 전력 및 발열 튜닝 (Power & Thermal)
- [ ] 메인보드 바이오스(BIOS) 전력 제한 해제 또는 에코 모드(Eco Mode) 조율
- [ ] PBO(Precision Boost Overdrive) / Curve Optimizer 또는 Intel CEP/언더볼팅 세팅 분석
- [ ] 윈도우 전원 관리 옵션 세부 튜닝 (프로세서 상태 및 냉각 정책 설정)

### 2. 메모리 및 지연 시간 최적화 (Memory & Latency)
- [ ] EXPO / XMP 메모리 오버클럭 오작동 여부 및 Latency 측정
- [ ] 백그라운드 불필요한 서비스 비활성화 및 프로세스 우선순위 정리

### 3. AI 및 개발 환경 최적화 (AI & Dev Stack)
- [ ] CUDA / cuDNN 라이브러리 및 GPU 컴퓨팅 가속화 환경 튜닝
- [ ] Git, ripgrep, Node.js, Python 등 로컬 개발 스택 튜닝 및 디스크 I/O 분산

---

## 📂 파일 구성
- `implementation_plan.md`: 최적화 적용 전에 작성되는 계획 문서
- `optimization_result.md`: 각 단계별 성능 벤치마크 및 롤백 가이드
- `scratch/`: 데스크톱 최적화 자동화 스크립트 및 스키마 백업 폴더 (예정)

---

## ↩️ 롤백 (Rollback) 및 복구 경로
- 최적화 작업 전 Windows 복원 지점(Restore Point) 생성을 필수로 합니다.
- 하드웨어 수준의 오버클럭/언더볼팅 오작동 시 바이오스 초기화(CMOS Clear) 방법을 숙지하고 진행합니다.

---

## 🔗 관련 문서
- [상위 통합 README.md](../README.md)
