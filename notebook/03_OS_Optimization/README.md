# ⚙️ OS 최적화 및 복구 (03_OS_Optimization)

이 섹션은 Windows OS의 튜닝, 오작동 교정, 환경 설정 복구와 관련된 스크립트 및 히스토리를 관리합니다.

## 🗂 구성 요소
* `scripts/`: 자동 설정 복구 및 시스템 튜닝 PowerShell 스크립트 모음
* `README.md`: OS 최적화/복구 내역 가이드 및 수동 조치 절차 기록

---

## 🛠 조치 및 유지보수 이력

### 1. 윈도우 시작 시 알림(Toast) 자동 꺼짐 현상 해결
* **해결 일자**: 2026-07-21
* **관찰 현상**: 노트북 부팅 혹은 사용자 로그인 시 시스템 알림(Toast Notifications) 허용 설정이 자동으로 꺼지는(비활성화) 현상.
* **원인 분석**:
  - Windows Push Notification 데이터베이스(`wpndatabase.db`) 손상으로 인한 상태 보존 실패.
  - 로그인 세션 생성 시 특정 환경 정책에 의한 전역 알림 레지스트리 초기화.
* **해결 조치**:
  1. **알림 DB 재빌드**: WPN 관련 서비스 중단 후 손상 의심 데이터베이스(`wpndatabase.db`) 백업 후 초기화하여 새 DB 생성을 유도.
  2. **시작 시 자동 활성화**: 로그인할 때마다 전역 알림 레지스트리(`NOC_GLOBAL_SETTING_TOASTS_ENABLED = 1`)를 강제 적용하는 스크립트를 투명한 백그라운드 모드(VBScript)로 윈도우 시작프로그램에 등록.
* **관련 스크립트**:
  - [Fix-WindowsNotifications.ps1](scripts/Fix-WindowsNotifications.ps1): 알림 DB 초기화 및 알림 전역 활성화 레지스트리 적용.
  - [Register-NotificationStartupTask.ps1](scripts/Register-NotificationStartupTask.ps1): 위 조치 스크립트를 로그인 시 백그라운드로 자동 실행되도록 하이브리드 등록 (작업 스케줄러 혹은 시작프로그램 폴더).
  - [Test-NotificationStartupVbs.ps1](scripts/Test-NotificationStartupVbs.ps1): 시작프로그램 VBScript의 인용 경로 문법을 무해한 명령으로 검증.

### 1-1. 시작프로그램 VBScript 컴파일 오류 교정 (2026-07-21)
* **관찰 현상**: `Fix-Notifications-Startup.vbs` 실행 시 Windows Script Host 800A0401 컴파일 오류 발생.
* **근본 원인**: PowerShell `-File` 경로를 감싼 큰따옴표가 VBScript 문자열 안에서 이스케이프되지 않아 문자열이 조기에 종료됨.
* **교정 및 재발 방지**: 등록 스크립트가 VBScript 규칙에 맞게 큰따옴표를 두 번(`""`) 출력하도록 수정하고, Windows Script Host 파싱 테스트를 추가.
