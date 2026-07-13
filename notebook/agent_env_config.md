# 💻 노트북 환경 - Antigravity 에이전트 환경설정 기록 (Agent Tool Configuration)

이 문서는 노트북 최적화 작업대(`notebook/`)에서 **Antigravity 에이전트**의 정상 동작을 보장하기 위해 셋업된 개발 도구의 사양과 자동 명령어 권한 설정 내역을 기록합니다. 
본 설정을 공유함으로써 다른 환경(예: 데스크톱)으로 작업대를 이전하거나 환경을 재구축할 때 일관된 에이전트 수행 환경을 제공할 수 있습니다.

---

## 🛠️ 에이전트 개발 도구 스택 (Tools Version)
현재 노트북(MSI GL75 9SDK) 최적화 작업대에서 검증 및 구성된 에이전트 실행 도구 사양입니다.

- **OS**: Microsoft Windows 11 Enterprise LTSC (Version: 10.0.26100, 64-bit)
- **Git**: `2.55.0.windows.2`
- **Node.js**: `v24.18.0`
- **npm**: `11.16.0`
- **uv (Python 패키지 관리자)**: `0.11.28`
- **Python (py 런처)**: `3.14.6`

---

## 🛡️ 에이전트 자동 실행 권한 설정 (.claude/settings.local.json)
에이전트가 사용자 확인(UAC 승인 제외) 없이 안전하게 반복 진단 및 최적화 조회를 수행할 수 있도록 허용된 로컬 명령어 권한 리스트입니다.

해당 설정은 프로젝트 루트의 [.claude/settings.local.json](file:///d:/D_Workspace_NB/-google-workspace/-antigravity-workspace/260713_pc-optimization/.claude/settings.local.json) 파일에 정의되어 있으며, Git 추적 대상으로 포함되어 리포지토리에 보존됩니다.

### 주요 허용 명령어 범주
1. **전원 옵션 조회**: `powercfg /getactivescheme`, `powercfg /query` 등 전원 스킴 조회
2. **시스템 및 디바이스 진단**:
   - `Get-Service`를 통한 서비스 상태 조회 (SysMain, WSearch, DiagTrack 등)
   - `Get-CimInstance`를 통한 가상 메모리(PageFile) 및 시스템 하드웨어 사양 정보 조회
   - ACPI 온도를 측정하기 위한 `MSAcpi_ThermalZoneTemperature` 조회
3. **가상 메모리 및 최적화 스크립트 실행 권한**:
   - `cpu_boost_optimizer.ps1` 및 `pagefile_elevated.ps1` 스크립트의 실행 및 UAC 승격 래퍼 동작 확인

---

## ⚙️ 설정 반영 및 동기화 가이드
새로운 머신 환경에서 해당 설정을 복원하거나 유지하려면 아래 절차를 진행하십시오.

1. **로컬 권한 보존**:
   - `.gitignore` 설정에 의해 `!.claude/settings.local.json` 예외 처리가 반영되어 있습니다.
   - 프로젝트를 클론하면 에이전트의 툴 허용 권한이 그대로 유지되어 재승인 과정 없이 자동 검증 스크립트를 바로 실행할 수 있습니다.
2. **도구 버전 동기화**:
   - 에이전트 작업 실행 중 도구 호환성 에러가 발생할 경우, 상단의 **에이전트 개발 도구 스택** 버전을 기준으로 환경 설정을 통일해 주시기 바랍니다.
