# PC 환경 최적화 통합 작업대 (PC Environment Optimization Workspace)

이 저장소는 노트북(Notebook) 및 데스크톱(Desktop) PC 환경에서 발열 제어, 지연 감소(Latency Reduction), 성능 및 개발 생산성 극대화를 달성하기 위한 환경 최적화 및 튜닝 기록을 통합 관리하는 공간입니다.

각 환경의 대상 하드웨어 사양과 튜닝 스크립트, 그리고 복구(Rollback) 경로는 개별 작업대 내에서 안전하게 격리되어 관리됩니다.

---

## 📂 작업대 분류 (Workspaces)

### 1. [💻 노트북 최적화 작업대](notebook/README.md) (`notebook/`)
- **대상**: MSI GL75 9SDK (Intel i7-9750H / Windows 11 Enterprise LTSC 2024)
- **주요 내용**: 언더볼팅 분석, 프로세서 상태 및 부스트 조율, LTSC 사용성 복원, 개발 스택 최신화, 그리고 3개 AI 에이전트(Claude Code·Codex·Antigravity) 환경을 **각자 전용 문서로 분리 관리**.
- **바로가기**: [notebook/README.md](notebook/README.md)

### 2. [🖥️ 데스크톱 최적화 작업대](desktop/README.md) (`desktop/`)
- **대상**: 데스크톱 PC 환경 (사양 확인 및 셋업 예정)
- **주요 내용**: 고성능 연산 환경 및 AI 개발 환경 최적화, 발열 및 오버클러킹/언더볼팅 조율 계획 수립.
- **바로가기**: [desktop/README.md](desktop/README.md)

---

## 🛠️ 공통 최적화 원칙
- **비침범성**: 기존의 유효한 하드웨어 레벨 언더볼팅/성능 세팅은 최대한 보존하며 소프트웨어 스택과 전원 관리 스킴을 먼저 조율합니다.
- **안전성 (Safe-first)**: 모든 최적화 적용 전에 반드시 백업(Rollback) 경로를 확보하고 복구 가능 여부를 검증합니다.
- **독립성**: 환경별 스크립트와 설정 파일은 각 하위 폴더(`notebook/scratch/`, `desktop/scratch/`) 내에서 동작하여 간섭을 방지합니다.
- **에이전트 도메인 격리**: 여러 AI 에이전트를 함께 쓸 때, 한 에이전트는 다른 에이전트의 설정(`.claude/`·`~/.codex/`·`.agents/`)을 건드리지 않으며 각자 전용 문서에서만 환경을 관리합니다.

> 머신 고유값(호스트명·절대경로·사용자명 등)을 담은 설정 파일은 git에서 제외하고 **구조만 문서화**합니다. 자세한 위생 규칙은 [`.gitignore`](.gitignore) 및 각 에이전트 환경 문서를 참조하세요.
